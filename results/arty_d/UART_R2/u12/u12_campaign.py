"""U12 board campaign: CLEAR/V-04 repeat then Pack24.
Not PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
"""
from __future__ import annotations

import csv
import json
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u9")
from uart_r2_u9_board_test import (
    CLR_ACK,
    CLR_BUSY,
    CLR_CMD,
    GOLD_OK,
    UART_TIMEOUT_S,
    dump_json,
    find_port,
    load_mem,
    now_iso,
    read_raw_stamped,
    send_words,
    sha256_file,
    tsv_expect,
)
import serial
import uart_r2_u9_board_test as u9mod

u9mod.OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\PACK24_FINAL_U12")
u9mod.BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u12\uart_r2_u12_candidate.bit")
BIT = u9mod.BIT
OUT = u9mod.OUT
RAW = OUT / "RAW_UART"
GOLD_DIR = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)
TSV = GOLD_DIR / "pack_abi24_expect.tsv"
BAN = {
    "cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9",
    "f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7",
    "ec32257570bd6e193d9341086b75ce1ec5607958998cd144faae1d3fab034232",
    "17494f2cd18ca885fca74968b9182091d637508d720d56ef7bc09928af1aa213",
    "2bc835fd28174051dc2015f7bacd8ad5c919a5a2ce9c60695fe0530b405d6098",
    "66fe2bd739b31f4a62883e8d21d247ebe12d04c3b0b961af523733323ef1da88",
    "4ab8e14203c7c1bafd32862da055592ba12fbb361b7b74f307b7cbd284a227a1",
    "713ea856baa9f36bdfecad0eaa356c4f3be872191d2820845bcd4f8f90e55b0e",
}
SETTLE_S = 15.0
MAG = 0x0200015A
UNSUP = 0x0200075A


def open_gold(port: str) -> serial.Serial:
    ser = serial.Serial()
    ser.port = port
    ser.baudrate = 115200
    ser.bytesize = serial.EIGHTBITS
    ser.parity = serial.PARITY_NONE
    ser.stopbits = serial.STOPBITS_ONE
    ser.timeout = 0.05
    ser.write_timeout = 8.0
    ser.dtr = False
    ser.rts = False
    ser.open()
    t0 = time.time()
    while time.time() - t0 < 0.25:
        ser.read(4096)
    ser.reset_input_buffer()
    return ser


def classify(word: str | None, n: int) -> dict:
    mag = word == f"{MAG:08x}"
    unsup = word == f"{UNSUP:08x}"
    n0 = n == 0
    return {"mag": mag, "unsup": unsup, "n0": n0}


def phase4_liveness(ser: serial.Serial, sha: str) -> int:
    recs = []
    send_words(ser, [CLR_CMD])
    c1 = read_raw_stamped(ser, 3.0)
    recs.append({"step": "CLEAR1", **c1})
    print("CLEAR1", c1["sub"], c1["word"], "n=", c1["n"])
    if c1.get("word") != f"{CLR_ACK:08x}":
        dump_json("BOARD_BASELINE.json", {"stop": "CLEAR1", "sha": sha, "recs": recs})
        print("STOP CLEAR1")
        return 1
    v04 = load_mem("PA24-V-04")
    send_words(ser, v04)
    p = read_raw_stamped(ser, UART_TIMEOUT_S)
    recs.append({"step": "PACK_V04", **p})
    print("V04", p["sub"], p["word"], "n=", p["n"])
    dump_json(
        "BOARD_BASELINE.json",
        {
            "when": now_iso(),
            "sha": sha,
            "class": "UART_R2_U12_PACK24_FINAL",
            "PROGRAM_PASS": "NO",
            "BOARD_PASS": "NOT_EVIDENCED",
            "recs": recs,
        },
    )
    if p.get("word") != f"{GOLD_OK:08x}":
        print("STOP V04")
        return 1
    print("PHASE4_LIVENESS_OK")
    return 0


