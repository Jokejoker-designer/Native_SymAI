"""One COM session: 12s settle, CLEAR, then V-04 pack, then second CLEAR, then A-01.
No BREAK. Writes only under build_u3/board_test. Not PACK_ABI_24_24_PASS.
"""
from __future__ import annotations

import json
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2")
from uart_r2_u3_board_test import (  # noqa: E402
    CLR_ACK,
    CLR_CMD,
    GOLD_OK,
    NAK_R02,
    OUT,
    UART_TIMEOUT_S,
    dump_json,
    find_port,
    load_mem,
    now_iso,
    open_ser,
    read_raw_stamped,
    send_words,
    tsv_expect,
)


def main() -> int:
    port = find_port()
    if port is None:
        dump_json("NO_COM.json", {"when": now_iso(), "err": "FTDI 776EB not found"})
        print("SKIP no COM")
        return 2
    print("SETTLE_12S_BEFORE_OPEN", port)
    time.sleep(12.0)
    # Match the only T1 procedure that ACKed: do not drain_until_idle(max=4s).
    import serial

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
    t_drain = time.time()
    while time.time() - t_drain < 0.25:
        ser.read(4096)
    ser.reset_input_buffer()
    recs = []
    try:
        send_words(ser, [CLR_CMD])
        c1 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR1", **c1})
        print("CLEAR1", c1["sub"], "n=", c1["n"], "word=", c1["word"])
        if c1.get("word") != f"{CLR_ACK:08x}":
            dump_json("T1_THEN_PACK.json", {"stop": "CLEAR1 not ACK", "recs": recs})
            print("STOP no pack")
            return 1

        v04 = load_mem("PA24-V-04")
        send_words(ser, v04)
        p1 = read_raw_stamped(ser, UART_TIMEOUT_S)
        recs.append(
            {
                "step": "PACK_V04_NO_SECOND_CLEAR",
                "expect": f"{GOLD_OK:08x}",
                "gold_match": p1.get("word") == f"{GOLD_OK:08x}",
                "tx_n": 4 * len(v04),
                **p1,
            }
        )
        print(
            "V04",
            p1["sub"],
            "n=",
            p1["n"],
            "word=",
            p1["word"],
            "match=",
            recs[-1]["gold_match"],
        )

        send_words(ser, [CLR_CMD])
        c2 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR2_AFTER_V04", **c2})
        print("CLEAR2", c2["sub"], "n=", c2["n"], "word=", c2["word"])

        if c2.get("word") == f"{CLR_ACK:08x}":
            a01 = load_mem("PA24-A-01")
            send_words(ser, a01)
            p2 = read_raw_stamped(ser, UART_TIMEOUT_S)
            recs.append(
                {
                    "step": "PACK_A01_AFTER_CLEAR2",
                    "expect": f"{tsv_expect('PA24-A-01'):08x}",
                    "gold_match": p2.get("word") == f"{NAK_R02:08x}",
                    "tx_n": 4 * len(a01),
                    **p2,
                }
            )
            print(
                "A01",
                p2["sub"],
                "n=",
                p2["n"],
                "word=",
                p2["word"],
                "match=",
                recs[-1]["gold_match"],
            )
        else:
            recs.append({"step": "PACK_A01_SKIPPED", "reason": "CLEAR2 not ACK"})
            print("A01 skipped")

        dump_json("T1_THEN_PACK.json", {"when": now_iso(), "port": port, "recs": recs})
        return 0
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
