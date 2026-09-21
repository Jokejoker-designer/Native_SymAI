"""4-step leftover then isolated reject TAP + V-01 GOLD dest observe.

A-02 header reject and R-01 page-CRC reject: TAP commit is not this-pack
S_COMMIT (rejects never enter S_COMMIT). Do not invent generation_flipped=0.
V-01 GOLD after S_RD_WAIT is dest-complete handshake; dest word export still
UART-absent. Query gen=1 after V-01 is dest_fail/gen observe only.

PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. Not overlay H/U33.
"""
from __future__ import annotations

import json
import struct
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u33obs")
from u33obs_capture import TAP1, collect_words_from_bytes, decode_tap  # noqa: E402
from u33obs_hops import (  # noqa: E402
    BEGINW,
    OUT,
    PROG_QUERY,
    WANT_QUERY,
    dump_tap,
    find_port,
    hops_gold_dump,
    hops_leftover,
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
from u33obs_pack24 import load_mem, split_status_tap  # noqa: E402

sys.path.insert(0, r"D:\FPGA\Native_SymAI\docs\audits\20260919_u33_discriminator")
from uart_token_to_compare import parse_query_word  # noqa: E402

GOLD_PY = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\pack_abi24_gold.py"
)
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


def tap_slice(tap: dict | None) -> dict:
    if not tap:
        return {}
    keys = (
        "identity",
        "class",
        "commit_event",
        "same_capture_epoch",
        "capture_valid",
        "generation_flipped",
        "generation_before",
        "generation_after",
        "hop",
        "uart0",
        "uart1",
        "load0",
        "load1",
    )
    return {k: tap.get(k) for k in keys}


def this_pack_flip(status_class: str, tap: dict | None) -> int | None:
    if not tap or status_class != "GOLD":
        return None
    if (
        tap.get("commit_event") == 1
        and tap.get("same_capture_epoch") == 1
        and tap.get("capture_valid") == 1
        and tap.get("generation_before") is not None
        and tap.get("generation_after") is not None
        and tap.get("generation_before") != tap.get("generation_after")
        and tap.get("generation_flipped") == 1
    ):
        return 1
    if (
        tap.get("commit_event") == 1
        and tap.get("same_capture_epoch") == 1
        and tap.get("capture_valid") == 1
        and tap.get("generation_before") is not None
        and tap.get("generation_after") is not None
        and tap.get("generation_before") == tap.get("generation_after")
        and tap.get("generation_flipped") == 0
    ):
        return 0
    return None


def query_gen1() -> list[int]:
    import importlib.util

    spec = importlib.util.spec_from_file_location("pack_abi24_gold", GOLD_PY)
    if spec is None or spec.loader is None:
        raise RuntimeError("gold missing")
    mod = importlib.util.module_from_spec(spec)
    sys.modules["pack_abi24_gold"] = mod
    spec.loader.exec_module(mod)
    blob = mod.pack_query(generation=1, txn_id=1)
    pad = blob + (b"\x00" * ((-len(blob)) % 4))
    return [struct.unpack_from("<I", pad, i)[0] for i in range(0, len(pad), 4)]


def send_case(ser, recs: list, cid: str) -> tuple:
    send_words(ser, load_mem(cid))
    stream = read_buf(ser, 12.0) + read_buf(ser, 0.5)
    rec = rec_of(stream, cid)
    recs.append(rec)
    status, n, tap = split_status_tap(stream)
    if tap is None and TAP1 in collect_words_from_bytes(stream):
        words = collect_words_from_bytes(stream)
        tap = decode_tap(words[words.index(TAP1) :])
    return rec, status, n, tap, stream


