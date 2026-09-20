"""U33TAP silicon capture after owner PROGRAM=YES. Not overlay U33. Not PACK_ABI_24_24_PASS.

Host: no dummy-open on natural/DUP4. Queue RX words (MAG may fire mid-TX).
CELL_NATURAL: CLEAR + V-04.
CELL_DUP4: CLEAR + extra BEGIN + V-04 (XSim class A).
CELL_DUMMY: dummy-open then CLEAR + V-04 (MUTE vs TAP dump-after-NAK).
"""
from __future__ import annotations

import json
import sys
import time
from datetime import datetime, timezone, timedelta
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u9")
from uart_r2_u9_board_test import (
    CLR_ACK,
    CLR_CMD,
    find_port,
    load_mem,
    now_iso,
    read_raw_stamped,
    send_words,
    sha256_file,
)
import serial
from serial.tools import list_ports

WANT = "d448544f88f09d4c78990b08c2810928d00e9f319f0bf653966ddacdd8897d7f"
BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u33tap\uart_r2_u33tap_candidate.bit")
BAN_U33 = "ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350"
BAN_H = "cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9"
FTDI = "210319BE776EB"
TAP1 = 0x31504154
BEGINW = 0x00800001
MAGIC = 0x3149414E
MAG = 0x0200015A
GOLD = 0x010000A5
MARK_S = 2.0
OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\U33TAP_CAPTURE_20260920")
TZ = timezone(timedelta(hours=7))


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


def drain_words(ser: serial.Serial, timeout_s: float) -> dict:
    t0 = time.time()
    buf = bytearray()
    recs = []
    idle_rounds = 0
    while time.time() - t0 < timeout_s:
        r = read_raw_stamped(ser, min(0.4, max(0.05, timeout_s - (time.time() - t0))))
        recs.append(r)
        if r.get("n", 0):
            buf.extend(bytes.fromhex(r["raw_hex"]))
            idle_rounds = 0
        elif buf:
            idle_rounds += 1
            if idle_rounds >= 2:
                break
    words = [int.from_bytes(buf[i : i + 4], "little") for i in range(0, len(buf) // 4 * 4, 4)]
    return {"raw_hex": bytes(buf).hex(), "n": len(buf), "words": [f"{w:08x}" for w in words], "recs": recs}


def classify_tap(words: list[int]) -> dict:
    idx = next((i for i, w in enumerate(words) if w == TAP1), None)
    if idx is None:
        return {"tap": "NO_TAP1", "class": "NO_DUMP"}
    p0 = words[idx + 1] if idx + 1 < len(words) else None
    p1 = words[idx + 2] if idx + 2 < len(words) else None
    p2 = words[idx + 3] if idx + 3 < len(words) else None
    if p0 == BEGINW and p1 == MAGIC:
        cls = "CLASS_G_p1_MAGIC"
    elif p0 == BEGINW and p1 == BEGINW:
        cls = "CLASS_A_p1_BEGIN first_divergent=p1"
    elif p0 is not None and p0 != BEGINW:
        cls = f"CLASS_P0_NOT_BEGIN p0={p0:08x}"
    else:
        cls = "CLASS_OTHER"
    return {
        "tap": "TAP1",
        "class": cls,
        "p0": None if p0 is None else f"{p0:08x}",
        "p1": None if p1 is None else f"{p1:08x}",
        "p2": None if p2 is None else f"{p2:08x}",
    }


def run_cell(ser: serial.Serial, name: str, extra_begin: bool, v04: list[int]) -> dict:
    send_words(ser, [CLR_CMD])
    c1 = read_raw_stamped(ser, 3.0)
    rec = {"cell": name, "CLEAR1": c1}
    print(name, "CLEAR1", c1.get("n"), c1.get("raw_hex"), c1.get("word"))
    if c1.get("n", 0) == 0:
        rec["stop"] = "CLEAR1_N0"
        rec["verdict"] = "MUTE_CLEAR"
        return rec
    if c1.get("word") != f"{CLR_ACK:08x}":
        rec["stop"] = "CLEAR1_NOT_ACK"
        rec["verdict"] = "NOT_ACK"
        return rec
    if extra_begin:
        send_words(ser, [BEGINW])
        rec["TX_EXTRA_BEGIN"] = f"{BEGINW:08x}"
    send_words(ser, v04)
    rx = drain_words(ser, 12.0)
    rec["RX"] = {k: rx[k] for k in ("raw_hex", "n", "words")}
    rec["RX_detail"] = rx["recs"]
    words = [int(w, 16) for w in rx["words"]]
    rec["tap"] = classify_tap(words)
    first = words[0] if words else None
    if first == GOLD:
        rec["verdict"] = "GOLD"
    elif first == MAG:
        rec["verdict"] = "MAG"
    elif first is None:
        rec["verdict"] = "MUTE"
    else:
        rec["verdict"] = f"OTHER_{first:08x}"
    print(name, "verdict", rec["verdict"], "n", rx["n"], "tap", rec["tap"].get("class"), rec["tap"].get("p0"), rec["tap"].get("p1"))
    return rec


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    sha = sha256_file(BIT)
    print("DISK_SHA", sha)
    if sha != WANT:
        print("SHA_MISMATCH")
        return 3
    if sha in {BAN_U33, BAN_H}:
        print("FORBIDDEN_IDENTITY")
        return 3
    port = find_port()
    if not port:
        print("NO_COM")
        return 2
    matches = [p for p in list_ports.comports() if p.device.upper() == port.upper()]
    if len(matches) != 1 or (matches[0].serial_number or "").upper() != FTDI:
        print("PORT_SERIAL_MISMATCH", port)
        return 2
    v04 = load_mem("PA24-V-04")
    cells = []
    ser = open_mark(port)
    try:
        cells.append(run_cell(ser, "CELL_NATURAL", False, v04))
    finally:
        ser.close()
    time.sleep(1.0)
    ser = open_mark(port)
    try:
        cells.append(run_cell(ser, "CELL_DUP4", True, v04))
    finally:
        ser.close()
    time.sleep(1.0)
    d = open_mark(port)
    d.close()
    time.sleep(0.2)
    ser = open_mark(port)
    try:
        cells.append(run_cell(ser, "CELL_DUMMY", False, v04))
    finally:
        ser.close()
    out = {
        "iso": now_iso(),
        "identity": "U33TAP",
        "disk_bit_sha256": sha,
        "NOT_U33": BAN_U33,
        "NOT_H": BAN_H,
        "port": port,
        "ftdi": FTDI,
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "BOARD_PASS": "NOT_EVIDENCED",
        "TIMING_PASS": "NO",
        "cells": cells,
    }
    path = OUT / "CAPTURE.json"
    path.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("WROTE", path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
