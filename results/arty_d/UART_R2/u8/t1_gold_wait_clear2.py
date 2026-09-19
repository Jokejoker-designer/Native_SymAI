"""U8: T1 + V-04 GOLD then 0.5s then CLEAR2. Fresh program required."""
from __future__ import annotations

import sys
import time

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u8")
from uart_r2_u8_board_test import (
    CLR_ACK,
    CLR_CMD,
    UART_TIMEOUT_S,
    dump_json,
    find_port,
    load_mem,
    now_iso,
    read_raw_stamped,
    send_words,
)
import serial

def main() -> int:
    port = find_port()
    if port is None:
        print("NO_COM")
        return 2
    print("SETTLE_12S", port)
    time.sleep(12.0)
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
            dump_json("T1_GOLD_WAIT_CLEAR2.json", {"stop": "CLEAR1 not ACK", "recs": recs})
            return 1
        v04 = load_mem("PA24-V-04")
        send_words(ser, v04)
        p1 = read_raw_stamped(ser, UART_TIMEOUT_S)
        recs.append({"step": "PACK_V04", **p1})
        print("V04", p1["sub"], p1["word"])
        # G1: dest-complete token is not a license to issue CLEAR in the same
        # UART instant. Drain host RX then wait one char-time budget.
        t_drain = time.time()
        drained = 0
        while time.time() - t_drain < 0.25:
            extra = ser.read(4096)
            drained += len(extra)
        ser.reset_input_buffer()
        time.sleep(0.25)
        send_words(ser, [CLR_CMD])
        c2 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR2_AFTER_GOLD_DRAIN", "drained_after_gold": drained, **c2})
        print("CLEAR2", c2["sub"], c2["word"], "n=", c2["n"])
        dump_json("T1_GOLD_WAIT_CLEAR2.json", {"when": now_iso(), "port": port, "recs": recs})
        return 0
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
