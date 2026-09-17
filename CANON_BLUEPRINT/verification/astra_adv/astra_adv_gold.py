#!/usr/bin/env python3
"""ASTRA adversarial / status-proof Q-eval gold — AGENT_B.

Independent of python/m1/pack_vectors.py and of verification/fe256/fe256_gold.py.
Does not score DUT RTL. --selfcheck is generator hygiene, not a ladder stamp
(not ASTRA_ADV_PASS, FE256_PASS, PACK_ABI_24_24_PASS, BOARD_PASS, FINAL_PASS).

Canon: [§03.9] Q-eval; [§04.12] encodings; [§31.11] case IDs.
XSim harness: verification/astra_adv/tb_astra_adv_xsim_compare.sv (PROGRAM=NO).

Primary status namespace (StructuredResult.status only):
  0x00 illegal / PROTOCOL_FAULT
  0x01 ANSWER
  0x02 UNKNOWN
  0x03 CONFLICT
  0x04 SEARCH_INCOMPLETE
  0x05 UNSUPPORTED_QUERY
  0x06 DATA_INTEGRITY_FAIL
  0x80 PARSE_ERROR adapter-only

reason_code is a separate field. TIE_OVERFLOW 0x22, K_INVALID 0x23,
INVALID_DESCRIPTOR 0x55, and COMMITTED_CORRUPT 0x56 are never status bytes.

Usage:
  python astra_adv_gold.py --selfcheck
  python astra_adv_gold.py --selfcheck --emit out
  python astra_adv_gold.py --compare DUT.jsonl
"""

from __future__ import annotations

import argparse
import ast
import json
import struct
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

MAGIC_QUERY = 0x4E51
MAGIC_RESULT = 0x4E52
ABI_VERSION = 0x01
NAMESPACE = 0x0001
GENERATION = 0x0001

ST_ANSWER = 0x01
ST_UNKNOWN = 0x02
ST_CONFLICT = 0x03
ST_SEARCH_INCOMPLETE = 0x04
ST_UNSUPPORTED_QUERY = 0x05
ST_DATA_INTEGRITY_FAIL = 0x06
ST_PARSE_ERROR = 0x80

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

ILLEGAL_FPGA_STATUS = frozenset({0x00, 0x22, 0x23, 0x55, 0x56, 0x80})

RC_NONE = 0x00
RC_VERIFIED_SUPPORT = 0x01
RC_NO_VERIFIED_SUPPORT = 0x10
RC_CANDIDATE_ONLY = 0x11
RC_BUDGET_EXHAUSTED = 0x20
RC_TIE_OVERFLOW = 0x22
RC_K_INVALID = 0x23
RC_DISTINCT_VERIFIED_REFS = 0x30
RC_OPERATOR_UNIMPLEMENTED = 0x40
RC_PACK_CRC = 0x50
RC_STALE_GENERATION = 0x54
RC_INVALID_DESCRIPTOR = 0x55
RC_COMMITTED_CORRUPT = 0x56
RC_PROVENANCE_MISSING = 0x61

REASON_NEVER_STATUS = frozenset(
    {
        RC_NO_VERIFIED_SUPPORT,
        RC_CANDIDATE_ONLY,
        RC_BUDGET_EXHAUSTED,
        RC_TIE_OVERFLOW,
        RC_K_INVALID,
        RC_DISTINCT_VERIFIED_REFS,
        RC_OPERATOR_UNIMPLEMENTED,
        RC_PACK_CRC,
        RC_STALE_GENERATION,
        RC_INVALID_DESCRIPTOR,
        RC_COMMITTED_CORRUPT,
        RC_PROVENANCE_MISSING,
    }
)

KIND_NONE = 0x00
KIND_ENTITY = 0x01
CMPL_NA = 0x00
CMPL_COMPLETE = 0x01
CMPL_PARTIAL = 0x02

RFLAG_HAS_PROOF = 1 << 0
RFLAG_HAS_CONFLICT = 1 << 2
QFLAG_PROOF_REQ = 1 << 0

MODE_COMPARE = 0
MODE_CLASSIFY = 1
MODE_PROTOCOL = 2
MODE_REWARD = 3

STATUS_NAME = {
    ST_ANSWER: "ANSWER",
    ST_UNKNOWN: "UNKNOWN",
    ST_CONFLICT: "CONFLICT",
    ST_SEARCH_INCOMPLETE: "SEARCH_INCOMPLETE",
    ST_UNSUPPORTED_QUERY: "UNSUPPORTED_QUERY",
    ST_DATA_INTEGRITY_FAIL: "DATA_INTEGRITY_FAIL",
    ST_PARSE_ERROR: "PARSE_ERROR",
}

GOLD_SPEC = "ASTRA_ADV_QEVAL_R0_1_B_RUNTIME_LAW_01"
# First 11 IDs are locked coverage. Prior 17 retained. New IDs append only.
LOCKED_CASE_IDS = (
    "AA-ILLEGAL-00",
    "AA-NS-ST22",
    "AA-NS-ST55",
    "AA-TIE-01",
    "AA-DESC-01",
    "AA-ANS-PROOF0",
    "AA-INC-BUDGET",
    "AA-UNK-ABSENT",
    "AA-CONFLICT-01",
    "AA-ANS-DIAMOND",
    "AA-CAND-01",
    "AA-NS-ST80",
    "AA-TXN-ECHO",
    "AA-QTRUNC-01",
    "AA-QCRC-01",
    "AA-STALE-GEN",
    "AA-PROTO-01",
    "AA-REW-DUP",
    "AA-REW-ID",
    "AA-KINV-01",
    "AA-FEM-CRC",
)

LOCKED_PREFIX_11 = LOCKED_CASE_IDS[:11]
LOCKED_PREFIX_17 = LOCKED_CASE_IDS[:17]


def crc16_ccitt_false(data: bytes) -> int:
    """CRC16-CCITT-FALSE [§04.12]. Local copy; do not import fe256_gold."""
    c = 0xFFFF
    for b in data:
        c ^= b << 8
        for _ in range(8):
            c = ((c << 1) ^ 0x1021) & 0xFFFF if c & 0x8000 else (c << 1) & 0xFFFF
    return c


def classify_status(status: int) -> str:
    """Host/wire classifier. Does not coerce illegal status to UNKNOWN."""
    if status == 0x00:
        return "PROTOCOL_FAULT"
    if status == ST_PARSE_ERROR:
        return "ADAPTER_ONLY"
    if status in REASON_NEVER_STATUS:
        return "ILLEGAL_STATUS_REASON_COLLISION"
    if status in PRIMARY_ASTRA_STATUS:
        return "ASTRA_STATUS"
    return "ILLEGAL_STATUS"


