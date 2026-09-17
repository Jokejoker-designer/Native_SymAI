#!/usr/bin/env python3
"""FE256 R0.1 Python gold reference — AGENT_B / Verification Lead.

Standalone (stdlib only). Generates the 256 preregistered QueryRecord (32 B)
and StructuredResult (48 B) binaries for FE256_256_256_PASS scoring.

This file is the executable gold authority for XSim compare. Dummy JSONL
elsewhere in the tree is not gold.

Canon locks:
  §03.9  Q-eval transition rules
  §04.12 R0.1 numeric encodings
  §31.3  class counts
  §32    FE256_GOLD_FROZEN then XSim/board ladder

XSim != board. This script never claims BOARD_PASS.

Usage:
  python fe256_gold.py --selfcheck --emit out
"""

from __future__ import annotations

import argparse
import hashlib
import json
import random
import struct
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable

# ---------------------------------------------------------------------------
# §04.12 locked encodings (do not "fix" to match DUT)
# ---------------------------------------------------------------------------

ABI_VERSION = 0x01
NAMESPACE_FE256 = 0x0001
GENERATION_A = 0x0001
GENERATION_B = 0x0002

MAGIC_QUERY = 0x4E51  # 'NQ'
MAGIC_RESULT = 0x4E52  # 'NR'

# Primary StructuredResult.status namespace [§04.12]. Exclusive of reason_code.
# 0x00 is illegal (uninitialized buffer detect). FPGA gold never emits 0x00/0x80.
# 0x22, 0x23, 0x55, and 0x56 are reason_code values only — never status.
ST_ANSWER = 0x01
ST_UNKNOWN = 0x02
ST_CONFLICT = 0x03
ST_SEARCH_INCOMPLETE = 0x04
ST_UNSUPPORTED_QUERY = 0x05
ST_DATA_INTEGRITY_FAIL = 0x06
ST_PARSE_ERROR = 0x80  # adapter-only; FPGA gold never emits

STATUS_NAME = {
    ST_ANSWER: "ANSWER",
    ST_UNKNOWN: "UNKNOWN",
    ST_CONFLICT: "CONFLICT",
    ST_SEARCH_INCOMPLETE: "SEARCH_INCOMPLETE",
    ST_UNSUPPORTED_QUERY: "UNSUPPORTED_QUERY",
    ST_DATA_INTEGRITY_FAIL: "DATA_INTEGRITY_FAIL",
    ST_PARSE_ERROR: "PARSE_ERROR",
}

# reason_code namespace only (StructuredResult.reason_code). Not status bytes.
# RC_VERIFIED_SUPPORT=0x01 overlaps ST_ANSWER numerically; field identity splits them.
RC_NONE = 0x00
RC_VERIFIED_SUPPORT = 0x01
RC_NO_VERIFIED_SUPPORT = 0x10
RC_CANDIDATE_ONLY = 0x11
RC_CONTEXT_INCOMPATIBLE = 0x13
RC_BUDGET_EXHAUSTED = 0x20
RC_TIE_OVERFLOW = 0x22  # never a status; pair with ST_SEARCH_INCOMPLETE
RC_K_INVALID = 0x23  # never a status; pair with ST_DATA_INTEGRITY_FAIL
RC_DISTINCT_VERIFIED_REFS = 0x30
RC_OPERATOR_UNIMPLEMENTED = 0x40
RC_DIRECTION_ILLEGAL = 0x41
RC_PACK_CRC = 0x50
RC_STALE_GENERATION = 0x54
RC_INVALID_DESCRIPTOR = 0x55  # never a status; pair with ST_DATA_INTEGRITY_FAIL
RC_COMMITTED_CORRUPT = 0x56  # never a status; pair with ST_DATA_INTEGRITY_FAIL
RC_PROVENANCE_MISSING = 0x61

PRIMARY_ASTRA_STATUS = frozenset(
    {
        ST_ANSWER,
        ST_UNKNOWN,
        ST_CONFLICT,
        ST_SEARCH_INCOMPLETE,
        ST_UNSUPPORTED_QUERY,
        ST_DATA_INTEGRITY_FAIL,
    }
)
REASON_NEVER_STATUS = frozenset(
    {
        RC_NO_VERIFIED_SUPPORT,
        RC_CANDIDATE_ONLY,
        RC_CONTEXT_INCOMPATIBLE,
        RC_BUDGET_EXHAUSTED,
        RC_TIE_OVERFLOW,
        RC_K_INVALID,
        RC_DISTINCT_VERIFIED_REFS,
        RC_OPERATOR_UNIMPLEMENTED,
        RC_DIRECTION_ILLEGAL,
        RC_PACK_CRC,
        RC_STALE_GENERATION,
        RC_INVALID_DESCRIPTOR,
        RC_COMMITTED_CORRUPT,
        RC_PROVENANCE_MISSING,
    }
)

KIND_NONE = 0x00
KIND_ENTITY = 0x01
KIND_VALUE = 0x02
KIND_RANGE = 0x03
KIND_PROCEDURE = 0x04
KIND_PROOF_PATH = 0x05

CMPL_NA = 0x00
CMPL_COMPLETE = 0x01
CMPL_PARTIAL = 0x02

# query_meta
OP_DIRECT = 0x0
OP_REVERSE = 0x1
OP_MULTIHOP = 0x2
OP_VALUE = 0x3
OP_CONSTRAINT = 0x4
OP_IDENTITY = 0x5
OP_PROVENANCE = 0x6
OP_CONTEXT = 0x7
OP_UNSUPPORTED = 0xF

DIR_FWD = 0
DIR_REV = 1

QOP_WHAT = 0
QOP_WHO = 1
QOP_WHERE = 2
QOP_WHEN = 3
QOP_WHY = 4
QOP_WHICH = 5
QOP_HOW = 6

QFLAG_PROOF_REQ = 1 << 0
QFLAG_PROV_REQ = 1 << 1
QFLAG_INFER_OK = 1 << 2

RFLAG_HAS_PROOF = 1 << 0
RFLAG_HAS_PROV = 1 << 1
RFLAG_HAS_CONFLICT = 1 << 2

# relations
REL_USES = 9
REL_USED_BY = 109
REL_HAS_VALUE = 10
REL_HAS_RANGE = 11
REL_PART_OF = 12
REL_IS_A = 19
REL_RATED = 14
REL_UNSUPPORTED = 0x3FFF

CTX_NONE = 0
CTX_WALL = 1
CTX_DUCT = 2
CTX_HEAT = 3

