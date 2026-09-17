#!/usr/bin/env python3
"""Pack/ABI-24 gold — AGENT_B. Independent of python/m1/pack_vectors.py.

24 integrity cases [§31.2] against locked ManifestHeader [§04.6]:
  128 B header, reserved=12, CRC-32/ISO-HDLC over [0:112),
  pack_generation u32 distinct from knowledge_generation u16.

Does not import DUT helpers. zlib is used only as a CRC cross-check in
--selfcheck, not as the encoder of record. Schema/content identities are
SHA-256 of documented labels/payloads, not cloned DUT filler bytes.

This generator selfcheck is not PACK_ABI_24_24_PASS, BOARD_PASS, or FINAL_PASS.

Usage:
  python pack_abi24_gold.py --selfcheck --emit out
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
import sys
import zlib
from dataclasses import dataclass, field
from pathlib import Path

MAGIC_NAI1 = 0x3149414E
MANIFEST_VERSION = 1
ABI_VERSION = 1
SCHEMA_VERSION = 1
PAGE_SIZE = 256
HEADER_LENGTH = 128
PAGE_CRC_SCHEME = 1  # CRC-32/ISO-HDLC
PREFIX = 112
RESERVED = 12
UNSET_GENERATION = 0xFFFFFFFF

KIND_NODE = 1
KIND_SENTINEL = 8
OP_BEGIN = 0x01
OP_REGION = 0x02
OP_PAGE = 0x03
OP_END = 0x04

RC_OK = 0x00
RC_BAD_MAGIC = 0x01
RC_ABI_MISMATCH = 0x02
RC_SCHEMA_MISMATCH = 0x03
RC_MANIFEST_CRC = 0x04
RC_PAGE_CRC = 0x05
RC_UNSUPPORTED = 0x07
RC_HEADER_LENGTH = 0x09
RC_RESERVED_NZ = 0x0A
RC_CONTENT_MISMATCH = 0x0D
RC_STALE_PACK_GENERATION = 0x0E
RC_TRUNCATED = 0x0F

ST_UNKNOWN = 0x02
ST_DATA_INTEGRITY_FAIL = 0x06
RC_PACK_CRC = 0x50
RC_STALE_GENERATION = 0x54
RC_INVALID_DESCRIPTOR = 0x55

OUTCOME_OK = "LOAD_OK"
OUTCOME_REJECT = "LOAD_REJECT"
OUTCOME_QUERY = "QUERY_INTEGRITY"

MAGIC_QUERY = 0x4E51
MAGIC_RESULT = 0x4E52
SENTINEL_WORD = 0x4E414931  # ASCII "NAI1"; not DUT 0xA5A5A5A5

# Frozen campaign identities — derived here, not copied from pack_vectors.py.
SCHEMA_LABEL_R01 = b"NAI1-R0.1-SCHEMA-IDENTITY-PACK-A"
SCHEMA_LABEL_RIVAL = b"NAI1-R0.1-SCHEMA-IDENTITY-RIVAL"
SCHEMA_ID_R01 = hashlib.sha256(SCHEMA_LABEL_R01).digest()
SCHEMA_ID_RIVAL = hashlib.sha256(SCHEMA_LABEL_RIVAL).digest()
PAY_A = struct.pack("<IIII", 0xA11CE001, 0x5E4714E1, 0xC0FFEE01, 0xAB1E0001)
PAY_B = struct.pack("<IIII", 0xA11CE002, 0x5E4714E2, 0xC0FFEE02, 0xAB1E0002)
PAY_N = struct.pack("<IIII", 0x4E0DE001, 0x4E0DE002, 0x4E0DE003, 0x4E0DE004)
PAY_S = struct.pack("<IIII", 0x5E47E001, 0x5E47E002, 0x5E47E003, 0x5E47E004)
CONTENT_A = hashlib.sha256(PAY_A).digest()
CONTENT_B = hashlib.sha256(PAY_B).digest()
CONTENT_NS = hashlib.sha256(PAY_N + PAY_S).digest()

DUT_CLONE_SCHEMA = b"\x11" * 32
DUT_CLONE_CONTENT = b"\x22" * 32


def crc32_iso_hdlc(data: bytes) -> int:
    """CRC-32/ISO-HDLC, independent of DUT. Must match zlib.crc32 in selfcheck."""
    crc = 0xFFFFFFFF
    for b in data:
        crc ^= b
        for _ in range(8):
            crc = ((crc >> 1) ^ 0xEDB88320) if (crc & 1) else (crc >> 1)
    return crc ^ 0xFFFFFFFF


def crc16_ccitt_false(data: bytes) -> int:
    """CRC16-CCITT-FALSE [§04.12]. Independent copy; do not import fe256_gold."""
    c = 0xFFFF
    for b in data:
        c ^= b << 8
        for _ in range(8):
            c = ((c << 1) ^ 0x1021) & 0xFFFF if c & 0x8000 else (c << 1) & 0xFFFF
    return c


def u32(x: int, endian: str = "<") -> bytes:
    return struct.pack(endian + "I", x & 0xFFFFFFFF)


def u16(x: int, endian: str = "<") -> bytes:
    return struct.pack(endian + "H", x & 0xFFFF)


def cmd(opcode: int, payload: bytes, flags: int = 0) -> bytes:
    return struct.pack("<BBH", opcode, flags, len(payload) & 0xFFFF) + payload


def pack_header(
    *,
    magic: int = MAGIC_NAI1,
    manifest_version: int = MANIFEST_VERSION,
    abi_version: int = ABI_VERSION,
    schema_version: int = SCHEMA_VERSION,
    flags: int = 0,
    pack_generation: int = 1,
    node_count: int = 1,
    edge_count: int = 0,
    value_count: int = 0,
    context_count: int = 0,
    provenance_count: int = 0,
    region_count: int = 1,
    schema_sha: bytes | None = None,
    content_sha: bytes | None = None,
    page_size: int = PAGE_SIZE,
    header_length: int = HEADER_LENGTH,
    page_crc_scheme: int = PAGE_CRC_SCHEME,
    reserved: bytes | None = None,
    corrupt_crc: bool = False,
    endian: str = "<",
) -> bytes:
    schema_sha = schema_sha if schema_sha is not None else SCHEMA_ID_R01
    content_sha = content_sha if content_sha is not None else CONTENT_A
    reserved = reserved if reserved is not None else (b"\x00" * RESERVED)
    if len(schema_sha) != 32 or len(content_sha) != 32:
        raise ValueError("sha fields must be 32 bytes")
    body = b"".join(
        [
            u32(magic, endian),
            u16(manifest_version, endian),
            u16(abi_version, endian),
            u16(schema_version, endian),
            u16(flags, endian),
            u32(pack_generation, endian),
            u32(node_count, endian),
            u32(edge_count, endian),
            u32(value_count, endian),
            u32(context_count, endian),
            u32(provenance_count, endian),
            u32(region_count, endian),
            schema_sha,
            content_sha,
            u32(page_size, endian),
            u16(header_length, endian),
            u16(page_crc_scheme, endian),
        ]
    )
    if len(body) != PREFIX:
        raise RuntimeError(f"prefix {len(body)} != {PREFIX}")
    crc = crc32_iso_hdlc(body)
    if corrupt_crc:
        crc ^= 0xFFFFFFFF
    hdr = body + u32(crc, endian) + reserved
    return hdr


def pack_header_rival_132(*, pack_generation: int = 22) -> bytes:
    """Retired reserved=16 / 132-byte candidate. Illegal R0.1 ABI."""
    return pack_header(
        pack_generation=pack_generation,
        header_length=132,
        reserved=b"\x00" * 16,
        content_sha=CONTENT_A,
    )


def unpack_header(hdr: bytes) -> dict:
    if len(hdr) < PREFIX + 4:
        raise ValueError(f"header length {len(hdr)}")
    body, crc_b, reserved = hdr[:PREFIX], hdr[PREFIX:PREFIX + 4], hdr[PREFIX + 4 :]
    crc = struct.unpack("<I", crc_b)[0]
    calc = crc32_iso_hdlc(body)
    (
        magic,
        man_ver,
        abi,
        schema,
        flags,
        pack_gen,
        n_node,
        n_edge,
        n_val,
        n_ctx,
        n_prov,
        n_reg,
    ) = struct.unpack_from("<IHHHHIIIIIII", body, 0)
    schema_sha = body[40:72]
    content_sha = body[72:104]
    page_size, header_length, scheme = struct.unpack_from("<IHH", body, 104)
    return {
        "magic": magic,
        "manifest_version": man_ver,
        "abi_version": abi,
        "schema_version": schema,
        "flags": flags,
        "pack_generation": pack_gen,
        "node_count": n_node,
        "edge_count": n_edge,
        "value_count": n_val,
        "context_count": n_ctx,
        "provenance_count": n_prov,
        "region_count": n_reg,
        "schema_sha": schema_sha.hex(),
        "content_sha": content_sha.hex(),
        "page_size": page_size,
        "header_length": header_length,
        "page_crc_scheme": scheme,
        "manifest_crc32": crc,
        "crc_ok": crc == calc,
        "reserved_zero": reserved == b"\x00" * len(reserved),
        "wire_len": len(hdr),
    }


def region_desc(
    *,
    region_id: int = 0,
    kind: int = KIND_SENTINEL,
    ddr_offset: int = 0,
    payload: bytes = b"",
    sentinel: int = SENTINEL_WORD,
    corrupt_crc: bool = False,
) -> bytes:
    rcrc = crc32_iso_hdlc(payload)
    if corrupt_crc:
        rcrc ^= 0xFFFFFFFF
    desc = b"".join(
        [
            bytes([region_id & 0xFF, kind & 0xFF]),
            u16(0),
            u32(ddr_offset),
            u32(len(payload)),
            u16(4),
            u16(1),
            u32(max(1, (len(payload) + 3) // 4)),
            u32(rcrc),
            u32(sentinel),
            u32(0),
        ]
    )
    if len(desc) != 32:
        raise RuntimeError(len(desc))
    return desc


def data_page(
    *,
    seq: int,
    region_id: int,
    offset: int,
    payload: bytes,
    corrupt_crc: bool = False,
) -> bytes:
    crc = crc32_iso_hdlc(payload)
    if corrupt_crc:
        crc ^= 0xFFFFFFFF
    header = b"".join(
        [u16(seq), bytes([region_id & 0xFF, 0]), u32(offset), u16(len(payload)), u16(0), u32(crc)]
    )
    if len(header) != 16:
        raise RuntimeError(len(header))
    pad = (-len(payload)) % 4
    return header + payload + (b"\x00" * pad)


def stream(man: bytes, regions: list[bytes], pages: list[bytes], end: bool = True) -> bytes:
    parts = [cmd(OP_BEGIN, man)]
    for r in regions:
        parts.append(cmd(OP_REGION, r))
    for p in pages:
        parts.append(cmd(OP_PAGE, p))
    if end:
        parts.append(cmd(OP_END, b""))
    return b"".join(parts)


def valid_pack(
    *,
    pack_generation: int,
    payload: bytes,
    content_sha: bytes,
    schema_sha: bytes = SCHEMA_ID_R01,
    kind: int = KIND_SENTINEL,
) -> bytes:
    man = pack_header(
        pack_generation=pack_generation,
        schema_sha=schema_sha,
        content_sha=content_sha,
        region_count=1,
    )
    return stream(man, [region_desc(payload=payload, kind=kind)], [data_page(seq=1, region_id=0, offset=0, payload=payload)])


def pack_query(*, generation: int, txn_id: int = 1, corrupt_crc: bool = False) -> bytes:
    body = struct.pack(
        "<HBBIHHHIHIIH",
        MAGIC_QUERY,
        1,
        0x03,
        txn_id,
        generation & 0xFFFF,
        1,
        0x0000,
        0x00010100,
        9,
        0,
        0,
        64,
    )
    if len(body) != 30:
        raise RuntimeError(len(body))
    crc = crc16_ccitt_false(body)
    if corrupt_crc:
        crc ^= 0xFFFF
    return body + struct.pack("<H", crc)


def pack_result_illegal_status() -> bytes:
    """48 B StructuredResult-shaped record with illegal ASTRA status 0x00."""
    body = struct.pack(
        "<HBBBBBBIHHIIIIIIIBB",
        MAGIC_RESULT,
        1,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
    )
    if len(body) != 46:
        raise RuntimeError(len(body))
    return body + struct.pack("<H", crc16_ccitt_false(body))


@dataclass
class Expect:
    outcome: str
    reason: int
    ack: int
    reject: int
    generation_flipped: int
    header_bytes: int = HEADER_LENGTH
    active_generation_after: int | None = None
    query_status: int | None = None
    query_reason: int | None = None
    astra_status_forbidden: tuple = (ST_UNKNOWN, 0)


@dataclass
class Case:
    case_id: str
    group: str
    notes: str
    blob: bytes
    expect: Expect
    steps: list[dict] = field(default_factory=list)
    query_blob: bytes | None = None


def build_cases() -> list[Case]:
    cases: list[Case] = []

    def add(
        cid: str,
        group: str,
        notes: str,
        blob: bytes,
        outcome: str,
        reason: int,
        *,
        flip: int = 0,
        header_bytes: int = HEADER_LENGTH,
        active_after: int | None = None,
        query_status: int | None = None,
        query_reason: int | None = None,
        steps: list[dict] | None = None,
        query_blob: bytes | None = None,
    ) -> None:
        ack = 1 if outcome == OUTCOME_OK else 0
        rej = 0 if outcome == OUTCOME_OK else 1
        if query_status is not None and outcome != OUTCOME_OK:
            # Load may ACK while query-time integrity fails (R-04).
            pass
        cases.append(
            Case(
                cid,
                group,
                notes,
                blob,
                Expect(
                    outcome=outcome,
                    reason=reason,
                    ack=ack,
                    reject=rej,
                    generation_flipped=flip,
                    header_bytes=header_bytes,
                    active_generation_after=active_after,
                    query_status=query_status,
                    query_reason=query_reason,
                ),
                steps=steps or [],
                query_blob=query_blob,
            )
        )

    # --- 4 valid ---
    add(
        "PA24-V-01",
        "VALID",
        "valid 128 B LE gen=1 PAY_A SENTINEL",
        valid_pack(pack_generation=1, payload=PAY_A, content_sha=CONTENT_A),
        OUTCOME_OK,
        RC_OK,
        flip=1,
        active_after=1,
    )
    add(
        "PA24-V-02",
        "VALID",
        "valid gen=2 PAY_B standalone from UNSET",
        valid_pack(pack_generation=2, payload=PAY_B, content_sha=CONTENT_B),
        OUTCOME_OK,
        RC_OK,
        flip=1,
        active_after=2,
    )
    man3 = pack_header(
        pack_generation=3,
        region_count=2,
        schema_sha=SCHEMA_ID_R01,
        content_sha=CONTENT_NS,
        node_count=1,
    )
    stream3 = stream(
        man3,
        [
            region_desc(region_id=0, kind=KIND_NODE, ddr_offset=0, payload=PAY_N),
            region_desc(region_id=1, kind=KIND_SENTINEL, ddr_offset=16, payload=PAY_S),
        ],
        [
            data_page(seq=1, region_id=0, offset=0, payload=PAY_N),
            data_page(seq=2, region_id=1, offset=16, payload=PAY_S),
        ],
    )
    add(
        "PA24-V-03",
        "VALID",
        "valid 2-region NODE+SENTINEL both pages present",
        stream3,
        OUTCOME_OK,
        RC_OK,
        flip=1,
        active_after=3,
    )
    v4 = valid_pack(pack_generation=65535, payload=PAY_A, content_sha=CONTENT_A)
    add(
        "PA24-V-04",
        "VALID",
        "round-trip header 128 B LE pack_generation=65535",
        v4,
        OUTCOME_OK,
        RC_OK,
        flip=1,
        active_after=65535,
    )

    # --- 4 schema-hash ---
    schema_flip = bytearray(SCHEMA_ID_R01)
    schema_flip[0] ^= 0x01
    add(
        "PA24-S-01",
        "SCHEMA",
        "schema_sha bit0 flipped, header CRC recomputed",
        valid_pack(pack_generation=10, payload=PAY_A, content_sha=CONTENT_A, schema_sha=bytes(schema_flip)),
        OUTCOME_REJECT,
        RC_SCHEMA_MISMATCH,
    )
    add(
        "PA24-S-02",
        "SCHEMA",
        "schema_sha all-zero",
        valid_pack(pack_generation=11, payload=PAY_A, content_sha=CONTENT_A, schema_sha=b"\x00" * 32),
        OUTCOME_REJECT,
        RC_SCHEMA_MISMATCH,
    )
    add(
        "PA24-S-03",
        "SCHEMA",
        "schema_sha SCHEMA_ID_RIVAL",
        valid_pack(pack_generation=12, payload=PAY_A, content_sha=CONTENT_A, schema_sha=SCHEMA_ID_RIVAL),
        OUTCOME_REJECT,
        RC_SCHEMA_MISMATCH,
    )
    man_s4 = pack_header(
        pack_generation=13,
        schema_version=99,
        schema_sha=SCHEMA_ID_R01,
        content_sha=CONTENT_A,
    )
    add(
        "PA24-S-04",
        "SCHEMA",
        "schema_version=99 with matching identity — not ABI-OK",
        stream(man_s4, [region_desc(payload=PAY_A)], [data_page(seq=1, region_id=0, offset=0, payload=PAY_A)]),
        OUTCOME_REJECT,
        RC_SCHEMA_MISMATCH,
    )

    # --- 4 ABI ---
    add(
        "PA24-A-01",
        "ABI",
        "abi_version=99",
        cmd(OP_BEGIN, pack_header(abi_version=99, pack_generation=20, content_sha=CONTENT_A)),
        OUTCOME_REJECT,
        RC_ABI_MISMATCH,
    )
    be = pack_header(pack_generation=21, endian=">", content_sha=CONTENT_A)
    add(
        "PA24-A-02",
        "ABI",
        "ManifestHeader packed big-endian; magic bytes 31 49 41 4E",
        cmd(OP_BEGIN, be),
        OUTCOME_REJECT,
        RC_BAD_MAGIC,
    )
    rival132 = pack_header_rival_132()
    add(
        "PA24-A-03",
        "ABI",
        "BEGIN_PACK payload length 132 (reserved=16 rival)",
        cmd(OP_BEGIN, rival132),
        OUTCOME_REJECT,
        RC_HEADER_LENGTH,
        header_bytes=132,
    )
    add(
        "PA24-A-04",
        "ABI",
        "BEGIN_PACK truncated to 64 B (retired PackHeader)",
        cmd(OP_BEGIN, pack_header(pack_generation=23, content_sha=CONTENT_A)[:64]),
        OUTCOME_REJECT,
        RC_TRUNCATED,
        header_bytes=64,
    )

    # --- 4 content-hash ---
    add(
        "PA24-C-01",
        "CONTENT",
        "content_sha 32xEE vs PAY_A",
        valid_pack(pack_generation=30, payload=PAY_A, content_sha=b"\xee" * 32),
        OUTCOME_REJECT,
        RC_CONTENT_MISMATCH,
    )
    add(
        "PA24-C-02",
        "CONTENT",
        "content_sha all-zero",
        valid_pack(pack_generation=31, payload=PAY_A, content_sha=b"\x00" * 32),
        OUTCOME_REJECT,
        RC_CONTENT_MISMATCH,
    )
    add(
        "PA24-C-03",
        "CONTENT",
        "content_sha CONTENT_B while page is PAY_A",
        valid_pack(pack_generation=32, payload=PAY_A, content_sha=CONTENT_B),
        OUTCOME_REJECT,
        RC_CONTENT_MISMATCH,
    )
    add(
        "PA24-C-04",
        "CONTENT",
        "content_sha SHA256(PAY_A||0x00)",
        valid_pack(pack_generation=33, payload=PAY_A, content_sha=hashlib.sha256(PAY_A + b"\x00").digest()),
        OUTCOME_REJECT,
        RC_CONTENT_MISMATCH,
    )

    # --- 4 CRC / record ---
    add(
        "PA24-R-01",
        "CRC",
        "DATA_PAGE.payload_crc32 XOR; page bytes unchanged",
        stream(
            pack_header(pack_generation=40, content_sha=CONTENT_A),
            [region_desc(payload=PAY_A)],
            [data_page(seq=1, region_id=0, offset=0, payload=PAY_A, corrupt_crc=True)],
        ),
        OUTCOME_REJECT,
        RC_PAGE_CRC,
    )
    add(
        "PA24-R-02",
        "CRC",
        "manifest_crc32 XOR; reserved still zero",
        cmd(OP_BEGIN, pack_header(pack_generation=41, content_sha=CONTENT_A, corrupt_crc=True)),
        OUTCOME_REJECT,
        RC_MANIFEST_CRC,
    )
    add(
        "PA24-R-03",
        "CRC",
        "RegionDescriptor.region_crc32 XOR; page CRC still matches PAY_A",
        stream(
            pack_header(pack_generation=42, content_sha=CONTENT_A),
            [region_desc(payload=PAY_A, corrupt_crc=True)],
            [data_page(seq=1, region_id=0, offset=0, payload=PAY_A)],
        ),
        OUTCOME_REJECT,
        RC_PAGE_CRC,
    )
    inner = PAY_A + pack_query(generation=1, corrupt_crc=True) + pack_result_illegal_status()
    r4 = valid_pack(pack_generation=43, payload=inner, content_sha=hashlib.sha256(inner).digest())
    cases.append(
        Case(
            "PA24-R-04",
            "CRC",
            "page CRC valid; inner QueryRecord CRC16 flipped + illegal ASTRA status 0x00",
            r4,
            Expect(
                outcome=OUTCOME_OK,
                reason=RC_OK,
                ack=1,
                reject=0,
                generation_flipped=1,
                header_bytes=128,
                active_generation_after=43,
                query_status=ST_DATA_INTEGRITY_FAIL,
                query_reason=RC_PACK_CRC,
            ),
            query_blob=pack_query(generation=43, txn_id=2, corrupt_crc=False),
        )
    )

    # --- 4 generation / A-B ---
    g01_a = valid_pack(pack_generation=1, payload=PAY_A, content_sha=CONTENT_A)
    g01_b = valid_pack(pack_generation=2, payload=PAY_B, content_sha=CONTENT_B)
    cases.append(
        Case(
            "PA24-G-01",
            "GENERATION",
            "A-B atomic success: COMMIT gen=1 then gen=2 into inactive slot",
            g01_b,
            Expect(
                outcome=OUTCOME_OK,
                reason=RC_OK,
                ack=1,
                reject=0,
                generation_flipped=1,
                header_bytes=128,
                active_generation_after=2,
            ),
            steps=[
                {
                    "step": 1,
                    "blob_role": "pack_gen_1",
                    "outcome": OUTCOME_OK,
                    "reason": RC_OK,
                    "active_after": 1,
                    "blob_hex": g01_a.hex(),
                },
                {
                    "step": 2,
                    "blob_role": "pack_gen_2",
                    "outcome": OUTCOME_OK,
                    "reason": RC_OK,
                    "active_after": 2,
                    "blob_hex": g01_b.hex(),
                },
            ],
        )
    )
    add(
        "PA24-G-02",
        "GENERATION",
        "pack_generation=0 illegal; no silent map to knowledge_generation=0",
        cmd(OP_BEGIN, pack_header(pack_generation=0, content_sha=CONTENT_A)),
        OUTCOME_REJECT,
        RC_UNSUPPORTED,
        active_after=UNSET_GENERATION,
    )
    add(
        "PA24-G-03",
        "GENERATION",
        "pack_generation=0x00010000; must not truncate to u16",
        cmd(OP_BEGIN, pack_header(pack_generation=0x00010000, content_sha=CONTENT_A)),
        OUTCOME_REJECT,
        RC_UNSUPPORTED,
        active_after=UNSET_GENERATION,
    )
    fail_b = stream(
        pack_header(pack_generation=3, content_sha=CONTENT_A),
        [region_desc(payload=PAY_A)],
        [data_page(seq=1, region_id=0, offset=0, payload=PAY_A, corrupt_crc=True)],
    )
    rewind = valid_pack(pack_generation=1, payload=PAY_A, content_sha=CONTENT_A)
    cases.append(
        Case(
            "PA24-G-04",
            "GENERATION",
            "stale query gen=1 after active=2; failed gen=3 PAGE_CRC; rewind pack gen=1 is STALE_PACK_GENERATION",
            fail_b,
            Expect(
                outcome=OUTCOME_REJECT,
                reason=RC_PAGE_CRC,
                ack=0,
                reject=1,
                generation_flipped=0,
                header_bytes=128,
                active_generation_after=2,
                query_status=ST_DATA_INTEGRITY_FAIL,
                query_reason=RC_STALE_GENERATION,
            ),
            steps=[
                {"step": "prior", "note": "PA24-G-01 complete", "active": 2},
                {
                    "step": "query",
                    "knowledge_generation": 1,
                    "status": ST_DATA_INTEGRITY_FAIL,
                    "reason": RC_STALE_GENERATION,
                    "never": ["UNKNOWN", "status_0x00"],
                },
                {"step": "failed_B", "outcome": OUTCOME_REJECT, "reason": RC_PAGE_CRC, "active_stays": 2},
                {
                    "step": "rewind_pack_gen_1",
                    "outcome": OUTCOME_REJECT,
                    "reason": RC_STALE_PACK_GENERATION,
                    "blob_hex": rewind.hex(),
                },
            ],
            query_blob=pack_query(generation=1, txn_id=9),
        )
    )
    return cases


def selfcheck(cases: list[Case]) -> list[str]:
    err: list[str] = []
    if len(cases) != 24:
        err.append(f"count {len(cases)} != 24")
    ids = [c.case_id for c in cases]
    if len(set(ids)) != 24:
        err.append("duplicate case_id")
    groups: dict[str, int] = {}
    for c in cases:
        groups[c.group] = groups.get(c.group, 0) + 1
    want = {"VALID": 4, "SCHEMA": 4, "ABI": 4, "CONTENT": 4, "CRC": 4, "GENERATION": 4}
    if groups != want:
        err.append(f"groups {groups} != {want}")

    sample = b"NAI1-pack-prefix-check" + bytes(range(80))
    if crc32_iso_hdlc(sample) != (zlib.crc32(sample) & 0xFFFFFFFF):
        err.append("crc32_iso_hdlc != zlib.crc32")

    field_sizes = [4, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4, 32, 32, 4, 2, 2, 4, 12]
    if sum(field_sizes) != 128:
        err.append(f"ManifestHeader field sum {sum(field_sizes)} != 128")
    if sum(field_sizes[:17]) != 112:
        err.append("CRC coverage prefix != 112")

    if SCHEMA_ID_R01 == DUT_CLONE_SCHEMA or CONTENT_A == DUT_CLONE_CONTENT:
        err.append("campaign identity cloned DUT 0x11/0x22 filler")
    if SCHEMA_ID_R01 == SCHEMA_ID_RIVAL:
        err.append("schema identities collided")
    if CONTENT_A == CONTENT_B:
        err.append("PAY_A/PAY_B content identity collided")

    h = pack_header(pack_generation=1)
    if len(h) != 128:
        err.append("LE header not 128")
    u = unpack_header(h)
    if not u["crc_ok"] or u["pack_generation"] != 1 or not u["reserved_zero"]:
        err.append(f"round-trip header {u}")
    if u["schema_sha"] != SCHEMA_ID_R01.hex():
        err.append("default schema identity is not SCHEMA_ID_R01")

    rival = pack_header_rival_132()
    if len(rival) != 132:
        err.append(f"rival header {len(rival)} != 132")
    if unpack_header(rival)["header_length"] != 132:
        err.append("rival header_length field not 132")

    be = pack_header(endian=">", pack_generation=1)
    if be[:4] != bytes.fromhex("3149414E"):
        err.append(f"BE magic bytes {be[:4].hex()} != 3149414E")

    by = {c.case_id: c for c in cases}
    required = [
        "PA24-V-01",
        "PA24-V-02",
        "PA24-V-03",
        "PA24-V-04",
        "PA24-S-01",
        "PA24-S-02",
        "PA24-S-03",
        "PA24-S-04",
        "PA24-A-01",
        "PA24-A-02",
        "PA24-A-03",
        "PA24-A-04",
        "PA24-C-01",
        "PA24-C-02",
        "PA24-C-03",
        "PA24-C-04",
        "PA24-R-01",
        "PA24-R-02",
        "PA24-R-03",
        "PA24-R-04",
        "PA24-G-01",
        "PA24-G-02",
        "PA24-G-03",
        "PA24-G-04",
    ]
    for rid in required:
        if rid not in by:
            err.append(f"missing {rid}")

    def _opcodes(blob: bytes) -> list[int]:
        ops = []
        i = 0
        while i + 4 <= len(blob):
            op, _flags, plen = struct.unpack_from("<BBH", blob, i)
            ops.append(op)
            i += 4 + plen
        return ops

    if "PA24-V-03" in by:
        ops = _opcodes(by["PA24-V-03"].blob)
        if ops.count(OP_PAGE) != 2 or ops.count(OP_REGION) != 2:
            err.append(f"PA24-V-03 opcodes {ops} need 2 REGION + 2 PAGE")

    if "PA24-A-02" in by and by["PA24-A-02"].blob[4:8] != bytes.fromhex("3149414E"):
        # cmd header is 4 B then BEGIN payload; magic is payload[0:4]
        payload = by["PA24-A-02"].blob[4:]
        if payload[:4] != bytes.fromhex("3149414E"):
            err.append(f"PA24-A-02 magic {payload[:4].hex()} != 3149414E")

    if "PA24-A-03" in by:
        begin_len = struct.unpack_from("<H", by["PA24-A-03"].blob, 2)[0]
        if begin_len != 132:
            err.append(f"PA24-A-03 BEGIN length {begin_len} != 132")
        if by["PA24-A-03"].expect.reason != RC_HEADER_LENGTH:
            err.append("132 rival not HEADER_LENGTH")

    if "PA24-A-04" in by:
        begin_len = struct.unpack_from("<H", by["PA24-A-04"].blob, 2)[0]
        if begin_len != 64:
            err.append(f"PA24-A-04 BEGIN length {begin_len} != 64")

    if "PA24-G-01" in by and len(by["PA24-G-01"].steps) != 2:
        err.append("PA24-G-01 must be a two-step A-B sequence")
    if "PA24-G-03" in by and by["PA24-G-03"].expect.reason != RC_UNSUPPORTED:
        err.append("wide pack_generation must not truncate")
    if "PA24-G-04" in by:
        if by["PA24-G-04"].expect.query_reason != RC_STALE_GENERATION:
            err.append("PA24-G-04 stale query must be STALE_GENERATION")
        if not any(s.get("reason") == RC_STALE_PACK_GENERATION for s in by["PA24-G-04"].steps):
            err.append("PA24-G-04 missing rewind STALE_PACK_GENERATION")

    if "PA24-R-04" in by:
        c = by["PA24-R-04"]
        if c.expect.outcome != OUTCOME_OK:
            err.append("PA24-R-04 load may ACK when page CRC is valid")
        if c.expect.query_status != ST_DATA_INTEGRITY_FAIL:
            err.append("PA24-R-04 query must be DATA_INTEGRITY_FAIL")
        if c.expect.query_status in (ST_UNKNOWN, 0):
            err.append("PA24-R-04 mapped to UNKNOWN or status 0")

    crc_reasons = {by[k].expect.reason for k in ("PA24-R-01", "PA24-R-02", "PA24-R-03") if k in by}
    if RC_RESERVED_NZ in crc_reasons:
        err.append("CRC group must not hide RESERVED_NZ")

    for c in cases:
        if c.expect.outcome == "UNKNOWN":
            err.append(f"{c.case_id} mapped load outcome to UNKNOWN")
        if c.expect.query_status in (ST_UNKNOWN, 0):
            err.append(f"{c.case_id} query status UNKNOWN or 0x00")
        if c.group == "VALID" and c.expect.outcome != OUTCOME_OK:
            err.append(f"{c.case_id} valid not OK")
        if c.group in ("SCHEMA", "ABI", "CONTENT") and c.expect.outcome != OUTCOME_REJECT:
            err.append(f"{c.case_id} {c.group} not REJECT")
        if "pack_vectors" in sys.modules:
            err.append("pack_vectors imported")
    return err


def emit_artifacts(out: Path, cases: list[Case]) -> dict:
    out.mkdir(parents=True, exist_ok=True)
    jsonl = out / "pack_abi24_cases.jsonl"
    with jsonl.open("w", encoding="utf-8") as f:
        for c in cases:
            rec = {
                "case_id": c.case_id,
                "group": c.group,
                "notes": c.notes,
                "blob_hex": c.blob.hex(),
                "blob_len": len(c.blob),
                "query_blob_hex": None if c.query_blob is None else c.query_blob.hex(),
                "steps": c.steps,
                "expect": {
                    "outcome": c.expect.outcome,
                    "reason": c.expect.reason,
                    "ack": c.expect.ack,
                    "reject": c.expect.reject,
                    "generation_flipped": c.expect.generation_flipped,
                    "header_bytes": c.expect.header_bytes,
                    "active_generation_after": c.expect.active_generation_after,
                    "query_status": c.expect.query_status,
                    "query_reason": c.expect.query_reason,
                    "never_status": ["UNKNOWN", "ASTRA_0x00"],
                },
            }
            f.write(json.dumps(rec, sort_keys=True, separators=(",", ":")) + "\n")
            (out / f"{c.case_id}.bin").write_bytes(c.blob)
            words = c.blob + (b"\x00" * ((-len(c.blob)) % 4))
            mem = [f"{len(words)//4:08x}"] + [
                f"{struct.unpack_from('<I', words, i)[0]:08x}" for i in range(0, len(words), 4)
            ]
            (out / f"{c.case_id}.mem").write_text("\n".join(mem) + "\n", encoding="ascii")

    emit_expect_svh(out, cases)
    emit_expect_tsv(out, cases)

    (out / "pack_abi24_constants.svh").write_text(
        f"""// AGENT_B Pack/ABI-24 constants. Not DUT RTL. PROGRAM=NO.