def status_namespace_ok(status: int) -> bool:
    return status in PRIMARY_ASTRA_STATUS


def pack_query(
    txn_id: int,
    generation: int = GENERATION,
    namespace_id: int = NAMESPACE,
    subject_id: int = 0x010100,
    relation_id: int = 0x0001,
    object_ref: int = 0,
    context_id: int = 0,
    search_budget: int = 64,
    flags: int = QFLAG_PROOF_REQ,
    query_meta: int = 0,
    crc_ok: bool = True,
    truncate_to: int | None = None,
) -> bytes:
    """Local QueryRecord packer. Do not import fe256_gold or pack_vectors."""
    body = struct.pack(
        "<HBBIHHHIHIIH",
        MAGIC_QUERY,
        ABI_VERSION,
        flags,
        txn_id,
        generation,
        namespace_id,
        query_meta,
        subject_id,
        relation_id,
        object_ref,
        context_id,
        search_budget,
    )
    if len(body) != 30:
        raise RuntimeError(f"QueryRecord body {len(body)} != 30")
    crc = crc16_ccitt_false(body)
    if not crc_ok:
        crc ^= 0xFFFF
    blob = body + struct.pack("<H", crc)
    if truncate_to is not None:
        blob = blob[:truncate_to]
    return blob


def blob_to_mem_lines(blob: bytes) -> list[str]:
    words = blob + (b"\x00" * ((-len(blob)) % 4))
    lines = [f"{len(words) // 4:08x}"]
    for i in range(0, len(words), 4):
        lines.append(f"{struct.unpack_from('<I', words, i)[0]:08x}")
    return lines


@dataclass(frozen=True)
class Obs:
    integrity_ok: bool = True
    invalid_count: int | None = 0
    tie_overflow: bool | None = False
    unsupported: bool = False
    budget_exhausted: bool = False
    scope_complete: bool = True
    verified_pairs: tuple[tuple[int, int], ...] = ()
    candidate_only: bool = False
    proof_ref: int = 0
    conflict_ref: int = 0
    txn_id: int = 1
    query_generation: int = GENERATION
    active_generation: int = GENERATION
    protocol_fault: bool = False
    query_truncated: bool = False
    query_crc_ok: bool = True
    k_invalid: bool | None = False
    committed_corrupt: bool = False
    integrity_fault: bool = False


REW_ACCEPTED = "ACCEPTED"
REW_DUPLICATE = "DUPLICATE"
REW_IDENTITY_MISMATCH = "IDENTITY_MISMATCH"
REW_NO_PENDING = "NO_PENDING"
REW_NOT_EXECUTED = "NOT_EXECUTED"
REW_EFFECT_UNOBSERVED = "EFFECT_UNOBSERVED"
REW_SOURCE_ILLEGAL = "SOURCE_ILLEGAL"
REW_EXAM_FROZEN = "EXAM_FROZEN"
REW_OVERWRITE_REFUSED = "OVERWRITE_REFUSED"


@dataclass(frozen=True)
class CausalId:
    episode_id: int
    step_id: int
    command_id: int
    generation: int


@dataclass(frozen=True)
class RewardObs:
    pending: CausalId | None
    executed: CausalId | None
    effect: CausalId | None
    exec_valid: bool = False
    effect_accepted: bool = False
    reward_source_legal: bool = False
    exam: bool = False
    already_credited: bool = False
    overwrite_attempt: bool = False


@dataclass(frozen=True)
class RewardDecision:
    reward_accepted: bool
    learner_update: bool
    reason: str


def causal_eq(a: CausalId | None, b: CausalId | None) -> bool:
    if a is None or b is None:
        return False
    return (
        a.episode_id == b.episode_id
        and a.step_id == b.step_id
        and a.command_id == b.command_id
        and a.generation == b.generation
    )


def reward_gate(obs: RewardObs) -> RewardDecision:
    """B-01 Reward Gate. Independent of Q*/SPEAR/FEM DUT helpers."""
    if obs.overwrite_attempt:
        return RewardDecision(False, False, REW_OVERWRITE_REFUSED)
    if obs.exam:
        return RewardDecision(False, False, REW_EXAM_FROZEN)
    if obs.pending is None:
        return RewardDecision(False, False, REW_NO_PENDING)
    if not causal_eq(obs.pending, obs.executed) or not causal_eq(obs.pending, obs.effect):
        return RewardDecision(False, False, REW_IDENTITY_MISMATCH)
    if not obs.exec_valid:
        return RewardDecision(False, False, REW_NOT_EXECUTED)
    if not obs.effect_accepted:
        return RewardDecision(False, False, REW_EFFECT_UNOBSERVED)
    if not obs.reward_source_legal:
        return RewardDecision(False, False, REW_SOURCE_ILLEGAL)
    if obs.already_credited:
        return RewardDecision(False, False, REW_DUPLICATE)
    return RewardDecision(True, True, REW_ACCEPTED)


def reward_sequence(first: RewardObs, second: RewardObs | None = None) -> list[RewardDecision]:
    first_dec = reward_gate(first)
    out = [first_dec]
    if second is None:
        return out
    already = first_dec.learner_update and causal_eq(first.pending, second.pending)
    out.append(
        reward_gate(
            RewardObs(
                pending=second.pending,
                executed=second.executed,
                effect=second.effect,
                exec_valid=second.exec_valid,
                effect_accepted=second.effect_accepted,
                reward_source_legal=second.reward_source_legal,
                exam=second.exam,
                already_credited=second.already_credited or already,
                overwrite_attempt=second.overwrite_attempt,
            )
        )
    )
    return out


@dataclass
class ResultRec:
    txn_id: int
    status: int
    reason_code: int = RC_NONE
    answer_kind: int = KIND_NONE
    completeness: int = CMPL_COMPLETE
    flags: int = 0
    generation: int = GENERATION
    namespace_id: int = NAMESPACE
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
    if fields[0] != MAGIC_RESULT:
        raise ValueError(f"bad result magic {fields[0]:#x}")
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


