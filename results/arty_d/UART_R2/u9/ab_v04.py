"""A/B T1+V-04 after PROGRAM already killed hw_server. Identity chosen by argv[1]=u8|u9b.
Not BOARD_PASS / PACK_ABI_24_24_PASS / PROGRAM_PASS.
"""
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

WHICH = sys.argv[1] if len(sys.argv) > 1 else "u8"
BITS = {
    "u8": Path(r"D:\FPGA\arty_d\UART_R2\build_u8\uart_r2_u8_candidate.bit"),
    "u9b": Path(r"D:\FPGA\arty_d\UART_R2\build_u9b\uart_r2_u9b_candidate.bit"),
}
OUTS = {
    "u8": Path(r"D:\FPGA\arty_d\UART_R2\build_u8\board_test"),
    "u9b": Path(r"D:\FPGA\arty_d\UART_R2\build_u9b\board_test"),
}
BAN = {
    "cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9",
    "f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7",
    "ec32257570bd6e193d9341086b75ce1ec5607958998cd144faae1d3fab034232",
    "17494f2cd18ca885fca74968b9182091d637508d720d56ef7bc09928af1aa213",
    "66fe2bd739b31f4a62883e8d21d247ebe12d04c3b0b961af523733323ef1da88",
}

BIT = BITS[WHICH]
u9mod.OUT = OUTS[WHICH]
u9mod.BIT = BIT
SETTLE_S = 15.0


def main() -> int:
    sha = sha256_file(BIT)
    if sha in BAN:
        print("REFUSE", sha)
        return 3
    port = find_port()
    if port is None:
        print("NO_COM")
        return 2
    print("AB", WHICH, sha)
    print("SETTLE", SETTLE_S, port)
    time.sleep(SETTLE_S)
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
    recs = []
    try:
        send_words(ser, [CLR_CMD])
        c1 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR1", **c1})
        print("CLEAR1", c1["sub"], c1["word"])
        if c1.get("word") != f"{CLR_ACK:08x}":
            dump_json(f"AB_{WHICH}_V04.json", {"stop": "CLEAR1", "sha": sha, "recs": recs})
            print("STOP CLEAR1")
            return 1
        v04 = load_mem("PA24-V-04")
        send_words(ser, v04)
        p = read_raw_stamped(ser, UART_TIMEOUT_S)
        recs.append(
            {
                "step": "PACK_V04",
                "gold_match": p.get("word") == f"{GOLD_OK:08x}",
                **p,
            }
        )
        print("V04", p["sub"], p["word"], "match", recs[-1]["gold_match"])
        dump_json(
            f"AB_{WHICH}_V04.json",
            {
                "when": now_iso(),
                "which": WHICH,
                "sha": sha,
                "PROGRAM_PASS": "NO",
                "BOARD_PASS": "NOT_EVIDENCED",
                "PACK_ABI_24_24_PASS": "NO",
                "recs": recs,
            },
        )
        return 0 if recs[-1]["gold_match"] else 1
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
