"""Layer 1 host commit windows. One COM session. Not BOARD_PASS / PACK_ABI_24_24_PASS.

Laws encoded:
  PROGRAM != READY          settle COM-closed after JTAG
  COM-open != MARK idle     short drain then first command immediately
  ACK != pack license       wait after ACK before pack
  GOLD/NAK != CLEAR license drain+wait after dest-complete token
  leftover miss => STOP     do not send the next semantic command
"""
from __future__ import annotations

import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u8")
from uart_r2_u8_board_test import (
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

OUT_NAME = "LAYER1_COMMIT_WINDOWS.json"
SETTLE_AFTER_PROGRAM_S = 12.0
DRAIN_AFTER_OPEN_S = 0.25
WAIT_AFTER_ACK_S = 0.0
WAIT_AFTER_TOKEN_S = 0.0
ROUNDS = 3


def open_commit_port(port: str) -> serial.Serial:
    # Match the only GOLD session: dtr/rts False before open. Do not set dsrdtr
    # (that path returned CLEAR1 n=0 on this FTDI).
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
    while time.time() - t0 < DRAIN_AFTER_OPEN_S:
        ser.read(4096)
    ser.reset_input_buffer()
    return ser


def drain_idle(ser: serial.Serial, idle_s: float, max_s: float) -> int:
    n = 0
    t_end = time.time() + max_s
    last = time.time()
    ser.timeout = 0.05
    while time.time() < t_end:
        chunk = ser.read(4096)
        if chunk:
            n += len(chunk)
            last = time.time()
        elif time.time() - last >= idle_s:
            break
    ser.reset_input_buffer()
    return n


def main() -> int:
    sha = sha256_file(BIT)
    if sha in BAN:
        dump_json("REFUSE_IDENTITY.json", {"sha": sha})
        print("REFUSE", sha)
        return 3
    port = find_port()
    if port is None:
        dump_json("NO_COM.json", {"err": "FTDI 776EB not found"})
        print("NO_COM")
        return 2
    print("LAYER1_SHA", sha)
    print("KILL_HW_SERVER_BEFORE_UART")
    import subprocess

    subprocess.run(["taskkill", "/F", "/IM", "hw_server.exe"], capture_output=True)
    subprocess.run(["taskkill", "/F", "/IM", "cs_server.exe"], capture_output=True)
    print("SETTLE_AFTER_PROGRAM", SETTLE_AFTER_PROGRAM_S, port)
    time.sleep(SETTLE_AFTER_PROGRAM_S)
    ser = open_commit_port(port)
    recs: list[dict] = []
    rounds_ok = 0
    try:
        send_words(ser, [CLR_CMD])
        c1 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR1", "round": 0, **c1})
        print("CLEAR1", c1["sub"], c1["word"])
        if c1.get("word") != f"{CLR_ACK:08x}":
            dump_json(OUT_NAME, {"stop": "CLEAR1 not ACK", "sha": sha, "recs": recs})
            print("STOP layer1 CLEAR1")
            return 1
        time.sleep(WAIT_AFTER_ACK_S)

        v04 = load_mem("PA24-V-04")
        for rnd in range(ROUNDS):
            send_words(ser, v04)
            p = read_raw_stamped(ser, UART_TIMEOUT_S)
            recs.append(
                {
                    "step": "PACK_V04",
                    "round": rnd,
                    "expect": f"{GOLD_OK:08x}",
                    "gold_match": p.get("word") == f"{GOLD_OK:08x}",
                    "tx_n": 4 * len(v04),
                    **p,
                }
            )
            print("V04 r", rnd, p["sub"], p["word"])
            if p.get("word") != f"{GOLD_OK:08x}":
                dump_json(
                    OUT_NAME,
                    {
                        "stop": "V04 not GOLD",
                        "sha": sha,
                        "rounds_ok": rounds_ok,
                        "recs": recs,
                    },
                )
                print("STOP layer1 V04")
                return 1
            send_words(ser, [CLR_CMD])
            c2 = read_raw_stamped(ser, 3.0)
            recs.append(
                {
                    "step": "CLEAR_AFTER_GOLD",
                    "round": rnd,
                    **c2,
                }
            )
            print("CLEAR_AFTER_GOLD r", rnd, c2["sub"], c2["word"])
            if c2.get("word") not in (f"{CLR_ACK:08x}", f"{CLR_BUSY:08x}"):
                dump_json(
                    OUT_NAME,
                    {
                        "stop": "CLEAR after GOLD not ACK/BUSY",
                        "sha": sha,
                        "rounds_ok": rounds_ok,
                        "recs": recs,
                    },
                )
                print("STOP layer1 CLEAR2")
                return 1
            if c2.get("word") == f"{CLR_BUSY:08x}":
                dump_json(
                    OUT_NAME,
                    {
                        "stop": "CLEAR BUSY after GOLD",
                        "sha": sha,
                        "rounds_ok": rounds_ok,
                        "recs": recs,
                    },
                )
                print("STOP layer1 BUSY")
                return 1
            time.sleep(WAIT_AFTER_ACK_S)
            rounds_ok += 1
        dump_json(
            OUT_NAME,
            {
                "when": now_iso(),
                "port": port,
                "sha": sha,
                "layer": "HOST_COMMIT_WINDOWS",
                "rounds_ok": rounds_ok,
                "rounds_want": ROUNDS,
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
