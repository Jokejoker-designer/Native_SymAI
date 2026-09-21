"""Isolated G-04 R1 order: G-01 two-step then fail_B then stale query.

Does not CLEAR between. Does not invent flip=0. Does not overwrite Pack24 jsonl.
PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. No reprogram.
"""
from __future__ import annotations

import json
import struct
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u33obs")
from u33obs_hops import (  # noqa: E402
    OUT,
    PROG_QUERY,
    WANT_QUERY,
    dump_tap,
    find_port,
    kill_jtag,
    now_iso,
    open_mark,
    parse_program_txt,
    read_buf,
    rec_of,
    send_clear_until_ack,
    send_words,
)
from u33obs_pack24 import load_mem  # noqa: E402

sys.path.insert(0, r"D:\FPGA\Native_SymAI\docs\audits\20260919_u33_discriminator")
from uart_token_to_compare import parse_query_word  # noqa: E402

STEP1 = Path(r"D:\FPGA\arty_d\pack_abi24_obs_dut\xsim\out\PA24-G-01.step1.mem")
MEM = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)
GOLD_PY = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\pack_abi24_gold.py"
)


def load_mem_path(path: Path) -> list[int]:
    lines = [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]
    nwords = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + nwords]]
    if len(words) != nwords:
        raise ValueError(f"{path.name} short")
    return words


def query_words(cid: str) -> list[int]:
    import importlib.util

    spec = importlib.util.spec_from_file_location("pack_abi24_gold", GOLD_PY)
    if spec is None or spec.loader is None:
        raise RuntimeError("gold missing")
    mod = importlib.util.module_from_spec(spec)
    sys.modules["pack_abi24_gold"] = mod
    spec.loader.exec_module(mod)
    blob = None
    for c in mod.build_cases():
        if c.case_id == cid:
            blob = c.query_blob
            break
    if not blob:
        raise RuntimeError(f"no query_blob {cid}")
    pad = blob + (b"\x00" * ((-len(blob)) % 4))
    return [struct.unpack_from("<I", pad, i)[0] for i in range(0, len(pad), 4)]


def main() -> int:
    prog = parse_program_txt(PROG_QUERY)
    sha = (prog.get("SHA256") or "").lower()
    out = {
        "when": now_iso(),
        "want_sha256": WANT_QUERY,
        "program_txt": prog,
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "dest_wipe": "NO",
        "order": "G-01 two-step then fail_B then QueryRecord gen=1",
        "recs": [],
    }
    if prog.get("STATUS") != "PROGRAMMED" or sha != WANT_QUERY:
        print("ISO_REFUSED need 8fc14f25", sha)
        return 4
    kill_jtag()
    time.sleep(0.5)
    port = find_port()
    if not port:
        print("NO_COM")
        return 2
    dummy = open_mark(port)
    dummy.close()
    time.sleep(0.2)
    ser = open_mark(port)
    recs = out["recs"]
    try:
        send_clear_until_ack(ser, recs, "g04r1_clear")
        send_words(ser, load_mem_path(STEP1))
        r1 = rec_of(read_buf(ser, 12.0), "g01_step1")
        recs.append(r1)
        print("G01_STEP1", r1["status_class"], r1.get("word"))
        send_words(ser, load_mem_path(MEM / "PA24-G-01.mem"))
        r2 = rec_of(read_buf(ser, 12.0), "g01_step2")
        recs.append(r2)
        print("G01_STEP2", r2["status_class"], r2.get("word"))
        dump_tap(ser, recs, "g01_dump")
        send_words(ser, load_mem("PA24-G-04"))
        fail = rec_of(read_buf(ser, 12.0) + read_buf(ser, 0.5), "fail_b")
        recs.append(fail)
        print("FAIL_B", fail["status_class"], fail.get("word"), "n", fail["n"])
        out["fail_b_word"] = fail.get("word")
        send_words(ser, query_words("PA24-G-04"))
        qrec = rec_of(read_buf(ser, 8.0) + read_buf(ser, 1.0), "g04_query_after_fail_b")
        recs.append(qrec)
        parsed = parse_query_word(int(qrec["word"], 16)) if qrec.get("word") else None
        out["query_status_class"] = qrec["status_class"]
        out["query_word"] = qrec.get("word")
        out["query_parsed"] = parsed
        out["query_fields_invented"] = False
        print("G04_QUERY_AFTER_FAIL_B", qrec["status_class"], qrec.get("word"), parsed)
    finally:
        ser.close()
    path = OUT / "U33OBS_QUERY_ISO_G04_R1_ORDER.json"
    path.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("ISO_JSON", path)
    print("PACK_ABI_24_24_PASS=NO PROGRAM_PASS=NO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