def qeval(obs: Obs) -> ResultRec:
    """§03.9 first-match Q-eval over explicit observables (not a graph store)."""

    def emit(status: int, reason: int, **kw) -> ResultRec:
        d = {
            "txn_id": obs.txn_id,
            "generation": obs.active_generation,
            "namespace_id": NAMESPACE,
            "status": status,
            "reason_code": reason,
            "answer_kind": KIND_NONE,
            "proof_ref": 0,
            "conflict_ref": 0,
            "answer_ref": 0,
            "flags": 0,
            "answer_count": 0,
        }
        if status == ST_ANSWER:
            d["completeness"] = CMPL_COMPLETE
            d["answer_count"] = 1
        elif status == ST_SEARCH_INCOMPLETE:
            d["completeness"] = CMPL_PARTIAL
        elif status in (ST_CONFLICT, ST_UNKNOWN):
            d["completeness"] = CMPL_COMPLETE
        else:
            d["completeness"] = CMPL_NA
        d.update(kw)
        if status == ST_SEARCH_INCOMPLETE:
            d["answer_kind"] = KIND_NONE
            d["proof_ref"] = 0
            d["conflict_ref"] = 0
            d["completeness"] = CMPL_PARTIAL
        elif status == ST_ANSWER:
            flags = int(d.get("flags", 0))
            if d.get("proof_ref"):
                flags |= RFLAG_HAS_PROOF
            d["flags"] = flags
        elif status == ST_CONFLICT:
            d["answer_kind"] = KIND_NONE
            d["completeness"] = CMPL_COMPLETE
            flags = int(d.get("flags", 0))
            if d.get("conflict_ref"):
                flags |= RFLAG_HAS_CONFLICT
            d["flags"] = flags
        elif status == ST_UNKNOWN:
            d["answer_kind"] = KIND_NONE
            d["completeness"] = CMPL_COMPLETE
        return ResultRec(**d)

    # Protocol / query-frame faults first. Never UNKNOWN [§03.9] [§04.11].
    if obs.protocol_fault:
        return emit(ST_DATA_INTEGRITY_FAIL, RC_PACK_CRC)
    if obs.query_truncated or obs.query_crc_ok is False:
        return emit(ST_DATA_INTEGRITY_FAIL, RC_INVALID_DESCRIPTOR)
    if not obs.integrity_ok:
        return emit(ST_DATA_INTEGRITY_FAIL, RC_PACK_CRC)
    if obs.query_generation not in (0, obs.active_generation):
        return emit(ST_DATA_INTEGRITY_FAIL, RC_STALE_GENERATION)
    if obs.k_invalid is True:
        return emit(ST_DATA_INTEGRITY_FAIL, RC_K_INVALID)
    if obs.invalid_count is not None and obs.invalid_count > 0:
        return emit(ST_DATA_INTEGRITY_FAIL, RC_INVALID_DESCRIPTOR)
    if obs.committed_corrupt or obs.integrity_fault:
        return emit(ST_DATA_INTEGRITY_FAIL, RC_COMMITTED_CORRUPT)
    if obs.unsupported:
        return emit(ST_UNSUPPORTED_QUERY, RC_OPERATOR_UNIMPLEMENTED)
    if obs.tie_overflow is True:
        return emit(ST_SEARCH_INCOMPLETE, RC_TIE_OVERFLOW)
    if obs.budget_exhausted or not obs.scope_complete:
        return emit(ST_SEARCH_INCOMPLETE, RC_BUDGET_EXHAUSTED)

    distinct_refs = {ref for ref, _val in obs.verified_pairs}
    if len(distinct_refs) >= 2:
        cref = obs.conflict_ref if obs.conflict_ref else 0x070100
        return emit(
            ST_CONFLICT,
            RC_DISTINCT_VERIFIED_REFS,
            conflict_ref=cref,
        )
    if len(distinct_refs) == 1:
        aref = next(iter(distinct_refs))
        if obs.proof_ref == 0:
            return emit(ST_UNKNOWN, RC_PROVENANCE_MISSING)
        return emit(
            ST_ANSWER,
            RC_VERIFIED_SUPPORT,
            answer_kind=KIND_ENTITY,
            answer_ref=aref,
            proof_ref=obs.proof_ref,
            completeness=CMPL_COMPLETE,
            answer_count=1,
        )
    if obs.candidate_only:
        return emit(ST_UNKNOWN, RC_CANDIDATE_ONLY)
    return emit(ST_UNKNOWN, RC_NO_VERIFIED_SUPPORT)


def query_from_obs(obs: Obs) -> bytes:
    return pack_query(
        txn_id=obs.txn_id,
        generation=obs.query_generation,
        search_budget=0 if obs.budget_exhausted else 64,
        crc_ok=obs.query_crc_ok,
        truncate_to=16 if obs.query_truncated else None,
    )


def field_coupling_errors(case_id: str, r: ResultRec) -> list[str]:
    """§03.9.3 coupling. FPGA path must not emit 0x00/0x22/0x55/0x80."""
    err: list[str] = []
    if r.status in ILLEGAL_FPGA_STATUS:
        err.append(f"{case_id} illegal FPGA status {r.status:#x}")
    if r.status == ST_ANSWER:
        if r.proof_ref == 0:
            err.append(f"{case_id} ANSWER proof_ref=0")
        if r.answer_kind == KIND_NONE:
            err.append(f"{case_id} ANSWER answer_kind=NONE")
        if r.completeness != CMPL_COMPLETE:
            err.append(f"{case_id} ANSWER completeness not COMPLETE")
        if r.conflict_ref != 0:
            err.append(f"{case_id} ANSWER conflict_ref!=0")
    if r.status == ST_SEARCH_INCOMPLETE:
        if r.completeness != CMPL_PARTIAL:
            err.append(f"{case_id} SEARCH_INCOMPLETE completeness not PARTIAL")
        if r.answer_kind != KIND_NONE:
            err.append(f"{case_id} SEARCH_INCOMPLETE answer_kind not NONE")
    if r.status == ST_CONFLICT:
        if r.conflict_ref == 0:
            err.append(f"{case_id} CONFLICT conflict_ref=0")
        if r.reason_code != RC_DISTINCT_VERIFIED_REFS:
            err.append(f"{case_id} CONFLICT reason {r.reason_code:#x} != DISTINCT_VERIFIED_REFS 0x30")
        if r.reason_code == 0x00:
            err.append(f"{case_id} CONFLICT used reason 0x00 as if it were status")
        if r.status == 0x00:
            err.append(f"{case_id} CONFLICT collapsed to status 0x00")
    return err


@dataclass
class Case:
    case_id: str
    kind: str
    notes: str
    obs: Obs | None = None
    wire_status: int | None = None
    expect_class: str | None = None
    expect: ResultRec | None = None
    result_hex: str = ""
    query_hex: str = ""
    mode: int = MODE_COMPARE
    reward_steps: tuple[RewardDecision, ...] = ()


