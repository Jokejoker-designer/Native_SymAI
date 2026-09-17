"""Generate deterministic Q* op-script vectors (C-CODE-04). Truth: qstar_ref.py.

Vector = 32-bit words for $readmemh.
  word0 = n_ops, word1 = 0 (reserved)
  op    = 9 words: [op, p0, p1, p2, p3, e0, e1, e2, e3]
OPS
  1 SEED        p0=seed16
  2 RESET
  3 LOAD_THETA  p0=addr(0..63) p1=val16
  4 READ_THETA  p0=addr                      e0=val16
  5 PROPOSE     p0=f3..f0 p1=f7..f4 p2=mask|exam<<8 p3=eps16
                e0=prop[2:0]|greedy<<4|explored<<8|no_legal<<9|valid<<10|qsat<<11|refused<<12|pending<<13
                e1=q[prop]  e2=lfsr_after
  6 UPDATE      p0=exec_act|exec_valid<<4|rew_acc<<5|exam<<6 p1=reward16 p2=qnext32 p3=alpha|gamma<<8
                e0=applied|reason<<4|pending<<8  e1=version  e2=delta32
  7 COUNTERS    e0=explore|prop_refused<<16 e1=credit_denied e2=no_legal e3=illegal_exec|exam_blocked<<16
  8 SET_VERSION p0=version16
No expected value is hand-written; all come from the reference model.
"""
from __future__ import annotations

import json
import random
from pathlib import Path
from typing import List

from qstar_ref import N_ACT, N_SF, QStar, to_unsigned

OUT_DIR = Path(__file__).resolve().parents[2] / "tb" / "learning" / "vectors" / "qstar"
U32 = 0xFFFFFFFF


class Script:
    def __init__(self) -> None:
        self.qs = QStar()
        self.words: List[int] = []
        self.n = 0

    def _op(self, op: int, p=(0, 0, 0, 0), e=(0, 0, 0, 0)) -> None:
        self.words += [op] + [x & U32 for x in p] + [x & U32 for x in e]
        self.n += 1

    def seed(self, s: int) -> None:
        self.qs.seed(s)
        self._op(1, (s & 0xFFFF, 0, 0, 0))

    def reset(self) -> None:
        self.qs.reset_learned()
        self._op(2)

    def load_theta(self, addr: int, val: int) -> None:
        self.qs.load_theta(addr, val)
        self._op(3, (addr, to_unsigned(val, 16), 0, 0))

    def read_theta(self, addr: int) -> None:
        self._op(4, (addr, 0, 0, 0), (self.qs.read_theta(addr), 0, 0, 0))

    def read_all_theta(self) -> None:
        for a in range(N_ACT * N_SF):
            self.read_theta(a)

    def set_version(self, v: int) -> None:
        self.qs.set_version(v)
        self._op(8, (v & 0xFFFF, 0, 0, 0))

    def propose(self, feat: List[int], mask: int, exam: bool, eps: int = 0):
        r = self.qs.propose(feat, mask, exam, eps)
        f = [to_unsigned(x, 8) for x in feat]
        p0 = f[0] | f[1] << 8 | f[2] << 16 | f[3] << 24
        p1 = f[4] | f[5] << 8 | f[6] << 16 | f[7] << 24
        e0 = (r.proposed_action | r.greedy_action << 4 | int(r.explored) << 8 | int(r.no_legal) << 9
              | int(r.proposal_valid) << 10 | int(r.q_sat) << 11 | int(r.refused) << 12
              | int(r.pending_after) << 13)
        qsel = r.q[r.proposed_action] if r.proposal_valid else 0
        self._op(5, (p0, p1, (mask & 0xFF) | int(exam) << 8, eps & 0xFFFF), (e0, qsel, r.lfsr_after, 0))
        return r

    def update(self, exec_valid: bool, act: int, rew_acc: bool, reward: int, qnext: int,
               alpha: int, gamma: int, exam: bool):
        u = self.qs.update(exec_valid, act, rew_acc, reward, qnext, alpha, gamma, exam)
        p0 = (act & 7) | int(exec_valid) << 4 | int(rew_acc) << 5 | int(exam) << 6
        self._op(6, (p0, to_unsigned(reward, 16), to_unsigned(qnext, 32), (alpha & 0xFF) | (gamma & 0xFF) << 8),
                 (int(u.applied) | u.reason << 4 | int(u.pending_after) << 8, u.version_after, u.delta, 0))
        return u

    def resolve_unexecuted(self):
        """Controller resolves a proposal that was never executed (NO_BINDING/NO_ACTION): consumes pending."""
        return self.update(False, 0, False, 0, 0, 0, 0, False)

    def counters(self) -> None:
        q = self.qs
        self._op(7, e=(q.explore_count | q.prop_refused_count << 16, q.credit_denied_count, q.no_legal_count,
                       q.illegal_exec_count | q.exam_blocked_count << 16))

    def dump(self) -> List[int]:
        return [self.n, 0] + self.words


