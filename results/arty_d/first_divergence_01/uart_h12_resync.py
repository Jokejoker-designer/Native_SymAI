"""Board host: after CLEAR UNSUP, retry CLEAR with --unsup-pad N zeros (default 0).
Do not pad after PACK MAG/UNSUP. Frozen uart_pack24_clear_board.py not edited.
Not PACK_ABI_24_24_PASS / BOARD_PASS / PROGRAM_PASS.
"""
from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\m4_mig")
from uart_pack24_clear_board import (
    CLR_ACK,
    CLR_BUSY,
    CLR_CMD,
    CLR_ERR,
    OUT,
    find_port,
    load_mem,
    open_ser,
    read_word,
    send_words,
)

UNSUP = 0x0200075A
MAG = 0x0200015A
SENTINEL = 0x0200085A
GOLD = 0x010000A5
EVID = Path(r"D:\FPGA\arty_d\first_divergence_01")


def tok_name(w: int | None) -> str:
    if w is None:
        return "NO_BYTE"
    if w == CLR_ACK:
        return "ACK"
    if w == CLR_BUSY:
        return "BUSY"
    if w == CLR_ERR:
        return "ERR"
    if w == GOLD:
        return "GOLD"
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


def clear_with_resync(ser, recs: list, i: int, unsup_pad: int) -> int | None:
    send_words(ser, [CLR_CMD])
    got = read_word(ser, 3.0)
    recs.append({"i": i, "phase": "CLEAR", "got": None if got is None else f"{got:08x}", "tok": tok_name(got), "resync": False})
    print(f"H12B i={i} CLEAR {tok_name(got)}", flush=True)
    if got == CLR_ACK:
        return got
    if got == UNSUP:
        n = unsup_pad
        if n:
            ser.write(bytes(n))
            ser.flush()
            time.sleep(0.05)
        send_words(ser, [CLR_CMD])
        got2 = read_word(ser, 3.0)
        recs.append(
            {
                "i": i,
                "phase": f"CLEAR_UNSUP_PAD{n}",
                "got": None if got2 is None else f"{got2:08x}",
                "tok": tok_name(got2),
                "resync": n > 0,
            }
        )
        print(f"H12B i={i} CLEAR_UNSUP_PAD{n} {tok_name(got2)}", flush=True)
        return got2
    if got is None:
        return got
    if got == MAG:
        return got
    if got == CLR_BUSY:
        time.sleep(0.2)
        send_words(ser, [CLR_CMD])
        got2 = read_word(ser, 3.0)
        recs.append(
            {
                "i": i,
                "phase": "CLEAR_BUSY_RETRY",
                "got": None if got2 is None else f"{got2:08x}",
                "tok": tok_name(got2),
                "resync": False,
            }
        )
        print(f"H12B i={i} CLEAR_BUSY_RETRY {tok_name(got2)}", flush=True)
        return got2
    return got


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--case", default="PA24-V-04")
    ap.add_argument("--n", type=int, default=20)
    ap.add_argument("--unsup-pad", type=int, default=0)
    ap.add_argument("--out", default=str(EVID / "H12_BOARD_UNSUP_PAD0.jsonl"))
    args = ap.parse_args()
    port = find_port()
    if port is None:
        print("SKIP no COM")
        return 2
    words = load_mem(OUT / f"{args.case}.mem")
    ser = open_ser(port)
    recs: list[dict] = []
    n_gold = 0
    n_unsup = 0
    n_mag = 0
    n_mute = 0
    try:
        for i in range(args.n):
            c = clear_with_resync(ser, recs, i, args.unsup_pad)
            if c is None:
                n_mute += 1
                print(f"H12B stop MUTE at CLEAR i={i}", flush=True)
                break
            if c != CLR_ACK:
                print(f"H12B skip PACK i={i} tok={tok_name(c)}", flush=True)
                continue
            send_words(ser, words)
            p = read_word(ser, 12.0)
            name = tok_name(p)
            recs.append({"i": i, "phase": "PACK", "got": None if p is None else f"{p:08x}", "tok": name, "resync": False})
            print(f"H12B i={i} PACK {name}", flush=True)
            if p is None:
                n_mute += 1
                continue
            if p == GOLD:
                n_gold += 1
            elif p == UNSUP:
                n_unsup += 1
            elif p == MAG:
                n_mag += 1
    finally:
        ser.close()
    outp = Path(args.out)
    outp.write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
    print(
        f"H12_BOARD_UNSUP_PAD gold={n_gold} unsup={n_unsup} mag={n_mag} mute={n_mute} "
        f"nrec={len(recs)} wrote {outp} (not PACK_ABI_24_24_PASS / not BOARD_PASS / not PROGRAM_PASS)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