def build_cases() -> list[Case]:
    cases: list[Case] = []

    def add_classify(case_id: str, wire_status: int, expect_class: str, notes: str) -> None:
        q = pack_query(txn_id=0xA000)
        cases.append(
            Case(
                case_id=case_id,
                kind="classify",
                notes=notes,
                wire_status=wire_status,
                expect_class=expect_class,
                query_hex=q.hex(),
                mode=MODE_CLASSIFY,
            )
        )

    def add_qeval(case_id: str, obs: Obs, notes: str, mode: int = MODE_COMPARE) -> None:
        r = qeval(obs)
        q = query_from_obs(obs)
        cases.append(
            Case(
                case_id=case_id,
                kind="qeval" if mode == MODE_COMPARE else "wire_fault",
                notes=notes,
                obs=obs,
                expect=r,
                result_hex=r.pack().hex(),
                query_hex=q.hex(),
                mode=mode,
                expect_class="PROTOCOL_FAULT" if mode == MODE_PROTOCOL else None,
            )
        )

    add_classify(
        "AA-ILLEGAL-00",
        0x00,
        "PROTOCOL_FAULT",
        "status 0x00 is uninitialized/protocol fault; never UNKNOWN/CONFLICT",
    )
    add_classify(
        "AA-NS-ST22",
        RC_TIE_OVERFLOW,
        "ILLEGAL_STATUS_REASON_COLLISION",
        "0x22 is reason TIE_OVERFLOW; never a primary status",
    )
    add_classify(
        "AA-NS-ST55",
        RC_INVALID_DESCRIPTOR,
        "ILLEGAL_STATUS_REASON_COLLISION",
        "0x55 is reason INVALID_DESCRIPTOR; never a primary status",
    )
    add_qeval(
        "AA-TIE-01",
        Obs(
            txn_id=0xA104,
            tie_overflow=True,
            verified_pairs=((0x020100, 1),),
            proof_ref=0x060100,
            scope_complete=False,
        ),
        "TIE-R0 overflow → status 0x04 + reason 0x22; hits do not become ANSWER",
    )
    add_qeval(
        "AA-DESC-01",
        Obs(
            txn_id=0xA106,
            invalid_count=1,
            verified_pairs=((0x020100, 1),),
            proof_ref=0x060100,
        ),
        "invalid_count>0 → status 0x06 + reason 0x55; never status 0x55",
    )
    add_qeval(
        "AA-ANS-PROOF0",
        Obs(
            txn_id=0xA101,
            verified_pairs=((0x020100, 1),),
            proof_ref=0,
            scope_complete=True,
        ),
        "verified support with proof_ref=0 cannot be ANSWER",
    )
    add_qeval(
        "AA-INC-BUDGET",
        Obs(
            txn_id=0xA120,
            budget_exhausted=True,
            verified_pairs=((0x020100, 1),),
            proof_ref=0x060100,
            scope_complete=False,
        ),
        "budget exhaust with hits → SEARCH_INCOMPLETE, not UNKNOWN",
    )
    add_qeval(
        "AA-UNK-ABSENT",
        Obs(txn_id=0xA110, scope_complete=True),
        "complete empty scope → UNKNOWN, not SEARCH_INCOMPLETE",
    )
    add_qeval(
        "AA-CONFLICT-01",
        Obs(
            txn_id=0xA130,
            verified_pairs=((0x020100, 1), (0x020200, 2)),
            proof_ref=0x060100,
            conflict_ref=0x070100,
            scope_complete=True,
        ),
        "two distinct verified answer_ref → CONFLICT + reason 0x30, not ANSWER",
    )
    add_qeval(
        "AA-ANS-DIAMOND",
        Obs(
            txn_id=0xA111,
            verified_pairs=((0x020100, 1), (0x020100, 1)),
            proof_ref=0x060100,
            scope_complete=True,
        ),
        "two proofs of the same answer_ref remain ANSWER",
    )
    add_qeval(
        "AA-CAND-01",
        Obs(txn_id=0xA112, candidate_only=True, scope_complete=True, proof_ref=0),
        "CANDIDATE-only complete scope → UNKNOWN / CANDIDATE_ONLY; never ANSWER",
    )
    add_classify(
        "AA-NS-ST80",
        ST_PARSE_ERROR,
        "ADAPTER_ONLY",
        "status 0x80 is adapter-only; illegal on FPGA path; never UNKNOWN",
    )
    add_qeval(
        "AA-TXN-ECHO",
        Obs(txn_id=0xA201, scope_complete=True),
        "lawful result must echo query txn_id; mismatch is protocol fault, not UNKNOWN",
    )
    add_qeval(
        "AA-QTRUNC-01",
        Obs(
            txn_id=0xA210,
            query_truncated=True,
            verified_pairs=((0x020100, 1),),
            proof_ref=0x060100,
        ),
        "truncated QueryRecord → DATA_INTEGRITY_FAIL + 0x55; never UNKNOWN",
    )
    add_qeval(
        "AA-QCRC-01",
        Obs(
            txn_id=0xA211,
            query_crc_ok=False,
            verified_pairs=((0x020100, 1),),
            proof_ref=0x060100,
        ),
        "bad QueryRecord CRC16-CCITT-FALSE → 0x06 + 0x55; never UNKNOWN",
    )
    add_qeval(
        "AA-STALE-GEN",
        Obs(
            txn_id=0xA154,
            query_generation=0x0002,
            active_generation=GENERATION,
            verified_pairs=((0x020100, 1),),
            proof_ref=0x060100,
            scope_complete=True,
        ),
        "stale knowledge_generation → status 0x06 + STALE_GENERATION 0x54, not UNKNOWN",
    )
    add_qeval(
        "AA-PROTO-01",
        Obs(
            txn_id=0xA220,
            protocol_fault=True,
            verified_pairs=((0x020100, 1),),
            proof_ref=0x060100,
        ),
        "SEQ_GAP/TIMEOUT/CRC_ERROR protocol fault never maps to UNKNOWN",
        mode=MODE_PROTOCOL,
    )

    cid = CausalId(episode_id=0xE001, step_id=0x0001, command_id=0xC0DE, generation=GENERATION)
    dup_steps = reward_sequence(
        RewardObs(
            pending=cid,
            executed=cid,
            effect=cid,
            exec_valid=True,
            effect_accepted=True,
            reward_source_legal=True,
        ),
        RewardObs(
            pending=cid,
            executed=cid,
            effect=cid,
            exec_valid=True,
            effect_accepted=True,
            reward_source_legal=True,
        ),
    )
    q_rew = pack_query(txn_id=0xA301)
    cases.append(
        Case(
            case_id="AA-REW-DUP",
            kind="reward_law",
            notes="same causal (episode_id,step_id,command_id,generation) must not update twice",
            query_hex=q_rew.hex(),
            mode=MODE_REWARD,
            reward_steps=tuple(dup_steps),
        )
    )
    mismatch = CausalId(episode_id=0xE001, step_id=0x0001, command_id=0xBEEF, generation=GENERATION)
    id_steps = reward_sequence(
        RewardObs(
            pending=cid,
            executed=cid,
            effect=mismatch,
            exec_valid=True,
            effect_accepted=True,
            reward_source_legal=True,
        )
    )
    cases.append(
        Case(
            case_id="AA-REW-ID",
            kind="reward_law",
            notes="ObservedEffect command_id mismatch → reward_accepted=0; no learner update",
            query_hex=pack_query(txn_id=0xA302).hex(),
            mode=MODE_REWARD,
            reward_steps=tuple(id_steps),
        )
    )
    add_qeval(
        "AA-KINV-01",
        Obs(
            txn_id=0xA323,
            k_invalid=True,
            verified_pairs=((0x020100, 1),),
            proof_ref=0x060100,
            scope_complete=True,
        ),
        "k_invalid=1 → status 0x06 + reason 0x23; never ANSWER/UNKNOWN; never status 0x23",
    )
    add_qeval(
        "AA-FEM-CRC",
        Obs(
            txn_id=0xA356,
            committed_corrupt=True,
            integrity_fault=True,
            verified_pairs=((0x020100, 1),),
            proof_ref=0x060100,
            scope_complete=True,
        ),
        "COMMIT present + CRC invalid → 0x06 + 0x56; never UNKNOWN; not a valid committed prototype",
    )
    return cases