def feat_const(v: int) -> List[int]:
    return [v] * N_SF


def case_baseline_priority() -> Script:
    s = Script()
    for mask in (0x7F, 0x7E, 0x7C, 0x40, 0x22, 0x10, 0x00, 0x80):  # 0x80 -> reserved only -> no legal
        s.propose(feat_const(0x3F), mask, exam=True)
    s.counters()
    return s


def case_mask_never_wins() -> Script:
    s = Script()
    # ACT (3) has huge q; SUBMIT (5) medium; RETRIEVE (0) negative
    for i in range(N_SF):
        s.load_theta(3 * N_SF + i, 0x7FFF)
        s.load_theta(5 * N_SF + i, 0x1000)
        s.load_theta(0 * N_SF + i, -0x1000)
    f = feat_const(0x7F)
    s.propose(f, 0x7F, True)          # ACT legal -> 3
    s.propose(f, 0x7F & ~(1 << 3), True)  # ACT illegal -> 5
    s.propose(f, 0b0000001, True)     # only RETRIEVE legal, negative q -> still 0
    s.propose(f, 0b0001000 | 0x80, True)  # ACT + reserved
    s.counters()
    return s


def case_tiebreak() -> Script:
    s = Script()
    for a in (2, 4, 6):
        s.load_theta(a * N_SF + 0, 0x0800)
    s.propose([0x7F] + [0] * 7, 0x7F, True)   # q equal for 2,4,6 -> 2
    s.propose([0x7F] + [0] * 7, 0x70, True)   # legal 4,5,6 -> 4
    s.propose([0x7F] + [0] * 7, 0x40, True)   # only 6
    return s


def case_exam_deterministic() -> Script:
    s = Script()
    s.seed(0xBEEF)
    for i in range(N_SF):
        s.load_theta(1 * N_SF + i, 0x0400 * (i + 1))
    f = [0x10 * (i + 1) - 0x40 for i in range(N_SF)]
    for _ in range(4):
        s.propose(f, 0x7F, exam=True, eps=0xFFFF)   # eps ignored in EXAM; lfsr unchanged
    s.counters()
    return s


def case_train_exploration() -> Script:
    s = Script()
    s.seed(0x1234)
    for i in range(N_SF):
        s.load_theta(2 * N_SF + i, 0x2000)
    f = feat_const(0x40)
    # every TRAIN proposal is resolved (unexecuted) before the next one: one pending at a time
    for _ in range(8):
        s.propose(f, 0x7F, exam=False, eps=0xFFFF)  # always explore (lfsr < 0xFFFF unless state==0xFFFF)
        s.resolve_unexecuted()
    for _ in range(4):
        s.propose(f, 0x7F, exam=False, eps=0x0000)  # never explore; lfsr still advances in TRAIN
        s.resolve_unexecuted()
    for _ in range(12):
        s.propose(f, 0b0010101, exam=False, eps=0x8000)  # ~50%, legal set {0,2,4}
        s.resolve_unexecuted()
    s.counters()
    return s


