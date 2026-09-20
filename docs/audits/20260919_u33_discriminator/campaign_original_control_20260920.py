"""U33 board campaign: MARK 2s, exact n=4 ACK/GOLD, then Pack24.
Not PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
"""
from __future__ import annotations

import json
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u9")
from uart_r2_u9_board_test import (
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
    tsv_expect,
    kill_jtag_usb_servers,
)
import csv
import serial
import uart_r2_u9_board_test as u9mod

# Do not overwrite frozen PACK24_U33/CLEAR_V04_24.json (FAIL_BOARD MAG r3).
u9mod.OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\U33_ORIGINAL_HOST_CONTROL_20260920T1627_REPROG")
OUT = u9mod.OUT
RAW = OUT / "RAW_UART"
BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u33\uart_r2_u33_candidate.bit")
WANT = "ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350"
TSV = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out\pack_abi24_expect.tsv"
)
MARK_S = 2.0
WAIT_AFTER_ACK_S = 0.0
WAIT_AFTER_GOLD_S = 0.0
BUSY_RETRY = 8
CLR_BUSY_S = f"{CLR_BUSY:08x}"


def open_mark(port: str) -> serial.Serial:
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
    while time.time() - t0 < MARK_S:
        ser.read(max(1, ser.in_waiting))
    ser.reset_input_buffer()
    return ser


def exact4(rec: dict, want: int) -> bool:
    return rec.get("n") == 4 and rec.get("word") == f"{want:08x}"


def reopen_mark(ser: serial.Serial, port: str) -> serial.Serial:
    ser.close()
    time.sleep(0.2)
    return open_mark(port)


def send_clear(ser: serial.Serial, recs: list, step: str, rnd=None) -> dict:
    send_words(ser, [CLR_CMD])
    rec = read_raw_stamped(ser, 3.0)
    item = {"step": step, **rec}
    if rnd is not None:
        item["round"] = rnd
    recs.append(item)
    print(step if rnd is None else f"{step} {rnd}", rec["sub"], rec["n"], rec.get("raw_hex"))
    return rec


def drain_idle(ser: serial.Serial, recs: list, step: str, rnd=None, timeout_s: float = 0.2) -> dict:
    rec = read_raw_stamped(ser, timeout_s)
    if rec.get("n", 0):
        item = {"step": step, **rec}
        if rnd is not None:
            item["round"] = rnd
        recs.append(item)
        print(step if rnd is None else f"{step} {rnd}", rec["sub"], rec["n"], rec.get("raw_hex"))
    return rec


def send_clear_until_ack(ser: serial.Serial, recs: list, step: str, rnd=None) -> dict:
    last = send_clear(ser, recs, step, rnd)
    for k in range(BUSY_RETRY):
        if exact4(last, CLR_ACK):
            return last
        if last.get("word") == CLR_BUSY_S or (last.get("n", 0) or 0) > 4:
            drain_idle(ser, recs, f"{step}_DRAIN", rnd)
            last = send_clear(ser, recs, f"{step}_BUSY{k}", rnd)
            continue
        if last.get("n", 0) == 0:
            last = send_clear(ser, recs, f"{step}_RETRY", rnd)
            if last.get("n", 0) == 0:
                return last
            continue
        return last
    return last