def selfcheck(cases: list[Case] | None = None) -> list[str]:
    rows = cases if cases is not None else build_cases()
    err: list[str] = []
    got_ids = [c.case_id for c in rows]
    if got_ids != list(LOCKED_CASE_IDS):
        err.append(f"case_id order {got_ids} != {list(LOCKED_CASE_IDS)}")
    if list(LOCKED_CASE_IDS[:11]) != list(LOCKED_PREFIX_11):
        err.append("locked prefix of 11 CASE_IDs drifted")
    if list(LOCKED_CASE_IDS[:17]) != list(LOCKED_PREFIX_17):
        err.append("locked prefix of 17 CASE_IDs drifted")
    if len(LOCKED_CASE_IDS) < 17:
        err.append("locked case list shrank below 17")

    if MAGIC_QUERY != 0x4E51 or MAGIC_RESULT != 0x4E52:
        err.append("magic drift")
    if RC_TIE_OVERFLOW in PRIMARY_ASTRA_STATUS or RC_INVALID_DESCRIPTOR in PRIMARY_ASTRA_STATUS:
        err.append("reason 0x22/0x55 leaked into primary status set")
    if RC_K_INVALID in PRIMARY_ASTRA_STATUS or RC_COMMITTED_CORRUPT in PRIMARY_ASTRA_STATUS:
        err.append("reason 0x23/0x56 leaked into primary status set")
    if RC_TIE_OVERFLOW in STATUS_NAME or RC_INVALID_DESCRIPTOR in STATUS_NAME:
        err.append("STATUS_NAME mixed reason bytes")
    if RC_K_INVALID in STATUS_NAME or RC_COMMITTED_CORRUPT in STATUS_NAME:
        err.append("STATUS_NAME mixed K_INVALID/COMMITTED_CORRUPT")
    src = Path(__file__).read_text(encoding="utf-8")
    tree = ast.parse(src)
    for node in ast.walk(tree):
        names: list[str] = []
        if isinstance(node, ast.Import):
            names.extend(a.name for a in node.names)
        elif isinstance(node, ast.ImportFrom):
            names.append(node.module or "")
        for name in names:
            if "pack_vectors" in name or "fe256_gold" in name:
                err.append(f"gold source imports {name}")
    if "pack_vectors" in sys.modules:
        err.append("imported python/m1/pack_vectors.py")

    by = {c.case_id: c for c in rows}

    c = by["AA-ILLEGAL-00"]
    if classify_status(0x00) != "PROTOCOL_FAULT" or c.expect_class != "PROTOCOL_FAULT":
        err.append("AA-ILLEGAL-00 must be PROTOCOL_FAULT")
    if classify_status(0x00) in ("ASTRA_STATUS", "UNKNOWN", "CONFLICT"):
        err.append("status 0x00 coerced")

    if classify_status(RC_TIE_OVERFLOW) != "ILLEGAL_STATUS_REASON_COLLISION":
        err.append("status 0x22 must be rejected as reason-collision")
    if classify_status(RC_INVALID_DESCRIPTOR) != "ILLEGAL_STATUS_REASON_COLLISION":
        err.append("status 0x55 must be rejected as reason-collision")
    if classify_status(RC_K_INVALID) != "ILLEGAL_STATUS_REASON_COLLISION":
        err.append("status 0x23 must be rejected as reason-collision")
    if classify_status(RC_COMMITTED_CORRUPT) != "ILLEGAL_STATUS_REASON_COLLISION":
        err.append("status 0x56 must be rejected as reason-collision")
    if classify_status(ST_PARSE_ERROR) != "ADAPTER_ONLY":
        err.append("status 0x80 must be ADAPTER_ONLY")
    if status_namespace_ok(RC_TIE_OVERFLOW) or status_namespace_ok(RC_INVALID_DESCRIPTOR):
        err.append("0x22/0x55 accepted as status")
    if status_namespace_ok(RC_K_INVALID) or status_namespace_ok(RC_COMMITTED_CORRUPT):
        err.append("0x23/0x56 accepted as status")
    if status_namespace_ok(0x00) or status_namespace_ok(ST_PARSE_ERROR):
        err.append("0x00/0x80 accepted as ASTRA status")

    tie = by["AA-TIE-01"].expect
    if tie is None or tie.status != ST_SEARCH_INCOMPLETE or tie.reason_code != RC_TIE_OVERFLOW:
        err.append("AA-TIE-01 must be status 0x04 + reason 0x22")
    if tie is not None and (tie.status == RC_TIE_OVERFLOW or tie.completeness != CMPL_PARTIAL):
        err.append("AA-TIE-01 used 0x22 as status or not PARTIAL")

    desc = by["AA-DESC-01"].expect
    if desc is None or desc.status != ST_DATA_INTEGRITY_FAIL or desc.reason_code != RC_INVALID_DESCRIPTOR:
        err.append("AA-DESC-01 must be status 0x06 + reason 0x55")
    if desc is not None and desc.status == RC_INVALID_DESCRIPTOR:
        err.append("AA-DESC-01 used 0x55 as status")

    proof0 = by["AA-ANS-PROOF0"].expect
    if proof0 is None or proof0.status == ST_ANSWER or proof0.proof_ref != 0:
        err.append("AA-ANS-PROOF0 must not ANSWER")
    if proof0 is not None and proof0.status != ST_UNKNOWN:
        err.append("AA-ANS-PROOF0 expected UNKNOWN / PROVENANCE_MISSING")
    if proof0 is not None and proof0.reason_code != RC_PROVENANCE_MISSING:
        err.append("AA-ANS-PROOF0 reason must be PROVENANCE_MISSING")

    inc = by["AA-INC-BUDGET"].expect
    if inc is None or inc.status != ST_SEARCH_INCOMPLETE or inc.reason_code != RC_BUDGET_EXHAUSTED:
        err.append("AA-INC-BUDGET must be SEARCH_INCOMPLETE / BUDGET_EXHAUSTED")
    if inc is not None and inc.status == ST_UNKNOWN:
        err.append("AA-INC-BUDGET collapsed to UNKNOWN")
    if inc is not None and inc.status == ST_ANSWER:
        err.append("AA-INC-BUDGET collapsed to ANSWER")

    unk = by["AA-UNK-ABSENT"].expect
    if unk is None or unk.status != ST_UNKNOWN or unk.reason_code != RC_NO_VERIFIED_SUPPORT:
        err.append("AA-UNK-ABSENT must be UNKNOWN / NO_VERIFIED_SUPPORT")
    if unk is not None and unk.status == ST_SEARCH_INCOMPLETE:
        err.append("AA-UNK-ABSENT collapsed to SEARCH_INCOMPLETE")

    conf = by["AA-CONFLICT-01"].expect
    if conf is None or conf.status != ST_CONFLICT or conf.reason_code != RC_DISTINCT_VERIFIED_REFS:
        err.append("AA-CONFLICT-01 must be CONFLICT / 0x30")
    if conf is not None and (conf.status == ST_ANSWER or conf.conflict_ref == 0):
        err.append("AA-CONFLICT-01 plurality collapsed to ANSWER or zero conflict_ref")
    if conf is not None and conf.reason_code == 0x00:
        err.append("AA-CONFLICT-01 used reason 0x00 as if it were status")

    diamond = by["AA-ANS-DIAMOND"].expect
    if diamond is None or diamond.status != ST_ANSWER or diamond.proof_ref == 0:
        err.append("AA-ANS-DIAMOND must ANSWER with proof_ref!=0")
    if diamond is not None and (
        diamond.answer_kind == KIND_NONE
        or diamond.completeness != CMPL_COMPLETE
        or diamond.conflict_ref != 0
    ):
        err.append("AA-ANS-DIAMOND ANSWER coupling broken")

    cand = by["AA-CAND-01"].expect
    if cand is None or cand.status != ST_UNKNOWN or cand.reason_code != RC_CANDIDATE_ONLY:
        err.append("AA-CAND-01 must be UNKNOWN / CANDIDATE_ONLY")
    if cand is not None and cand.status == ST_ANSWER:
        err.append("AA-CAND-01 CANDIDATE-only became ANSWER")

    echo = by["AA-TXN-ECHO"].expect
    if echo is None or echo.txn_id != 0xA201:
        err.append("AA-TXN-ECHO must echo txn_id 0xA201")
    if echo is not None and echo.status == ST_UNKNOWN and echo.txn_id != 0xA201:
        err.append("AA-TXN-ECHO mismatch coerced to UNKNOWN")

    trunc = by["AA-QTRUNC-01"].expect
    if trunc is None or trunc.status != ST_DATA_INTEGRITY_FAIL or trunc.reason_code != RC_INVALID_DESCRIPTOR:
        err.append("AA-QTRUNC-01 must be 0x06 + 0x55")
    if trunc is not None and trunc.status == ST_UNKNOWN:
        err.append("AA-QTRUNC-01 mapped to UNKNOWN")
    tq = bytes.fromhex(by["AA-QTRUNC-01"].query_hex)
    if len(tq) != 16:
        err.append("AA-QTRUNC-01 QueryRecord must be truncated to 16 bytes")

    qcrc = by["AA-QCRC-01"].expect
    if qcrc is None or qcrc.status != ST_DATA_INTEGRITY_FAIL or qcrc.reason_code != RC_INVALID_DESCRIPTOR:
        err.append("AA-QCRC-01 must be 0x06 + 0x55")
    if qcrc is not None and qcrc.status == ST_UNKNOWN:
        err.append("AA-QCRC-01 mapped to UNKNOWN")
    cq = bytes.fromhex(by["AA-QCRC-01"].query_hex)
    if len(cq) != 32 or crc16_ccitt_false(cq[:30]) == struct.unpack("<H", cq[30:])[0]:
        err.append("AA-QCRC-01 must carry a bad CRC16-CCITT-FALSE")

    stale = by["AA-STALE-GEN"].expect
    if stale is None or stale.status != ST_DATA_INTEGRITY_FAIL or stale.reason_code != RC_STALE_GENERATION:
        err.append("AA-STALE-GEN must be status 0x06 + reason 0x54")
    if stale is not None and stale.status == ST_UNKNOWN:
        err.append("AA-STALE-GEN mapped to UNKNOWN")
    if stale is not None and stale.status == ST_ANSWER:
        err.append("AA-STALE-GEN became ANSWER")

    proto = by["AA-PROTO-01"]
    if proto.expect_class != "PROTOCOL_FAULT":
        err.append("AA-PROTO-01 expect_class must be PROTOCOL_FAULT")
    if proto.expect is None or proto.expect.status == ST_UNKNOWN:
        err.append("AA-PROTO-01 protocol fault mapped to UNKNOWN")
    if proto.expect is not None and proto.expect.status in ILLEGAL_FPGA_STATUS:
        err.append("AA-PROTO-01 emitted illegal FPGA status")

    if by["AA-NS-ST80"].expect_class != "ADAPTER_ONLY":
        err.append("AA-NS-ST80 must be ADAPTER_ONLY")

    dup = by["AA-REW-DUP"].reward_steps
    if len(dup) != 2:
        err.append("AA-REW-DUP must have two presentations")
    elif not (dup[0].reward_accepted and dup[0].learner_update and dup[0].reason == REW_ACCEPTED):
        err.append("AA-REW-DUP first presentation must accept and update once")
    elif dup[1].learner_update or dup[1].reason != REW_DUPLICATE:
        err.append("AA-REW-DUP second presentation must not update (DUPLICATE)")

    rid = by["AA-REW-ID"].reward_steps
    if not rid or rid[0].reward_accepted or rid[0].learner_update:
        err.append("AA-REW-ID must refuse reward_accepted and learner update")
    elif rid[0].reason != REW_IDENTITY_MISMATCH:
        err.append("AA-REW-ID reason must be IDENTITY_MISMATCH")

    kinv = by["AA-KINV-01"].expect
    if kinv is None or kinv.status != ST_DATA_INTEGRITY_FAIL or kinv.reason_code != RC_K_INVALID:
        err.append("AA-KINV-01 must be status 0x06 + reason 0x23")
    if kinv is not None and (kinv.status in (ST_ANSWER, ST_UNKNOWN) or kinv.status == RC_K_INVALID):
        err.append("AA-KINV-01 became ANSWER/UNKNOWN or used 0x23 as status")
    if kinv is not None and kinv.completeness != CMPL_NA:
        err.append("AA-KINV-01 completeness must be NOT_APPLICABLE")

    fem = by["AA-FEM-CRC"].expect
    if fem is None or fem.status != ST_DATA_INTEGRITY_FAIL or fem.reason_code != RC_COMMITTED_CORRUPT:
        err.append("AA-FEM-CRC must be status 0x06 + reason 0x56")
    if fem is not None and (fem.status == ST_UNKNOWN or fem.status == RC_COMMITTED_CORRUPT):
        err.append("AA-FEM-CRC mapped to UNKNOWN or used 0x56 as status")
    if fem is not None and fem.completeness != CMPL_NA:
        err.append("AA-FEM-CRC completeness must be NOT_APPLICABLE")

    for c in rows:
        if c.expect is None:
            continue
        r = c.expect
        err.extend(field_coupling_errors(c.case_id, r))
        if r.status not in PRIMARY_ASTRA_STATUS:
            err.append(f"{c.case_id} emitted status {r.status:#x} outside primary namespace")
        if r.status in ILLEGAL_FPGA_STATUS:
            err.append(f"{c.case_id} emitted forbidden status {r.status:#x}")
        packed = bytes.fromhex(c.result_hex)
        if unpack_result(packed).status != r.status:
            err.append(f"{c.case_id} result pack roundtrip failed")
        if int.from_bytes(packed[0:2], "little") != MAGIC_RESULT:
            err.append(f"{c.case_id} magic drift")
        if c.kind != "classify" and unpack_result(packed).txn_id != r.txn_id:
            err.append(f"{c.case_id} result txn_id drift")
    return err