`ifndef PACK_ABI24_CONSTANTS_SVH
`define PACK_ABI24_CONSTANTS_SVH
localparam integer PACK_HDR_BYTES = 128;
localparam integer PACK_HDR_PREFIX = 112;
localparam integer PACK_HDR_RESERVED = 12;
localparam [31:0] PACK_MAGIC_NAI1 = 32'h3149414E;
localparam [7:0] PACK_RC_OK = 8'h00;
localparam [7:0] PACK_RC_BAD_MAGIC = 8'h01;
localparam [7:0] PACK_RC_ABI_MISMATCH = 8'h02;
localparam [7:0] PACK_RC_SCHEMA_MISMATCH = 8'h03;
localparam [7:0] PACK_RC_MANIFEST_CRC = 8'h04;
localparam [7:0] PACK_RC_PAGE_CRC = 8'h05;
localparam [7:0] PACK_RC_UNSUPPORTED = 8'h07;
localparam [7:0] PACK_RC_HEADER_LENGTH = 8'h09;
localparam [7:0] PACK_RC_RESERVED_NZ = 8'h0A;
localparam [7:0] PACK_RC_CONTENT_MISMATCH = 8'h0D;
localparam [7:0] PACK_RC_STALE_PACK_GENERATION = 8'h0E;
localparam [7:0] PACK_RC_TRUNCATED = 8'h0F;
localparam integer PACK_ABI24_N = 24;
localparam [255:0] PACK_SCHEMA_ID_R01 = 256'h{SCHEMA_ID_R01.hex()};
`endif
""",
        encoding="utf-8",
    )
    law = {
        "pass_fail_law": [
            "Compare DUT load_ack/load_reject/reason/generation_flipped/header_bytes to expect per case_id.",
            "Header wire size is 128. BEGIN payload 132 is HEADER_LENGTH. BEGIN payload 64 is TRUNCATED.",
            "pack_generation u32 must not be truncated to knowledge_generation u16.",
            "Never map pack reasons to ASTRA UNKNOWN. Never treat ASTRA status 0x00 as lawful.",
            "schema_sha256/content_sha256 are FPGA stored-identity compares, not FPGA SHA-256. Do not claim FPGA_SHA256_VERIFIED.",
            "PA24-R-04: page-CRC-only ACK is allowed; query of that generation must DATA_INTEGRITY_FAIL, never ANSWER/UNKNOWN/status 0x00.",
            "PA24-G-01 is a two-step A-B commit. PA24-G-04 keeps active_generation=2 on failed B.",
            "XSim match is XSIM evidence only. Not BOARD_PASS. Not PACK_ABI_24_24_PASS until DUT matches all 24.",
            "Do not import python/m1/pack_vectors.py as the gold encoder or as the DUT encoder.",
            "Appendix (not in 24): RESERVED_NZ, SENTINEL_MISMATCH, SEQ_GAP, DRAIN_ERR, region_count=0.",
        ],
        "schema_id_r01": SCHEMA_ID_R01.hex(),
        "schema_id_rival": SCHEMA_ID_RIVAL.hex(),
        "content_a": CONTENT_A.hex(),
        "content_b": CONTENT_B.hex(),
        "content_ns": CONTENT_NS.hex(),
        "schema_label_r01": SCHEMA_LABEL_R01.decode("ascii"),
        "schema_label_rival": SCHEMA_LABEL_RIVAL.decode("ascii"),
    }
    (out / "pack_abi24_pass_law.json").write_text(json.dumps(law, indent=2) + "\n", encoding="utf-8")
    man = {
        "spec": "PACK_ABI_24_R0_1_AGENT_B",
        "stamp": "PACK_ABI24_GOLD_CANDIDATE",
        "n_cases": 24,
        "header_bytes": 128,
        "reserved_bytes": 12,
        "crc": "CRC-32/ISO-HDLC over [0:112)",
        "magic": hex(MAGIC_NAI1),
        "endianness": "little",
        "schema_id_r01": SCHEMA_ID_R01.hex(),
        "cases_sha256": hashlib.sha256(jsonl.read_bytes()).hexdigest(),
        "harness": "verification/pack_abi24/tb_pack_abi24_xsim_compare.sv",
        "host_compare": "python pack_abi24_gold.py --compare DUT.jsonl",
        "note": "CANDIDATE gold. PACK_ABI_24_24_PASS only after DUT matches all 24. XSim!=board. Generator selfcheck is not a ladder stamp.",
    }
    (out / "pack_abi24_manifest.json").write_text(json.dumps(man, indent=2) + "\n", encoding="utf-8")
    root = Path(__file__).resolve().parent
    (root / "pack_abi24_constants.svh").write_text(
        (out / "pack_abi24_constants.svh").read_text(encoding="utf-8"), encoding="utf-8"
    )
    (root / "pack_abi24_fopen.svh").write_text(
        (out / "pack_abi24_fopen.svh").read_text(encoding="utf-8"), encoding="utf-8"
    )
    return man


def emit_expect_tsv(out: Path, cases: list[Case]) -> None:
    lines = [
        "case_id\toutcome\treason\tack\treject\tflip\theader_bytes\tquery_status\tquery_reason\tn_steps\tblob_len"
    ]
    for c in cases:
        qs = "" if c.expect.query_status is None else str(c.expect.query_status)
        qr = "" if c.expect.query_reason is None else str(c.expect.query_reason)
        lines.append(
            f"{c.case_id}\t{c.expect.outcome}\t{c.expect.reason}\t{c.expect.ack}\t"
            f"{c.expect.reject}\t{c.expect.generation_flipped}\t{c.expect.header_bytes}\t"
            f"{qs}\t{qr}\t{len(c.steps)}\t{len(c.blob)}"
        )
    (out / "pack_abi24_expect.tsv").write_text("\n".join(lines) + "\n", encoding="utf-8")


def emit_expect_svh(out: Path, cases: list[Case]) -> None:
    if len(cases) != 24:
        raise RuntimeError("expect table requires 24 cases")
    max_words = max((len(c.blob) + 3) // 4 for c in cases)
    lines = [
        "// Auto-generated by pack_abi24_gold.py. Icarus-friendly. Not DUT RTL. PROGRAM=NO.",
        "`ifndef PACK_ABI24_EXPECT_SVH",
        "`define PACK_ABI24_EXPECT_SVH",
        f"localparam integer PACK_ABI24_MAX_WORDS = {max_words};",
        "localparam [8:0] PACK_ABI24_QNA = 9'h1FF;",
        "reg [8*12-1:0] PA24_ID [0:23];",
        "reg [7:0] PA24_REASON [0:23];",
        "reg PA24_ACK [0:23];",
        "reg PA24_REJ [0:23];",
        "reg PA24_FLIP [0:23];",
        "integer PA24_HDR_BYTES [0:23];",
        "reg [8:0] PA24_QSTATUS [0:23];",
        "reg [8:0] PA24_QREASON [0:23];",
        "integer PA24_NSTEPS [0:23];",
        "initial begin",
    ]
    for i, c in enumerate(cases):
        qs = 0x1FF if c.expect.query_status is None else c.expect.query_status
        qr = 0x1FF if c.expect.query_reason is None else c.expect.query_reason
        nst = max(1, len(c.steps))
        lines.append(f'  PA24_ID[{i}] = "{c.case_id}";')
        lines.append(f"  PA24_REASON[{i}] = 8'h{c.expect.reason:02X};")
        lines.append(f"  PA24_ACK[{i}] = 1'b{c.expect.ack};")
        lines.append(f"  PA24_REJ[{i}] = 1'b{c.expect.reject};")
        lines.append(f"  PA24_FLIP[{i}] = 1'b{c.expect.generation_flipped};")
        lines.append(f"  PA24_HDR_BYTES[{i}] = {c.expect.header_bytes};")
        lines.append(f"  PA24_QSTATUS[{i}] = 9'h{qs:03X};")
        lines.append(f"  PA24_QREASON[{i}] = 9'h{qr:03X};")
        lines.append(f"  PA24_NSTEPS[{i}] = {nst};")
    lines.append("end")
    lines.append("`endif")
    lines.append("")
    (out / "pack_abi24_expect.svh").write_text("\n".join(lines), encoding="utf-8")
    (out / "pack_abi24_case_ids.txt").write_text(
        "\n".join(c.case_id for c in cases) + "\n", encoding="ascii"
    )
    fopen_lines = [
        "function integer pa24_fopen_mem;",
        "  input integer rec;",
        "  begin",
        "    case (rec)",
    ]
    for i, c in enumerate(cases):
        fopen_lines.append(f'      {i}: pa24_fopen_mem = $fopen("out/{c.case_id}.mem", "r");')
    fopen_lines.append("      default: pa24_fopen_mem = 0;")
    fopen_lines.append("    endcase")
    fopen_lines.append("  end")
    fopen_lines.append("endfunction")
    fopen_lines.append("")
    (out / "pack_abi24_fopen.svh").write_text("\n".join(fopen_lines), encoding="utf-8")
    (Path(__file__).resolve().parent / "pack_abi24_fopen.svh").write_text(
        "\n".join(fopen_lines), encoding="utf-8"
    )


