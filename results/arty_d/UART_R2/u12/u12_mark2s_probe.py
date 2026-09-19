"""U12 phase4 diagnostic: longer MARK after COM-open. No RTL change."""
from __future__ import annotations

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
)
import serial
import uart_r2_u9_board_test as u9mod

u9mod.OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\PACK24_FINAL_U12")
BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u12\uart_r2_u12_candidate.bit")


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
    return ser


def main() -> int:
    sha = sha256_file(BIT)
    port = find_port()
    print("PROBE_SHA", sha, port)
    ser = open_gold(port)
    recs = []
    try:
        t0 = time.time()
        discarded = 0
        while time.time() - t0 < 2.0:
            discarded += len(ser.read(4096))
        ser.reset_input_buffer()
        print("DRAIN2S", discarded)
        send_words(ser, [CLR_CMD])
        c1 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR1_MARK2S", "discarded": discarded, **c1})
        print("CLEAR1", c1["sub"], c1["word"], "n=", c1["n"], c1["raw_hex"])
        if c1.get("word") != f"{CLR_ACK:08x}":
            time.sleep(0.2)
            send_words(ser, [CLR_CMD])
            c2 = read_raw_stamped(ser, 3.0)
            recs.append({"step": "CLEAR2_RETRY", **c2})
            print("CLEAR2", c2["sub"], c2["word"], "n=", c2["n"], c2["raw_hex"])
            dump_json("BOARD_BASELINE_PROBE.json", {"when": now_iso(), "sha": sha, "recs": recs})
            return 1
        v04 = load_mem("PA24-V-04")
        send_words(ser, v04)
        p = read_raw_stamped(ser, UART_TIMEOUT_S)
        recs.append({"step": "V04", **p})
        print("V04", p["sub"], p["word"], "n=", p["n"])
        dump_json("BOARD_BASELINE_PROBE.json", {"when": now_iso(), "sha": sha, "recs": recs})
        return 0 if p.get("word") == f"{GOLD_OK:08x}" else 1
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