def emit_svh(out_dir: Path, cases: list[Case]) -> None:
    n = len(cases)
    const = [
        "// AGENT_B ASTRA adv constants. Not DUT RTL. PROGRAM=NO.",
        "`ifndef ASTRA_ADV_CONSTANTS_SVH",
        "`define ASTRA_ADV_CONSTANTS_SVH",
        f"localparam integer ASTRA_ADV_N = {n};",
        "localparam integer ASTRA_ADV_MAX_WORDS = 16;",
        "localparam integer ASTRA_ADV_RESULT_WORDS = 12;",
        "localparam [7:0] ASTRA_ADV_ST_UNKNOWN = 8'h02;",
        "localparam [7:0] ASTRA_ADV_ILLEGAL_00 = 8'h00;",
        "localparam [7:0] ASTRA_ADV_ILLEGAL_22 = 8'h22;",
        "localparam [7:0] ASTRA_ADV_ILLEGAL_55 = 8'h55;",
        "localparam [7:0] ASTRA_ADV_ILLEGAL_80 = 8'h80;",
        "localparam integer ASTRA_ADV_MODE_COMPARE = 0;",
        "localparam integer ASTRA_ADV_MODE_CLASSIFY = 1;",
        "localparam integer ASTRA_ADV_MODE_PROTOCOL = 2;",
        "localparam integer ASTRA_ADV_MODE_REWARD = 3;",
        "localparam [7:0] ASTRA_ADV_ILLEGAL_23 = 8'h23;",
        "localparam [7:0] ASTRA_ADV_ILLEGAL_56 = 8'h56;",
        "`endif",
        "",
    ]
    (out_dir / "astra_adv_constants.svh").write_text("\n".join(const), encoding="utf-8")

    fopen = [
        "function integer aa_fopen_mem;",
        "  input integer rec;",
        "  begin",
        "    case (rec)",
    ]
    for i, c in enumerate(cases):
        fopen.append(f'      {i}: aa_fopen_mem = $fopen("out/{c.case_id}.mem", "r");')
    fopen.extend(
        [
            "      default: aa_fopen_mem = 0;",
            "    endcase",
            "  end",
            "endfunction",
            "",
        ]
    )
    (out_dir / "astra_adv_fopen.svh").write_text("\n".join(fopen), encoding="utf-8")

    exp = [
        "// AGENT_B ASTRA adv expect. Not DUT RTL. PROGRAM=NO.",
        "// iverilog-friendly: integer/reg arrays, no string localparam.",
        f"integer AA_MODE [0:{n - 1}];",
        f"reg [7:0] AA_STATUS [0:{n - 1}];",
        f"reg [7:0] AA_REASON [0:{n - 1}];",
        f"reg [7:0] AA_CMPL [0:{n - 1}];",
        f"reg [7:0] AA_KIND [0:{n - 1}];",
        f"reg [31:0] AA_TXN [0:{n - 1}];",
        f"reg [31:0] AA_PROOF [0:{n - 1}];",
        f"reg [31:0] AA_CONFLICT [0:{n - 1}];",
        f"reg [8*16-1:0] AA_ID [0:{n - 1}];",
        "initial begin",
    ]
    for i, c in enumerate(cases):
        r = c.expect
        st = 0 if r is None else r.status
        rc = 0 if r is None else r.reason_code
        cm = 0 if r is None else r.completeness
        kd = 0 if r is None else r.answer_kind
        txn = 0 if r is None else r.txn_id
        pr = 0 if r is None else r.proof_ref
        cf = 0 if r is None else r.conflict_ref
        exp.append(f'  AA_ID[{i}] = "{c.case_id}";')
        exp.append(f"  AA_MODE[{i}] = {c.mode};")
        exp.append(f"  AA_STATUS[{i}] = 8'h{st:02x};")
        exp.append(f"  AA_REASON[{i}] = 8'h{rc:02x};")
        exp.append(f"  AA_CMPL[{i}] = 8'h{cm:02x};")
        exp.append(f"  AA_KIND[{i}] = 8'h{kd:02x};")
        exp.append(f"  AA_TXN[{i}] = 32'h{txn:08x};")
        exp.append(f"  AA_PROOF[{i}] = 32'h{pr:08x};")
        exp.append(f"  AA_CONFLICT[{i}] = 32'h{cf:08x};")
    exp.append("end")
    exp.append("")
    (out_dir / "astra_adv_expect.svh").write_text("\n".join(exp), encoding="utf-8")

    root = Path(__file__).resolve().parent
    for name in ("astra_adv_constants.svh", "astra_adv_fopen.svh", "astra_adv_expect.svh"):
        (root / name).write_text((out_dir / name).read_text(encoding="utf-8"), encoding="utf-8")


