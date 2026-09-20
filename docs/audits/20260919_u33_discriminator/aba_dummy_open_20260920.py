"""A/B/A dummy-open only. Same original-host timeouts/TX. No reprogram. No product RTL.
PACK_ABI_24_24_PASS=NO. Stop at first divergence per arm.
A = dummy-open MARK 2s purge close 200ms then real-open.
B = skip dummy-open/close only.
"""
from __future__ import annotations

import hashlib
import json
import os
import sys
import time
from datetime import datetime, timezone, timedelta
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u9")
from uart_r2_u9_board_test import (
    CLR_ACK,
    CLR_CMD,
    GOLD_OK,
    UART_TIMEOUT_S,
    find_port,
    load_mem,
    now_iso,
    read_raw_stamped,
    send_words,
    sha256_file,
)
import serial
from serial.tools import list_ports

WANT = "ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350"
BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u33\uart_r2_u33_candidate.bit")
FTDI = "210319BE776EB"
MARK_S = 2.0
SER_TIMEOUT = 0.05
WRITE_TIMEOUT = 8.0
BETWEEN_ARM_S = 1.0
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(r"D:\FPGA\arty_d\UART_R2\results\U33_ABA_DUMMYOPEN_20260920")
TZ = timezone(timedelta(hours=7))


def digest(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def exact4(rec: dict, want: int) -> bool:
    return rec.get("n") == 4 and rec.get("word") == f"{want:08x}"


def open_mark(port: str) -> serial.Serial:
    ser = serial.Serial()
    ser.port = port
    ser.baudrate = 115200
    ser.bytesize = serial.EIGHTBITS
    ser.parity = serial.PARITY_NONE
    ser.stopbits = serial.STOPBITS_ONE
    ser.timeout = SER_TIMEOUT
    ser.write_timeout = WRITE_TIMEOUT
    ser.dtr = False
    ser.rts = False
    ser.open()
    t0 = time.time()
    while time.time() - t0 < MARK_S:
        ser.read(max(1, ser.in_waiting))
    ser.reset_input_buffer()
    return ser


def session_open(port: str, dummy: bool) -> tuple[serial.Serial, list[dict]]:
    ev = []
    t0 = time.monotonic_ns()
    if dummy:
        d = open_mark(port)
        ev.append({"step": "DUMMY_OPEN_CLOSE", "t_ns": time.monotonic_ns() - t0, "mark_s": MARK_S})
        d.close()
        time.sleep(0.2)
        ev.append({"step": "DUMMY_GAP_200MS", "t_ns": time.monotonic_ns() - t0})
    ser = open_mark(port)
    ev.append({"step": "REAL_OPEN", "dummy": dummy, "t_ns": time.monotonic_ns() - t0, "mark_s": MARK_S,
               "timeout_s": SER_TIMEOUT})
    return ser, ev


def run_arm(port: str, name: str, dummy: bool, v04: list[int]) -> dict:
    recs = []
    ser, ev = session_open(port, dummy)
    recs.extend(ev)
    stop = None
    verdict = "UNKNOWN"
    try:
        send_words(ser, [CLR_CMD])
        recs.append({"step": "TX_CLEAR", "nbytes": 4})
        c1 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR1", **c1})
        print(name, "CLEAR1", c1.get("n"), c1.get("raw_hex"))
        if c1.get("n", 0) == 0:
            stop = "CLEAR1_N0"
            ser.close()
            time.sleep(0.2)
            ser = open_mark(port)
            recs.append({"step": "REOPEN_AFTER_N0"})
            print(name, "REOPEN_AFTER_N0")
            send_words(ser, [CLR_CMD])
            c1 = read_raw_stamped(ser, 3.0)
            recs.append({"step": "CLEAR1_REOPEN", **c1})
            print(name, "CLEAR1_REOPEN", c1.get("n"), c1.get("raw_hex"))
        if not exact4(c1, CLR_ACK):
            stop = stop or "CLEAR1_NOT_ACK"
            verdict = "MUTE_OR_NOT_ACK"
            return {"arm": name, "dummy": dummy, "stop": stop, "verdict": verdict, "recs": recs}
        begin_n = sum(1 for w in v04 if w == 0x00800001)
        recs.append({"step": "TX_V04", "nwords": len(v04), "nbytes": 4 * len(v04), "begin_n": begin_n,
                     "w0": f"0x{v04[0]:08x}", "w1": f"0x{v04[1]:08x}"})
        print(name, "TX_V04 nwords", len(v04), "begin_n", begin_n)
        send_words(ser, v04)
        p = read_raw_stamped(ser, UART_TIMEOUT_S)
        recs.append({"step": "V04_0", **p})
        print(name, "V04", p.get("n"), p.get("raw_hex"))
        extra = read_raw_stamped(ser, 0.2)
        recs.append({"step": "V04_0_DRAIN", **extra})
        if extra.get("n", 0):
            print(name, "DRAIN", extra.get("n"), extra.get("raw_hex"))
        if p.get("word") == f"{GOLD_OK:08x}" and p.get("n") == 4 and extra.get("n", 0) == 0:
            verdict = "GOLD"
            stop = "GOLD_FIRST_HOP"
        else:
            verdict = "V04_FAIL"
            stop = "V04_0"
        return {"arm": name, "dummy": dummy, "stop": stop, "verdict": verdict, "recs": recs}
    finally:
        try:
            ser.close()
        except Exception:
            pass


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    sha = sha256_file(BIT)
    print("DISK_SHA", sha)
    if sha != WANT:
        print("SHA_MISMATCH")
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
    arms = [("A1", True), ("B", False), ("A2", True)]
    results = []
    for i, (name, dummy) in enumerate(arms):
        print("===", name, "dummy", dummy, "===")
        r = run_arm(port, name, dummy, v04)
        results.append(r)
        if i < len(arms) - 1:
            time.sleep(BETWEEN_ARM_S)
    out = {
        "iso": now_iso(),
        "resident_sha256_owner_recorded": WANT,
        "disk_bit_sha256": sha,
        "sram_readback": "NOT_PERFORMED",
        "port": port,
        "ftdi": FTDI,
        "reprogram": os.environ.get("ABA_REPROGRAM", "NO"),
        "program_record": os.environ.get("ABA_PROGRAM_RECORD", ""),
        "product_rtl": "UNCHANGED",
        "variable": "dummy_open_close_only",
        "held_constant": ["MARK_S=2", "timeout=0.05", "real_open_purge", "TX V-04 208B",
                          "WAIT_AFTER_ACK=0", "CLEAR then one V-04", "UART_TIMEOUT_S=12"],
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "BOARD_PASS": "NOT_EVIDENCED",
        "arms": results,
    }
    path = OUT / "ABA.json"
    path.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("WROTE", path)
    for r in results:
        print("ARM", r["arm"], "dummy", r["dummy"], "verdict", r["verdict"], "stop", r["stop"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
