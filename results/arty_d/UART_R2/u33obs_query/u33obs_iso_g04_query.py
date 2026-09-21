"""Isolated G-04 GOLD then QueryRecord on unique QUERY identity.

Expect 03|06|54|51 STALE if generation mismatches; never copy TSV.
PROGRAM_PASS=NO. PACK_ABI_24_24_PASS=NO.
"""
from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u33obs")
from u33obs_hops import (  # noqa: E402
    OUT,
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

sys.path.insert(0, r"D:\FPGA\Native_SymAI\docs\audits\20260919_u33_discriminator")
from uart_token_to_compare import parse_query_word  # noqa: E402

PROG_QUERY = Path(r"D:\FPGA\arty_d\UART_R2\results\U33OBS_QUERY_OWNER_PROGRAM\PROGRAM.txt")
BAN = {
    "cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9",
    "f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7",
    "ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350",
    "eb99ac69f07e582c1ac4b1a1da876bfa1a381310133b9fe7c7605bf9e766166b",
    "71b9198f512972bae75af04e406d26c17d7940ecadd324e5b5ffecaedcbf6762",
    "251eafa9451cabd83089fc5cba0c6351f1955c27a70dd9a60e7e2321f4910764",
    "bd541f9579dfe0e2ca1b9dc4e220818fe460e293e6a7c42c08ecf8652fc9b46f",
    "08c647ee850cb513f503448ea91c1461551450a145151f0fe02fb296f8137728",
    "99823c92122ac1e3bb16ddbc3885610a84b51cbb2e16416e94ccced91ac81099",
}
MEM = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)
GOLD_PY = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\pack_abi24_gold.py"
)


def load_mem(cid: str) -> list[int]:
    path = MEM / f"{cid}.mem"
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
    sha = prog.get("SHA256", "")
    out = {
        "when": now_iso(),
        "program_txt": prog,
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "identity": "U33OBS_QUERY",
        "recs": [],
    }
    if prog.get("STATUS") != "PROGRAMMED" or sha in BAN or not sha:
        print("ISO_REFUSED need programmed unique query identity", sha)
        return 4
    kill_jtag()
    port = find_port()
    if not port:
        print("NO_COM")
        return 2
    dummy = open_mark(port)
    dummy.close()
    import time

    time.sleep(0.2)
    ser = open_mark(port)
    recs = out["recs"]
    try:
        send_clear_until_ack(ser, recs, "iso_g04_clear")
        send_words(ser, load_mem("PA24-G-04"))
        rec = rec_of(read_buf(ser, 12.0), "iso_g04")
        recs.append(rec)
        print("ISO_G04", rec["status_class"], "n", rec["n"], rec.get("word"))
        out["g04_status"] = rec["status_class"]
        out["g04_word"] = rec.get("word")
        d = dump_tap(ser, recs, "iso_g04_dump")
        tap = d.get("tap") or {}
        out["g04_tap"] = {
            k: tap.get(k)
            for k in (
                "commit_event",
                "same_capture_epoch",
                "capture_valid",
                "generation_flipped",
                "generation_before",
                "generation_after",
            )
        }
        qw = query_words("PA24-G-04")
        send_words(ser, qw)
        qrec = rec_of(read_buf(ser, 8.0) + read_buf(ser, 1.0), "iso_g04_query")
        recs.append(qrec)
        parsed = parse_query_word(int(qrec["word"], 16)) if qrec.get("word") else None
        out["query_status_class"] = qrec["status_class"]
        out["query_word"] = qrec.get("word")
        out["query_parsed"] = parsed
        out["query_fields_invented"] = False
        print("ISO_G04_QUERY", qrec["status_class"], qrec.get("word"), parsed)
    finally:
        ser.close()
    path = OUT / "U33OBS_QUERY_ISO_G04.json"
    path.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("ISO_JSON", path)
    print("PACK_ABI_24_24_PASS=NO PROGRAM_PASS=NO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
