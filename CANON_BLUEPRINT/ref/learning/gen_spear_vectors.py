"""Generate deterministic SPEAR test vectors from the reference model (C-CODE-02).

Expected values come from spear_ref (the truth source), never from the DUT.
Output: tb/learning/vectors/spear/<case>.hex  (+ manifest.json)

Hex file layout (32-bit words, one per line, for $readmemh):
  w0        N_desc
  w1        k_soft | k_hard<<8 | relation_class<<16 | max_hops<<20 | answer_kind<<24
  w2        namespace_id | generation<<16
  w3        acc_w | shift<<8 | k_hard_max<<16
  w4        active_id_max (loaded-profile value; A-ID-PROFILE-01. Arty example 0x00FFFFFF, not a law)
  w5..w12   weights: w[2i] in [15:0], w[2i+1] in [31:16]  (two's complement)
  per desc  5 words: d[127:96] d[95:64] d[63:32] d[31:0]  exp=valid<<31|sat<<30|score[15:0]
  final     F0 = admitted_count | tie_overflow<<8 | k_invalid<<9 | n_valid<<16
            F1 = invalid_count
            admitted_count x 2 words: candidate_ref ; score[15:0] | sat<<16
"""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path
from typing import List

sys.path.insert(0, str(Path(__file__).parent))
from spear_ref import (  # noqa: E402
    ACC_W_DEFAULT, SHIFT_DEFAULT, W_MAX, W_MIN, N_FEAT, K_HARD_MAX_DEFAULT, ACTIVE_ID_MAX_DEFAULT,
    ID_FULL_MAX, Descriptor, QueryCtx, spear_rank, to_unsigned,
)

OUT_DIR = Path(__file__).resolve().parents[2] / "tb" / "learning" / "vectors" / "spear"


def raw_meta(relation_class=0, hop_distance=15, provenance=0, context_match=0, hotness=0,
             fem_pen=0, recency=0, answer_kind=0, hint=0, posting=0, value_fit=0,
             conflict=0, est_cost=15) -> int:
    m = 0
    m |= (relation_class & 0xF) << 36
    m |= (hop_distance & 0xF) << 32
    m |= (provenance & 1) << 31
    m |= (context_match & 3) << 29
    m |= (hotness & 0xF) << 25
    m |= (fem_pen & 0xF) << 21
    m |= (recency & 0xF) << 17
    m |= (answer_kind & 0xF) << 13
    m |= (hint & 3) << 11
    m |= (posting & 3) << 9
    m |= (value_fit & 0xF) << 5
    m |= (conflict & 1) << 4
    m |= est_cost & 0xF
    return m


# Query context used by most cases
Q_REL, Q_HOPS, Q_AK, Q_NS, Q_GEN = 5, 7, 2, 0x00A5, 0x0011


def ctx(k_soft=4, k_hard=8, max_hops=Q_HOPS) -> QueryCtx:
    return QueryCtx(relation_class=Q_REL, max_hops=max_hops, answer_kind=Q_AK,
                    namespace_id=Q_NS, generation=Q_GEN, k_soft=k_soft, k_hard=k_hard)


def all_max_desc(ref: int) -> Descriptor:
    """All 15 active features at their maximum (f9=126, f10=126, others 127/120)."""
    return Descriptor(ref, 1, Q_NS, Q_GEN,
                      raw_meta(relation_class=Q_REL, hop_distance=0, provenance=1, context_match=2,
                               hotness=15, fem_pen=15, recency=15, answer_kind=Q_AK, hint=3,
                               posting=3, value_fit=15, conflict=1, est_cost=0))


def zero_desc(ref: int) -> Descriptor:
    return Descriptor(ref, 0, 0x0000, 0x0000, raw_meta())


def rounding_desc(ref: int) -> Descriptor:
    """f1 = 8 (max_hops=1, hop=0), f2 = 127 (provenance). Every other feature 0."""
    return Descriptor(ref, 0, 0x0000, 0x0000, raw_meta(hop_distance=0, provenance=1))