def emit_artifacts(out_dir: Path, cases: list[Case]) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    jsonl = out_dir / "astra_adv_cases.jsonl"
    with jsonl.open("w", encoding="utf-8") as f:
        for c in cases:
            rec = {
                "case_id": c.case_id,
                "kind": c.kind,
                "mode": c.mode,
                "notes": c.notes,
                "wire_status": c.wire_status,
                "expect_class": c.expect_class,
                "result_hex": c.result_hex or None,
                "query_hex": c.query_hex or None,
                "query_len": len(bytes.fromhex(c.query_hex)) if c.query_hex else 0,
                "reward_steps": [
                    {
                        "reward_accepted": s.reward_accepted,
                        "learner_update": s.learner_update,
                        "reason": s.reason,
                    }
                    for s in c.reward_steps
                ]
                or None,
            }
            if c.expect is not None:
                rec["expected"] = {
                    "status": STATUS_NAME.get(c.expect.status, hex(c.expect.status)),
                    "status_u8": c.expect.status,
                    "reason_code": c.expect.reason_code,
                    "completeness": c.expect.completeness,
                    "answer_kind": c.expect.answer_kind,
                    "proof_ref": c.expect.proof_ref,
                    "conflict_ref": c.expect.conflict_ref,
                    "answer_ref": c.expect.answer_ref,
                    "txn_id": c.expect.txn_id,
                }
            f.write(json.dumps(rec, sort_keys=True, separators=(",", ":")) + "\n")
            if c.query_hex:
                (out_dir / f"{c.case_id}.mem").write_text(
                    "\n".join(blob_to_mem_lines(bytes.fromhex(c.query_hex))) + "\n",
                    encoding="ascii",
                )
            if c.result_hex:
                (out_dir / f"{c.case_id}.exp.mem").write_text(
                    "\n".join(blob_to_mem_lines(bytes.fromhex(c.result_hex))) + "\n",
                    encoding="ascii",
                )
    emit_svh(out_dir, cases)
    manifest = {
        "spec": GOLD_SPEC,
        "n_cases": len(cases),
        "case_ids": [c.case_id for c in cases],
        "locked_prefix_11": list(LOCKED_PREFIX_11),
        "locked_prefix_17": list(LOCKED_PREFIX_17),
        "magic_query": hex(MAGIC_QUERY),
        "magic_result": hex(MAGIC_RESULT),
        "harness": "verification/astra_adv/tb_astra_adv_xsim_compare.sv",
        "dut_stub": "verification/astra_adv/astra_adv_dut.sv",
        "note": (
            "Q-eval invariant gold + XSim compare vectors. Not ASTRA_ADV_PASS / "
            "FE256_PASS / PACK_ABI_24_24_PASS / BOARD_PASS. PROGRAM=NO. "
            "Fail-closed until Agent D binds q_ready/s_ready."
        ),
    }
    (out_dir / "astra_adv_manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
    )
    return manifest


