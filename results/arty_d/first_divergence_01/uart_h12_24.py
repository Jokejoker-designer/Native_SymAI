"""24-case board diagnostic with pad0 CLEAR retry. Frozen uart_pack24_clear_board.py not edited.

After CLEAR UNSUP, retry CLEAR with 0 pad bytes. Do not pad after PACK NAK.
Not PACK_ABI_24_24_PASS / BOARD_PASS / PROGRAM_PASS.
"""
from __future__ import annotations

import csv
import json
import sys
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\m4_mig")
from uart_pack24_clear_board import (
    CLR_ACK,
    OUT,
    TSV,
    expect_word,
    find_port,
    load_mem,
    open_ser,
    read_word,
    send_words,
)

sys.path.insert(0, r"D:\FPGA\arty_d\first_divergence_01")
from uart_h12_resync import clear_with_resync, tok_name

EVID = Path(r"D:\FPGA\arty_d\first_divergence_01")


def main() -> int:
    port = find_port()
    if port is None:
        print("SKIP no COM")
        return 2
    rows = list(csv.DictReader(TSV.open(encoding="utf-8"), delimiter="\t"))
    ser = open_ser(port)
    recs: list[dict] = []
    n_ok = 0
    n_pack = 0
    n_mute = 0
    n_clear_fail = 0
    try:
        for i, row in enumerate(rows):
            cid = row["case_id"]
            exp = expect_word(int(row["ack"]), int(row["reject"]), int(row["reason"]))
            n0 = len(recs)
            c = clear_with_resync(ser, recs, i, unsup_pad=0)
            for r in recs[n0:]:
                r["case_id"] = cid
            if c is None:
                n_mute += 1
                print(f"H12_24 {cid} CLEAR MUTE stop", flush=True)
                break
            if c != CLR_ACK:
                n_clear_fail += 1
                print(f"H12_24 {cid} skip PACK CLEAR={tok_name(c)}", flush=True)
                continue
            words = load_mem(OUT / f"{cid}.mem")
            send_words(ser, words)
            p = read_word(ser, 12.0)
            name = tok_name(p)
            ok = p == exp
            n_pack += 1
            n_ok += int(ok)
            recs.append(
                {
                    "i": i,
                    "case_id": cid,
                    "phase": "PACK",
                    "expect": f"{exp:08x}",
                    "got": None if p is None else f"{p:08x}",
                    "tok": name,
                    "ok": ok,
                }
            )
            print(
                f"H12_24 {cid} exp={exp:08x} got={None if p is None else f'{p:08x}'} {name} "
                f"{'OK' if ok else 'FAIL'}",
                flush=True,
            )
            if p is None:
                n_mute += 1
                print(f"H12_24 PACK MUTE stop at {cid}", flush=True)
                break
    finally:
        ser.close()
    outp = EVID / "H12_BOARD_24_PAD0.jsonl"
    outp.write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
    print(
        f"H12_BOARD_24_PAD0 pack_ok={n_ok}/{n_pack} clear_fail={n_clear_fail} mute={n_mute} "
        f"wrote {outp} (not PACK_ABI_24_24_PASS / not BOARD_PASS / not PROGRAM_PASS)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