def case_zero_credit_unexecuted() -> Script:
    s = Script()
    f = feat_const(0x40)
    s.propose(f, 0x7F, exam=False, eps=0)
    s.update(False, 0, True, 0x1000, 0x00100000, 0x80, 0xE6, False)   # not executed -> zero credit, consumed
    s.read_all_theta()
    s.update(True, 5, True, 0x1000, 0, 0x80, 0xE6, False)             # pending consumed -> NO_PROPOSAL
    s.propose(f, 0x7F, exam=False, eps=0)
    s.update(True, 0, False, 0x1000, 0x00100000, 0x80, 0xE6, False)   # reward not accepted -> pending kept
    s.update(True, 0, True, 0x1000, 0x00100000, 0x80, 0xE6, True)     # EXAM frozen -> consumed
    s.propose(f, 0x7F, exam=False, eps=0)
    s.update(True, 5, True, 0x1000, 0, 0x80, 0xE6, False)             # executed action 5 was legal -> applied
    s.update(True, 3, True, 0x1000, 0, 0x80, 0xE6, False)             # second credit needs a second proposal -> NO_PROPOSAL
    s.propose(f, 0x7F, exam=False, eps=0)
    s.update(True, 3, True, 0x1000, 0, 0x80, 0xE6, False)             # now applied on action 3
    s.propose(f, 0b0000011, exam=False, eps=0)
    s.update(True, 4, True, 0x1000, 0, 0x80, 0xE6, False)             # 4 illegal in latched mask -> denied, consumed
    s.update(True, 0, True, 0x1000, 0, 0x80, 0xE6, False)             # NO_PROPOSAL
    s.read_all_theta()
    s.counters()
    return s


def case_pending_protocol() -> Script:
    """C-CODE-07 falsifiers: duplicate reward, proposal overwrite, overlapping-mask stale reward,
    update after pending consumed, EXAM/no-legal never pending, learn_reset clears pending."""
    s = Script()
    fa, fb, fc = feat_const(0x40), feat_const(-0x30), [0x7F, -0x80, 0x40, -0x40, 0x01, -0x01, 0x00, 0x33]
    # duplicate reward
    ra = s.propose(fa, 0x7F, exam=False, eps=0)
    s.update(True, ra.proposed_action, True, 0x1000, 0, 0x80, 0xE6, False)   # applied, version 1
    s.update(True, ra.proposed_action, True, 0x1000, 0, 0x80, 0xE6, False)   # NO_PROPOSAL, version stays 1
    s.read_all_theta()
    # proposal overwrite refused; credit lands on the pending (A) context, not on B
    s.propose(fa, 0x01, exam=False, eps=0)                                   # A pending, only action 0 legal
    s.propose(fb, 0x02, exam=False, eps=0xFFFF)                              # refused: no LFSR advance, no explore
    s.propose(fc, 0x7F, exam=True, eps=0)                                    # refused even in EXAM
    s.update(True, 0, True, 0x2000, 0, 0x80, 0xE6, False)                    # applied with A's features
    s.read_all_theta()
    # overlapping-mask stale reward: D resolved, E pending; stale D reward has no valid pending identity
    rd = s.propose(fa, 0x7F, exam=False, eps=0)
    s.update(True, rd.proposed_action, True, 0x0800, 0, 0x80, 0xE6, False)
    re_ = s.propose(fc, 0x7F, exam=False, eps=0)
    s.update(True, rd.proposed_action, False, 0x0800, 0, 0x80, 0xE6, False)  # REWARD_NOT_ACCEPTED, pending kept
    s.update(True, re_.proposed_action, True, 0x0800, 0, 0x80, 0xE6, False)  # applied on E
    s.read_all_theta()
    # update after pending consumed by each terminal reason
    s.propose(fa, 0x03, exam=False, eps=0)
    s.update(True, 4, True, 0x1000, 0, 0x80, 0xE6, False)                    # ILLEGAL_EXEC -> consumed
    s.update(True, 0, True, 0x1000, 0, 0x80, 0xE6, False)                    # NO_PROPOSAL
    s.propose(fa, 0x7F, exam=False, eps=0)
    s.update(True, 0, True, 0x1000, 0, 0x80, 0xE6, True)                     # EXAM_FROZEN -> consumed
    s.update(True, 0, True, 0x1000, 0, 0x80, 0xE6, False)                    # NO_PROPOSAL
    s.propose(fa, 0x7F, exam=False, eps=0)
    s.update(False, 0, True, 0x1000, 0, 0x80, 0xE6, False)                   # NOT_EXECUTED -> consumed
    s.update(True, 0, True, 0x1000, 0, 0x80, 0xE6, False)                    # NO_PROPOSAL
    # EXAM and no-legal proposals never create a pending
    s.propose(fa, 0x7F, exam=True, eps=0xFFFF)
    s.propose(fa, 0x7F, exam=True, eps=0xFFFF)                               # not refused
    s.update(True, 0, True, 0x1000, 0, 0x80, 0xE6, False)                    # NO_PROPOSAL
    s.propose(fa, 0x00, exam=False, eps=0)                                   # no legal
    s.update(True, 0, True, 0x1000, 0, 0x80, 0xE6, False)                    # NO_PROPOSAL
    # learn_reset clears a pending proposal
    s.propose(fa, 0x7F, exam=False, eps=0)
    s.reset()
    s.update(True, 0, True, 0x1000, 0, 0x80, 0xE6, False)                    # NO_PROPOSAL
    s.propose(fa, 0x7F, exam=False, eps=0)                                   # accepted again
    s.resolve_unexecuted()
    s.read_all_theta()
    s.counters()
    return s