EP_VERIFIED = "VERIFIED"
EP_CANDIDATE = "CANDIDATE"

CLASS_COUNTS = {
    "FE-DIRECT": 48,
    "FE-VALUE": 32,
    "FE-REVERSE": 32,
    "FE-MULTIHOP": 32,
    "FE-CONTEXT": 24,
    "FE-PROVENANCE": 16,
    "FE-NEGATIVE": 24,
    "FE-CONFLICT": 16,
    "FE-IDENTITY": 16,
    "FE-ABLATION": 16,
}

SHUFFLE_SEED = 0x0FE256
GOLD_SPEC = "FE256_R0_1_AGENT_B"


def mid(i: int) -> int:
    return 0x010100 + i


def oid(i: int) -> int:
    return 0x020100 + i


def fid(i: int) -> int:
    return 0x030100 + (i // 6)


def family(f: int) -> int:
    return 0x030100 + f


ROOT = 0x030000


def wall_oid(i: int) -> int:
    return 0x021100 + i


def duct_oid(i: int) -> int:
    return 0x021200 + i


def fam_obj(f: int) -> int:
    return 0x020300 + f


def val_id(i: int) -> int:
    return 0x040100 + i


def rate_id(i: int) -> int:
    return 0x0A0100 + i


def prov_id(i: int) -> int:
    return 0x050100 + i


def proof_id(i: int) -> int:
    return 0x060100 + i


def conflict_ref(i: int) -> int:
    return 0x070100 + i


def absent_id(i: int) -> int:
    return 0x080100 + i


def conf_sub(i: int) -> int:
    return 0x090100 + i


def conf_oa(i: int) -> int:
    return 0x091100 + i


def conf_ob(i: int) -> int:
    return 0x091200 + i


def path_proof(kind: str, i: int) -> int:
    tag = {"2H": 0x061000, "3H": 0x062000}[kind]
    return tag + i


# ---------------------------------------------------------------------------
# CRC16-CCITT-FALSE (poly 0x1021, init 0xFFFF, xorout 0) — same as Gate14 UART
# ---------------------------------------------------------------------------

def crc16_ccitt_false(data: bytes) -> int:
    c = 0xFFFF
    for b in data:
        c ^= b << 8
        for _ in range(8):
            c = ((c << 1) ^ 0x1021) & 0xFFFF if c & 0x8000 else (c << 1) & 0xFFFF
    return c


def pack_qmeta(op_class: int, direction: int, object_valid: bool, max_hops: int, qop: int) -> int:
    return (
        ((op_class & 0xF) << 12)
        | ((direction & 0x3) << 10)
        | ((1 if object_valid else 0) << 9)
        | ((max_hops & 0xF) << 5)
        | ((qop & 0x7) << 2)
    )


def unpack_qmeta(m: int) -> dict:
    return {
        "op_class": (m >> 12) & 0xF,
        "direction": (m >> 10) & 0x3,
        "object_valid": bool((m >> 9) & 1),
        "max_hops": (m >> 5) & 0xF,
        "qop": (m >> 2) & 0x7,
    }


# ---------------------------------------------------------------------------
# Codecs
# ---------------------------------------------------------------------------

@dataclass
class QueryRec:
    txn_id: int
    subject_id: int
    relation_id: int
    object_ref: int = 0
    context_id: int = 0
    generation: int = GENERATION_A
    namespace_id: int = NAMESPACE_FE256
    op_class: int = OP_DIRECT
    direction: int = DIR_FWD
    object_valid: bool = False
    max_hops: int = 1
    qop: int = QOP_WHAT
    search_budget: int = 64
    flags: int = QFLAG_PROOF_REQ | QFLAG_PROV_REQ
    abi_version: int = ABI_VERSION

    @property
    def query_meta(self) -> int:
        return pack_qmeta(self.op_class, self.direction, self.object_valid, self.max_hops, self.qop)

    def pack(self) -> bytes:
        body = struct.pack(
            "<HBBIHHHIHIIH",
            MAGIC_QUERY,
            self.abi_version,
            self.flags,
            self.txn_id,
            self.generation,
            self.namespace_id,
            self.query_meta,
            self.subject_id,
            self.relation_id,
            self.object_ref,
            self.context_id,
            self.search_budget,
        )
        if len(body) != 30:
            raise RuntimeError(f"QueryRecord body {len(body)} != 30")
        return body + struct.pack("<H", crc16_ccitt_false(body))


def unpack_query(blob: bytes) -> QueryRec:
    if len(blob) != 32:
        raise ValueError("QueryRecord must be 32 bytes")
    body, crc = blob[:30], struct.unpack("<H", blob[30:])[0]
    if crc16_ccitt_false(body) != crc:
        raise ValueError("QueryRecord CRC mismatch")
    magic, abi, flags, txn, gen, ns, qmeta, sub, rel, obj, ctx, bud = struct.unpack(
        "<HBBIHHHIHIIH", body
    )
    if magic != MAGIC_QUERY:
        raise ValueError(f"bad query magic {magic:#x}")
    meta = unpack_qmeta(qmeta)
    return QueryRec(
        txn_id=txn,
        subject_id=sub,
        relation_id=rel,
        object_ref=obj,
        context_id=ctx,
        generation=gen,
        namespace_id=ns,
        op_class=meta["op_class"],
        direction=meta["direction"],
        object_valid=meta["object_valid"],
        max_hops=meta["max_hops"],
        qop=meta["qop"],
        search_budget=bud,
        flags=flags,
        abi_version=abi,
    )


@dataclass
class ResultRec:
    txn_id: int
    status: int
    reason_code: int = RC_NONE
    answer_kind: int = KIND_NONE
    completeness: int = CMPL_COMPLETE
    flags: int = 0
    generation: int = GENERATION_A
    namespace_id: int = NAMESPACE_FE256
    answer_ref: int = 0
    value_lo: int = 0
    value_hi: int = 0
    proof_ref: int = 0
    provenance_ref: int = 0
    context_ref: int = 0
    conflict_ref: int = 0
    answer_count: int = 0
    payload_words: int = 0
    abi_version: int = ABI_VERSION

    def pack(self) -> bytes:
        body = struct.pack(
            "<HBBBBBBIHHIIIIIIIBB",
            MAGIC_RESULT,
            self.abi_version,
            self.status,
            self.reason_code,
            self.answer_kind,
            self.completeness,
            self.flags,
            self.txn_id,
            self.generation,
            self.namespace_id,
            self.answer_ref,
            self.value_lo,
            self.value_hi,
            self.proof_ref,
            self.provenance_ref,
            self.context_ref,
            self.conflict_ref,
            self.answer_count,
            self.payload_words,
        )
        if len(body) != 46:
            raise RuntimeError(f"StructuredResult body {len(body)} != 46")
        return body + struct.pack("<H", crc16_ccitt_false(body))


def unpack_result(blob: bytes) -> ResultRec:
    if len(blob) != 48:
        raise ValueError("StructuredResult must be 48 bytes")
    body, crc = blob[:46], struct.unpack("<H", blob[46:])[0]
    if crc16_ccitt_false(body) != crc:
        raise ValueError("StructuredResult CRC mismatch")
    fields = struct.unpack("<HBBBBBBIHHIIIIIIIBB", body)
    magic = fields[0]
    if magic != MAGIC_RESULT:
        raise ValueError(f"bad result magic {magic:#x}")
    return ResultRec(
        abi_version=fields[1],
        status=fields[2],
        reason_code=fields[3],
        answer_kind=fields[4],
        completeness=fields[5],
        flags=fields[6],
        txn_id=fields[7],
        generation=fields[8],
        namespace_id=fields[9],
        answer_ref=fields[10],
        value_lo=fields[11],
        value_hi=fields[12],
        proof_ref=fields[13],
        provenance_ref=fields[14],
        context_ref=fields[15],
        conflict_ref=fields[16],
        answer_count=fields[17],
        payload_words=fields[18],
    )


# ---------------------------------------------------------------------------
# Store + §03.9 Q-eval
# ---------------------------------------------------------------------------

@dataclass
class Edge:
    edge_id: int
    subject: int
    relation: int
    obj: int
    context_id: int
    provenance_id: int
    proof_id: int
    epistemic: str
    generation: int = GENERATION_A
    answer_kind: int = KIND_ENTITY
    value_lo: int = 0
    value_hi: int = 0


@dataclass
class Store:
    edges: list[Edge] = field(default_factory=list)
    provenance_present: set[int] = field(default_factory=set)
    generation: int = GENERATION_A
    integrity_ok: bool = True
    reverse_legal: set[int] = field(default_factory=lambda: {REL_USES})
    fwd: dict = field(default_factory=dict)
    rev: dict = field(default_factory=dict)
    out: dict = field(default_factory=dict)

    def reindex(self) -> None:
        self.fwd = {}
        self.rev = {}
        self.out = {}
        for e in self.edges:
            self.fwd.setdefault((e.subject, e.relation), []).append(e)
            self.rev.setdefault((e.obj, e.relation), []).append(e)
            self.out.setdefault(e.subject, []).append(e)

    def clone(self) -> "Store":
        s = Store(
            edges=list(self.edges),
            provenance_present=set(self.provenance_present),
            generation=self.generation,
            integrity_ok=self.integrity_ok,
            reverse_legal=set(self.reverse_legal),
        )
        s.reindex()
        return s


def context_ok(edge: Edge, qctx: int) -> bool:
    if qctx == CTX_NONE:
        return edge.context_id == CTX_NONE
    return edge.context_id == qctx


def astra_qeval(store: Store, q: QueryRec) -> ResultRec:
    """§03.9 Q-eval: first matching guard wins."""
    base = dict(
        txn_id=q.txn_id,
        generation=store.generation,
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

    # Q-INT
    if not store.integrity_ok:
        return emit(ST_DATA_INTEGRITY_FAIL, RC_PACK_CRC)
    if q.generation not in (0, store.generation):
        return emit(ST_DATA_INTEGRITY_FAIL, RC_STALE_GENERATION)

    # Q-UNSUP
    if q.op_class == OP_UNSUPPORTED or q.relation_id == REL_UNSUPPORTED:
        return emit(ST_UNSUPPORTED_QUERY, RC_OPERATOR_UNIMPLEMENTED)
    if q.direction == DIR_REV and q.relation_id not in store.reverse_legal:
        return emit(ST_UNSUPPORTED_QUERY, RC_DIRECTION_ILLEGAL)

    # Q-INC-BUDGET before search
    if q.search_budget == 0:
        return emit(ST_SEARCH_INCOMPLETE, RC_BUDGET_EXHAUSTED)

    work = 0

    def charge() -> bool:
        nonlocal work
        work += 1
        return work > q.search_budget

    if q.op_class == OP_MULTIHOP or (q.flags & QFLAG_INFER_OK and q.max_hops > 1):
        return _eval_multihop(store, q, emit, charge)

    if q.direction == DIR_FWD:
        postings = list(store.fwd.get((q.subject_id, q.relation_id), []))
    else:
        postings = list(store.rev.get((q.subject_id, q.relation_id), []))

    hits: list[Edge] = []
    scoped_complete = True
    for e in postings:
        if charge():
            scoped_complete = False
            break
        if not context_ok(e, q.context_id):
            continue
        if q.object_valid:
            if e.answer_kind == KIND_RANGE:
                if not (e.value_lo <= q.object_ref <= e.value_hi):
                    continue
            elif e.obj != q.object_ref:
                continue
        hits.append(e)

    if not scoped_complete:
        return emit(ST_SEARCH_INCOMPLETE, RC_BUDGET_EXHAUSTED)

    return _finish_hits(store, q, hits, emit)


def _eval_multihop(store, q, emit, charge):
    # BFS over VERIFIED edges; last hop must match q.relation_id.
    frontier = [(q.subject_id, [], 0)]  # node, path edges, hops
    seen = {q.subject_id}
    found: list[list[Edge]] = []
    incomplete = False
    while frontier:
        node, path, hops = frontier.pop(0)
        if hops >= q.max_hops:
            continue
        for e in store.out.get(node, []):
            if charge():
                incomplete = True
                break
            if e.epistemic != EP_VERIFIED:
                continue
            if not context_ok(e, q.context_id):
                continue
            nxt_path = path + [e]
            if e.relation == q.relation_id:
                found.append(nxt_path)
            if e.obj not in seen:
                seen.add(e.obj)
                frontier.append((e.obj, nxt_path, hops + 1))
        if incomplete:
            break
    if incomplete:
        return emit(ST_SEARCH_INCOMPLETE, RC_BUDGET_EXHAUSTED)
    if not found:
        return emit(ST_UNKNOWN, RC_NO_VERIFIED_SUPPORT)
    # collapse by terminal object
    by_ans: dict[int, list[Edge]] = {}
    for p in found:
        by_ans.setdefault(p[-1].obj, p)
    if len(by_ans) > 1:
        keys = sorted(by_ans)
        return emit(
            ST_CONFLICT,
            RC_DISTINCT_VERIFIED_REFS,
            conflict_ref=keys[0] ^ keys[1] | 0x07000000,
            proof_ref=by_ans[keys[0]][-1].proof_id,
        )
    ans = next(iter(by_ans))
    path = by_ans[ans]
    last = path[-1]
    if (q.flags & QFLAG_PROV_REQ) and last.provenance_id not in store.provenance_present:
        return emit(ST_UNKNOWN, RC_PROVENANCE_MISSING)
    kind = last.answer_kind
    pid = path_proof("3H" if len(path) >= 3 else "2H", q.subject_id & 0xFF)
    return emit(
        ST_ANSWER,
        RC_VERIFIED_SUPPORT,
        answer_kind=kind,
        answer_ref=ans,
        proof_ref=pid,
        provenance_ref=last.provenance_id,
        value_lo=last.value_lo,
        value_hi=last.value_hi,
        completeness=CMPL_COMPLETE,
    )


def _finish_hits(store: Store, q: QueryRec, hits: list[Edge], emit):
    verified = [e for e in hits if e.epistemic == EP_VERIFIED]
    candidates = [e for e in hits if e.epistemic == EP_CANDIDATE]

    if (q.flags & QFLAG_PROV_REQ) and verified:
        kept = []
        missing = False
        for e in verified:
            if e.provenance_id in store.provenance_present:
                kept.append(e)
            else:
                missing = True
        if not kept and missing:
            return emit(ST_UNKNOWN, RC_PROVENANCE_MISSING)
        verified = kept

    if len(verified) >= 2:
        refs = {e.subject if q.direction == DIR_REV else e.obj for e in verified}
        if len(refs) > 1:
            groups = {id(e) for e in verified}
            cref = conflict_ref(min(e.edge_id for e in verified) & 0xFF)
            # stable conflict_ref from subjects
            vs = sorted(refs)
            cref = 0x070100 + (vs[0] & 0xFF)
            return emit(
                ST_CONFLICT,
                RC_DISTINCT_VERIFIED_REFS,
                conflict_ref=cref,
                proof_ref=verified[0].proof_id,
                provenance_ref=verified[0].provenance_id,
            )

    if verified:
        e = verified[0]
        answer = e.subject if q.direction == DIR_REV else e.obj
        if q.flags & QFLAG_PROOF_REQ and e.proof_id == 0:
            return emit(ST_UNKNOWN, RC_PROVENANCE_MISSING)
        return emit(
            ST_ANSWER,
            RC_VERIFIED_SUPPORT,
            answer_kind=e.answer_kind,
            answer_ref=answer,
            proof_ref=e.proof_id,
            provenance_ref=e.provenance_id,
            value_lo=e.value_lo,
            value_hi=e.value_hi,
            completeness=CMPL_COMPLETE,
        )

    if candidates and not verified:
        return emit(ST_UNKNOWN, RC_CANDIDATE_ONLY)

    if q.context_id != CTX_NONE:
        return emit(ST_UNKNOWN, RC_CONTEXT_INCOMPATIBLE)
    return emit(ST_UNKNOWN, RC_NO_VERIFIED_SUPPORT)


# ---------------------------------------------------------------------------
# Universe
# ---------------------------------------------------------------------------

def _add(store: Store, e: Edge) -> None:
    store.edges.append(e)
    if e.provenance_id:
        store.provenance_present.add(e.provenance_id)


def build_store_a() -> Store:
    s = Store(generation=GENERATION_A)
    eid = 1
    for i in range(48):
        _add(
            s,
            Edge(
                eid, mid(i), REL_USES, oid(i), CTX_NONE,
                prov_id(i), proof_id(i), EP_VERIFIED,
            ),
        )
        eid += 1
        _add(
            s,
            Edge(
                eid, oid(i), REL_PART_OF, fid(i), CTX_NONE,
                prov_id(100 + i), proof_id(100 + i), EP_VERIFIED,
            ),
        )
        eid += 1
    for f in range(8):
        _add(
            s,
            Edge(
                eid, family(f), REL_IS_A, ROOT, CTX_NONE,
                prov_id(200 + f), proof_id(200 + f), EP_VERIFIED,
            ),
        )
        eid += 1
        _add(
            s,
            Edge(
                eid, family(f), REL_USES, fam_obj(f), CTX_NONE,
                prov_id(210 + f), proof_id(210 + f), EP_VERIFIED,
            ),
        )
        eid += 1
    for i in range(12):
        _add(
            s,
            Edge(
                eid, mid(i), REL_USES, wall_oid(i), CTX_WALL,
                prov_id(300 + i), proof_id(300 + i), EP_VERIFIED,
            ),
        )
        eid += 1
        _add(
            s,
            Edge(
                eid, mid(i), REL_USES, duct_oid(i), CTX_DUCT,
                prov_id(320 + i), proof_id(320 + i), EP_VERIFIED,
            ),
        )
        eid += 1
    # VALUE mix: 12 range, 8 scalar, 4 enum, 4 unit, 4 boundary
    for i in range(12):
        _add(
            s,
            Edge(
                eid, mid(i), REL_HAS_RANGE, val_id(i), CTX_NONE,
                prov_id(400 + i), proof_id(400 + i), EP_VERIFIED,
                answer_kind=KIND_RANGE, value_lo=220 + i, value_hi=240 + i,
            ),
        )
        eid += 1
    for i in range(12, 20):
        _add(
            s,
            Edge(
                eid, mid(i), REL_HAS_VALUE, val_id(i), CTX_NONE,
                prov_id(400 + i), proof_id(400 + i), EP_VERIFIED,
                answer_kind=KIND_VALUE, value_lo=9000 + i, value_hi=0,
            ),
        )
        eid += 1
    for i in range(20, 24):
        _add(
            s,
            Edge(
                eid, mid(i), REL_HAS_VALUE, val_id(i), CTX_NONE,
                prov_id(400 + i), proof_id(400 + i), EP_VERIFIED,
                answer_kind=KIND_VALUE, value_lo=i - 19, value_hi=0,
            ),
        )
        eid += 1
    for i in range(24, 28):
        unit = 1 if i % 2 == 0 else 2
        _add(
            s,
            Edge(
                eid, mid(i), REL_HAS_VALUE, val_id(i), CTX_NONE,
                prov_id(400 + i), proof_id(400 + i), EP_VERIFIED,
                answer_kind=KIND_VALUE, value_lo=12000, value_hi=unit,
            ),
        )
        eid += 1
    for i in range(28, 32):
        _add(
            s,
            Edge(
                eid, mid(i), REL_HAS_RANGE, val_id(i), CTX_NONE,
                prov_id(400 + i), proof_id(400 + i), EP_VERIFIED,
                answer_kind=KIND_RANGE, value_lo=100, value_hi=100 + i,
            ),
        )
        eid += 1
    for i in range(16):
        _add(
            s,
            Edge(
                eid, mid(i), REL_RATED, rate_id(i), CTX_NONE,
                prov_id(500 + i), proof_id(500 + i), EP_VERIFIED,
            ),
        )
        eid += 1
    for i in range(16):
        _add(
            s,
            Edge(
                eid, conf_sub(i), REL_USES, conf_oa(i), CTX_NONE,
                prov_id(600 + i), proof_id(600 + i), EP_VERIFIED,
            ),
        )
        eid += 1
        _add(
            s,
            Edge(
                eid, conf_sub(i), REL_USES, conf_ob(i), CTX_NONE,
                prov_id(700 + i), proof_id(700 + i), EP_VERIFIED,
            ),
        )
        eid += 1
    for i in (10, 11):
        _add(
            s,
            Edge(
                eid, absent_id(i), REL_USES, oid(0), CTX_NONE,
                prov_id(800 + i), proof_id(800 + i), EP_CANDIDATE,
            ),
        )
        eid += 1
    s.reindex()
    return s


def build_store_b(a: Store) -> Store:
    b = a.clone()
    b.generation = GENERATION_B
    # remove global USES for models 16-19
    drop_models = {mid(i) for i in range(16, 20)}
    b.edges = [
        e
        for e in b.edges
        if not (e.relation == REL_USES and e.subject in drop_models and e.context_id == CTX_NONE)
    ]
    # mutate direction: drop FWD USES for models 20-23 (reverse lookup would also fail)
    drop_dir = {mid(i) for i in range(20, 24)}
    b.edges = [
        e
        for e in b.edges
        if not (e.relation == REL_USES and e.subject in drop_dir and e.context_id == CTX_NONE)
    ]
    # remove WALL edges models 0-3
    drop_wall = {mid(i) for i in range(0, 4)}
    b.edges = [
        e
        for e in b.edges
        if not (e.relation == REL_USES and e.subject in drop_wall and e.context_id == CTX_WALL)
    ]
    # remove provenance for RATED 0-3
    for i in range(4):
        b.provenance_present.discard(prov_id(500 + i))
    b.reindex()
    return b


# ---------------------------------------------------------------------------
# Case campaign
# ---------------------------------------------------------------------------

@dataclass
class Case:
    case_id: str
    group: str
    query: QueryRec
    pack: str  # A or B
    notes: str = ""
    alias: str = ""


def _q(**kw) -> QueryRec:
    return QueryRec(**kw)


def build_cases() -> list[Case]:
    cases: list[Case] = []
    txn = 1

    def add(group: str, q: QueryRec, pack: str = "A", notes: str = "", alias: str = "") -> None:
        nonlocal txn
        q.txn_id = txn
        seq = 1 + sum(1 for c in cases if c.group == group)
        cases.append(Case(f"{group}-{seq:03d}", group, q, pack, notes, alias))
        txn += 1

    for i in range(48):
        add(
            "FE-DIRECT",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=REL_USES,
                op_class=OP_DIRECT, max_hops=1, flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
            ),
            notes=f"global USES model {i}",
        )

    for i in range(32):
        rel = REL_HAS_RANGE if i < 12 or i >= 28 else REL_HAS_VALUE
        ov = i >= 28
        oref = 100 if ov else 0
        add(
            "FE-VALUE",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=rel,
                op_class=OP_VALUE, object_valid=ov, object_ref=oref,
                max_hops=1, qop=QOP_WHAT, flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
            ),
            notes="range" if rel == REL_HAS_RANGE else "scalar/enum/unit",
        )

    for i in range(32):
        add(
            "FE-REVERSE",
            _q(
                txn_id=0, subject_id=oid(i), relation_id=REL_USES,
                op_class=OP_REVERSE, direction=DIR_REV, max_hops=1,
                flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
            ),
            notes=f"reverse USES of object {i}",
        )

    for i in range(24):
        add(
            "FE-MULTIHOP",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=REL_PART_OF,
                op_class=OP_MULTIHOP, max_hops=2, search_budget=64,
                flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ | QFLAG_INFER_OK,
            ),
            notes="2-hop model-USES-obj-PART_OF-family",
        )
    for i in range(24, 32):
        add(
            "FE-MULTIHOP",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=REL_IS_A,
                op_class=OP_MULTIHOP, max_hops=3, search_budget=64,
                flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ | QFLAG_INFER_OK,
            ),
            notes="3-hop to ROOT via IS_A",
        )

    for i in range(6):
        add(
            "FE-CONTEXT",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=REL_USES,
                op_class=OP_CONTEXT, context_id=CTX_WALL, max_hops=1,
                flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
            ),
            notes="WALL contrast A",
        )
        add(
            "FE-CONTEXT",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=REL_USES,
                op_class=OP_CONTEXT, context_id=CTX_DUCT, max_hops=1,
                flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
            ),
            notes="DUCT contrast B (different answer)",
        )
    for i in range(6, 12):
        add(
            "FE-CONTEXT",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=REL_USES,
                op_class=OP_CONTEXT, context_id=CTX_WALL, max_hops=1,
                flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
            ),
            notes="WALL present",
        )
        add(
            "FE-CONTEXT",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=REL_USES,
                op_class=OP_CONTEXT, context_id=CTX_HEAT, max_hops=1,
                flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
            ),
            notes="HEAT absent → UNKNOWN",
        )

    for i in range(16):
        add(
            "FE-PROVENANCE",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=REL_RATED,
                op_class=OP_PROVENANCE, max_hops=1,
                flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
            ),
            notes=f"rated provenance {prov_id(500 + i):#x}",
        )

    for i in range(12):
        add(
            "FE-NEGATIVE",
            _q(
                txn_id=0, subject_id=absent_id(i), relation_id=REL_USES,
                op_class=OP_DIRECT, max_hops=1,
                flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
            ),
            notes="CANDIDATE-only" if i >= 10 else "known node, absent verified USES",
        )
    for i in range(4):
        add(
            "FE-NEGATIVE",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=REL_UNSUPPORTED,
                op_class=OP_UNSUPPORTED, max_hops=1, flags=0,
            ),
            notes="unsupported relation/op",
        )
    for i in range(24, 28):
        add(
            "FE-NEGATIVE",
            _q(
                txn_id=0, subject_id=mid(i), relation_id=REL_PART_OF,
                op_class=OP_MULTIHOP, max_hops=2, search_budget=1,
                flags=QFLAG_PROOF_REQ | QFLAG_INFER_OK,
            ),
            notes="budget=1 on 2-hop → SEARCH_INCOMPLETE",
        )
    for i in range(4):
        add(
            "FE-NEGATIVE",
            _q(
                txn_id=0, subject_id=rate_id(i), relation_id=REL_RATED,
                op_class=OP_REVERSE, direction=DIR_REV, max_hops=1, flags=0,
            ),
            notes="REV on RATED is not reverse-legal",
        )

    for i in range(16):
        add(
            "FE-CONFLICT",
            _q(
                txn_id=0, subject_id=conf_sub(i), relation_id=REL_USES,
                op_class=OP_DIRECT, max_hops=1,
                flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
            ),
            notes="two verified USES objects",
        )

    for i in range(32, 36):
        add("FE-IDENTITY", _q(
            txn_id=0, subject_id=mid(i), relation_id=REL_USES,
            op_class=OP_IDENTITY, max_hops=1,
            flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
        ), notes="alias A → canonical", alias="alias-A")
        add("FE-IDENTITY", _q(
            txn_id=0, subject_id=mid(i), relation_id=REL_USES,
            op_class=OP_IDENTITY, max_hops=1,
            flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
        ), notes="alias B → same canonical", alias="alias-B")
    for f in range(2):
        add("FE-IDENTITY", _q(
            txn_id=0, subject_id=mid(f * 6), relation_id=REL_USES,
            op_class=OP_IDENTITY, max_hops=1,
            flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
        ), notes="exact model, not family")
        add("FE-IDENTITY", _q(
            txn_id=0, subject_id=family(f), relation_id=REL_USES,
            op_class=OP_IDENTITY, max_hops=1,
            flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
        ), notes="family USES ≠ child model object")
    add("FE-IDENTITY", _q(
        txn_id=0, subject_id=mid(36), relation_id=REL_USES,
        op_class=OP_IDENTITY, max_hops=1,
        flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
    ), notes="sibling A")
    add("FE-IDENTITY", _q(
        txn_id=0, subject_id=mid(37), relation_id=REL_USES,
        op_class=OP_IDENTITY, max_hops=1,
        flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
    ), notes="sibling B isolation")
    add("FE-IDENTITY", _q(
        txn_id=0, subject_id=mid(38), relation_id=REL_USES,
        op_class=OP_IDENTITY, max_hops=1,
        flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
    ), notes="sibling C")
    add("FE-IDENTITY", _q(
        txn_id=0, subject_id=mid(39), relation_id=REL_USES,
        op_class=OP_IDENTITY, max_hops=1,
        flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
    ), notes="sibling D isolation")

    for i in range(16, 20):
        add("FE-ABLATION", _q(
            txn_id=0, subject_id=mid(i), relation_id=REL_USES,
            op_class=OP_DIRECT, generation=GENERATION_B, max_hops=1,
            flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
        ), pack="B", notes="Pack-B removed global USES")
    for i in range(20, 24):
        add("FE-ABLATION", _q(
            txn_id=0, subject_id=mid(i), relation_id=REL_USES,
            op_class=OP_DIRECT, generation=GENERATION_B, max_hops=1,
            flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
        ), pack="B", notes="Pack-B mutated/removed FWD USES")
    for i in range(4):
        add("FE-ABLATION", _q(
            txn_id=0, subject_id=mid(i), relation_id=REL_USES,
            op_class=OP_CONTEXT, context_id=CTX_WALL, generation=GENERATION_B,
            max_hops=1, flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
        ), pack="B", notes="Pack-B removed WALL edge")
    for i in range(4):
        add("FE-ABLATION", _q(
            txn_id=0, subject_id=mid(i), relation_id=REL_RATED,
            op_class=OP_PROVENANCE, generation=GENERATION_B, max_hops=1,
            flags=QFLAG_PROOF_REQ | QFLAG_PROV_REQ,
        ), pack="B", notes="Pack-B dropped provenance for RATED")

    return cases


