"""D-PACK-VALIDATION-RESET-01 board diagnostic. VALIDATION_ONLY. Not PACK_ABI.

Discriminate board ingest failure class after CLEAR:
  H1 word overrun under backpressure  -> paced bytes recover gold, burst does not
  H2 byte misalignment / line noise   -> paced does not recover
Per case: CLEAR -> expect CLEAR_ACK -> send case (paced or burst) -> raw RX dump.
Metrics separate: CLEAR_ACK_OK, GOLD_MATCH, ISO_EQ. Not PACK_ABI_24_24_PASS / BOARD_PASS.
"""
from __future__ import annotations

import argparse
import csv
import json
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\m4_mig")
import uart_pack24_clear_board as base  # noqa: E402

EVID = Path(r"D:\FPGA\arty_d\m4_mig_clear")


def read_raw(ser, first_timeout_s: float, idle_s: float = 0.25) -> bytes:
    ser.timeout = 0.05
    got = bytearray()
    t_end = time.time() + first_timeout_s
    last = None
    while True:
        chunk = ser.read(4096)
        now = time.time()
        if chunk:
            got.extend(chunk)
            last = now
        elif last is not None and now - last >= idle_s:
            break
        elif last is None and now >= t_end:
            break
    return bytes(got)


def send_paced(ser, words: list[int], byte_gap_s: float) -> None:
    for w in words:
        for b in w.to_bytes(4, "little"):
            ser.write(bytes([b]))
            ser.flush()
            time.sleep(byte_gap_s)


def first_word(raw: bytes) -> int | None:
    if len(raw) < 4:
        return None
    return int.from_bytes(raw[:4], "little")


def first_token(raw: bytes) -> tuple[int | None, bytes]:
    for tok in (base.CLR_ACK, base.CLR_BUSY, base.CLR_ERR):
        needle = tok.to_bytes(4, "little")
        i = raw.find(needle)
        if i >= 0:
            return tok, raw[i + 4 :]
    return first_word(raw), raw[4:] if len(raw) >= 4 else raw


def run(ser, rows: list[dict], mode: str, gap_s: float, iso: dict) -> list[dict]:
    recs: list[dict] = []
    for row in rows:
        cid = row["case_id"]
        exp = base.expect_word(int(row["ack"]), int(row["reject"]), int(row["reason"]))
        base.drain_until_idle(ser, idle_s=0.2, max_s=1.5)
        base.send_words(ser, [base.CLR_CMD])
        raw_c = read_raw(ser, 3.0)
        got_c, _ = first_token(raw_c)
        clr_ok = got_c == base.CLR_ACK
        words = base.load_mem(base.OUT / f"{cid}.mem")
        t0 = time.time()
        if mode == "paced":
            send_paced(ser, words, gap_s)
        else:
            base.send_words(ser, words)
        raw_p = read_raw(ser, base.UART_TIMEOUT_S)
        dt = time.time() - t0
        got = first_word(raw_p)
        rec = {
            "mode": mode,
            "case_id": cid,
            "nwords": len(words),
            "clear_raw": raw_c.hex(),
            "clear_ok": clr_ok,
            "expect": f"{exp:08x}",
            "got": None if got is None else f"{got:08x}",
            "raw": raw_p.hex(),
            "raw_len": len(raw_p),
            "gold_match": got == exp,
            "iso_got": iso.get(cid),
            "iso_eq": (None if got is None else f"{got:08x}") == iso.get(cid),
            "dt_s": round(dt, 3),
        }
        print(
            f"{mode} {cid} clr={'OK' if clr_ok else raw_c.hex()} exp={exp:08x} "
            f"got={rec['got']} rawlen={len(raw_p)} {'GOLD' if rec['gold_match'] else 'MISS'} "
            f"iso={'EQ' if rec['iso_eq'] else 'NE'} dt={dt:.3f}",
            flush=True,
        )
        recs.append(rec)
    return recs


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", choices=["paced", "burst"], default="paced")
    ap.add_argument("--gap-ms", type=float, default=0.5)
    ap.add_argument("--settle", type=float, default=8.0)
    args = ap.parse_args()
    port = base.find_port()
    if port is None:
        print("SKIP no COM")
        return 2
    rows = list(csv.DictReader(base.TSV.open(encoding="utf-8"), delimiter="\t"))
    iso: dict = {}
    iso_path = base.ROOT / "UART_PACK24_ISO_BOARD.jsonl"
    if iso_path.exists():
        for ln in iso_path.read_text(encoding="utf-8").splitlines():
            if ln.strip():
                r = json.loads(ln)
                iso[r["case_id"]] = r.get("got")
    ser = base.open_ser(port)
    time.sleep(args.settle)
    base.drain_until_idle(ser, idle_s=0.5, max_s=6.0)
    try:
        recs = run(ser, rows, args.mode, args.gap_ms / 1000.0, iso)
    finally:
        ser.close()
    EVID.mkdir(parents=True, exist_ok=True)
    outp = EVID / f"UART_CLEAR_DIAG_{args.mode}.jsonl"
    outp.write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
    n_clr = sum(1 for r in recs if r["clear_ok"])
    n_gold = sum(1 for r in recs if r["gold_match"])
    n_iso = sum(1 for r in recs if r["iso_eq"])
    print(
        f"UART_CLEAR_DIAG mode={args.mode} gap_ms={args.gap_ms} CLEAR_ACK_OK={n_clr}/{len(recs)} "
        f"GOLD_MATCH={n_gold}/{len(recs)} ISO_EQ={n_iso}/{len(recs)} "
        f"(diagnostic; not PACK_ABI_24_24_PASS / BOARD_PASS)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
