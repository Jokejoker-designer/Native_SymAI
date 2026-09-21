#!/usr/bin/env python3
"""D-owned directory-bearing Pack emitter for CT1. Does not edit pack_abi24_gold.py.

Imports gold helpers read-only so CRC/ABI-24 framing matches V-04 GOLD.
PROGRAM=NO. Not PACK_ABI_24_24_PASS.
"""
from __future__ import annotations

import hashlib
import struct
import sys
from pathlib import Path

GOLD = Path(r"D:\FPGA\Native_SymAI\CANON_BLUEPRINT\verification\pack_abi24")
sys.path.insert(0, str(GOLD))
import pack_abi24_gold as g  # noqa: E402  read-only

SID_A = 0x00010100
NB_B = 0x00020100
NB_C = 0x00030100
GEN_B = 0x000000B1
GEN_C = 0x000000C1


def hot_dir_entry(sid: int, fwd: int, rev: int = 0, gen: int = 1, kind: int = 1, flags: int = 0) -> bytes:
    """§02.4.2 HotDirectoryEntry 128b as used by exact_directory."""
    return struct.pack("<IIIHBB", sid & 0xFFFFFFFF, fwd & 0xFFFFFFFF, rev & 0xFFFFFFFF, gen & 0xFFFF, kind & 0xFF, flags & 0xFF)


def to_mem(blob: bytes) -> str:
    if len(blob) % 4:
        blob += b"\x00" * (4 - (len(blob) % 4))
    words = [struct.unpack_from("<I", blob, i)[0] for i in range(0, len(blob), 4)]
    lines = [f"{len(words):08x}"] + [f"{w:08x}" for w in words]
    return "\n".join(lines) + "\n"


def emit_pack(payload: bytes, pack_generation: int) -> bytes:
    content = hashlib.sha256(payload).digest()
    return g.valid_pack(pack_generation=pack_generation, payload=payload, content_sha=content, kind=g.KIND_SENTINEL)


def main() -> int:
    out = Path(__file__).resolve().parent / "xsim" / "ct1"
    out.mkdir(parents=True, exist_ok=True)
    packs = {
        "CT1-A2B.mem": emit_pack(hot_dir_entry(SID_A, NB_B, gen=0x00B1), GEN_B),
        "CT1-A2C.mem": emit_pack(hot_dir_entry(SID_A, NB_C, gen=0x00C1), GEN_C),
    }
    for name, blob in packs.items():
        (out / name).write_text(to_mem(blob), encoding="ascii")
        print(f"{name} words={len(blob)//4} sha256={hashlib.sha256(blob).hexdigest()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