def case_update_arith() -> Script:
    s = Script()
    # positive/negative reward, gamma discounting, negative feature -> negative step, sat16 at theta edge
    f = [0x7F, -0x80, 0x40, -0x40, 0x01, -0x01, 0x00, 0x33]
    s.propose(f, 0x7F, exam=False, eps=0)
    s.update(True, 0, True, 0x7FFF, 0x7FFFFFFF, 0xFF, 0xFF, False)   # big positive target, delta clipped
    s.read_all_theta()
    s.propose(f, 0x7F, exam=False, eps=0)
    s.update(True, 0, True, -0x8000, -0x80000000, 0xFF, 0xFF, False)  # big negative, clipped
    s.read_all_theta()
    for i in range(N_SF):
        s.load_theta(1 * N_SF + i, 0x7FF0)
    s.propose(f, 0x7F, exam=False, eps=0)
    s.update(True, 1, True, 0x7FFF, 0x7FFFFFFF, 0xFF, 0x00, False)    # push into sat16 +
    s.read_all_theta()
    for i in range(N_SF):
        s.load_theta(1 * N_SF + i, -0x7FF0)
    s.propose(f, 0x7F, exam=False, eps=0)
    s.update(True, 1, True, -0x8000, -0x80000000, 0xFF, 0x00, False)  # push into sat16 -
    s.read_all_theta()
    # exact half rounding in update step: alpha=0x80, delta engineered, feat=1
    s.reset()
    s.propose([0x01] + [0] * 7, 0x7F, exam=False, eps=0)
    s.update(True, 0, True, 0x0010, 0, 0x80, 0x00, False)             # r<<7 = 0x800 -> step = rshr(0x80*0x800*1,22)
    s.read_theta(0)
    s.counters()
    return s


