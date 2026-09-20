"""Pack/ABI-24 run1 on programmed U33OBS. CLEAR between cases. No leftover BEGIN.

generation_flipped only from TAP four-AND in the same response. UART never invents it.
Not PACK_ABI_24_24_PASS. PROGRAM_PASS=NO. Not overlay H/U33.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u33obs")
from u33obs_capture import TAP1, collect_words_from_bytes, decode_tap, mapper  # noqa: E402
from u33obs_hops import (  # noqa: E402
    OUT,
    PROG,
    WANT_BIT,
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

MEM = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)
CASES = [
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


def load_mem(cid: str) -> list[int]:
    path = MEM / f"{cid}.mem"
    lines = [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]
    nwords = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + nwords]]
    if len(words) != nwords:
        raise ValueError(f"{path.name} short {len(words)}/{nwords}")
    return words


def split_status_tap(buf: bytes) -> tuple[int | None, int, dict | None]:
    words = collect_words_from_bytes(buf)
    if not words:
        return None, 0, None
    status = words[0]
    tap = None
    if TAP1 in words:
        tap = decode_tap(words[words.index(TAP1) :])
    return status, 4, tap


def pack24_run1() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    prog = parse_program_txt(PROG)
    out = {
        "when": now_iso(),
        "run": "run1",
        "want_sha256": WANT_BIT,
        "program_txt": prog,
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "fresh": False,
        "run2": False,
        "recs": [],
        "rows": [],
    }
    if prog.get("STATUS") != "PROGRAMMED" or prog.get("SHA256") != WANT_BIT:
        print("PACK24_REFUSED need programmed OBS", WANT_BIT)
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
    m = mapper()
    jsonl_lines = []
    try:
        for cid in CASES:
            words = load_mem(cid)
            send_clear_until_ack(ser, out["recs"], f"{cid}_clear")
            send_words(ser, words)
            buf = read_buf(ser, 12.0)
            extra = read_buf(ser, 0.5)
            stream = buf + extra
            rec = rec_of(stream, cid)
            out["recs"].append(rec)
            status, n, tap = split_status_tap(stream)
            flip = None
            if tap and tap.get("generation_flipped") is not None:
                flip = tap["generation_flipped"]
            row = m.map_row(cid, status, n, generation_flipped=flip)
            if tap:
                row["tap_identity"] = tap.get("identity")
                row["tap_class"] = tap.get("class")
            dut = m.dut_compare_fields(row) if row.get("map_ok") else {"case_id": cid, "map_ok": False, "map_error": row.get("map_error")}
            dut["PACK_ABI_24_24_PASS"] = "NO"
            dut["source"] = "BOARD_U33OBS_PACK24_RUN1"
            jsonl_lines.append(dut)
            out["rows"].append(row)
            print(cid, rec.get("status_class"), "n", rec.get("n"), "map_ok", row.get("map_ok"), "flip", flip, "ready", row.get("compare_ready"))
    finally:
        ser.close()
    jsonl_path = OUT / "PACK24_RUN1_DUT.jsonl"
    jsonl_path.write_text("".join(json.dumps(x) + "\n" for x in jsonl_lines), encoding="utf-8")
    out["dut_jsonl"] = str(jsonl_path)
    out["stop"] = "PACK24_RUN1_DONE"
    (OUT / "PACK24_RUN1.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("DUT", jsonl_path)
    print("PACK_ABI_24_24_PASS=NO")
    return 0


def one_case(ser, cid: str, recs: list) -> dict:
    words = load_mem(cid)
    send_clear_until_ack(ser, recs, f"{cid}_iso_clear")
    send_words(ser, words)
    buf = read_buf(ser, 12.0) + read_buf(ser, 0.5)
    rec = rec_of(buf, cid)
    recs.append(rec)
    status, n, tap = split_status_tap(buf)
    return {"rec": rec, "status": None if status is None else f"{status:08x}", "n": n, "tap": tap}


def pack24_probe_first_div() -> int:
    """Isolated V-03 then A-03 after Pack24 dest. No reprogram. No leftover BEGIN."""
    OUT.mkdir(parents=True, exist_ok=True)
    prog = parse_program_txt(PROG)
    out = {
        "when": now_iso(),
        "run": "probe_v03_a03",
        "want_sha256": WANT_BIT,
        "program_txt": prog,
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "recs": [],
    }
    if prog.get("STATUS") != "PROGRAMMED" or prog.get("SHA256") != WANT_BIT:
        print("PROBE_REFUSED")
        return 4
    kill_jtag()
    port = find_port()
    if not port:
        print("NO_COM")
        return 2
    ser = open_mark(port)
    try:
        out["v03"] = one_case(ser, "PA24-V-03", out["recs"])
        out["a03"] = one_case(ser, "PA24-A-03", out["recs"])
        print("V-03", out["v03"]["rec"].get("status_class"), out["v03"]["rec"].get("word"))
        print("A-03", out["a03"]["rec"].get("status_class"), out["a03"]["rec"].get("word"))
    finally:
        ser.close()
    path = OUT / "PACK24_PROBE_V03_A03.json"
    path.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("WROTE", path)
    return 0


def main(argv: list[str]) -> int:
    if len(argv) > 1 and argv[1] == "--run1":
        return pack24_run1()
    if len(argv) > 1 and argv[1] == "--probe-v03-a03":
        return pack24_probe_first_div()
    print("usage: u33obs_pack24.py --run1 | --probe-v03-a03")
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
