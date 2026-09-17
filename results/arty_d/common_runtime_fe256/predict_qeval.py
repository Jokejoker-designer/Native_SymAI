"""Predict Q-UNSUP / Q-DIR pre-search pack vs B gold. Does not write gold."""
from __future__ import annotations

import struct
import sys
from pathlib import Path

ROOT = Path(
    r"d:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\fe256"
)
sys.path.insert(0, str(ROOT))
from fe256_gold import (  # noqa: E402
    CMPL_NA,
    CMPL_PARTIAL,
    DIR_REV,
    KIND_NONE,
    MAGIC_RESULT,
    OP_UNSUPPORTED,
    REL_UNSUPPORTED,
    REL_USES,
    RC_BUDGET_EXHAUSTED,
    RC_DIRECTION_ILLEGAL,
    RC_INVALID_DESCRIPTOR,
    RC_OPERATOR_UNIMPLEMENTED,
    ST_SEARCH_INCOMPLETE,
    ST_UNSUPPORTED_QUERY,
    crc16_ccitt_false,
    unpack_query,
    unpack_result,
)

QHEX = ROOT / "out" / "fe256_queries.hex"
RHEX = ROOT / "out" / "fe256_gold_results.hex"


def pack_result(q, st, rc, cmpl, ctx):
    body = struct.pack(
        "<HBBBBBBIHHIIIIIIIBB",
        MAGIC_RESULT,
        1,
        st,
        rc,
        KIND_NONE,
        cmpl,
        0,
        q.txn_id,
        q.generation,
        q.namespace_id,
        0,
        0,
        0,
        0,
        0,
        ctx,
        0,
        0,
        0,
    )
    return body + struct.pack("<H", crc16_ccitt_false(body))


def qeval_presearch(q):
    if q.op_class == OP_UNSUPPORTED or q.relation_id == REL_UNSUPPORTED:
        return ST_UNSUPPORTED_QUERY, RC_OPERATOR_UNIMPLEMENTED, CMPL_NA
    if q.direction == DIR_REV and q.relation_id != REL_USES:
        return ST_UNSUPPORTED_QUERY, RC_DIRECTION_ILLEGAL, CMPL_NA
    if q.search_budget == 0:
        return ST_SEARCH_INCOMPLETE, RC_BUDGET_EXHAUSTED, CMPL_PARTIAL
    return ST_SEARCH_INCOMPLETE, RC_BUDGET_EXHAUSTED, CMPL_PARTIAL


def main():
    qs = [bytes.fromhex(l.strip()) for l in QHEX.read_text().splitlines() if l.strip()]
    rs = [bytes.fromhex(l.strip()) for l in RHEX.read_text().splitlines() if l.strip()]
    n = match = 0
    by_st = {}
    extra = []
    lost = []
    for i, (qb, rb) in enumerate(zip(qs, rs)):
        q = unpack_query(qb)
        gold = unpack_result(rb)
        st, rc, cm = qeval_presearch(q)
        pred = pack_result(q, st, rc, cm, q.context_id)
        n += 1
        ok = pred == rb
        if ok:
            match += 1
        key = (st, rc)
        by_st[key] = by_st.get(key, 0) + 1
        if ok and gold.status not in (ST_SEARCH_INCOMPLETE, ST_UNSUPPORTED_QUERY):
            extra.append(i)
        if (not ok) and gold.status == ST_UNSUPPORTED_QUERY:
            lost.append((i, gold.status, gold.reason_code, st, rc, q.op_class, q.relation_id, q.direction))
    print("predicted_match", match, "/", n)
    print("pred_status_pairs", { (hex(a), hex(b)): c for (a, b), c in sorted(by_st.items())})
    print("false_match_non_inc_unsup", extra)
    print("unsup_gold_miss", lost[:12], "n", len(lost))
    unsup_idx = [i for i, rb in enumerate(rs) if unpack_result(rb).status == 5]
    print("gold_unsup_idx", unsup_idx)
    for i in unsup_idx:
        q = unpack_query(qs[i])
        g = unpack_result(rs[i])
        print(
            f"  {i} gold st={g.status:02x} rc={g.reason_code:02x} cm={g.completeness:02x}"
            f" ctx={g.context_ref:08x} gen={g.generation:04x} txn={g.txn_id:08x}"
            f" q.op={q.op_class:x} rel={q.relation_id:x} dir={q.direction} ctx={q.context_id}"
            f" q.gen={q.generation:04x}"
        )
        st, rc, cm = qeval_presearch(q)
        pred = pack_result(q, st, rc, cm, q.context_id)
        print("    pred match", pred == rs[i], "pred", pred.hex(), "gold", rs[i].hex())


if __name__ == "__main__":
    main()
