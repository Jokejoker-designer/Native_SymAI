"""D-PACK-VALIDATION-RESET-01 board host.

VALIDATION_ONLY CLEAR_REQ 0x44524743 ACK 0xC1EA50A5 BUSY 0xC1EA50B5.
NOT_PACK_ABI / NOT_ASTRA_ABI / NOT_FINAL_TOP_CONTRACT.
Program FPGA once (arty_a7_r2_top_m4_mig_validation_clear.bit), then:
  --mode clear   two rounds of CLEAR then each of 24
  --mode seq     24 sequential without CLEAR
  --mode compare vs UART_PACK24_ISO_BOARD.jsonl (historical ISO 14/24)
Metrics: CLEAR_EQ_REPROGRAM vs GOLD_MATCH are separate.
Not PACK_ABI_24_24_PASS / BOARD_PASS.
"""
from __future__ import annotations

import argparse
import csv
import json
import sys
import time
from pathlib import Path

ROOT = Path(r"D:\FPGA\arty_d\m4_mig")
EVID = Path(r"D:\FPGA\arty_d\m4_mig_clear")
OUT = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)
TSV = OUT / "pack_abi24_expect.tsv"
CLR_CMD = 0x44524743
CLR_ACK = 0xC1EA50A5
CLR_BUSY = 0xC1EA50B5
CLR_ERR = 0xC1EA50E5
UART_TIMEOUT_S = 12.0


def load_mem(path: Path) -> list[int]:
    lines = [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]
    nwords = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + nwords]]
    if len(words) != nwords:
        raise ValueError(f"{path.name} short {len(words)}/{nwords}")
    return words


def expect_word(ack: int, rej: int, reason: int) -> int:
    if ack:
        return (0x01 << 24) | (reason << 8) | 0xA5
    if rej:
        return (0x02 << 24) | (reason << 8) | 0x5A
    raise ValueError("neither ack nor rej")


def find_port() -> str | None:
    from serial.tools import list_ports

    for p in list_ports.comports():
        if (p.serial_number or "").upper().endswith("776EB"):
            return p.device
    return None


def drain_until_idle(ser, idle_s: float = 0.3, max_s: float = 4.0) -> int:
    ser.timeout = 0.05
    discarded = 0
    t_end = time.time() + max_s
    last_rx = time.time()
    while time.time() < t_end:
        chunk = ser.read(4096)
        if chunk:
            discarded += len(chunk)
            last_rx = time.time()
        elif time.time() - last_rx >= idle_s:
            break
    ser.reset_input_buffer()
    return discarded


def read_word(ser, timeout_s: float) -> int | None:
    ser.timeout = 0.2
    got = bytearray()
    t0 = time.time()
    while len(got) < 4 and (time.time() - t0) < timeout_s:
        chunk = ser.read(4 - len(got))
        if chunk:
            got.extend(chunk)
    if len(got) < 4:
        return None
    return int.from_bytes(bytes(got), "little")


def send_words(ser, words: list[int]) -> None:
    ser.write(b"".join(w.to_bytes(4, "little") for w in words))
    ser.flush()


def open_ser(port: str):
    import serial

    ser = serial.Serial()
    ser.port = port
    ser.baudrate = 115200
    ser.timeout = 0.2
    ser.write_timeout = 8.0
    ser.dtr = False
    ser.rts = False
    ser.open()
    drain_until_idle(ser)
    return ser


def read_raw(ser, timeout_s: float, idle_s: float = 0.25) -> bytes:
    ser.timeout = 0.05
    got = bytearray()
    t_end = time.time() + timeout_s
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


def find_token(raw: bytes, token: int) -> tuple[int | None, bytes]:
    needle = token.to_bytes(4, "little")
    i = raw.find(needle)
    if i < 0:
        if len(raw) < 4:
            return None, raw
        return int.from_bytes(raw[:4], "little"), raw[4:]
    return token, raw[i + 4 :]


def do_clear(ser) -> int | None:
    last: int | None = None
    for _ in range(3):
        drain_until_idle(ser, idle_s=0.15, max_s=1.0)
        send_words(ser, [CLR_CMD])
        raw = read_raw(ser, 2.0, idle_s=0.15)
        got, _ = find_token(raw, CLR_ACK)
        if got == CLR_ACK:
            drain_until_idle(ser, idle_s=0.1, max_s=0.4)
            return CLR_ACK
        got_b, _ = find_token(raw, CLR_BUSY)
        if got_b == CLR_BUSY:
            drain_until_idle(ser, idle_s=0.1, max_s=0.4)
            return CLR_BUSY
        got_e, _ = find_token(raw, CLR_ERR)
        if got_e == CLR_ERR:
            drain_until_idle(ser, idle_s=0.1, max_s=0.4)
            return CLR_ERR
        last = None if len(raw) < 4 else int.from_bytes(raw[:4], "little")
        time.sleep(0.05)
    drain_until_idle(ser, idle_s=0.1, max_s=0.5)
    return last


