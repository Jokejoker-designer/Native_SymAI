"""H18 stamped UART capture. Does not modify frozen uart_pack24_clear_board.py.

Writes timestamps + raw + H18 class. NOT_RUN until H9 removed arm is authorized.
Not PACK_ABI_24_24_PASS / BOARD_PASS.
"""
from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

import serial
from serial.tools import list_ports

sys.path.insert(0, r"D:\FPGA\arty_d\m4_mig")
from uart_pack24_clear_board import (
    CLR_ACK,
    CLR_BUSY,
    CLR_CMD,
    CLR_ERR,
    OUT,
    load_mem,
    open_ser,
    send_words,
)

EVID = Path(r"D:\FPGA\arty_d\first_divergence_01")
MAG = 0x0200015A
UNSUP = 0x0200075A
SENTINEL = 0x0200085A


def find_port() -> str | None:
    for p in list_ports.comports():
        if (p.serial_number or "").upper().endswith("776EB"):
            return p.device
    return None


def sub_of(w: int) -> str:
    if w == CLR_ACK:
        return "ACK"
    if w == CLR_BUSY:
        return "BUSY"
    if w == CLR_ERR:
        return "ERR"
    if w == MAG:
        return "MAG"
    if w == UNSUP:
        return "UNSUP"
    if w == SENTINEL:
        return "SENTINEL"
    if (w & 0xFF) == 0xA5 and ((w >> 24) & 0xFF) == 0x01:
        return "GOLD"
    if (w & 0xFF) == 0x5A and ((w >> 24) & 0xFF) == 0x02:
        return f"NAK_R{(w >> 8) & 0xFF:02x}"
    return f"OTHER_{w:08x}"


def h18_class(raw: bytes, expect: int | None) -> dict:
    n = len(raw)
    if n == 0:
        return {"h18": "NO_BYTE", "sub": "NONE", "n": 0, "word": None}
    if n < 4:
        return {"h18": "PARTIAL_RESPONSE", "sub": "NONE", "n": n, "word": None}
    w = int.from_bytes(raw[:4], "little")
    word = f"{w:08x}"
    sub = sub_of(w)
    if expect is not None and w == expect:
        h18 = "CORRECT_4BYTE"
    else:
        h18 = "WRONG_VALID_4BYTE"
    extra = n - 4
    return {
        "h18": h18,
        "sub": sub,
        "n": n,
        "word": word,
        "extra_bytes": extra,
    }


def read_raw_stamped(ser, timeout_s: float, idle_s: float = 0.25) -> dict:
    ser.timeout = 0.05
    got = bytearray()
    chunks: list[dict] = []
    t0 = time.time()
    t_end = t0 + timeout_s
    last = None
    t_first = None
    while True:
        chunk = ser.read(4096)
        now = time.time()
        if chunk:
            if t_first is None:
                t_first = now
            gap = None if last is None else round(now - last, 4)
            chunks.append({"t": round(now - t0, 4), "n": len(chunk), "hex": chunk.hex(), "gap_s": gap})
            got.extend(chunk)
            last = now
        elif last is not None and now - last >= idle_s:
            break
        elif last is None and now >= t_end:
            break
    t_last = last
    delayed = bool(t_first is not None and (t_first - t0) > 1.0)
    return {
        "raw_hex": bytes(got).hex(),
        "n": len(got),
        "dt_s": round(time.time() - t0, 4),
        "t_first_s": None if t_first is None else round(t_first - t0, 4),
        "t_last_s": None if t_last is None else round(t_last - t0, 4),
        "delayed_gt_1s": delayed,
        "chunks": chunks,
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", choices=["probe", "h11"], default="probe")
    ap.add_argument("--case", default="PA24-V-04")
    ap.add_argument("--n", type=int, default=8)
    ap.add_argument("--out", default=str(EVID / "H18_STAMP.jsonl"))
    args = ap.parse_args()
    port = find_port()
    if port is None:
        print("SKIP no COM")
        return 2
    ser = open_ser(port)
    outp = Path(args.out)
    recs = []
    try:
        if args.mode == "probe":
            t_tx = time.time()
            send_words(ser, [CLR_CMD])
            cap = read_raw_stamped(ser, 3.0)
            cls = h18_class(bytes.fromhex(cap["raw_hex"] or ""), CLR_ACK)
            rec = {"phase": "CLEAR", "t_tx": t_tx, **cap, **cls, "expect": f"{CLR_ACK:08x}"}
            recs.append(rec)
            print(
                f"PROBE h18={cls['h18']} sub={cls['sub']} n={cap['n']} "
                f"t_first={cap['t_first_s']} delayed={cap['delayed_gt_1s']}",
                flush=True,
            )
        else:
            words = load_mem(OUT / f"{args.case}.mem")
            for i in range(args.n):
                send_words(ser, [CLR_CMD])
                cap_c = read_raw_stamped(ser, 3.0)
                cls_c = h18_class(bytes.fromhex(cap_c["raw_hex"] or ""), CLR_ACK)
                rec_c = {"i": i, "phase": "CLEAR", "case": args.case, **cap_c, **cls_c}
                recs.append(rec_c)
                print(f"H11 {i} CLEAR {cls_c['h18']} {cls_c['sub']} n={cap_c['n']}", flush=True)
                if cls_c["h18"] == "NO_BYTE":
                    break
                if cls_c.get("word") != f"{CLR_ACK:08x}":
                    continue
                send_words(ser, words)
                cap_p = read_raw_stamped(ser, 12.0)
                cls_p = h18_class(bytes.fromhex(cap_p["raw_hex"] or ""), 0x010000A5)
                rec_p = {"i": i, "phase": "PACK", "case": args.case, **cap_p, **cls_p}
                recs.append(rec_p)
                print(f"H11 {i} PACK {cls_p['h18']} {cls_p['sub']} n={cap_p['n']}", flush=True)
                if cls_p["h18"] == "NO_BYTE":
                    break
    finally:
        ser.close()
    outp.write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
    print(f"wrote {outp} n={len(recs)} (not PACK_ABI_24_24_PASS)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
