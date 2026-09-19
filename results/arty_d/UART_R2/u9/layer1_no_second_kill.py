"""One-shot after PROGRAM already killed hw_server. No second kill.
Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.
"""
from __future__ import annotations

import sys
import time

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u9")
from uart_r2_u9_board_test import (
    BAN,
    BIT,
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

OUT_NAME = "LAYER1_NO_SECOND_KILL.json"
SETTLE_S = 15.0
DRAIN_S = 0.25
ROUNDS = 3


def main() -> int:
    sha = sha256_file(BIT)
    if sha in BAN:
        print("REFUSE", sha)
        return 3
    port = find_port()
    if port is None:
        print("NO_COM")
        return 2
    print("NO_SECOND_KILL_SHA", sha)
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
    while time.time() - t0 < DRAIN_S:
        ser.read(4096)
    ser.reset_input_buffer()
    recs = []
    rounds_ok = 0
    try:
        send_words(ser, [CLR_CMD])
        c1 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR1", **c1})
        print("CLEAR1", c1["sub"], c1["word"], "n", c1["n"])
        if c1.get("word") != f"{CLR_ACK:08x}":
            dump_json(OUT_NAME, {"stop": "CLEAR1 not ACK", "sha": sha, "recs": recs})
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
                    {"stop": "V04 not GOLD", "sha": sha, "rounds_ok": rounds_ok, "recs": recs},
                )
                print("STOP V04")
                return 1
            send_words(ser, [CLR_CMD])
            c2 = read_raw_stamped(ser, 3.0)
            recs.append({"step": "CLEAR2", "round": rnd, **c2})
            print("CLEAR2 r", rnd, c2["sub"], c2["word"])
            if c2.get("word") != f"{CLR_ACK:08x}":
                dump_json(
                    OUT_NAME,
                    {"stop": "CLEAR2 not ACK", "sha": sha, "rounds_ok": rounds_ok, "recs": recs},
                )
                print("STOP CLEAR2")
                return 1
            rounds_ok += 1
        dump_json(
            OUT_NAME,
            {
                "when": now_iso(),
                "sha": sha,
                "rounds_ok": rounds_ok,
                "PROGRAM_PASS": "NO",
                "BOARD_PASS": "NOT_EVIDENCED",
                "PACK_ABI_24_24_PASS": "NO",
                "recs": recs,
            },
        )
        print("LAYER1_HOST_ROUNDS_OK", rounds_ok)
        return 0
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