def evaluate_campaign(cases: list[Case]) -> tuple[Store, Store, list[tuple[Case, ResultRec, bytes, bytes]]]:
    a = build_store_a()
    b = build_store_b(a)
    out = []
    for c in cases:
        store = a if c.pack == "A" else b
        r = astra_qeval(store, c.query)
        qb, rb = c.query.pack(), r.pack()
        if unpack_query(qb).txn_id != c.query.txn_id:
            raise RuntimeError("query roundtrip failed")
        if unpack_result(rb).status != r.status:
            raise RuntimeError("result roundtrip failed")
        out.append((c, r, qb, rb))
    return a, b, out


def class_policy_errors(rows: list[tuple[Case, ResultRec, bytes, bytes]]) -> list[str]:
    err = []
    by = {}
    for c, r, _, _ in rows:
        by.setdefault(c.group, []).append((c, r))
    for g, n in CLASS_COUNTS.items():
        got = len(by.get(g, []))
        if got != n:
            err.append(f"count {g}: {got} != {n}")
    if len(rows) != 256:
        err.append(f"total {len(rows)} != 256")

    def statuses(g):
        return [r.status for _, r in by.get(g, [])]

    if any(s != ST_ANSWER for s in statuses("FE-DIRECT")):
        err.append("FE-DIRECT must all be ANSWER")
    if any(s != ST_ANSWER for s in statuses("FE-VALUE")):
        err.append("FE-VALUE must all be ANSWER")
    if any(s != ST_ANSWER for s in statuses("FE-REVERSE")):
        err.append("FE-REVERSE must all be ANSWER")
    if any(s != ST_ANSWER for s in statuses("FE-MULTIHOP")):
        err.append("FE-MULTIHOP must all be ANSWER")
    if any(s != ST_ANSWER for s in statuses("FE-PROVENANCE")):
        err.append("FE-PROVENANCE must all be ANSWER")
    if any(s != ST_CONFLICT for s in statuses("FE-CONFLICT")):
        err.append("FE-CONFLICT must all be CONFLICT")
    if any(r.conflict_ref == 0 for _, r in by.get("FE-CONFLICT", [])):
        err.append("FE-CONFLICT conflict_ref must be non-zero")
    if any(r.reason_code != RC_DISTINCT_VERIFIED_REFS for _, r in by.get("FE-CONFLICT", [])):
        err.append("FE-CONFLICT reason must be DISTINCT_VERIFIED_REFS")

    ctx_st = statuses("FE-CONTEXT")
    if ctx_st.count(ST_ANSWER) < 12:
        err.append("FE-CONTEXT needs ≥12 ANSWER")
    if ST_UNKNOWN not in ctx_st:
        err.append("FE-CONTEXT needs UNKNOWN contrast")

    neg = by.get("FE-NEGATIVE", [])
    if any(r.status == ST_ANSWER for _, r in neg):
        err.append("FE-NEGATIVE must not ANSWER")
    if sum(1 for _, r in neg if r.status == ST_UNKNOWN) != 12:
        err.append("FE-NEGATIVE must contain 12 UNKNOWN")
    if sum(1 for _, r in neg if r.status == ST_UNSUPPORTED_QUERY) != 8:
        # 4 unsupported op + 4 illegal reverse
        err.append("FE-NEGATIVE must contain 8 UNSUPPORTED_QUERY (4 op + 4 direction)")
    if sum(1 for _, r in neg if r.status == ST_SEARCH_INCOMPLETE) != 4:
        err.append("FE-NEGATIVE must contain 4 SEARCH_INCOMPLETE")
    if any(r.status == ST_UNKNOWN and r.reason_code == RC_BUDGET_EXHAUSTED for _, r in neg):
        err.append("budget abort must not be UNKNOWN")

    abl = by.get("FE-ABLATION", [])
    if any(r.status == ST_ANSWER for _, r in abl):
        err.append("FE-ABLATION Pack-B must not keep Pack-A ANSWER")

    idn = by.get("FE-IDENTITY", [])
    if any(r.status != ST_ANSWER for _, r in idn):
        err.append("FE-IDENTITY queries must ANSWER")
    alias_pairs = {}
    for c, r in idn:
        if c.alias:
            alias_pairs.setdefault(c.query.subject_id, []).append(r.answer_ref)
    for sub, refs in alias_pairs.items():
        if len(set(refs)) != 1:
            err.append(f"alias pair subject {sub:#x} leaked identity")

    fam0 = None
    model0 = None
    for c, r in idn:
        if c.notes == "family USES ≠ child model object":
            fam0 = r.answer_ref
        if c.notes == "exact model, not family" and c.query.subject_id == mid(0):
            model0 = r.answer_ref
    if fam0 is not None and model0 is not None and fam0 == model0:
        err.append("family/model identity collapse")

    sib = {c.query.subject_id: r.answer_ref for c, r in idn if "sibling" in c.notes}
    if len(set(sib.values())) != len(sib):
        err.append("sibling models collapsed to one answer")

    for c, r, qb, rb in rows:
        if r.status == 0:
            err.append(f"{c.case_id} illegal status 0")
        if r.status in REASON_NEVER_STATUS:
            err.append(f"{c.case_id} reason byte {r.status:#x} used as status")
        if r.status not in PRIMARY_ASTRA_STATUS:
            err.append(f"{c.case_id} status {r.status:#x} outside primary ASTRA namespace")
        if r.status == ST_ANSWER and r.proof_ref == 0:
            err.append(f"{c.case_id} ANSWER missing proof_ref")
        if r.status == ST_ANSWER and r.answer_kind == KIND_NONE:
            err.append(f"{c.case_id} ANSWER kind NONE")
        if r.status == ST_SEARCH_INCOMPLETE and r.completeness != CMPL_PARTIAL:
            err.append(f"{c.case_id} INCOMPLETE not PARTIAL")
        if r.status == ST_ANSWER and r.completeness == CMPL_PARTIAL:
            err.append(f"{c.case_id} ANSWER after incomplete")
        if r.status == ST_CONFLICT and r.completeness != CMPL_COMPLETE:
            err.append(f"{c.case_id} CONFLICT without complete scope")
        if r.status == ST_PARSE_ERROR:
            err.append(f"{c.case_id} FPGA gold emitted PARSE_ERROR")
        if len(qb) != 32 or len(rb) != 48:
            err.append(f"{c.case_id} bad packed sizes")
        if unpack_result(rb).txn_id != c.query.txn_id:
            err.append(f"{c.case_id} txn mismatch")
    return err


