"""H19 board probe: CLEAR ACK then exact A-01 bytes; log TX length vs PACK token.

Does not edit frozen uart_pack24_clear_board.py.
Does not pad. Does not claim PACK_ABI_24_24_PASS / BOARD_PASS / PROGRAM_PASS.
"""
from __future__ import annotations

import json
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\m4_mig")
from uart_pack24_clear_board import (
    CLR_ACK,
    CLR_BUSY,
    CLR_ERR,
    OUT,
    drain_until_idle,
    find_port,
    load_mem,
    open_ser,
    read_raw,
)

EVID = Path(r"D:\FPGA\arty_d\first_divergence_01")
CLR_CMD = 0x44524743
UNSUP = 0x0200075A
NAK_R02 = 0x0200025A
MAG = 0x0200015A
NLOOP = 3


def tok_name(w: int | None) -> str:
    if w is None:
        return "NO_BYTE"
    table = {
        CLR_ACK: "ACK",
        CLR_BUSY: "BUSY",
        CLR_ERR: "ERR",
        UNSUP: "UNSUP",
        NAK_R02: "NAK_R02",
        MAG: "MAG",
    }
    return table.get(w, f"OTHER_{w:08x}")


def first_word(raw: bytes) -> int | None:
    if len(raw) < 4:
        return None
    return int.from_bytes(raw[:4], "little")


def main() -> int:
    port = find_port()
    if port is None:
        print("H19_BOARD SKIP no COM 776EB")
        return 2
    words = load_mem(OUT / "PA24-A-01.mem")
    payload = b"".join(w.to_bytes(4, "little") for w in words)
    recs: list[dict] = []
    ser = open_ser(port)
    try:
        for i in range(NLOOP):
            pre = ser.in_waiting
            clr = CLR_CMD.to_bytes(4, "little")
            n_clr = ser.write(clr)
            ser.flush()
            raw_c = read_raw(ser, 3.0, idle_s=0.15)
            cw = first_word(raw_c)
            mid = ser.in_waiting
            rec_c = {
                "i": i,
                "phase": "CLEAR",
                "tx_n": n_clr,
                "tx_expect": 4,
                "in_waiting_before": pre,
                "in_waiting_after": mid,
                "rx_n": len(raw_c),
                "rx_hex": raw_c.hex(),
                "got": None if cw is None else f"{cw:08x}",
                "tok": tok_name(cw),
            }
            recs.append(rec_c)
            print(
                f"H19 i={i} CLEAR tx={n_clr} rx_n={len(raw_c)} tok={rec_c['tok']} "
                f"got={rec_c['got']} hex={raw_c.hex()[:32]}",
                flush=True,
            )
            if cw != CLR_ACK:
                print("H19 stop: no ACK (mute or leftover)", flush=True)
                break
            n_p = ser.write(payload)
            ser.flush()
            raw_p = read_raw(ser, 12.0, idle_s=0.2)
            pw = first_word(raw_p)
            rec_p = {
                "i": i,
                "phase": "PACK",
                "tx_n": n_p,
                "tx_expect": len(payload),
                "tx_nwords": len(words),
                "rx_n": len(raw_p),
                "rx_hex": raw_p.hex(),
                "got": None if pw is None else f"{pw:08x}",
                "tok": tok_name(pw),
                "exact_tx": n_p == len(payload),
            }
            recs.append(rec_p)
            print(
                f"H19 i={i} PACK tx={n_p}/{len(payload)} exact={rec_p['exact_tx']} "
                f"rx_n={len(raw_p)} tok={rec_p['tok']} got={rec_p['got']}",
                flush=True,
            )
            time.sleep(0.05)
    finally:
        ser.close()

    outp = EVID / "H19_BOARD_A01.jsonl"
    with outp.open("w", encoding="utf-8") as fh:
        for r in recs:
            fh.write(json.dumps(r) + "\n")
    n_unsup = sum(1 for r in recs if r.get("tok") == "UNSUP")
    n_nak = sum(1 for r in recs if r.get("tok") == "NAK_R02")
    n_mute = sum(1 for r in recs if r.get("tok") == "NO_BYTE")
    print(
        f"H19_BOARD jsonl={outp} unsup={n_unsup} nak={n_nak} mute={n_mute} "
        f"(not PACK_ABI_24_24_PASS)",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