def case_reset_restore() -> Script:
    s = Script()
    s.seed(0x0BAD)
    rng = random.Random(7)
    f = [rng.randint(-128, 127) for _ in range(N_SF)]
    # train a few episodes so theta departs from baseline
    for _ in range(6):
        r = s.propose(f, 0x7F, exam=False, eps=0)
        s.update(True, r.proposed_action, True, rng.randint(-0x2000, 0x2000), rng.randint(-0x100000, 0x100000),
                 0x60, 0xE6, False)
        r = s.propose(f, 0b0110100, exam=False, eps=0)
        s.update(True, 2 if (0b0110100 >> 2) & 1 else r.proposed_action, True, 0x1800, 0, 0x60, 0xE6, False)
    # snapshot
    snap = list(s.qs.theta)
    ver = s.qs.version
    p_before = s.propose(f, 0x7F, exam=True)
    s.read_all_theta()
    # reset -> baseline (fixed priority) ; version 0
    s.reset()
    s.propose(f, 0x7F, exam=True)
    s.propose(f, 0b0110000, exam=True)
    s.read_theta(0)
    s.read_theta(63)
    s.propose(f, 0x7F, exam=False, eps=0)
    s.update(True, 0, True, 0x1000, 0, 0x80, 0xE6, False)  # baseline is trainable again
    s.reset()
    # restore
    for i, v in enumerate(snap):
        s.load_theta(i, v)
    s.set_version(ver)
    p_after = s.propose(f, 0x7F, exam=True)
    assert p_after.proposed_action == p_before.proposed_action and p_after.q == p_before.q
    s.read_all_theta()
    s.counters()
    return s


def case_random(seed: int) -> Script:
    s = Script()
    rng = random.Random(seed)
    s.seed(rng.randint(1, 0xFFFF))
    for _ in range(rng.randint(0, 20)):
        s.load_theta(rng.randint(0, 63), rng.randint(-0x8000, 0x7FFF))
    for _ in range(40):
        f = [rng.randint(-128, 127) for _ in range(N_SF)]
        mask = rng.randint(0, 0xFF)
        exam = rng.random() < 0.3
        r = s.propose(f, mask, exam, rng.choice([0, 0x4000, 0x8000, 0xFFFF]))
        if rng.random() < 0.8:
            act = r.proposed_action if rng.random() < 0.7 else rng.randint(0, 7)
            s.update(rng.random() < 0.8, act, rng.random() < 0.9, rng.randint(-0x8000, 0x7FFF),
                     rng.randint(-0x80000000, 0x7FFFFFFF), rng.randint(0, 255), rng.randint(0, 255),
                     exam if rng.random() < 0.8 else not exam)
        if rng.random() < 0.1:
            s.read_theta(rng.randint(0, 63))
        if s.qs.pending and rng.random() < 0.7:
            s.resolve_unexecuted()          # leave some pendings unresolved -> refused proposals get covered
    s.read_all_theta()
    s.counters()
    return s


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    cases = [
        ("q01_baseline_priority", case_baseline_priority()),
        ("q02_mask_never_wins", case_mask_never_wins()),
        ("q03_tiebreak_lowest_code", case_tiebreak()),
        ("q04_exam_deterministic", case_exam_deterministic()),
        ("q05_train_exploration", case_train_exploration()),
        ("q06_zero_credit_unexecuted", case_zero_credit_unexecuted()),
        ("q07_update_arith_clip_sat", case_update_arith()),
        ("q08_reset_restore", case_reset_restore()),
        ("q09_pending_protocol", case_pending_protocol()),
        ("q10_random_seeded", case_random(101)),
        ("q11_random_seeded", case_random(202)),
        ("q12_random_seeded", case_random(303)),
    ]
    manifest = []
    for name, sc in cases:
        words = sc.dump()
        (OUT_DIR / f"{name}.hex").write_text("\n".join(f"{w:08x}" for w in words) + "\n")
        manifest.append({"name": name, "n_ops": sc.n, "words": len(words)})
    (OUT_DIR / "manifest.json").write_text(json.dumps(manifest, indent=1))
    print(f"QSTAR_VECTORS_WRITTEN {len(cases)} -> {OUT_DIR}")


if __name__ == "__main__":
    main()