def shuffle_indices(n: int = 256, seed: int = SHUFFLE_SEED) -> list[int]:
    idx = list(range(n))
    rng = random.Random(seed)
    rng.shuffle(idx)
    return idx


def sha256_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def emit_svh(path: Path) -> None:
    path.write_text(
        """// Auto-generated by fe256_gold.py — XSim testbench constants. Not RTL design.
// AGENT_B verification artifact. PROGRAM=NO.
`ifndef FE256_ABI_CONSTANTS_SVH
`define FE256_ABI_CONSTANTS_SVH
localparam [15:0] FE256_MAGIC_QUERY  = 16'h4E51;
localparam [15:0] FE256_MAGIC_RESULT = 16'h4E52;
localparam [7:0]  FE256_ABI_VERSION  = 8'h01;
localparam [7:0]  FE256_ST_ANSWER = 8'h01;
localparam [7:0]  FE256_ST_UNKNOWN = 8'h02;
localparam [7:0]  FE256_ST_CONFLICT = 8'h03;
localparam [7:0]  FE256_ST_SEARCH_INCOMPLETE = 8'h04;
localparam [7:0]  FE256_ST_UNSUPPORTED_QUERY = 8'h05;
localparam [7:0]  FE256_ST_DATA_INTEGRITY_FAIL = 8'h06;
// Reason codes (not status): TIE_OVERFLOW=8'h22 K_INVALID=8'h23
// INVALID_DESCRIPTOR=8'h55 COMMITTED_CORRUPT=8'h56
localparam integer FE256_N_CASES = 256;
localparam integer FE256_QUERY_BYTES = 32;
localparam integer FE256_RESULT_BYTES = 48;
`endif
""",
        encoding="utf-8",
    )