def phase5_repeat(ser: serial.Serial, sha: str, rounds: int = 24) -> int:
    recs = []
    mag = unsup = n0 = timeout = trunc = 0
    RAW.mkdir(parents=True, exist_ok=True)
    v04 = load_mem("PA24-V-04")
    lines = []
    for rnd in range(rounds):
        send_words(ser, [CLR_CMD])
        c1 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR", "round": rnd, **c1})
        print("CLEAR", rnd, c1["sub"], c1["word"], "n=", c1["n"])
        (RAW / f"p5_r{rnd:02d}_clear.json").write_text(json.dumps(c1, indent=2), encoding="utf-8")
        if c1.get("word") == f"{CLR_BUSY:08x}":
            dump_json("CLEAR_V04_24.json", {"stop": "BUSY", "round": rnd, "sha": sha, "recs": recs})
            print("STOP BUSY")
            return 1
        if c1.get("word") != f"{CLR_ACK:08x}":
            n0 += int(c1.get("n", 0) == 0)
            timeout += int(c1.get("n", 0) == 0)
            trunc += int(0 < c1.get("n", 0) < 4)
            dump_json(
                "CLEAR_V04_24.json",
                {
                    "stop": "CLEAR",
                    "round": rnd,
                    "sha": sha,
                    "mag": mag,
                    "n0": n0,
                    "recs": recs,
                },
            )
            print("STOP CLEAR")
            return 1
        send_words(ser, v04)
        p = read_raw_stamped(ser, UART_TIMEOUT_S)
        recs.append({"step": "V04", "round": rnd, **p})
        print("V04", rnd, p["sub"], p["word"], "n=", p["n"])
        (RAW / f"p5_r{rnd:02d}_v04.json").write_text(json.dumps(p, indent=2), encoding="utf-8")
        flags = classify(p.get("word"), p.get("n", 0))
        mag += int(flags["mag"])
        unsup += int(flags["unsup"])
        n0 += int(flags["n0"])
        timeout += int(p.get("n", 0) == 0)
        trunc += int(0 < p.get("n", 0) < 4)
        lines.append(
            f"r{rnd} CLEAR={c1.get('word')} n={c1.get('n')} V04={p.get('word')} n={p.get('n')}"
        )
        if p.get("word") != f"{GOLD_OK:08x}":
            dump_json(
                "CLEAR_V04_24.json",
                {
                    "stop": "V04",
                    "round": rnd,
                    "sha": sha,
                    "mag": mag,
                    "n0": n0,
                    "unsup": unsup,
                    "recs": recs,
                },
            )
            print("STOP V04")
            return 1
    dump_json(
        "CLEAR_V04_24.json",
        {
            "when": now_iso(),
            "sha": sha,
            "clear": f"{rounds}/{rounds}",
            "v04": f"{rounds}/{rounds}",
            "mag": mag,
            "unsup": unsup,
            "n0": n0,
            "timeout": timeout,
            "trunc": trunc,
            "PROGRAM_PASS": "NO",
            "BOARD_PASS": "NOT_EVIDENCED",
            "recs": recs,
        },
    )
    (OUT / "CLEAR_V04_24.log").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("PHASE5_24_24_OK")
    return 0


def phase_pack24(ser: serial.Serial, sha: str, out_name: str) -> int:
    rows = list(csv.DictReader(TSV.open(encoding="utf-8"), delimiter="\t"))
    recs = []
    n_ok = 0
    for row in rows:
        cid = row["case_id"]
        exp = tsv_expect(cid)
        send_words(ser, [CLR_CMD])
        c1 = read_raw_stamped(ser, 3.0)
        if c1.get("word") != f"{CLR_ACK:08x}":
            rec = {
                "case_id": cid,
                "phase": "CLEAR",
                "expect": f"{CLR_ACK:08x}",
                "got": c1.get("word"),
                "raw_hex": c1.get("raw_hex"),
                "ok": False,
            }
            recs.append(rec)
            print("PACK24 STOP CLEAR", cid, c1.get("word"))
            (OUT / out_name).write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
            return 1
        words = load_mem(cid)
        t0 = time.time()
        send_words(ser, words)
        p = read_raw_stamped(ser, UART_TIMEOUT_S)
        dt = time.time() - t0
        ok = p.get("word") == f"{exp:08x}"
        rec = {
            "case_id": cid,
            "phase": "PACK",
            "expect": f"{exp:08x}",
            "got": p.get("word"),
            "raw_hex": p.get("raw_hex"),
            "n": p.get("n"),
            "dt_s": round(dt, 3),
            "ok": ok,
        }
        recs.append(rec)
        print(cid, rec["expect"], rec["got"], "OK" if ok else "FAIL")
        if not ok:
            (OUT / out_name).write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
            return 1
        n_ok += 1
    (OUT / out_name).write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
    print(out_name, f"{n_ok}/{len(rows)}")
    return 0 if n_ok == len(rows) else 1


def main() -> int:
    mode = sys.argv[1] if len(sys.argv) > 1 else "p4"
    sha = sha256_file(BIT)
    if sha in BAN:
        print("REFUSE", sha)
        return 3
    port = find_port()
    if port is None:
        print("NO_COM")
        return 2
    print("U12_SHA", sha, "MODE", mode, "PORT", port)
    if mode == "settle":
        print("SETTLE", SETTLE_S)
        time.sleep(SETTLE_S)
        return 0
    ser = open_gold(port)
    try:
        if mode == "p4":
            return phase4_liveness(ser, sha)
        if mode == "p5":
            return phase5_repeat(ser, sha, 24)
        if mode == "p4p5":
            rc = phase4_liveness(ser, sha)
            if rc:
                return rc
            return phase5_repeat(ser, sha, 24)
        if mode in {"pack1", "pack2", "pack3"}:
            names = {"pack1": "PACK24_RUN1.jsonl", "pack2": "PACK24_RUN2.jsonl", "pack3": "PACK24_FRESH_REPLAY.jsonl"}
            return phase_pack24(ser, sha, names[mode])
        print("usage: p4|p5|p4p5|pack1|pack2|pack3|settle")
        return 2
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
