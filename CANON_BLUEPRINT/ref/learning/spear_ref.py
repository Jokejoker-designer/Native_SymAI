"""SPEAR bit-exact reference model (§10.7, AGENT_C learning lane).

IMPLEMENTATION_CANDIDATE. This is the truth source for SPEAR RTL unit tests.

Implements the six LOGICAL reference stages of §10.7.2:
  stage_0 quantize  : descriptor validation + typed feature extraction
  stage_1 mac       : Q1.7 x Q4.12 products, saturating accumulate (index order)
  stage_2 round/sat : round half toward +inf, sat16, sticky sat_flag
  stage_3 select    : Top-K by total deterministic order
  stage_4 tie law   : TIE-R0, exposes TIE_OVERFLOW_BEYOND_K_HARD
  stage_5 emit      : ordered inspection queue (TOP_K != ANSWER)

Locked: UTILITY != TRUTH. No epistemic status is decided here; the model
exposes conditions/observables only (invalid_count, tie_overflow, k_invalid).

Profile inputs (A-ID-PROFILE-01, C-CODE-07): semantic ID is 32-bit. The loaded board/knowledge-pack
profile supplies `active_id_max`; SPEAR re-checks candidate_ref <= active_id_max as DEFENSIVE
validation only (ID_OUT_OF_ACTIVE_RANGE -> dropped, invalid_count++). The authoritative range
checker is the T1 directory admit; the numeric range (e.g. 24 bits on Arty) is a profile value,
never an identity law. K bounds: k_soft>=1, k_hard>=1, k_hard<=K_HARD_MAX (slot capacity) are
checked fail-closed -> k_invalid=1, admitted_count=0, tie_overflow=0. k_soft>k_hard is NOT an
error (K = min). Status mapping of invalid_count / k_invalid is B-owned.

Layouts below are LEARNING_LOCAL_LAYOUT_CANDIDATE (not §04 ABI).
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import List, Optional, Sequence

# ---------------------------------------------------------------------------
# Fixed-point conventions (§10.7.5): Qm.n, m includes sign, width = m + n
# ---------------------------------------------------------------------------
F_W = 8        # Q1.7 feature
W_W = 16       # Q4.12 weight
PROD_W = 24    # Q5.19 product
ACC_W_DEFAULT = 32
SHIFT_DEFAULT = 12
SCORE_W = 16
N_FEAT = 16
K_HARD_MAX_DEFAULT = 8                 # slot capacity of the candidate RTL (implementation parameter)
ACTIVE_ID_MAX_DEFAULT = 0x00FFFFFF     # Arty profile EXAMPLE (24 significant bits); profile value, not a law
ID_FULL_MAX = 0xFFFFFFFF               # semantic ID field width is 32 bits

F_MIN, F_MAX = -(1 << (F_W - 1)), (1 << (F_W - 1)) - 1
W_MIN, W_MAX = -(1 << (W_W - 1)), (1 << (W_W - 1)) - 1
SCORE_MIN, SCORE_MAX = -(1 << (SCORE_W - 1)), (1 << (SCORE_W - 1)) - 1


def to_signed(value: int, width: int) -> int:
    value &= (1 << width) - 1
    return value - (1 << width) if value >> (width - 1) else value


def to_unsigned(value: int, width: int) -> int:
    return value & ((1 << width) - 1)


def sat(value: int, width: int) -> tuple[int, bool]:
    lo, hi = -(1 << (width - 1)), (1 << (width - 1)) - 1
    if value > hi:
        return hi, True
    if value < lo:
        return lo, True
    return value, False


def sat_add(a: int, b: int, width: int) -> tuple[int, bool]:
    return sat(a + b, width)


def round_shift_sat16(acc: int, shift: int) -> tuple[int, bool]:
    """(acc + 2^(shift-1)) >>> shift, then sat16. Round half toward +inf."""
    biased = acc + (1 << (shift - 1))
    shifted = biased >> shift  # Python >> on int is arithmetic (floor)
    return sat(shifted, SCORE_W)


# ---------------------------------------------------------------------------
# CRC-16/CCITT-FALSE over descriptor bits [127:16] (112 bits, MSB first)
# ---------------------------------------------------------------------------
CRC_POLY = 0x1021
CRC_INIT = 0xFFFF
CRC_COVER_BITS = 112


def crc16_bits(value: int, nbits: int) -> int:
    crc = CRC_INIT
    for i in range(nbits - 1, -1, -1):
        bit = (value >> i) & 1
        msb = (crc >> 15) & 1
        crc = ((crc << 1) & 0xFFFF)
        if bit ^ msb:
            crc ^= CRC_POLY
    return crc


# ---------------------------------------------------------------------------
# CandidateDescriptor — LEARNING_LOCAL_LAYOUT_CANDIDATE (128 bits)
#   [127:96] candidate_ref   [95:92] source_op   [91:76] namespace_id
#   [75:60]  generation      [59:20] raw_meta    [19:16] flags   [15:0] crc16
# raw_meta[39:0] (learning-local candidate packing):
#   [39:36] relation_class  [35:32] hop_distance    [31] provenance_present
#   [30:29] context_match   [28:25] hotness_bucket  [24:21] fem_penalty_bucket
#   [20:17] recency_bucket  [16:13] answer_kind     [12:11] hint_level
#   [10:9]  posting_avail   [8:5]   value_fit       [4]     conflict_known
#   [3:0]   est_cost_bucket
# ---------------------------------------------------------------------------
@dataclass
class Descriptor:
    candidate_ref: int
    source_op: int
    namespace_id: int
    generation: int
    raw_meta: int
    flags: int = 0
    crc16: Optional[int] = None  # None -> compute correct CRC

    def body_bits(self) -> int:
        v = (to_unsigned(self.candidate_ref, 32) << 80)
        v |= (to_unsigned(self.source_op, 4) << 76)
        v |= (to_unsigned(self.namespace_id, 16) << 60)
        v |= (to_unsigned(self.generation, 16) << 44)
        v |= (to_unsigned(self.raw_meta, 40) << 4)
        v |= to_unsigned(self.flags, 4)
        return v  # 112 bits

    def correct_crc(self) -> int:
        return crc16_bits(self.body_bits(), CRC_COVER_BITS)

    def pack(self) -> int:
        crc = self.correct_crc() if self.crc16 is None else to_unsigned(self.crc16, 16)
        return (self.body_bits() << 16) | crc

    @staticmethod
    def unpack(word: int) -> "Descriptor":
        word &= (1 << 128) - 1
        return Descriptor(
            candidate_ref=(word >> 96) & 0xFFFFFFFF,
            source_op=(word >> 92) & 0xF,
            namespace_id=(word >> 76) & 0xFFFF,
            generation=(word >> 60) & 0xFFFF,
            raw_meta=(word >> 20) & ((1 << 40) - 1),
            flags=(word >> 16) & 0xF,
            crc16=word & 0xFFFF,
        )


@dataclass
class QueryCtx:
    relation_class: int
    max_hops: int
    answer_kind: int
    namespace_id: int
    generation: int
    k_soft: int
    k_hard: int


# ---------------------------------------------------------------------------
# logical_stage_0 — validation + typed feature extraction
# ---------------------------------------------------------------------------
def validate(desc: Descriptor, active_id_max: int = ACTIVE_ID_MAX_DEFAULT) -> tuple[bool, str]:
    word = desc.pack()
    if crc16_bits(word >> 16, CRC_COVER_BITS) != (word & 0xFFFF):
        return False, "CRC_FAIL"
    if to_unsigned(desc.candidate_ref, 32) > (active_id_max & ID_FULL_MAX):
        return False, "ID_OUT_OF_ACTIVE_RANGE"   # defensive profile check, not identity definition
    return True, "OK"


def k_bounds_ok(k_soft: int, k_hard: int, k_hard_max: int = K_HARD_MAX_DEFAULT) -> bool:
    """Fail-closed K contract: 1 <= k_soft, 1 <= k_hard <= k_hard_max. k_soft > k_hard is legal (K = min)."""
    return k_soft >= 1 and 1 <= k_hard <= k_hard_max


def _bucket8(b: int) -> int:
    return min(b * 8, F_MAX)


def extract_features(desc: Descriptor, q: QueryCtx) -> List[int]:
    m = desc.raw_meta
    relation_class = (m >> 36) & 0xF
    hop_distance = (m >> 32) & 0xF
    provenance = (m >> 31) & 0x1
    context_match = (m >> 29) & 0x3
    hotness = (m >> 25) & 0xF
    fem_pen = (m >> 21) & 0xF
    recency = (m >> 17) & 0xF
    answer_kind = (m >> 13) & 0xF
    hint = (m >> 11) & 0x3
    posting = (m >> 9) & 0x3
    value_fit = (m >> 5) & 0xF
    conflict = (m >> 4) & 0x1
    est_cost = m & 0xF

    f = [0] * N_FEAT
    f[0] = F_MAX if relation_class == (q.relation_class & 0xF) else 0
    prox = (q.max_hops & 0xF) - hop_distance
    f[1] = _bucket8(prox) if prox > 0 else 0
    f[2] = F_MAX if provenance else 0
    f[3] = {0: 0, 1: 64, 2: F_MAX, 3: F_MAX}[context_match]
    f[4] = _bucket8(hotness)
    f[5] = _bucket8(fem_pen)
    f[6] = _bucket8(recency)
    f[7] = F_MAX if desc.generation == (q.generation & 0xFFFF) else 0
    f[8] = F_MAX if answer_kind == (q.answer_kind & 0xF) else 0
    f[9] = hint * 42
    f[10] = bin(posting).count("1") * 63
    f[11] = _bucket8(value_fit)
    f[12] = F_MAX if conflict else 0
    f[13] = F_MAX if desc.namespace_id == (q.namespace_id & 0xFFFF) else 0
    f[14] = _bucket8(15 - est_cost)
    f[15] = 0
    for v in f:
        assert F_MIN <= v <= F_MAX
    return f


# ---------------------------------------------------------------------------
# logical_stage_1 / stage_2 — MAC + round/sat
# ---------------------------------------------------------------------------
def score_features(features: Sequence[int], weights: Sequence[int],
                   acc_w: int = ACC_W_DEFAULT, shift: int = SHIFT_DEFAULT) -> tuple[int, bool, int]:
    """Returns (score, sat_flag, acc). Accumulates in index order with saturation
    after every add (learning-local clarification of §10.7.5 'saturating add')."""
    acc = 0
    sat_flag = False
    for f_i, w_i in zip(features, weights):
        assert F_MIN <= f_i <= F_MAX and W_MIN <= w_i <= W_MAX
        prod = f_i * w_i
        assert -(1 << (PROD_W - 1)) <= prod <= (1 << (PROD_W - 1)) - 1
        acc, s = sat_add(acc, prod, acc_w)
        sat_flag |= s
    score, s2 = round_shift_sat16(acc, shift)
    sat_flag |= s2
    return score, sat_flag, acc


# ---------------------------------------------------------------------------
# stage_3..5 — Top-K, TIE-R0, emit
# ---------------------------------------------------------------------------
@dataclass
class Scored:
    seq: int
    candidate_ref: int
    score: int
    sat_flag: bool
    features: List[int] = field(default_factory=list)

    def order_key(self):
        # Descending on score, f1, f2, f13; ascending arrival seq. Total order.
        return (-self.score, -self.features[1], -self.features[2], -self.features[13], self.seq)


@dataclass
class SpearResult:
    scored: List[Scored]              # all VALID candidates in arrival order
    invalid_seqs: List[int]
    invalid_reasons: List[str]
    admitted: List[Scored]            # ordered inspection queue
    tie_overflow: bool
    n_valid: int
    k_invalid: bool = False           # K contract violated -> fail-closed (nothing admitted)

    @property
    def invalid_count(self) -> int:
        return len(self.invalid_seqs)

    @property
    def admitted_count(self) -> int:
        return len(self.admitted)


def spear_rank(descs: Sequence[Descriptor], q: QueryCtx, weights: Sequence[int],
               acc_w: int = ACC_W_DEFAULT, shift: int = SHIFT_DEFAULT,
               k_hard_max: int = K_HARD_MAX_DEFAULT,
               active_id_max: int = ACTIVE_ID_MAX_DEFAULT) -> SpearResult:
    assert len(weights) == N_FEAT
    k_invalid = not k_bounds_ok(q.k_soft, q.k_hard, k_hard_max)
    scored: List[Scored] = []
    invalid_seqs: List[int] = []
    invalid_reasons: List[str] = []
    for seq, d in enumerate(descs):
        ok, why = validate(d, active_id_max)
        if not ok:
            invalid_seqs.append(seq)
            invalid_reasons.append(why)
            continue
        f = extract_features(d, q)
        s, sf, _ = score_features(f, weights, acc_w, shift)
        scored.append(Scored(seq=seq, candidate_ref=d.candidate_ref, score=s, sat_flag=sf, features=f))

    ordered = sorted(scored, key=Scored.order_key)
    n_valid = len(ordered)
    k = min(q.k_soft, q.k_hard)
    tie_overflow = False

    if k_invalid:
        # fail-closed: candidates are still scored (observables), nothing is admitted, no TIE-R0 claim
        return SpearResult(scored=scored, invalid_seqs=invalid_seqs, invalid_reasons=invalid_reasons,
                           admitted=[], tie_overflow=False, n_valid=n_valid, k_invalid=True)
    if n_valid <= k:
        admitted = ordered
    else:
        boundary_score = ordered[k - 1].score
        if ordered[k].score != boundary_score:
            admitted = ordered[:k]
        else:
            above = [c for c in ordered if c.score > boundary_score]
            tie_class = [c for c in ordered if c.score == boundary_score]
            if len(above) + len(tie_class) <= q.k_hard:
                admitted = above + tie_class          # widen: admit ALL of T
            else:
                tie_overflow = True                    # TIE_OVERFLOW_BEYOND_K_HARD
                admitted = ordered[:k]                 # flag raised; status law owned by B

    return SpearResult(scored=scored, invalid_seqs=invalid_seqs, invalid_reasons=invalid_reasons,
                       admitted=admitted, tie_overflow=tie_overflow, n_valid=n_valid, k_invalid=False)


# ---------------------------------------------------------------------------
# Self-test of the rounding law against the §10.7.5 boundary table
# ---------------------------------------------------------------------------
_BOUNDARY_TABLE = [
    (2048, 1), (2047, 0), (2049, 1),
    (-2048, 0), (-2049, -1), (-2047, 0),
    (4096, 1), (-4096, -1), (0, 0),
]


def self_test() -> None:
    for acc, expect in _BOUNDARY_TABLE:
        got, s = round_shift_sat16(acc, SHIFT_DEFAULT)
        assert got == expect and not s, (acc, got, expect)
    # sat16 reachable only with reduced shift
    got, s = round_shift_sat16((1 << 26), 4)
    assert got == SCORE_MAX and s
    got, s = round_shift_sat16(-(1 << 26), 4)
    assert got == SCORE_MIN and s
    # acc saturation reachable only with narrowed accumulator
    a, s = sat_add((1 << 23) - 1, 1, 24)
    assert a == (1 << 23) - 1 and s
    a, s = sat_add(-(1 << 23), -1, 24)
    assert a == -(1 << 23) and s
    # default-width bound: |acc| <= 16 * 2^22 = 2^26 < 2^31 -> unreachable saturation
    assert N_FEAT * (1 << (PROD_W - 2)) < (1 << (ACC_W_DEFAULT - 1))
    # CRC round-trip
    d = Descriptor(0x00ABCDEF, 3, 0x1234, 0x0007, 0x123456789A, 0)
    assert validate(d) == (True, "OK")
    bad = Descriptor.unpack(d.pack() ^ 1)
    assert validate(bad)[0] is False
    # active range is a PROFILE value: same 32-bit ID is out-of-profile under the Arty example
    # and valid under a full-range profile (identity permutation changes nothing else)
    hi = Descriptor(0x01ABCDEF, 3, 0x1234, 0x0007, 0x123456789A, 0)
    assert validate(hi) == (False, "ID_OUT_OF_ACTIVE_RANGE")
    assert validate(hi, active_id_max=ID_FULL_MAX) == (True, "OK")
    assert validate(hi, active_id_max=0x01ABCDEF) == (True, "OK")
    assert validate(hi, active_id_max=0x01ABCDEE) == (False, "ID_OUT_OF_ACTIVE_RANGE")
    # K contract: fail-closed on 0 / over-capacity, min-law keeps k_soft > k_hard legal
    assert not k_bounds_ok(0, 8) and not k_bounds_ok(4, 0) and not k_bounds_ok(4, 9)
    assert k_bounds_ok(1, 1) and k_bounds_ok(8, 8) and k_bounds_ok(6, 3)
    ws = [0] * N_FEAT
    qk = QueryCtx(relation_class=0, max_hops=7, answer_kind=0, namespace_id=0x1234, generation=7,
                  k_soft=4, k_hard=9)
    r = spear_rank([d, d], qk, ws)
    assert r.k_invalid and r.admitted_count == 0 and not r.tie_overflow and r.n_valid == 2
    qk.k_hard = 8
    r = spear_rank([d, d], qk, ws)
    assert not r.k_invalid and r.admitted_count == 2
    print("SPEAR_REF_SELFTEST_PASS")


if __name__ == "__main__":
    self_test()