def emit_artifacts(out_dir: Path, rows, store_a: Store) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    qbin = b"".join(qb for _, _, qb, _ in rows)
    rbin = b"".join(rb for _, _, _, rb in rows)
    (out_dir / "fe256_queries.bin").write_bytes(qbin)
    (out_dir / "fe256_gold_results.bin").write_bytes(rbin)
    qhex = "\n".join(qb.hex() for _, _, qb, _ in rows) + "\n"
    rhex = "\n".join(rb.hex() for _, _, _, rb in rows) + "\n"
    (out_dir / "fe256_queries.hex").write_text(qhex, encoding="ascii")
    (out_dir / "fe256_gold_results.hex").write_text(rhex, encoding="ascii")

    jsonl = out_dir / "fe256_cases.jsonl"
    with jsonl.open("w", encoding="utf-8") as f:
        for c, r, qb, rb in rows:
            rec = {
                "case_id": c.case_id,
                "group": c.group,
                "pack": c.pack,
                "notes": c.notes,
                "alias": c.alias,
                "query": {
                    "txn_id": c.query.txn_id,
                    "subject_id": c.query.subject_id,
                    "relation_id": c.query.relation_id,
                    "object_ref": c.query.object_ref,
                    "object_valid": c.query.object_valid,
                    "context_id": c.query.context_id,
                    "direction": "REV" if c.query.direction == DIR_REV else "FWD",
                    "op_class": c.query.op_class,
                    "max_hops": c.query.max_hops,
                    "search_budget": c.query.search_budget,
                    "generation": c.query.generation,
                    "flags": c.query.flags,
                },
                "expected": {
                    "status": STATUS_NAME[r.status],
                    "status_u8": r.status,
                    "reason_code": r.reason_code,
                    "answer_kind": r.answer_kind,
                    "completeness": r.completeness,
                    "answer_ref": r.answer_ref,
                    "value_lo": r.value_lo,
                    "value_hi": r.value_hi,
                    "proof_ref": r.proof_ref,
                    "provenance_ref": r.provenance_ref,
                    "conflict_ref": r.conflict_ref,
                    "txn_id": r.txn_id,
                },
                "query_hex": qb.hex(),
                "result_hex": rb.hex(),
            }
            f.write(json.dumps(rec, sort_keys=True, separators=(",", ":")) + "\n")

    pack_src = out_dir / "fe256_pack_source.jsonl"
    with pack_src.open("w", encoding="utf-8") as f:
        for e in store_a.edges:
            f.write(
                json.dumps(
                    {
                        "edge_id": e.edge_id,
                        "subject_id": e.subject,
                        "relation_id": e.relation,
                        "object_ref": e.obj,
                        "context_id": e.context_id,
                        "provenance_id": e.provenance_id,
                        "proof_id": e.proof_id,
                        "epistemic": e.epistemic,
                        "answer_kind": e.answer_kind,
                        "value_lo": e.value_lo,
                        "value_hi": e.value_hi,
                    },
                    sort_keys=True,
                    separators=(",", ":"),
                )
                + "\n"
            )

    order = shuffle_indices(len(rows))
    (out_dir / "fe256_shuffle_order.json").write_text(
        json.dumps({"seed": SHUFFLE_SEED, "order": order}, indent=2) + "\n",
        encoding="utf-8",
    )
    emit_svh(out_dir / "fe256_abi_constants.svh")

    counts = {}
    for c, _, _, _ in rows:
        counts[c.group] = counts.get(c.group, 0) + 1
    manifest = {
        "spec": GOLD_SPEC,
        "n_cases": len(rows),
        "class_counts": counts,
        "queries_sha256": sha256_bytes(qbin),
        "results_sha256": sha256_bytes(rbin),
        "queries_bytes": len(qbin),
        "results_bytes": len(rbin),
        "endianness": "little",
        "crc": "CRC16-CCITT-FALSE poly=0x1021 init=0xFFFF xorout=0",
        "magic_query": hex(MAGIC_QUERY),
        "magic_result": hex(MAGIC_RESULT),
        "shuffle_seed": hex(SHUFFLE_SEED),
        "note": "XSim must match fe256_gold_results.bin bit-exact. BOARD_PASS is not implied.",
    }
    (out_dir / "fe256_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return manifest


def selfcheck(rows) -> list[str]:
    return class_policy_errors(rows)


def compare_packed(got: bytes, exp: bytes) -> list[str]:
    diffs = []
    if len(got) != len(exp):
        return [f"length {len(got)} != {len(exp)}"]
    if got == exp:
        return []
    ge, ee = unpack_result(got), unpack_result(exp)
    for name in (
        "status", "reason_code", "answer_kind", "completeness", "flags",
        "txn_id", "generation", "answer_ref", "value_lo", "value_hi",
        "proof_ref", "provenance_ref", "conflict_ref",
    ):
        gv, ev = getattr(ge, name), getattr(ee, name)
        if gv != ev:
            diffs.append(f"{name}: got {gv} expected {ev}")
    if not diffs:
        diffs.append("CRC or reserved field mismatch")
    return diffs


def main(argv: Iterable[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="FE256 R0.1 Python gold reference (AGENT_B)")
    ap.add_argument("--emit", type=Path, default=None, help="output directory")
    ap.add_argument("--selfcheck", action="store_true", help="run gold invariants")
    ap.add_argument("--compare", type=Path, default=None, help="DUT results.bin to compare")
    args = ap.parse_args(list(argv) if argv is not None else None)

    cases = build_cases()
    store_a, store_b, rows = evaluate_campaign(cases)
    errors = selfcheck(rows) if (args.selfcheck or args.emit or args.compare is None) else []

    if args.emit:
        man = emit_artifacts(args.emit, rows, store_a)
        print(json.dumps(man, indent=2))

    if args.compare:
        dut = args.compare.read_bytes()
        gold = b"".join(rb for _, _, _, rb in rows)
        if len(dut) != len(gold):
            print(f"DUT length {len(dut)} != gold {len(gold)}", file=sys.stderr)
            return 2
        nfail = 0
        for i in range(256):
            d = compare_packed(dut[i * 48 : (i + 1) * 48], gold[i * 48 : (i + 1) * 48])
            if d:
                nfail += 1
                print(f"FAIL {rows[i][0].case_id}: {d}")
        print(f"compare {256 - nfail}/256 match, {nfail} fail")
        if nfail:
            errors.append("DUT mismatch")

    if errors:
        print("SELFCHECK FAIL:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    if args.selfcheck or not args.emit:
        print(f"SELFCHECK PASS: {len(rows)}/256 gold records, class counts locked")
    return 0


if __name__ == "__main__":
    sys.exit(main())