def encode(descs: List[Descriptor], q: QueryCtx, weights: List[int], acc_w: int, shift: int,
           k_hard_max: int, active_id_max: int) -> List[int]:
    res = spear_rank(descs, q, weights, acc_w, shift, k_hard_max, active_id_max)
    words: List[int] = []
    words.append(len(descs))
    words.append(q.k_soft | (q.k_hard << 8) | (q.relation_class << 16) | (q.max_hops << 20) | (q.answer_kind << 24))
    words.append(q.namespace_id | (q.generation << 16))
    words.append(acc_w | (shift << 8) | (k_hard_max << 16))
    words.append(active_id_max & ID_FULL_MAX)
    for i in range(0, N_FEAT, 2):
        words.append(to_unsigned(weights[i], 16) | (to_unsigned(weights[i + 1], 16) << 16))
    scored_by_seq = {s.seq: s for s in res.scored}
    for seq, d in enumerate(descs):
        w = d.pack()
        words += [(w >> 96) & 0xFFFFFFFF, (w >> 64) & 0xFFFFFFFF, (w >> 32) & 0xFFFFFFFF, w & 0xFFFFFFFF]
        if seq in scored_by_seq:
            s = scored_by_seq[seq]
            words.append((1 << 31) | (int(s.sat_flag) << 30) | to_unsigned(s.score, 16))
        else:
            words.append(0)
    words.append(res.admitted_count | (int(res.tie_overflow) << 8) | (int(res.k_invalid) << 9) | (res.n_valid << 16))
    words.append(res.invalid_count)
    for a in res.admitted:
        words.append(to_unsigned(a.candidate_ref, 32))
        words.append(to_unsigned(a.score, 16) | (int(a.sat_flag) << 16))
    return words


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    rng = random.Random(0xC0DE_5EA2)
    cases = []

    def add(name, descs, q, weights, acc_w=ACC_W_DEFAULT, shift=SHIFT_DEFAULT,
            k_hard_max=K_HARD_MAX_DEFAULT, active_id_max=ACTIVE_ID_MAX_DEFAULT, note=""):
        words = encode(descs, q, weights, acc_w, shift, k_hard_max, active_id_max)
        (OUT_DIR / f"{name}.hex").write_text("\n".join(f"{w:08x}" for w in words) + "\n", encoding="ascii")
        res = spear_rank(descs, q, weights, acc_w, shift, k_hard_max, active_id_max)
        cases.append({
            "name": name, "acc_w": acc_w, "shift": shift, "k_hard_max": k_hard_max,
            "active_id_max": active_id_max, "n_desc": len(descs),
            "n_valid": res.n_valid, "invalid_count": res.invalid_count,
            "admitted_count": res.admitted_count, "tie_overflow": res.tie_overflow,
            "k_invalid": res.k_invalid, "invalid_reasons": res.invalid_reasons,
            "scores": [s.score for s in res.scored], "note": note,
        })

    zero_w = [0] * N_FEAT
    max_w = [W_MAX] * N_FEAT
    min_w = [W_MIN] * N_FEAT

    # --- scalar boundary family (default config) -----------------------------
    add("c01_zero", [zero_desc(0x000001)], ctx(), zero_w, note="all weights 0 -> score 0")
    add("c02_min_negative", [all_max_desc(0x000002)], ctx(), min_w, note="acc=-2^26 extreme, unsaturated")
    add("c03_max_positive", [all_max_desc(0x000003)], ctx(), max_w, note="acc=+66582544 extreme, unsaturated")

    def rw(w1: int, w2: int) -> List[int]:
        w = [0] * N_FEAT
        w[1], w[2] = w1, w2
        return w

    rq = ctx(max_hops=1)
    add("c04_pos_exact_half", [rounding_desc(0x000004)], rq, rw(256, 0), note="acc=2048 -> 1")
    add("c05_pos_below_half", [rounding_desc(0x000005)], rq, rw(240, 1), note="acc=2047 -> 0")
    add("c06_pos_above_half", [rounding_desc(0x000006)], rq, rw(145, 7), note="acc=2049 -> 1")
    add("c07_neg_exact_half", [rounding_desc(0x000007)], rq, rw(-256, 0), note="acc=-2048 -> 0")
    add("c08_neg_below_half", [rounding_desc(0x000008)], rq, rw(-240, -1), note="acc=-2047 -> 0")
    add("c09_neg_above_half", [rounding_desc(0x000009)], rq, rw(-145, -7), note="acc=-2049 -> -1")

    # --- saturation paths (parameter-narrowed configs; unreachable at default widths) ---
    add("c10_acc_sat_pos_accw24", [all_max_desc(0x00000A)], ctx(), max_w, acc_w=24,
        note="ACC_W=24: acc clamps +2^23-1, sat_flag=1")
    add("c11_acc_sat_neg_accw24", [all_max_desc(0x00000B)], ctx(), min_w, acc_w=24,
        note="ACC_W=24: acc clamps -2^23, sat_flag=1")
    add("c12_sat16_pos_shift4", [all_max_desc(0x00000C)], ctx(), max_w, shift=4,
        note="SHIFT=4: score sat16 +32767, sat_flag=1")
    add("c13_sat16_neg_shift4", [all_max_desc(0x00000D)], ctx(), min_w, shift=4,
        note="SHIFT=4: score sat16 -32768, sat_flag=1")

    # --- invalid descriptors ----------------------------------------------------
    good = all_max_desc(0x000010)
    bad_crc = Descriptor.unpack(all_max_desc(0x000011).pack() ^ 0x0001)  # corrupt CRC bit
    bad_id = all_max_desc(0x01000012)                                    # above Arty-profile active_id_max
    bad_body = Descriptor.unpack(all_max_desc(0x000013).pack() ^ (1 << 90))  # body corrupt -> CRC fail
    add("c14_invalid_descriptors", [good, bad_crc, bad_id, bad_body, zero_desc(0x000014)], ctx(), max_w,
        note="3 invalid excluded; invalid_count=3; n_valid=2")

    # --- active range is a PROFILE value (A-ID-PROFILE-01): same IDs, different profile -------------
    prof_descs = [all_max_desc(0x00FFFFFF), all_max_desc(0x01000000), all_max_desc(0xFFFFFFFF), all_max_desc(0x000010)]
    add("c30_profile_full_range_id32", prof_descs, ctx(), max_w, active_id_max=ID_FULL_MAX,
        note="full 32-bit profile: all four IDs valid; upper byte is NOT an identity check")
    add("c31_profile_arty_example", prof_descs, ctx(), max_w,
        note="Arty example active_id_max=0x00FFFFFF: 0x01000000 and 0xFFFFFFFF dropped as out-of-profile")
    add("c32_profile_exact_max", prof_descs, ctx(), max_w, active_id_max=0x01000000,
        note="active_id_max inclusive boundary: 0x01000000 valid, 0xFFFFFFFF dropped")

    # --- Top-K ordinary ----------------------------------------------------------
    def bucket_desc(ref: int, hotness: int, recency: int = 0) -> Descriptor:
        return Descriptor(ref, 0, Q_NS, Q_GEN, raw_meta(hotness=hotness, recency=recency))

    w_hot = [0] * N_FEAT
    w_hot[4] = 1000   # hotness drives score
    w_hot[6] = 10     # recency small
    ordinary = [bucket_desc(0x000100 + i, h, r) for i, (h, r) in
                enumerate([(3, 0), (9, 1), (1, 2), (12, 3), (7, 4), (5, 5), (15, 6), (0, 7)])]
    add("c15_topk_ordinary", ordinary, ctx(k_soft=3, k_hard=6), w_hot, note="8 distinct scores, K=3")

    # --- Top-K boundary tie, class fits within K_hard (widen) --------------------
    tie_widen = [bucket_desc(0x000200 + i, h) for i, h in enumerate([9, 9, 12, 5, 5, 5, 1, 0])]
    # scores: 12000,9000,9000,5000,5000,5000,1000,0 ; K=4 -> score[3]==score[4]==5000 ; T=3 ; 3+3=6<=8
    add("c16_topk_boundary_tie_widen", tie_widen, ctx(k_soft=4, k_hard=8), w_hot,
        note="tie at K boundary; above(3)+T(3)=6<=K_hard=8 -> admit 6")

    # --- tie class exceeding K_hard ----------------------------------------------
    tie_over = [bucket_desc(0x000300 + i, h) for i, h in enumerate([12, 5, 5, 5, 5, 5, 5, 5, 5])]
    # K=3: score[2]==score[3]==5000 ; above=1, T=8 ; 1+8=9 > K_hard=6 -> TIE_OVERFLOW
    add("c17_tie_exceeds_khard", tie_over, ctx(k_soft=3, k_hard=6), w_hot,
        note="TIE_OVERFLOW_BEYOND_K_HARD=1; admitted=K=3")

    # --- K contract boundaries (fail-closed k_invalid; B owns the status mapping) --------------------
    add("c40_k_soft_zero", tie_over, ctx(k_soft=0, k_hard=6), w_hot,
        note="k_soft=0 -> k_invalid=1, admitted=0, tie_overflow=0 (candidates still scored)")
    add("c41_k_hard_zero", tie_over, ctx(k_soft=3, k_hard=0), w_hot,
        note="k_hard=0 -> k_invalid=1")
    add("c42_k_hard_over_capacity", tie_over, ctx(k_soft=3, k_hard=9), w_hot,
        note="k_hard=9 > K_HARD_MAX=8 -> k_invalid=1; the TIE-R0 overflow must NOT be silently lost")
    add("c43_k_hard_eq_capacity", tie_over, ctx(k_soft=3, k_hard=8), w_hot,
        note="k_hard=8 == K_HARD_MAX: legal; 1+8=9 > 8 -> tie_overflow=1, admitted=3")
    add("c44_k_soft_gt_k_hard", ordinary, ctx(k_soft=6, k_hard=3), w_hot,
        note="k_soft>k_hard is legal under K=min -> K=3, k_invalid=0")
    add("c45_k_one_one", ordinary, ctx(k_soft=1, k_hard=1), w_hot,
        note="minimum legal K: admit exactly the top candidate")

    # --- secondary-key order within an equal-score class -----------------------------
    # identical score (hotness 6); differentiate by f1 (hop), f2 (prov), f13 (ns), seq
    def sec_desc(ref, hop, prov, ns):
        return Descriptor(ref, 0, ns, Q_GEN, raw_meta(hotness=6, hop_distance=hop, provenance=prov))
    w_sec = [0] * N_FEAT
    w_sec[4] = 1000
    secondary = [
        sec_desc(0x000401, hop=7, prov=0, ns=0x0000),   # f1=0 f2=0 f13=0 seq0
        sec_desc(0x000402, hop=3, prov=0, ns=0x0000),   # f1=32
        sec_desc(0x000403, hop=3, prov=1, ns=0x0000),   # f1=32 f2=127
        sec_desc(0x000404, hop=3, prov=1, ns=Q_NS),     # f1=32 f2=127 f13=127
        sec_desc(0x000405, hop=7, prov=0, ns=0x0000),   # same as seq0 -> after by seq
    ]
    add("c18_secondary_key_order", secondary, ctx(k_soft=5, k_hard=8), w_sec,
        note="equal scores; order f1 desc, f2 desc, f13 desc, seq asc -> 404,403,402,401,405")

    # --- seeded random regression ---------------------------------------------------
    for n in range(3):
        descs = []
        for i in range(12):
            body_ok = rng.random() > 0.15
            ref = rng.randrange(0, 1 << 24)
            if not body_ok and rng.random() < 0.5:
                ref |= rng.randrange(1, 256) << 24
            d = Descriptor(ref, rng.randrange(16), rng.choice([Q_NS, 0x0001]), rng.choice([Q_GEN, 0x0022]),
                           rng.randrange(1 << 40), rng.randrange(16))
            if not body_ok and (ref >> 24) == 0:
                d = Descriptor.unpack(d.pack() ^ (1 << rng.randrange(128)))
            descs.append(d)
        weights = [rng.randrange(W_MIN, W_MAX + 1) for _ in range(N_FEAT)]
        add(f"c2{n}_random_seeded", descs, ctx(k_soft=rng.randrange(1, 6), k_hard=8), weights,
            note="seeded random regression")

    (OUT_DIR / "manifest.json").write_text(json.dumps(cases, indent=1), encoding="ascii")
    print(f"SPEAR_VECTORS_WRITTEN {len(cases)} -> {OUT_DIR}")
    for c in cases:
        print(f"  {c['name']:32s} acc_w={c['acc_w']} shift={c['shift']:2d} idmax={c['active_id_max']:08x} "
              f"n={c['n_desc']:2d} valid={c['n_valid']:2d} inv={c['invalid_count']} adm={c['admitted_count']} "
              f"tie_ovf={int(c['tie_overflow'])} k_inv={int(c['k_invalid'])} scores={c['scores'][:6]}")


if __name__ == "__main__":
    main()
