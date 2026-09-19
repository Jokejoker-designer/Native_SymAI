"""U16 board campaign: MARK 2s, exact n=4 ACK/GOLD, then Pack24.
Not PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
"""
from __future__ import annotations

import json
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u9")
from uart_r2_u9_board_test import (
    CLR_ACK,
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
    kill_jtag_usb_servers,
)
import csv
import serial
import uart_r2_u9_board_test as u9mod

u9mod.OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\PACK24_U16")
OUT = u9mod.OUT
RAW = OUT / "RAW_UART"
BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u16\uart_r2_u16_candidate.bit")
WANT = "REPLACE_AFTER_BIT"
TSV = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out\pack_abi24_expect.tsv"
)
MARK_S = 2.0


def open_mark(port: str) -> serial.Serial:
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
    while time.time() - t0 < MARK_S:
        ser.read(max(1, ser.in_waiting))
    ser.reset_input_buffer()
    return ser


def exact4(rec: dict, want: int) -> bool:
    return rec.get("n") == 4 and rec.get("word") == f"{want:08x}"


def main() -> int:
    mode = sys.argv[1] if len(sys.argv) > 1 else "p4p5"
    OUT.mkdir(parents=True, exist_ok=True)
    RAW.mkdir(parents=True, exist_ok=True)
    sha = sha256_file(BIT)
    print("U16_SHA", sha, "MODE", mode)
    if mode == "settle":
        kill_jtag_usb_servers()
        time.sleep(15)
        return 0
    port = find_port()
    if not port:
        print("NO_COM")
        return 2
    ser = open_mark(port)
    recs = []
    try:
        if mode in {"p4", "p4p5"}:
            send_words(ser, [CLR_CMD])
            c1 = read_raw_stamped(ser, 3.0)
            recs.append({"step": "CLEAR1", **c1})
            print("CLEAR1", c1["sub"], c1["n"], c1.get("raw_hex"))
            if not exact4(c1, CLR_ACK):
                dump_json("BOARD_BASELINE.json", {"stop": "CLEAR1", "sha": sha, "recs": recs, "PROGRAM_PASS": "NO"})
                return 1
            v04 = load_mem("PA24-V-04")
            send_words(ser, v04)
            p = read_raw_stamped(ser, UART_TIMEOUT_S)
            recs.append({"step": "V04_0", **p})
            print("V04", p["sub"], p["n"], p.get("raw_hex"))
            dump_json("BOARD_BASELINE.json", {"sha": sha, "recs": recs, "PROGRAM_PASS": "NO", "BOARD_PASS": "NOT_EVIDENCED"})
            if not exact4(p, GOLD_OK):
                return 1
            print("PHASE4_OK")
            if mode == "p4":
                return 0
        if mode in {"p5", "p4p5"}:
            v04 = load_mem("PA24-V-04")
            mag = unsup = n0 = extra = 0
            for rnd in range(24):
                send_words(ser, [CLR_CMD])
                c = read_raw_stamped(ser, 3.0)
                recs.append({"step": "CLEAR", "round": rnd, **c})
                (RAW / f"p5_c{rnd:02d}.json").write_text(json.dumps(c, indent=2), encoding="utf-8")
                print("CLEAR", rnd, c["sub"], c["n"], c.get("raw_hex"))
                if c.get("word") == "0200015a":
                    mag += 1
                if c.get("word") == "0200075a":
                    unsup += 1
                if c.get("n", 0) == 0:
                    n0 += 1
                if c.get("n", 0) != 4:
                    extra += 1
                if not exact4(c, CLR_ACK):
                    dump_json("CLEAR_V04_24.json", {"stop": "CLEAR", "round": rnd, "sha": sha, "mag": mag, "n0": n0, "extra": extra, "recs": recs, "PROGRAM_PASS": "NO"})
                    return 1
                send_words(ser, v04)
                q = read_raw_stamped(ser, UART_TIMEOUT_S)
                recs.append({"step": "V04", "round": rnd, **q})
                (RAW / f"p5_v{rnd:02d}.json").write_text(json.dumps(q, indent=2), encoding="utf-8")
                print("V04", rnd, q["sub"], q["n"], q.get("raw_hex"))
                if q.get("word") == "0200015a":
                    mag += 1
                if q.get("word") == "0200075a":
                    unsup += 1
                if q.get("n", 0) == 0:
                    n0 += 1
                if q.get("n", 0) != 4:
                    extra += 1
                if not exact4(q, GOLD_OK):
                    dump_json("CLEAR_V04_24.json", {"stop": "V04", "round": rnd, "sha": sha, "mag": mag, "n0": n0, "extra": extra, "recs": recs, "PROGRAM_PASS": "NO"})
                    return 1
            dump_json(
                "CLEAR_V04_24.json",
                {
                    "when": now_iso(),
                    "sha": sha,
                    "clear": "24/24",
                    "v04": "24/24",
                    "mag": mag,
                    "unsup": unsup,
                    "n0": n0,
                    "extra": extra,
                    "PROGRAM_PASS": "NO",
                    "BOARD_PASS": "NOT_EVIDENCED",
                    "PACK_ABI_24_24_PASS": "NO",
                    "recs": recs,
                },
            )
            print("PHASE5_24_24_OK")
            return 0
        if mode in {"pack1", "pack2", "pack3"}:
            names = {"pack1": "PACK24_RUN1.jsonl", "pack2": "PACK24_RUN2.jsonl", "pack3": "PACK24_FRESH_REPLAY.jsonl"}
            rows = list(csv.DictReader(TSV.open(encoding="utf-8"), delimiter="\t"))
            recs = []
            n_ok = 0
            for row in rows:
                cid = row["case_id"]
                exp = tsv_expect(cid)
                send_words(ser, [CLR_CMD])
                c1 = read_raw_stamped(ser, 3.0)
                if not exact4(c1, CLR_ACK):
                    recs.append({"case_id": cid, "phase": "CLEAR", "raw_hex": c1.get("raw_hex"), "ok": False})
                    (OUT / names[mode]).write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
                    print("PACK24 STOP CLEAR", cid, c1.get("raw_hex"))
                    return 1
                send_words(ser, load_mem(cid))
                p = read_raw_stamped(ser, UART_TIMEOUT_S)
                ok = exact4(p, exp)
                recs.append({"case_id": cid, "expect": f"{exp:08x}", "got": p.get("word"), "raw_hex": p.get("raw_hex"), "n": p.get("n"), "ok": ok})
                print(cid, f"{exp:08x}", p.get("word"), p.get("n"), "OK" if ok else "FAIL")
                if not ok:
                    (OUT / names[mode]).write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
                    return 1
                n_ok += 1
            (OUT / names[mode]).write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
            print(names[mode], f"{n_ok}/{len(rows)}")
            return 0 if n_ok == len(rows) else 1
        print("usage: settle|p4|p5|p4p5|pack1|pack2|pack3")
        return 2
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