def compare_jsonl(path: Path, cases: list[Case]) -> list[str]:
    by = {c.case_id: c for c in cases if c.expect is not None}
    err: list[str] = []
    text = path.read_text(encoding="utf-8")
    rows = [json.loads(line) for line in text.splitlines() if line.strip()]
    seen = set()
    for rec in rows:
        cid = rec.get("case_id")
        seen.add(cid)
        gold = by.get(cid)
        if gold is None or gold.expect is None:
            st = rec.get("status")
            if st in ILLEGAL_FPGA_STATUS:
                err.append(f"{cid} DUT status {st:#x} illegal FPGA status")
            if gold is not None and gold.mode == MODE_PROTOCOL and st == ST_UNKNOWN:
                err.append(f"{cid} protocol fault mapped to UNKNOWN")
            continue
        for field_name, attr in (
            ("status", "status"),
            ("reason_code", "reason_code"),
            ("completeness", "completeness"),
            ("answer_kind", "answer_kind"),
            ("proof_ref", "proof_ref"),
            ("conflict_ref", "conflict_ref"),
            ("txn_id", "txn_id"),
        ):
            if field_name in rec and rec[field_name] != getattr(gold.expect, attr):
                err.append(
                    f"{cid} {field_name}: got {rec[field_name]} expected {getattr(gold.expect, attr)}"
                )
                if field_name == "txn_id":
                    err.append(f"{cid} txn_id echo fail; not UNKNOWN")
        st = rec.get("status", gold.expect.status)
        if st in ILLEGAL_FPGA_STATUS:
            err.append(f"{cid} DUT status {st:#x} outside primary namespace")
        if gold.mode == MODE_PROTOCOL and st == ST_UNKNOWN:
            err.append(f"{cid} protocol fault mapped to UNKNOWN")
        dut = ResultRec(
            txn_id=int(rec.get("txn_id", gold.expect.txn_id)),
            status=int(st),
            reason_code=int(rec.get("reason_code", gold.expect.reason_code)),
            completeness=int(rec.get("completeness", gold.expect.completeness)),
            answer_kind=int(rec.get("answer_kind", gold.expect.answer_kind)),
            proof_ref=int(rec.get("proof_ref", gold.expect.proof_ref)),
            conflict_ref=int(rec.get("conflict_ref", gold.expect.conflict_ref)),
        )
        err.extend(field_coupling_errors(str(cid), dut))
    missing = [cid for cid in by if cid not in seen]
    if missing:
        err.append(f"DUT missing qeval cases: {missing}")
    return err


def main(argv: Iterable[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="ASTRA adv Q-eval gold (AGENT_B)")
    ap.add_argument("--selfcheck", action="store_true")
    ap.add_argument("--emit", type=Path, default=None)
    ap.add_argument("--compare", type=Path, default=None)
    args = ap.parse_args(list(argv) if argv is not None else None)

    cases = build_cases()
    errors = selfcheck(cases) if (args.selfcheck or args.emit or args.compare is None) else []

    if args.emit:
        man = emit_artifacts(args.emit, cases)
        print(json.dumps(man, indent=2))

    if args.compare:
        errors.extend(compare_jsonl(args.compare, cases))

    if errors:
        print("SELFCHECK FAIL:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    if args.selfcheck or not args.emit:
        print(f"SELFCHECK OK: {len(cases)} ASTRA adv vectors; not a ladder stamp")
    return 0


if __name__ == "__main__":
    sys.exit(main())
