"""Q* macro-action selection — bit-exact reference model (C-CODE-04).

Spec: 10_LEARNING_AND_STRATEGY.md §10.8 (unaudited CANDIDATE). This file is the truth source
for rtl/native_ai/strategy/qstar_select.v tests.

Design law kept here:
  * Q* only PROPOSES. legal_mask is an INPUT from the ASTRA/capability path. Q* never creates
    legality or truth. A masked action can never win, whatever its q-value.
  * proposal != legal acceptance != execution != observed effect != reward acceptance != credit.
    An update is applied only when exec_valid=1 (the action actually ran), reward_accepted=1
    (pending identity / reward source valid, decided outside Q*), mode==TRAIN, and the executed
    action was legal in the mask latched at proposal time. Otherwise ZERO credit.
  * Reset baseline: theta := 0 -> argmax degenerates to fixed action-priority order (the H_RIVAL
    fixed policy). Restore: theta + q_policy_version loaded back -> identical proposals.
  * TRAIN: preregistered epsilon exploration using a 16-bit LFSR (seeded, logged). EXAM: epsilon
    forced to 0, LFSR not advanced, learning frozen -> deterministic.
  * Pending-credit protocol (C-CODE-07, candidate until B's law): at most ONE unresolved pending
    proposal. A TRAIN proposal with a non-empty legal mask becomes pending; EXAM / no-legal
    proposals create no pending (nothing can be credited). A proposal while one is pending is
    REFUSED (no state change, LFSR not advanced, prop_refused_count++). An update consumes the
    pending on APPLIED / NOT_EXECUTED / EXAM_FROZEN / ILLEGAL_EXEC; REWARD_NOT_ACCEPTED keeps it
    (a correctly identified reward may still arrive); NO_PROPOSAL changes nothing. Identity
    (episode_id/step_id/command_id) stays in the action lane (§05.6) — Q* holds no proposal_id.

Fixed-point (Qm.n, m includes sign):
  state_feat[i]  Q1.7   8b     theta[a][i]  Q4.12  16b     product Q5.19 24b
  q_a            Q13.19 32b (saturating per add, index order)     reward  Q4.12 16b -> <<7 -> Q5.19
  gamma, alpha   Q0.8 unsigned 8b
  target = sat32( (reward<<7) + rshr8(gamma * qnext_max) )
  delta  = clip( sat32(target - q_exec), +-DELTA_MAX )
  theta[a][i] += sat16( rshr(alpha * delta * feat_i, 22) )   (round half toward +inf, then sat16)

All of this is LOGICAL_STATE_ENCODING_CANDIDATE / learning-local; not §04 ABI, not ASTRA.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import List, Optional, Sequence

from spear_ref import sat, to_signed, to_unsigned

N_ACT = 8          # action_code[2:0]; 7 = reserved (never proposable)
N_SF = 8           # state features (candidate count)
F_W = 8
TH_W = 16
Q_W = 32
DELTA_MAX_DEFAULT = 1 << 22
UPD_SHIFT = 22     # Q0.8 * Q13.19 * Q1.7 = Q14.34 -> Q4.12 : shift 22
ACT_RESERVED = 7
NO_ACTION = 7      # emitted code when no legal action exists (proposal_valid = 0)

ACT_NAMES = ["RETRIEVE", "SEARCH", "OBSERVE", "ACT", "ASK_TEACHER", "SUBMIT", "STOP", "RESERVED"]

# update-result reason codes (observable, candidate encoding)
R_APPLIED = 0
R_NOT_EXECUTED = 1        # zero execution credit
R_REWARD_NOT_ACCEPTED = 2
R_EXAM_FROZEN = 3
R_ILLEGAL_EXEC = 4        # executed action was not legal in latched mask (contract violation observable)
R_NO_PROPOSAL = 5         # update with no unresolved pending proposal (already consumed / never made)

LFSR_TAPS = (16, 14, 13, 11)  # x^16 + x^14 + x^13 + x^11 + 1 (Fibonacci, 16-bit)


def lfsr_step(s: int) -> int:
    s &= 0xFFFF
    bit = ((s >> (16 - 16)) ^ (s >> (16 - 14)) ^ (s >> (16 - 13)) ^ (s >> (16 - 11))) & 1
    return ((s >> 1) | (bit << 15)) & 0xFFFF


def rshr(value: int, shift: int) -> int:
    """Arithmetic right shift with round half toward +inf."""
    return (value + (1 << (shift - 1))) >> shift


def dot_q(feat: Sequence[int], theta_row: Sequence[int]) -> tuple[int, bool]:
    """Serial saturating MAC, index order, sat32 per add. Returns (q, sat_flag)."""
    acc, satf = 0, False
    for f, t in zip(feat, theta_row):
        p = to_signed(f, F_W) * to_signed(t, TH_W)
        acc, s = sat(acc + p, Q_W)
        satf |= s
    return acc, satf


def kth_legal(mask: int, k: int) -> int:
    """Return the k-th (0-based) legal action code in ascending code order."""
    n = 0
    for a in range(N_ACT):
        if (mask >> a) & 1:
            if n == k:
                return a
            n += 1
    raise ValueError("k out of range")


def mod_small(x: int, n: int) -> int:
    """x in 0..7, n in 1..8: x mod n by repeated subtraction (RTL-shaped)."""
    while x >= n:
        x -= n
    return x


@dataclass
class ProposeResult:
    proposal_valid: bool
    proposed_action: int
    greedy_action: int
    explored: bool
    no_legal: bool
    q: List[int]
    q_sat: bool
    lfsr_after: int
    refused: bool = False        # proposal refused: a pending proposal is still unresolved
    pending_after: bool = False  # pending state after this call


@dataclass
class UpdateResult:
    applied: bool
    reason: int
    delta: int
    version_after: int
    pending_after: bool = False


@dataclass
class QStar:
    theta: List[int] = field(default_factory=lambda: [0] * (N_ACT * N_SF))  # unsigned 16 storage
    version: int = 0
    lfsr: int = 0xACE1
    delta_max: int = DELTA_MAX_DEFAULT
    # latched at proposal (credit context)
    last_feat: Optional[List[int]] = None
    last_mask: int = 0
    pending: bool = False             # exactly-one unresolved pending proposal
    # observables / counters
    explore_count: int = 0
    credit_denied_count: int = 0
    no_legal_count: int = 0
    illegal_exec_count: int = 0
    exam_blocked_count: int = 0
    illegal_selection_count: int = 0  # must stay 0 by construction
    prop_refused_count: int = 0       # proposals refused because one was still pending

    # ---- state management (X0-07 reset / restore) ---------------------------
    def reset_learned(self) -> None:
        self.theta = [0] * (N_ACT * N_SF)
        self.version = 0
        self.last_feat = None
        self.last_mask = 0
        self.pending = False

    def load_theta(self, addr: int, value16: int) -> None:
        self.theta[addr] = to_unsigned(value16, TH_W)

    def read_theta(self, addr: int) -> int:
        return self.theta[addr]

    def set_version(self, v: int) -> None:
        self.version = v & 0xFFFF

    def seed(self, s: int) -> None:
        self.lfsr = s & 0xFFFF

    def row(self, a: int) -> List[int]:
        return self.theta[a * N_SF:(a + 1) * N_SF]

    # ---- proposal -------------------------------------------------------------
    def propose(self, feat: Sequence[int], legal_mask: int, exam: bool, epsilon16: int) -> ProposeResult:
        feat = [to_unsigned(f, F_W) for f in feat]
        mask = legal_mask & 0x7F  # reserved code 7 is never proposable
        if self.pending:
            # refuse: never silently overwrite the credit context of the unresolved proposal
            self.prop_refused_count = min(self.prop_refused_count + 1, 0xFFFF)
            return ProposeResult(False, NO_ACTION, NO_ACTION, False, False, [0] * N_ACT, False,
                                 self.lfsr, refused=True, pending_after=True)
        q: List[int] = []
        qsat = False
        for a in range(N_ACT):
            v, s = dot_q(feat, self.row(a))
            q.append(v)
            qsat |= s
        self.last_feat = list(feat)
        self.last_mask = mask
        # TRAIN consumes one PRNG draw per proposal (logged, preregistered); EXAM never advances it.
        r = self.lfsr
        if not exam:
            self.lfsr = lfsr_step(self.lfsr)
        if mask == 0:
            self.no_legal_count += 1
            return ProposeResult(False, NO_ACTION, NO_ACTION, False, True, q, qsat, self.lfsr)
        # a creditable proposal exists only in TRAIN with a non-empty legal set
        self.pending = not exam
        # greedy: max over legal; tie -> lowest action code (fixed priority order)
        greedy = -1
        for a in range(N_ACT):
            if (mask >> a) & 1 and (greedy < 0 or q[a] > q[greedy]):
                greedy = a
        explored = False
        chosen = greedy
        if not exam:
            if r < (epsilon16 & 0xFFFF):
                n_legal = bin(mask).count("1")
                k = mod_small((r >> 13) & 0x7, n_legal)
                chosen = kth_legal(mask, k)
                explored = True
                self.explore_count += 1
        if not (mask >> chosen) & 1:  # by construction unreachable
            self.illegal_selection_count += 1
        return ProposeResult(True, chosen, greedy, explored, False, q, qsat, self.lfsr,
                             refused=False, pending_after=self.pending)

    # ---- credit-safe update -----------------------------------------------------
    def update(self, exec_valid: bool, executed_action: int, reward_accepted: bool,
               reward16: int, qnext_max32: int, alpha8: int, gamma8: int, exam: bool) -> UpdateResult:
        if not self.pending:
            return UpdateResult(False, R_NO_PROPOSAL, 0, self.version, False)   # no state change
        if not exec_valid:
            self.credit_denied_count += 1
            self.pending = False                                                 # consumed
            return UpdateResult(False, R_NOT_EXECUTED, 0, self.version, False)
        if not reward_accepted:
            self.credit_denied_count += 1                                        # pending kept
            return UpdateResult(False, R_REWARD_NOT_ACCEPTED, 0, self.version, True)
        if exam:
            self.exam_blocked_count += 1
            self.pending = False                                                 # consumed
            return UpdateResult(False, R_EXAM_FROZEN, 0, self.version, False)
        a = executed_action & 0x7
        if not (self.last_mask >> a) & 1:
            self.illegal_exec_count += 1
            self.pending = False                                                 # consumed
            return UpdateResult(False, R_ILLEGAL_EXEC, 0, self.version, False)
        q_exec, _ = dot_q(self.last_feat, self.row(a))
        r = to_signed(reward16, 16) << 7
        qn = to_signed(qnext_max32, Q_W)
        disc = rshr((gamma8 & 0xFF) * qn, 8)
        target, _ = sat(r + disc, Q_W)
        delta, _ = sat(target - q_exec, Q_W)
        if delta > self.delta_max:
            delta = self.delta_max
        elif delta < -self.delta_max:
            delta = -self.delta_max
        for i in range(N_SF):
            f = to_signed(self.last_feat[i], F_W)
            step = rshr((alpha8 & 0xFF) * delta * f, UPD_SHIFT)
            t = to_signed(self.theta[a * N_SF + i], TH_W)
            nt, _ = sat(t + step, TH_W)
            self.theta[a * N_SF + i] = to_unsigned(nt, TH_W)
        self.version = (self.version + 1) & 0xFFFF
        self.pending = False                                                     # consumed: exactly one credit
        return UpdateResult(True, R_APPLIED, delta, self.version, False)


def self_test() -> None:
    # LFSR period sanity (maximal 16-bit taps -> 65535)
    s = 1
    seen = 0
    while True:
        s = lfsr_step(s)
        seen += 1
        if s == 1 or seen > 70000:
            break
    assert seen == 65535, seen
    # baseline == fixed priority order
    qs = QStar()
    r = qs.propose([0] * N_SF, 0b0110110, True, 0)
    assert r.proposed_action == 1 and not r.explored and r.proposal_valid
    # masked high-q action never wins
    qs.load_theta(3 * N_SF + 0, 0x7FFF)
    r = qs.propose([0x7F] + [0] * 7, 0b0000011, True, 0)
    assert r.q[3] > 0 and r.proposed_action == 0
    # EXAM proposals create no pending -> update is NO_PROPOSAL, nothing changes
    u = qs.update(False, 3, True, 0x1000, 0, 0x40, 0xE6, False)
    assert not u.applied and u.reason == R_NO_PROPOSAL and qs.version == 0 and not qs.pending
    # zero credit when not executed (consumes the pending)
    r = qs.propose([0x40] * N_SF, 0xFF, False, 0)
    assert r.pending_after and qs.pending
    u = qs.update(False, 3, True, 0x1000, 0, 0x40, 0xE6, False)
    assert not u.applied and u.reason == R_NOT_EXECUTED and qs.version == 0 and not qs.pending
    # executed credit changes the executed row only
    before = list(qs.theta)
    r = qs.propose([0x40] * N_SF, 0xFF, False, 0)
    u = qs.update(True, r.proposed_action, True, 0x1000, 0, 0x80, 0x00, False)
    assert u.applied and qs.version == 1 and not qs.pending
    a = r.proposed_action
    for idx in range(N_ACT * N_SF):
        if idx // N_SF == a:
            continue
        assert qs.theta[idx] == before[idx]
    assert qs.theta[a * N_SF] != before[a * N_SF]
    # FALSIFIER duplicate reward: same reward again -> NO_PROPOSAL, no second credit
    snap_dup = list(qs.theta)
    u = qs.update(True, a, True, 0x1000, 0, 0x80, 0x00, False)
    assert not u.applied and u.reason == R_NO_PROPOSAL and qs.version == 1 and qs.theta == snap_dup
    # FALSIFIER proposal overwrite: second proposal while pending is refused, context kept
    ra = qs.propose([0x40] * N_SF, 0x01, False, 0)          # A: only action 0 legal
    lfsr_a = qs.lfsr
    rb = qs.propose([0xF6] * N_SF, 0x02, False, 0)          # B while A pending -> refused
    assert rb.refused and not rb.proposal_valid and qs.lfsr == lfsr_a and qs.prop_refused_count == 1
    assert qs.last_mask == 0x01 and qs.last_feat == [0x40] * N_SF   # A's context intact
    u = qs.update(True, 0, True, 0x1000, 0, 0x80, 0x00, False)
    assert u.applied and qs.version == 2                     # credited against A, not B
    # FALSIFIER overlapping-mask stale reward: D resolved, E pending, stale reward for D must be
    # rejected upstream (reward_accepted=0) -> pending kept; the correct reward then credits E
    rd = qs.propose([0x10] * N_SF, 0x7F, False, 0)
    assert qs.update(True, rd.proposed_action, True, 0x0800, 0, 0x80, 0x00, False).applied
    re_ = qs.propose([0x70] * N_SF, 0x7F, False, 0)
    u = qs.update(True, rd.proposed_action, False, 0x0800, 0, 0x80, 0x00, False)
    assert not u.applied and u.reason == R_REWARD_NOT_ACCEPTED and qs.pending
    u = qs.update(True, re_.proposed_action, True, 0x0800, 0, 0x80, 0x00, False)
    assert u.applied and not qs.pending
    # FALSIFIER update after pending consumed by ILLEGAL_EXEC / EXAM_FROZEN
    qs.propose([0x40] * N_SF, 0x03, False, 0)
    u = qs.update(True, 4, True, 0x1000, 0, 0x80, 0x00, False)
    assert u.reason == R_ILLEGAL_EXEC and not qs.pending
    assert qs.update(True, 0, True, 0x1000, 0, 0x80, 0x00, False).reason == R_NO_PROPOSAL
    qs.propose([0x40] * N_SF, 0xFF, False, 0)
    u = qs.update(True, 0, True, 0x1000, 0, 0x80, 0x00, True)
    assert not u.applied and u.reason == R_EXAM_FROZEN and not qs.pending
    assert qs.update(True, 0, True, 0x1000, 0, 0x80, 0x00, False).reason == R_NO_PROPOSAL
    # EXAM proposal never blocks (no pending) and never credits
    qs.propose([0x40] * N_SF, 0xFF, True, 0xFFFF)
    assert not qs.pending and qs.propose([0x40] * N_SF, 0xFF, True, 0).proposal_valid
    # no-legal proposal creates no pending
    assert qs.propose([0x40] * N_SF, 0x00, False, 0).no_legal and not qs.pending
    # reset -> baseline, restore -> identical
    snap = list(qs.theta)
    ver = qs.version
    p1 = qs.propose([0x40] * N_SF, 0xFF, True, 0)
    qs.propose([0x40] * N_SF, 0xFF, False, 0)     # leave a pending, reset must clear it
    qs.reset_learned()
    assert not qs.pending
    p2 = qs.propose([0x40] * N_SF, 0xFF, True, 0)
    assert p2.proposed_action == 0
    for i, v in enumerate(snap):
        qs.load_theta(i, v)
    qs.set_version(ver)
    p3 = qs.propose([0x40] * N_SF, 0xFF, True, 0)
    assert p3.proposed_action == p1.proposed_action and p3.q == p1.q
    print("QSTAR_REF_SELFTEST_PASS")


if __name__ == "__main__":
    self_test()