def gold_dut_rows(cases: list[Case]) -> list[dict]:
    rows = []
    for c in cases:
        rec = {
            "case_id": c.case_id,
            "outcome": c.expect.outcome,
            "reason": c.expect.reason,
            "ack": c.expect.ack,
            "reject": c.expect.reject,
            "generation_flipped": c.expect.generation_flipped,
            "header_bytes": c.expect.header_bytes,
        }
        if c.expect.query_status is not None:
            rec["query_status"] = c.expect.query_status
            rec["query_reason"] = c.expect.query_reason
        rows.append(rec)
    return rows


def compare_dut(path: Path, cases: list[Case]) -> int:
    rows = [json.loads(l) for l in path.read_text(encoding="utf-8").splitlines() if l.strip()]
    by = {r["case_id"]: r for r in rows}
    nfail = 0
    for c in cases:
        d = by.get(c.case_id)
        if not d:
            print(f"FAIL {c.case_id}: missing DUT row")
            nfail += 1
            continue
        exp = c.expect
        for k, v in (("outcome", exp.outcome), ("reason", exp.reason), ("ack", exp.ack), ("reject", exp.reject)):
            if d.get(k) != v:
                print(f"FAIL {c.case_id}: {k} got {d.get(k)} expected {v}")
                nfail += 1
        if d.get("generation_flipped") != exp.generation_flipped:
            print(f"FAIL {c.case_id}: generation_flipped got {d.get('generation_flipped')} expected {exp.generation_flipped}")
            nfail += 1
        if d.get("status") in exp.astra_status_forbidden:
            print(f"FAIL {c.case_id}: mapped to forbidden {d.get('status')}")
            nfail += 1
        if d.get("query_status") in (ST_UNKNOWN, 0):
            print(f"FAIL {c.case_id}: query_status {d.get('query_status')} forbidden")
            nfail += 1
        if exp.query_status is not None and d.get("query_status") != exp.query_status:
            print(f"FAIL {c.case_id}: query_status got {d.get('query_status')} expected {exp.query_status}")
            nfail += 1
        if exp.query_reason is not None and d.get("query_reason") != exp.query_reason:
            print(f"FAIL {c.case_id}: query_reason got {d.get('query_reason')} expected {exp.query_reason}")
            nfail += 1
    print(f"compare {24 - nfail}/24 match, {nfail} fail")
    return 1 if nfail else 0


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--emit", type=Path, default=None)
    ap.add_argument("--selfcheck", action="store_true")
    ap.add_argument("--compare", type=Path, default=None)
    args = ap.parse_args(argv)
    cases = build_cases()
    errors = selfcheck(cases)
    if args.emit:
        man = emit_artifacts(args.emit, cases)
        print(json.dumps(man, indent=2))
    if args.compare:
        rc = compare_dut(args.compare, cases)
        if rc:
            return rc
    if errors:
        print("SELFCHECK FAIL:", file=sys.stderr)
        for e in errors:
            print("  -", e, file=sys.stderr)
        return 1
    print("SELFCHECK: 24/24 Pack/ABI gold generator (not PACK_ABI_24_24_PASS)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