def run_clear_rounds(ser, rows: list[dict], rounds: int) -> list[dict]:
    recs: list[dict] = []
    for rnd in range(rounds):
        for row in rows:
            cid = row["case_id"]
            exp = expect_word(int(row["ack"]), int(row["reject"]), int(row["reason"]))
            cg = do_clear(ser)
            if cg != CLR_ACK:
                rec = {
                    "round": rnd,
                    "case_id": cid,
                    "phase": "CLEAR",
                    "expect": f"{CLR_ACK:08x}",
                    "got": None if cg is None else f"{cg:08x}",
                    "ok": False,
                }
                print(f"r{rnd} {cid} CLEAR FAIL got={rec['got']}", flush=True)
                recs.append(rec)
                continue
            words = load_mem(OUT / f"{cid}.mem")
            t0 = time.time()
            send_words(ser, words)
            got = read_word(ser, UART_TIMEOUT_S)
            drain_until_idle(ser, idle_s=0.15, max_s=1.5)
            dt = time.time() - t0
            ok = got == exp
            rec = {
                "round": rnd,
                "case_id": cid,
                "phase": "PACK",
                "expect": f"{exp:08x}",
                "got": None if got is None else f"{got:08x}",
                "dt_s": round(dt, 3),
                "ok": ok,
            }
            print(
                f"r{rnd} {cid} exp={exp:08x} got={rec['got']} dt={dt:.3f}s "
                f"{'OK' if ok else 'FAIL'}",
                flush=True,
            )
            recs.append(rec)
            time.sleep(0.05)
    return recs


def run_seq(ser, rows: list[dict]) -> list[dict]:
    recs: list[dict] = []
    for row in rows:
        cid = row["case_id"]
        exp = expect_word(int(row["ack"]), int(row["reject"]), int(row["reason"]))
        words = load_mem(OUT / f"{cid}.mem")
        t0 = time.time()
        send_words(ser, words)
        got = read_word(ser, UART_TIMEOUT_S)
        dt = time.time() - t0
        ok = got == exp
        rec = {
            "case_id": cid,
            "expect": f"{exp:08x}",
            "got": None if got is None else f"{got:08x}",
            "dt_s": round(dt, 3),
            "ok": ok,
        }
        print(
            f"SEQ {cid} exp={exp:08x} got={rec['got']} dt={dt:.3f}s "
            f"{'OK' if ok else 'FAIL'}",
            flush=True,
        )
        recs.append(rec)
        time.sleep(0.05)
    return recs


def compare_iso(clear_recs: list[dict]) -> None:
    iso_path = ROOT / "UART_PACK24_ISO_BOARD.jsonl"
    if not iso_path.exists():
        print("NO ISO jsonl")
        return
    iso = {}
    for ln in iso_path.read_text(encoding="utf-8").splitlines():
        if not ln.strip():
            continue
        r = json.loads(ln)
        iso[r["case_id"]] = r.get("got")
    r0 = [r for r in clear_recs if r.get("round") == 0 and r.get("phase") == "PACK"]
    n_eq = 0
    n_ne = 0
    for r in r0:
        ig = iso.get(r["case_id"])
        eq = r.get("got") == ig
        n_eq += int(eq)
        n_ne += int(not eq)
        mark = "EQ" if eq else "NE"
        print(f"ISO {mark} {r['case_id']} clear={r.get('got')} iso={ig}")
    print(f"CLEAR_VS_ISO eq={n_eq} ne={n_ne}/24 (not PACK_ABI_24_24_PASS)")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", choices=["clear", "seq", "compare"], default="clear")
    ap.add_argument("--rounds", type=int, default=2)
    args = ap.parse_args()
    port = find_port()
    if port is None:
        print("SKIP no COM")
        return 2
    rows = list(csv.DictReader(TSV.open(encoding="utf-8"), delimiter="\t"))
    ser = open_ser(port)
    time.sleep(8.0)
    drain_until_idle(ser, idle_s=0.5, max_s=6.0)
    EVID.mkdir(parents=True, exist_ok=True)
    try:
        if args.mode == "clear":
            recs = run_clear_rounds(ser, rows, args.rounds)
            outp = EVID / "UART_PACK24_CLEAR_BOARD.jsonl"
            txt = EVID / "UART_PACK24_CLEAR_BOARD.txt"
            outp.write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
            n_ok = sum(1 for r in recs if r.get("phase") == "PACK" and r.get("ok"))
            n_pack = sum(1 for r in recs if r.get("phase") == "PACK")
            banner = (
                f"UART_PACK24_CLEAR_BOARD pack_ok={n_ok}/{n_pack} "
                f"(DEBUG CLEAR; not PACK_ABI_24_24_PASS)"
            )
            print(banner)
            txt.write_text(
                "\n".join(
                    f"{r.get('round')}:{r.get('case_id')} {r.get('phase')} "
                    f"exp={r.get('expect')} got={r.get('got')} {'OK' if r.get('ok') else 'FAIL'}"
                    for r in recs
                )
                + "\n"
                + banner
                + "\nBOARD_PASS=NO\nPACK_ABI_24_24_PASS=NO\n",
                encoding="utf-8",
            )
            compare_iso(recs)
            return 0 if n_ok == n_pack else 1
        if args.mode == "seq":
            recs = run_seq(ser, rows)
            (EVID / "UART_PACK24_SEQ_NOCLEAR.txt").write_text(
                "\n".join(
                    f"{r['case_id']} exp={r['expect']} got={r['got']} {'OK' if r['ok'] else 'FAIL'}"
                    for r in recs
                )
                + "\n",
                encoding="utf-8",
            )
            n_ok = sum(1 for r in recs if r["ok"])
            print(f"UART_PACK24_SEQ_NOCLEAR {n_ok}/{len(recs)} (diagnostic)")
            return 0
        compare_iso(
            [
                json.loads(ln)
                for ln in (EVID / "UART_PACK24_CLEAR_BOARD.jsonl").read_text(encoding="utf-8").splitlines()
                if ln.strip()
            ]
        )
        return 0
    finally:
        ser.close()


if __name__ == "__main__":
    sys.exit(main())
