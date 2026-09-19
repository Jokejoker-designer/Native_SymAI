"""U11 N-round after PROGRAM killed hw_server. U11 RX gap + U8 CLEAR.
Not BOARD_PASS / PACK_ABI_24_24_PASS / PROGRAM_PASS.
"""
from __future__ import annotations

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
)
import serial
import uart_r2_u9_board_test as u9mod

u9mod.OUT = Path(r"D:\FPGA\arty_d\UART_R2\build_u11\board_test")
u9mod.BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u11\uart_r2_u11_candidate.bit")
BIT = u9mod.BIT
BAN = {
    "cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9",
    "f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7",
    "ec32257570bd6e193d9341086b75ce1ec5607958998cd144faae1d3fab034232",
    "17494f2cd18ca885fca74968b9182091d637508d720d56ef7bc09928af1aa213",
    "2bc835fd28174051dc2015f7bacd8ad5c919a5a2ce9c60695fe0530b405d6098",
    "66fe2bd739b31f4a62883e8d21d247ebe12d04c3b0b961af523733323ef1da88",
    "4ab8e14203c7c1bafd32862da055592ba12fbb361b7b74f307b7cbd284a227a1",
}
SETTLE_S = 15.0
ROUNDS = 3
OUT_NAME = "NN_U11.json"


def main() -> int:
    sha = sha256_file(BIT)
    if sha in BAN:
        print("REFUSE", sha)
        return 3
    port = find_port()
    if port is None:
        print("NO_COM")
        return 2
    print("NN_U11_SHA", sha)
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
    rounds_ok = 0
    try:
        send_words(ser, [CLR_CMD])
        c1 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR1", **c1})
        print("CLEAR1", c1["sub"], c1["word"])
        if c1.get("word") != f"{CLR_ACK:08x}":
            dump_json(OUT_NAME, {"stop": "CLEAR1", "sha": sha, "recs": recs})
            print("STOP CLEAR1")
            return 1
        v04 = load_mem("PA24-V-04")
        for rnd in range(ROUNDS):
            send_words(ser, v04)
            p = read_raw_stamped(ser, UART_TIMEOUT_S)
            recs.append(
                {
                    "step": "PACK_V04",
                    "round": rnd,
                    "gold_match": p.get("word") == f"{GOLD_OK:08x}",
                    **p,
                }
            )
            print("V04 r", rnd, p["sub"], p["word"])
            if p.get("word") != f"{GOLD_OK:08x}":
                dump_json(
                    OUT_NAME,
                    {"stop": "V04", "sha": sha, "rounds_ok": rounds_ok, "recs": recs},
                )
                print("STOP V04")
                return 1
            time.sleep(0.05)
            send_words(ser, [CLR_CMD])
            c2 = read_raw_stamped(ser, 3.0)
            recs.append({"step": "CLEAR2", "round": rnd, **c2})
            print("CLEAR2 r", rnd, c2["sub"], c2["word"])
            if c2.get("word") == f"{CLR_BUSY:08x}":
                dump_json(
                    OUT_NAME,
                    {"stop": "BUSY", "sha": sha, "rounds_ok": rounds_ok, "recs": recs},
                )
                print("STOP BUSY")
                return 1
            if c2.get("word") != f"{CLR_ACK:08x}":
                dump_json(
                    OUT_NAME,
                    {"stop": "CLEAR2", "sha": sha, "rounds_ok": rounds_ok, "recs": recs},
                )
                print("STOP CLEAR2")
                return 1
            rounds_ok += 1
        dump_json(
            OUT_NAME,
            {
                "when": now_iso(),
                "sha": sha,
                "class": "UART_R2_U11_CANDIDATE",
                "rounds_ok": rounds_ok,
                "PROGRAM_PASS": "NO",
                "BOARD_PASS": "NOT_EVIDENCED",
                "PACK_ABI_24_24_PASS": "NO",
                "recs": recs,
            },
        )
        print("NN_U11_ROUNDS_OK", rounds_ok)
        return 0
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
