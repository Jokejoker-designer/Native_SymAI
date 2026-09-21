"""Isolated R-04 GOLD+DUMP then QueryRecord hop on unique rearm. 4-step first-divergent.

uart_fe256_host.in_valid=0 on this identity. Expect query not to produce gold 6/80.
Do not invent query_status. Do not invent generation_flipped=0.
PROGRAM_PASS=NO. PACK_ABI_24_24_PASS=NO. Not overlay H/U33.
"""
from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u33obs")
from u33obs_hops import (  # noqa: E402
    OUT,
    PROG_REARM,
    WANT_REARM,
    dump_tap,
    find_port,
    kill_jtag,
    load_v04,
    now_iso,
    open_mark,
    parse_program_txt,
    read_buf,
    rec_of,
    send_clear_until_ack,
    send_words,
)

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
    prog = parse_program_txt(PROG_REARM)
    out = {
        "when": now_iso(),
        "want_sha256": WANT_REARM,
        "program_txt": prog,
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "identity": "U33OBS_REARM_08c647ee",
        "uart_fe256_host_in_valid": 0,
        "generation_flipped_law": (
            "true iff commit_event==1 AND generation_after!=generation_before "
            "AND same_capture_epoch AND capture_valid==1 from THIS pack S_COMMIT"
        ),
        "recs": [],
    }
    if prog.get("STATUS") != "PROGRAMMED" or prog.get("SHA256") != WANT_REARM:
        print("ISO_REFUSED need programmed rearm", WANT_REARM)
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
        send_clear_until_ack(ser, recs, "iso_r04_clear")
        send_words(ser, load_mem("PA24-R-04"))
        buf = read_buf(ser, 12.0)
        rec = rec_of(buf, "iso_r04")
        recs.append(rec)
        print("ISO_R04", rec["status_class"], "n", rec["n"], "word", rec.get("word"))
        out["r04_status"] = rec["status_class"]
        out["r04_word"] = rec.get("word")
        d = dump_tap(ser, recs, "iso_r04_dump")
        tap = d.get("tap") or {}
        out["r04_tap"] = {
            k: tap.get(k)
            for k in (
                "identity",
                "class",
                "commit_event",
                "same_capture_epoch",
                "capture_valid",
                "generation_flipped",
                "generation_before",
                "generation_after",
            )
        }
        four_and = (
            rec["status_class"] == "GOLD"
            and tap.get("commit_event") == 1
            and tap.get("same_capture_epoch") == 1
            and tap.get("capture_valid") == 1
            and tap.get("generation_before") is not None
            and tap.get("generation_after") is not None
            and tap.get("generation_before") != tap.get("generation_after")
            and tap.get("generation_flipped") == 1
        )
        out["r04_generation_flipped"] = 1 if four_and else None

        qw = query_words("PA24-R-04")
        out["query_nwords"] = len(qw)
        out["query_w0"] = f"{qw[0]:08x}"
        send_words(ser, qw)
        qbuf = read_buf(ser, 8.0)
        qextra = read_buf(ser, 1.0)
        qstream = qbuf + qextra
        qrec = rec_of(qstream, "iso_r04_query")
        recs.append(qrec)
        print(
            "ISO_R04_QUERY",
            qrec["status_class"],
            "n",
            qrec["n"],
            "word",
            qrec.get("word"),
            "nwords",
            qrec.get("nwords"),
        )
        out["query_status_class"] = qrec["status_class"]
        out["query_word"] = qrec.get("word")
        out["query_n"] = qrec["n"]
        out["query_raw_hex"] = qrec.get("raw_hex")
        out["query_fields_invented"] = False
        out["note"] = (
            "QueryRecord hop on pack-only identity (in_valid=0). "
            "Do not copy TSV 6/80 into DUT.jsonl from this hop."
        )
    finally:
        ser.close()
    path = OUT / "U33OBS_REARM_ISO_R04_QUERY.json"
    path.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("ISO_JSON", path)
    print("PACK_ABI_24_24_PASS=NO PROGRAM_PASS=NO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