def main() -> int:
    prog = parse_program_txt(PROG_QUERY)
    sha = (prog.get("SHA256") or "").lower()
    out = {
        "when": now_iso(),
        "want_sha256": WANT_QUERY,
        "program_txt": prog,
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "generation_flipped_law": (
            "true iff commit_event==1 AND generation_after!=generation_before "
            "AND same_capture_epoch AND capture_valid==1 from THIS pack S_COMMIT; "
            "false only on observed COMMIT after==before; else omit"
        ),
        "recs": [],
    }
    if prog.get("STATUS") != "PROGRAMMED" or sha != WANT_QUERY or sha in BAN:
        print("ISO_REFUSED need 8fc14f25", sha)
        return 4
    kill_jtag()
    time.sleep(1.0)
    port = find_port()
    if not port:
        print("NO_COM")
        return 2
    dummy = open_mark(port)
    dummy.close()
    time.sleep(0.2)
    ser = open_mark(port)
    recs = out["recs"]
    v04 = load_v04()
    try:
        hops_leftover(ser, recs, v04, out)
        hops_gold_dump(ser, recs, v04, out)

        send_clear_until_ack(ser, recs, "a02_clear")
        rec, status, n, tap, stream = send_case(ser, recs, "PA24-A-02")
        if tap is None:
            d = dump_tap(ser, recs, "a02_dump")
            tap = d.get("tap")
        out["a02"] = {
            "status_class": rec.get("status_class"),
            "word": rec.get("word"),
            "n": rec.get("n"),
            "tap": tap_slice(tap),
            "this_pack_flip": this_pack_flip(rec.get("status_class") or "", tap),
            "tap_not_this_pack": rec.get("status_class") != "GOLD",
            "invent_flip0": False,
        }
        print(
            "A-02",
            rec.get("status_class"),
            "commit",
            None if not tap else tap.get("commit_event"),
            "before",
            None if not tap else tap.get("generation_before"),
            "after",
            None if not tap else tap.get("generation_after"),
            "this_pack_flip",
            out["a02"]["this_pack_flip"],
        )

        send_clear_until_ack(ser, recs, "r01_clear")
        rec, status, n, tap, stream = send_case(ser, recs, "PA24-R-01")
        if tap is None:
            d = dump_tap(ser, recs, "r01_dump")
            tap = d.get("tap")
        out["r01"] = {
            "status_class": rec.get("status_class"),
            "word": rec.get("word"),
            "n": rec.get("n"),
            "tap": tap_slice(tap),
            "this_pack_flip": this_pack_flip(rec.get("status_class") or "", tap),
            "tap_not_this_pack": rec.get("status_class") != "GOLD",
            "invent_flip0": False,
        }
        print(
            "R-01",
            rec.get("status_class"),
            "commit",
            None if not tap else tap.get("commit_event"),
            "this_pack_flip",
            out["r01"]["this_pack_flip"],
        )

        send_clear_until_ack(ser, recs, "v01_clear")
        rec, status, n, tap, stream = send_case(ser, recs, "PA24-V-01")
        if tap is None and rec.get("status_class") == "GOLD":
            d = dump_tap(ser, recs, "v01_gold_dump")
            tap = d.get("tap")
        out["v01"] = {
            "status_class": rec.get("status_class"),
            "word": rec.get("word"),
            "n": rec.get("n"),
            "tap": tap_slice(tap),
            "this_pack_flip": this_pack_flip(rec.get("status_class") or "", tap),
            "dest_complete_handshake": rec.get("status_class") == "GOLD" and rec.get("n") == 4,
            "dest_word_export": "NOT_RUN",
        }
        print("V-01", rec.get("status_class"), "flip", out["v01"]["this_pack_flip"])
        if rec.get("status_class") == "GOLD":
            qw = query_gen1()
            send_words(ser, qw)
            qrec = rec_of(read_buf(ser, 8.0) + read_buf(ser, 1.0), "v01_query_gen1")
            recs.append(qrec)
            parsed = parse_query_word(int(qrec["word"], 16)) if qrec.get("word") else None
            out["v01_query"] = {
                "status_class": qrec.get("status_class"),
                "word": qrec.get("word"),
                "n": qrec.get("n"),
                "parsed": parsed,
                "note": "pack-stream dest_fail/gen observe; not dest word dump",
            }
            print("V-01_QUERY", qrec.get("status_class"), qrec.get("word"), parsed)

        out["leftover_begin_used"] = BEGINW
        out["note"] = (
            "Rejects do not enter pack_loader S_COMMIT. TAP commit after NAK "
            "is prior GOLD commit_seen if sticky. Do not invent flip=0. "
            "GOLD is dest-complete handshake via S_RD_WAIT; dest hex not UART."
        )
    finally:
        ser.close()
    path = OUT / "U33OBS_QUERY_ISO_REJECT_TAP_DEST.json"
    path.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("ISO_JSON", path)
    print("PACK_ABI_24_24_PASS=NO PROGRAM_PASS=NO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
