"""Emit QueryRecord mem + G-01 step-1 from B gold. Does not modify gold.py."""
from __future__ import annotations

import importlib.util
import struct
import sys
from pathlib import Path

GOLD = Path(
    r"D:\FPGA\Native_SymAI\CANON_BLUEPRINT\verification\pack_abi24\pack_abi24_gold.py"
)
OUT = Path(r"D:\FPGA\arty_d\pack_abi24_obs_dut\xsim\out")


def blob_mem(blob: bytes) -> str:
    words = blob + (b"\x00" * ((-len(blob)) % 4))
    lines = [f"{len(words) // 4:08x}"] + [
        f"{struct.unpack_from('<I', words, i)[0]:08x}" for i in range(0, len(words), 4)
    ]
    return "\n".join(lines) + "\n"


def main() -> int:
    spec = importlib.util.spec_from_file_location("pack_abi24_gold", GOLD)
    if spec is None or spec.loader is None:
        print("GOLD_MISSING")
        return 2
    mod = importlib.util.module_from_spec(spec)
    sys.modules["pack_abi24_gold"] = mod
    spec.loader.exec_module(mod)
    OUT.mkdir(parents=True, exist_ok=True)
    for c in mod.build_cases():
        if c.query_blob:
            (OUT / f"{c.case_id}.query.mem").write_text(blob_mem(c.query_blob), encoding="ascii")
            print("query", c.case_id, len(c.query_blob))
        if c.case_id == "PA24-G-01" and c.steps:
            hex0 = c.steps[0].get("blob_hex")
            if hex0:
                (OUT / "PA24-G-01.step1.mem").write_text(blob_mem(bytes.fromhex(hex0)), encoding="ascii")
                print("g01_step1", len(hex0) // 2)
    print("PACK_ABI_24_24_PASS=NO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
