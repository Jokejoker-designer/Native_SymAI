#!/usr/bin/env python3
"""CANDIDATE M1 pack vectors. Not Agent B gold. CRC-32/ISO-HDLC = zlib.crc32."""
from __future__ import annotations

import struct
import zlib
from pathlib import Path

MAGIC = 0x3149414E  # NAI1 little-endian
MANIFEST_VERSION = 1
ABI_VERSION = 1
SCHEMA_VERSION = 1
PAGE_SIZE = 256
HEADER_LENGTH = 128
PAGE_CRC_SCHEME = 1

OP_BEGIN = 0x01
OP_REGION = 0x02
OP_PAGE = 0x03
OP_END = 0x04

KIND_SENTINEL = 8
OUT = Path(__file__).resolve().parents[2] / "tb" / "native_ai" / "loader" / "vectors"


def u32(x: int) -> bytes:
    return struct.pack("<I", x & 0xFFFFFFFF)


def u16(x: int) -> bytes:
    return struct.pack("<H", x & 0xFFFF)


def cmd(opcode: int, payload: bytes, flags: int = 0) -> bytes:
    if len(payload) > 0xFFFF:
        raise ValueError("payload too large")
    return struct.pack("<BBH", opcode, flags, len(payload)) + payload


def manifest(*, magic: int = MAGIC, abi: int = ABI_VERSION, generation: int = 7,
             region_count: int = 1, schema_sha: bytes | None = None,
             content_sha: bytes | None = None) -> bytes:
    schema_sha = schema_sha or (b"\x11" * 32)
    content_sha = content_sha or (b"\x22" * 32)
    body = b"".join([
        u32(magic),
        u16(MANIFEST_VERSION),
        u16(abi),
        u16(SCHEMA_VERSION),
        u16(0),
        u32(generation),
        u32(1),  # node_count identity only
        u32(0),
        u32(0),
        u32(0),
        u32(0),
        u32(region_count),
        schema_sha,
        content_sha,
        u32(PAGE_SIZE),
        u16(HEADER_LENGTH),
        u16(PAGE_CRC_SCHEME),
    ])
    assert len(body) == 112, len(body)
    crc = zlib.crc32(body) & 0xFFFFFFFF
    hdr = body + u32(crc) + (b"\x00" * 12)
    assert len(hdr) == 128, len(hdr)
    return hdr


def region_desc(*, region_id: int = 0, kind: int = KIND_SENTINEL, ddr_offset: int = 0,
                payload: bytes = b"", sentinel: int = 0xA5A5A5A5) -> bytes:
    crc = zlib.crc32(payload) & 0xFFFFFFFF
    desc = b"".join([
        bytes([region_id & 0xFF, kind & 0xFF]),
        u16(0),
        u32(ddr_offset),
        u32(len(payload)),
        u16(4),
        u16(1),
        u32(max(1, len(payload) // 4)),
        u32(crc),
        u32(sentinel),
        u32(0),
    ])
    assert len(desc) == 32, len(desc)
    return desc


def data_page(*, seq: int, region_id: int, offset: int, payload: bytes,
              corrupt_crc: bool = False) -> bytes:
    crc = zlib.crc32(payload) & 0xFFFFFFFF
    if corrupt_crc:
        crc ^= 0xFFFFFFFF
    header = b"".join([
        u16(seq),
        bytes([region_id & 0xFF, 0]),
        u32(offset),
        u16(len(payload)),
        u16(0),
        u32(crc),
    ])
    assert len(header) == 16
    pad = (-len(payload)) % 4
    return header + payload + (b"\x00" * pad)


def pack_valid() -> bytes:
    payload = u32(0xA5A5A5A5) + u32(0x11111111) + u32(0x22222222) + u32(0x33333333)
    man = manifest()
    reg = region_desc(payload=payload, sentinel=0xA5A5A5A5)
    page = data_page(seq=1, region_id=0, offset=0, payload=payload)
    return b"".join([
        cmd(OP_BEGIN, man),
        cmd(OP_REGION, reg),
        cmd(OP_PAGE, page),
        cmd(OP_END, b""),
    ])


def pack_bad_magic() -> bytes:
    # BEGIN only: reject is sticky and s_ready drops (avoids TB deadlock).
    return cmd(OP_BEGIN, manifest(magic=0xDEADBEEF))


def pack_bad_abi() -> bytes:
    return cmd(OP_BEGIN, manifest(abi=99))


def pack_bad_page_crc() -> bytes:
    payload = u32(0xA5A5A5A5)
    man = manifest()
    reg = region_desc(payload=payload)
    page = data_page(seq=1, region_id=0, offset=0, payload=payload, corrupt_crc=True)
    return b"".join([
        cmd(OP_BEGIN, man),
        cmd(OP_REGION, reg),
        cmd(OP_PAGE, page),
    ])


def to_words(blob: bytes) -> list[int]:
    pad = (-len(blob)) % 4
    blob = blob + (b"\x00" * pad)
    return [struct.unpack_from("<I", blob, i)[0] for i in range(0, len(blob), 4)]


def write_mem(name: str, blob: bytes) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    words = to_words(blob)
    path = OUT / name
    lines = [f"{len(words):08x}"] + [f"{w:08x}" for w in words]
    path.write_text("\n".join(lines) + "\n", encoding="ascii")
    print(f"wrote {path} words={len(words)}")


def main() -> None:
    write_mem("v1_valid.mem", pack_valid())
    write_mem("v2_bad_magic.mem", pack_bad_magic())
    write_mem("v3_bad_abi.mem", pack_bad_abi())
    write_mem("v4_bad_page_crc.mem", pack_bad_page_crc())
    write_mem("v5_valid_drain.mem", pack_valid())


if __name__ == "__main__":
    main()