def main() -> int:
    mode = sys.argv[1] if len(sys.argv) > 1 else "p4p5"
    OUT.mkdir(parents=True, exist_ok=True)
    RAW.mkdir(parents=True, exist_ok=True)
    sha = sha256_file(BIT)
    print("U33_SHA", sha, "MODE", mode)
    if sha != WANT:
        print("SHA_MISMATCH")
        return 3
    if mode == "settle":
        None  # AUDIT: preserve other hardware servers; no taskkill
        time.sleep(5)
        return 0
    None  # AUDIT: preserve other hardware servers; no taskkill
    time.sleep(1.0)
    port = find_port()
    if not port:
        print("NO_COM")
        return 2
    dummy = open_mark(port)
    dummy.close()
    time.sleep(0.2)
    ser = open_mark(port)
    recs = []
    try:
        if mode in {"p4", "p4p5", "p4nw", "nwp4p5"}:
            if mode not in {"p4nw", "nwp4p5"}:
                send_clear(ser, recs, "WARMUP_CLEAR")
            c1 = send_clear_until_ack(ser, recs, "CLEAR1")
            if c1.get("n", 0) == 0:
                ser = reopen_mark(ser, port)
                recs.append({"step": "REOPEN_AFTER_N0", "port": port})
                print("REOPEN_AFTER_N0")
                c1 = send_clear_until_ack(ser, recs, "CLEAR1_REOPEN")
            if not exact4(c1, CLR_ACK):
                dump_json("BOARD_BASELINE.json", {"stop": "CLEAR1", "sha": sha, "recs": recs, "PROGRAM_PASS": "NO"})
                return 1
            time.sleep(WAIT_AFTER_ACK_S)
            v04 = load_mem("PA24-V-04")
            begin_n = sum(1 for w in v04 if w == 0x00800001)
            print("TX_V04_0 nwords", len(v04), "begin_n", begin_n, "w0", f"{v04[0]:08x}", "w1", f"{v04[1]:08x}")
            send_words(ser, v04)
            p = read_raw_stamped(ser, UART_TIMEOUT_S)
            recs.append({"step": "V04_0", **p})
            print("V04", p["sub"], p["n"], p.get("raw_hex"))
            if p.get("word") != f"{GOLD_OK:08x}":
                dump_json("BOARD_BASELINE.json", {"stop": "V04_0", "sha": sha, "recs": recs, "PROGRAM_PASS": "NO"})
                return 1
            drain_idle(ser, recs, "V04_0_DRAIN")
            print("PHASE4_OK")
            time.sleep(WAIT_AFTER_GOLD_S)
            if mode in {"p4", "p4nw"}:
                dump_json("BOARD_BASELINE.json", {"sha": sha, "recs": recs, "PROGRAM_PASS": "NO", "BOARD_PASS": "NOT_EVIDENCED", "warmup": mode not in {"p4nw", "nwp4p5"}})
                return 0
        if mode in {"p5", "p4p5", "nwp4p5"}:
            v04 = load_mem("PA24-V-04")
            mag = unsup = n0 = extra = 0
            for rnd in range(24):
                c = send_clear_until_ack(ser, recs, "CLEAR", rnd)
                if c.get("n", 0) == 0:
                    ser = reopen_mark(ser, port)
                    recs.append({"step": "REOPEN_AFTER_N0", "round": rnd, "port": port})
                    print("REOPEN_AFTER_N0", rnd)
                    c = send_clear_until_ack(ser, recs, "CLEAR_REOPEN", rnd)
                (RAW / f"p5_c{rnd:02d}.json").write_text(json.dumps(c, indent=2), encoding="utf-8")
                if c.get("word") == "0200015a":
                    mag += 1
                if c.get("word") == "0200075a":
                    unsup += 1
                if c.get("n", 0) == 0:
                    n0 += 1
                if c.get("n", 0) != 4:
                    extra += 1
                if not exact4(c, CLR_ACK):
                    dump_json("CLEAR_V04_24.json", {"stop": "CLEAR", "round": rnd, "sha": sha, "mag": mag, "n0": n0, "extra": extra, "recs": recs, "PROGRAM_PASS": "NO"})
                    return 1
                time.sleep(WAIT_AFTER_ACK_S)
                begin_n = sum(1 for w in v04 if w == 0x00800001)
                print("TX_V04", rnd, "nwords", len(v04), "begin_n", begin_n, "w0", f"{v04[0]:08x}", "w1", f"{v04[1]:08x}")
                send_words(ser, v04)
                q = read_raw_stamped(ser, UART_TIMEOUT_S)
                recs.append({"step": "V04", "round": rnd, **q})
                (RAW / f"p5_v{rnd:02d}.json").write_text(json.dumps(q, indent=2), encoding="utf-8")
                print("V04", rnd, q["sub"], q["n"], q.get("raw_hex"))
                if q.get("word") == "0200015a":
                    mag += 1
                if q.get("word") == "0200075a":
                    unsup += 1
                if q.get("n", 0) == 0:
                    n0 += 1
                if q.get("n", 0) != 4:
                    extra += 1
                if q.get("word") != f"{GOLD_OK:08x}":
                    dump_json("CLEAR_V04_24.json", {"stop": "V04", "round": rnd, "sha": sha, "mag": mag, "n0": n0, "extra": extra, "recs": recs, "PROGRAM_PASS": "NO"})
                    return 1
                drain_idle(ser, recs, "V04_DRAIN", rnd)
                time.sleep(WAIT_AFTER_GOLD_S)
            dump_json(
                "CLEAR_V04_24.json",
                {
                    "when": now_iso(),
                    "sha": sha,
                    "clear": "24/24",
                    "v04": "24/24",
                    "mag": mag,
                    "unsup": unsup,
                    "n0": n0,
                    "extra": extra,
                    "PROGRAM_PASS": "NO",
                    "BOARD_PASS": "NOT_EVIDENCED",
                    "PACK_ABI_24_24_PASS": "NO",
                    "recs": recs,
                },
            )
            if extra or n0 or mag or unsup:
                print("PHASE5_NOT_CLEAN", "extra", extra, "n0", n0, "mag", mag, "unsup", unsup)
                return 1
            print("PHASE5_24_24_OK")
            return 0
        if mode in {"pack1", "pack2", "pack3"}:
            names = {"pack1": "PACK24_RUN1.jsonl", "pack2": "PACK24_RUN2.jsonl", "pack3": "PACK24_FRESH_REPLAY.jsonl"}
            rows = list(csv.DictReader(TSV.open(encoding="utf-8"), delimiter="\t"))
            recs = []
            n_ok = 0
            for row in rows:
                cid = row["case_id"]
                exp = tsv_expect(cid)
                send_words(ser, [CLR_CMD])
                c1 = read_raw_stamped(ser, 3.0)
                if c1.get("word") == CLR_BUSY_S or (c1.get("n", 0) or 0) > 4:
                    drain_idle(ser, recs, f"{cid}_DRAIN")
                    send_words(ser, [CLR_CMD])
                    c1 = read_raw_stamped(ser, 3.0)
                tries = 0
                while c1.get("word") == CLR_BUSY_S and tries < BUSY_RETRY:
                    drain_idle(ser, recs, f"{cid}_DRAIN")
                    send_words(ser, [CLR_CMD])
                    c1 = read_raw_stamped(ser, 3.0)
                    tries += 1
                if not exact4(c1, CLR_ACK):
                    recs.append({"case_id": cid, "phase": "CLEAR", "raw_hex": c1.get("raw_hex"), "ok": False})
                    (OUT / names[mode]).write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
                    print("PACK24 STOP CLEAR", cid, c1.get("raw_hex"))
                    return 1
                send_words(ser, load_mem(cid))
                p = read_raw_stamped(ser, UART_TIMEOUT_S)
                ok = exact4(p, exp)
                recs.append({"case_id": cid, "expect": f"{exp:08x}", "got": p.get("word"), "raw_hex": p.get("raw_hex"), "n": p.get("n"), "ok": ok})
                print(cid, f"{exp:08x}", p.get("word"), p.get("n"), "OK" if ok else "FAIL")
                if not ok:
                    (OUT / names[mode]).write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
                    return 1
                n_ok += 1
            (OUT / names[mode]).write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
            print(names[mode], f"{n_ok}/{len(rows)}")
            return 0 if n_ok == len(rows) else 1
        print("usage: settle|p4|p5|p4p5|p4nw|nwp4p5|pack1|pack2|pack3")
        return 2
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
