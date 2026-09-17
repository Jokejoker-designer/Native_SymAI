#!/usr/bin/env python3
"""Export FE256 store ROM and check hardware-shaped Q-eval vs gold results.

Imports gold Store construction + codecs only. Does not copy astra_qeval.
PROGRAM=NO. XSim != board.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "verification" / "fe256"))

from fe256_gold import (  # noqa: E402
    CMPL_COMPLETE,
    CMPL_NA,
    CMPL_PARTIAL,
    DIR_REV,
    EP_VERIFIED,
    GENERATION_A,
    GENERATION_B,
    KIND_NONE,
    OP_MULTIHOP,
    OP_UNSUPPORTED,
    QFLAG_INFER_OK,
    QFLAG_PROOF_REQ,
    QFLAG_PROV_REQ,
    RC_BUDGET_EXHAUSTED,
    RC_CANDIDATE_ONLY,
    RC_CONTEXT_INCOMPATIBLE,
    RC_DIRECTION_ILLEGAL,
    RC_DISTINCT_VERIFIED_REFS,
    RC_NO_VERIFIED_SUPPORT,
    RC_OPERATOR_UNIMPLEMENTED,
    RC_PACK_CRC,
    RC_PROVENANCE_MISSING,
    RC_STALE_GENERATION,
    RC_VERIFIED_SUPPORT,
    REL_USES,
    REL_UNSUPPORTED,
    ResultRec,
    RFLAG_HAS_CONFLICT,
    RFLAG_HAS_PROOF,
    RFLAG_HAS_PROV,
    ST_ANSWER,
    ST_CONFLICT,
    ST_DATA_INTEGRITY_FAIL,
    ST_SEARCH_INCOMPLETE,
    ST_UNKNOWN,
    ST_UNSUPPORTED_QUERY,
    build_cases,
    build_store_a,
    build_store_b,
    crc16_ccitt_false,
    evaluate_campaign,
    path_proof,
)


def pack_edge(e, in_a: bool, in_b: bool, prov_b: bool) -> int:
    w = 0
    w |= e.edge_id & 0xFFFFFFFF
    w |= (e.subject & 0xFFFFFFFF) << 32
    w |= (e.obj & 0xFFFFFFFF) << 64
    w |= (e.provenance_id & 0xFFFFFFFF) << 96
    w |= (e.proof_id & 0xFFFFFFFF) << 128
    w |= (e.value_lo & 0xFFFFFFFF) << 160
    w |= (e.value_hi & 0xFFFFFFFF) << 192
    w |= (e.relation & 0xFFFF) << 224
    w |= (e.context_id & 0xFF) << 240
    w |= (e.answer_kind & 0xF) << 248
    if e.epistemic == EP_VERIFIED:
        w |= 1 << 252
    if in_a:
        w |= 1 << 253
    if in_b:
        w |= 1 << 254
    if prov_b:
        w |= 1 << 255
    return w


def emit_word(e) -> int:
    return pack_edge(e, True, True, True)  # placeholder unused


def context_ok(ectx: int, qctx: int) -> bool:
    if qctx == 0:
        return ectx == 0
    return ectx == qctx


def hw_qeval(edges, q, use_b: bool) -> ResultRec:
    store_gen = GENERATION_B if use_b else GENERATION_A
    base = dict(
        txn_id=q.txn_id,
        generation=store_gen,
        namespace_id=q.namespace_id,
        context_ref=q.context_id,
    )

    def emit(status: int, reason: int, **kw) -> ResultRec:
        d = dict(base)
        d.update(kw)
        if status == ST_ANSWER:
            d.setdefault("completeness", CMPL_COMPLETE)
            d.setdefault("reason_code", reason)
            flags = d.get("flags", 0)
            if d.get("proof_ref"):
                flags |= RFLAG_HAS_PROOF
            if d.get("provenance_ref"):
                flags |= RFLAG_HAS_PROV
            d["flags"] = flags
            d.setdefault("answer_count", 1)
        elif status == ST_SEARCH_INCOMPLETE:
            d.setdefault("completeness", CMPL_PARTIAL)
            d.setdefault("answer_kind", KIND_NONE)
        elif status == ST_CONFLICT:
            d.setdefault("completeness", CMPL_COMPLETE)
            d.setdefault("answer_kind", KIND_NONE)
            flags = d.get("flags", 0)
            if d.get("conflict_ref"):
                flags |= RFLAG_HAS_CONFLICT
            if d.get("proof_ref"):
                flags |= RFLAG_HAS_PROOF
            d["flags"] = flags
        elif status == ST_UNKNOWN:
            d.setdefault("completeness", CMPL_COMPLETE)
            d.setdefault("answer_kind", KIND_NONE)
        else:
            d.setdefault("completeness", CMPL_NA)
            d.setdefault("answer_kind", KIND_NONE)
        d["status"] = status
        d.setdefault("reason_code", reason)
        return ResultRec(**d)

    if q.generation not in (0, store_gen):
        return emit(ST_DATA_INTEGRITY_FAIL, RC_STALE_GENERATION)
    if q.op_class == OP_UNSUPPORTED or q.relation_id == REL_UNSUPPORTED:
        return emit(ST_UNSUPPORTED_QUERY, RC_OPERATOR_UNIMPLEMENTED)
    if q.direction == DIR_REV and q.relation_id != REL_USES:
        return emit(ST_UNSUPPORTED_QUERY, RC_DIRECTION_ILLEGAL)
    if q.search_budget == 0:
        return emit(ST_SEARCH_INCOMPLETE, RC_BUDGET_EXHAUSTED)

    def live(ed) -> bool:
        return bool(ed["in_b"] if use_b else ed["in_a"])

    def prov_ok(ed) -> bool:
        if ed["prov"] == 0:
            return False
        return bool(ed["prov_b"] if use_b else True)

    mh = q.op_class == OP_MULTIHOP or ((q.flags & QFLAG_INFER_OK) and q.max_hops > 1)
    work = 0

    def charge() -> bool:
        nonlocal work
        work += 1
        return work > q.search_budget

    if mh:
        # BFS FIFO (hardware-shaped)
        fifo = [(q.subject_id, 0, [])]  # node, hops, path edge dicts
        seen = {q.subject_id}
        found = []
        incomplete = False
        while fifo:
            node, hops, path = fifo.pop(0)
            if hops >= q.max_hops:
                continue
            for ed in edges:
                if not live(ed):
                    continue
                if ed["sub"] != node:
                    continue
                if charge():
                    incomplete = True
                    break
                if not ed["ver"]:
                    continue
                if not context_ok(ed["ctx"], q.context_id):
                    continue
                nxt = path + [ed]
                if ed["rel"] == q.relation_id:
                    found.append(nxt)
                if ed["obj"] not in seen:
                    seen.add(ed["obj"])
                    fifo.append((ed["obj"], hops + 1, nxt))
            if incomplete:
                break
        if incomplete:
            return emit(ST_SEARCH_INCOMPLETE, RC_BUDGET_EXHAUSTED)
        if not found:
            return emit(ST_UNKNOWN, RC_NO_VERIFIED_SUPPORT)
        by_ans = {}
        for p in found:
            by_ans.setdefault(p[-1]["obj"], p)
        if len(by_ans) > 1:
            keys = sorted(by_ans)
            return emit(
                ST_CONFLICT,
                RC_DISTINCT_VERIFIED_REFS,
                conflict_ref=keys[0] ^ keys[1] | 0x07000000,
                proof_ref=by_ans[keys[0]][-1]["proof"],
            )
        ans = next(iter(by_ans))
        path = by_ans[ans]
        last = path[-1]
        if (q.flags & QFLAG_PROV_REQ) and not prov_ok(last):
            return emit(ST_UNKNOWN, RC_PROVENANCE_MISSING)
        pid = path_proof("3H" if len(path) >= 3 else "2H", q.subject_id & 0xFF)
        return emit(
            ST_ANSWER,
            RC_VERIFIED_SUPPORT,
            answer_kind=last["kind"],
            answer_ref=ans,
            proof_ref=pid,
            provenance_ref=last["prov"],
            value_lo=last["vlo"],
            value_hi=last["vhi"],
            completeness=CMPL_COMPLETE,
        )

    hits = []
    incomplete = False
    for ed in edges:
        if not live(ed):
            continue
        posting = (
            (ed["obj"] == q.subject_id and ed["rel"] == q.relation_id)
            if q.direction == DIR_REV
            else (ed["sub"] == q.subject_id and ed["rel"] == q.relation_id)
        )
        if not posting:
            continue
        if charge():
            incomplete = True
            break
        if not context_ok(ed["ctx"], q.context_id):
            continue
        if q.object_valid:
            if ed["kind"] == 3:  # KIND_RANGE
                if not (ed["vlo"] <= q.object_ref <= ed["vhi"]):
                    continue
            elif ed["obj"] != q.object_ref:
                continue
        hits.append(ed)
    if incomplete:
        return emit(ST_SEARCH_INCOMPLETE, RC_BUDGET_EXHAUSTED)

    verified = [e for e in hits if e["ver"]]
    candidates = [e for e in hits if not e["ver"]]
    if (q.flags & QFLAG_PROV_REQ) and verified:
        kept = []
        missing = False
        for e in verified:
            if prov_ok(e):
                kept.append(e)
            else:
                missing = True
        if not kept and missing:
            return emit(ST_UNKNOWN, RC_PROVENANCE_MISSING)
        verified = kept
    if len(verified) >= 2:
        refs = {e["sub"] if q.direction == DIR_REV else e["obj"] for e in verified}
        if len(refs) > 1:
            vs = sorted(refs)
            cref = 0x070100 + (vs[0] & 0xFF)
            return emit(
                ST_CONFLICT,
                RC_DISTINCT_VERIFIED_REFS,
                conflict_ref=cref,
                proof_ref=verified[0]["proof"],
                provenance_ref=verified[0]["prov"],
            )
    if verified:
        e = verified[0]
        answer = e["sub"] if q.direction == DIR_REV else e["obj"]
        if q.flags & QFLAG_PROOF_REQ and e["proof"] == 0:
            return emit(ST_UNKNOWN, RC_PROVENANCE_MISSING)
        return emit(
            ST_ANSWER,
            RC_VERIFIED_SUPPORT,
            answer_kind=e["kind"],
            answer_ref=answer,
            proof_ref=e["proof"],
            provenance_ref=e["prov"],
            value_lo=e["vlo"],
            value_hi=e["vhi"],
            completeness=CMPL_COMPLETE,
        )
    if candidates and not verified:
        return emit(ST_UNKNOWN, RC_CANDIDATE_ONLY)
    if q.context_id != 0:
        return emit(ST_UNKNOWN, RC_CONTEXT_INCOMPATIBLE)
    return emit(ST_UNKNOWN, RC_NO_VERIFIED_SUPPORT)


def edge_rec(e, in_a, in_b, prov_b):
    return {
        "eid": e.edge_id,
        "sub": e.subject,
        "obj": e.obj,
        "rel": e.relation,
        "ctx": e.context_id,
        "prov": e.provenance_id,
        "proof": e.proof_id,
        "ver": e.epistemic == EP_VERIFIED,
        "kind": e.answer_kind,
        "vlo": e.value_lo,
        "vhi": e.value_hi,
        "in_a": in_a,
        "in_b": in_b,
        "prov_b": prov_b,
    }


def main() -> int:
    a = build_store_a()
    b = build_store_b(a)
    a_ids = {e.edge_id for e in a.edges}
    b_ids = {e.edge_id for e in b.edges}
    a_map = {e.edge_id: e for e in a.edges}
    dropped_prov = {pid for pid in a.provenance_present if pid not in b.provenance_present}

    recs = []
    for e in a.edges:
        recs.append(
            edge_rec(
                e,
                True,
                e.edge_id in b_ids,
                e.provenance_id not in dropped_prov,
            )
        )

    cases = build_cases()
    _, _, gold_rows = evaluate_campaign(cases)
    mism = []
    for c, r_gold, qb, rb in gold_rows:
        use_b = c.pack == "B"
        r_hw = hw_qeval(recs, c.query, use_b)
        if r_hw.pack() != rb:
            mism.append(
                {
                    "case": c.case_id,
                    "gold_status": r_gold.status,
                    "hw_status": r_hw.status,
                    "gold_reason": r_gold.reason_code,
                    "hw_reason": r_hw.reason_code,
                    "gold": rb.hex(),
                    "hw": r_hw.pack().hex(),
                }
            )
    out_dir = Path(__file__).resolve().parent
    rom_path = out_dir / "fe256_store.mem"
    lines = []
    for rec, e in zip(recs, a.edges):
        w = pack_edge(e, rec["in_a"], rec["in_b"], rec["prov_b"])
        lines.append(f"{w:064x}")
    rom_path.write_text("\n".join(lines) + "\n", encoding="ascii")
    meta = {
        "n_edges": len(recs),
        "n_store_a": len(a.edges),
        "n_store_b": len(b.edges),
        "dropped_prov": sorted(dropped_prov),
        "hw_vs_gold_mismatches": len(mism),
        "crc16_self": hex(crc16_ccitt_false(b"NAI1")),
    }
    (out_dir / "fe256_store_meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    if mism:
        (out_dir / "fe256_hw_mismatches.json").write_text(json.dumps(mism[:20], indent=2), encoding="utf-8")
        print(f"HW_QEVAL_MISMATCH {len(mism)}")
        print(json.dumps(mism[0], indent=2))
        return 1
    print(f"HW_QEVAL_MATCH 256  n_edges={len(recs)} rom={rom_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
