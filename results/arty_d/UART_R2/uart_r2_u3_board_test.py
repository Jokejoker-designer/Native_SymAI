"""UART_R2_U3_BOARD_TEST host. Does not modify RTL.

Writes ONLY under D:/FPGA/arty_d/UART_R2/build_u3/board_test/.
Does not write m4_mig_clear/PROGRAM.txt or identity H evidence.
Not PROGRAM_PASS / BOARD_PASS / TIMING_PASS / PACK_ABI_24_24_PASS.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import serial
from serial.tools import list_ports

OUT = Path(r"D:\FPGA\arty_d\UART_R2\build_u3\board_test")
BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u3\uart_r2_u3_candidate.bit")
RX = Path(r"D:\FPGA\arty_d\UART_R2\u3\uart_rx_word.sv")
GOLD = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)
TSV = GOLD / "pack_abi24_expect.tsv"
WANT_BIT = "17494f2cd18ca885fca74968b9182091d637508d720d56ef7bc09928af1aa213"
WANT_RX = "79fa752f02e2a6994682c0e96cde2daee5d6021a632ad2321ef56d90e2fc7367"
CLR_CMD = 0x44524743
CLR_ACK = 0xC1EA50A5
CLR_BUSY = 0xC1EA50B5
CLR_ERR = 0xC1EA50E5
UNSUP = 0x0200075A
MAG = 0x0200015A
GOLD_OK = 0x010000A5
NAK_R02 = 0x0200025A
UART_TIMEOUT_S = 12.0
PACED_GAP_S = 0.0005  # H10 0.5 ms/byte analogue


def sha256_file(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def now_iso() -> str:
    return datetime.now().astimezone().isoformat(timespec="seconds")


def find_port() -> str | None:
    for p in list_ports.comports():
        if (p.serial_number or "").upper().endswith("776EB"):
            return p.device
    return None


def dump_json(name: str, obj) -> Path:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")
    return path


def append_jsonl(name: str, recs: list[dict]) -> Path:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    path.write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
    return path


def load_mem(cid: str) -> list[int]:
    path = GOLD / f"{cid}.mem"
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


def tsv_expect(cid: str) -> int:
    for row in csv.DictReader(TSV.open(encoding="utf-8"), delimiter="\t"):
        if row["case_id"] == cid:
            return expect_word(int(row["ack"]), int(row["reject"]), int(row["reason"]))
    raise KeyError(cid)


def sub_of(w: int | None) -> str:
    if w is None:
        return "NONE"
    table = {
        CLR_ACK: "ACK",
        CLR_BUSY: "BUSY",
        CLR_ERR: "ERR",
        MAG: "MAG",
        UNSUP: "UNSUP",
        GOLD_OK: "GOLD",
        NAK_R02: "NAK_R02",
    }
    if w in table:
        return table[w]
    if (w & 0xFF) == 0xA5 and ((w >> 24) & 0xFF) == 0x01:
        return "GOLD"
    if (w & 0xFF) == 0x5A and ((w >> 24) & 0xFF) == 0x02:
        return f"NAK_R{(w >> 8) & 0xFF:02x}"
    return f"OTHER_{w:08x}"


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


def open_ser(port: str):
    ser = serial.Serial()
    ser.port = port
    ser.baudrate = 115200
    ser.bytesize = serial.EIGHTBITS
    ser.parity = serial.PARITY_NONE
    ser.stopbits = serial.STOPBITS_ONE
    ser.timeout = 0.2
    ser.write_timeout = 8.0
    ser.dtr = False
    ser.rts = False
    ser.open()
    drain_until_idle(ser)
    return ser


def send_words(ser, words: list[int]) -> None:
    ser.write(b"".join(w.to_bytes(4, "little") for w in words))
    ser.flush()


def send_paced(ser, words: list[int], gap_s: float) -> None:
    for w in words:
        for b in w.to_bytes(4, "little"):
            ser.write(bytes([b]))
            ser.flush()
            time.sleep(gap_s)


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
            chunks.append(
                {"t": round(now - t0, 4), "n": len(chunk), "hex": chunk.hex(), "gap_s": gap}
            )
            got.extend(chunk)
            last = now
        elif last is not None and now - last >= idle_s:
            break
        elif last is None and now >= t_end:
            break
    raw = bytes(got)
    w = int.from_bytes(raw[:4], "little") if len(raw) >= 4 else None
    return {
        "raw_hex": raw.hex(),
        "n": len(raw),
        "dt_s": round(time.time() - t0, 4),
        "t_first_s": None if t_first is None else round(t_first - t0, 4),
        "t_last_s": None if last is None else round(last - t0, 4),
        "chunks": chunks,
        "word": None if w is None else f"{w:08x}",
        "sub": sub_of(w),
        "tx_iso": now_iso(),
    }


def inventory() -> dict:
    pkg = Path(
        r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
        r"\CANON_BLUEPRINT"
    )
    files = {
        "bit": BIT,
        "rx": RX,
        "top": pkg / "rtl" / "native_ai" / "board" / "arty_a7_r2_top_m4_mig_candidate.sv",
        "xdc_mig": pkg / "rtl" / "native_ai" / "board" / "arty_a7_mig.xdc",
        "xdc_cdc": pkg / "rtl" / "native_ai" / "board" / "arty_a7_mig_cdc.xdc",
        "xdc_clear": pkg / "rtl" / "native_ai" / "board" / "arty_a7_mig_clear_cdc.xdc",
        "dcp": Path(r"D:\FPGA\arty_d\UART_R2\build_u3\post_route.dcp"),
        "host_this": Path(__file__),
        "tsv": TSV,
        "mem_a01": GOLD / "PA24-A-01.mem",
        "mem_v04": GOLD / "PA24-V-04.mem",
        "frozen_host": Path(r"D:\FPGA\arty_d\m4_mig\uart_pack24_clear_board.py"),
        "h11_stamp": Path(r"D:\FPGA\arty_d\first_divergence_01\uart_h18_stamp.py"),
    }
    hashes = {k: sha256_file(p) for k, p in files.items() if p.exists()}
    rec = {
        "when": now_iso(),
        "vivado": "2026.1",
        "jtag_serial": "210319BE776EA",
        "device": "xc7a100t_0",
        "uart_ftdi": "210319BE776EB",
        "baud": 115200,
        "framing": "8N1",
        "dtr_rts": "off",
        "jp2": "UNKNOWN_NOT_PHOTOGRAPHED; last owner report REMOVED 2026-09-17",
        "want_bit": WANT_BIT,
        "got_bit": hashes.get("bit"),
        "bit_match": hashes.get("bit") == WANT_BIT,
        "want_rx": WANT_RX,
        "got_rx": hashes.get("rx"),
        "rx_match": hashes.get("rx") == WANT_RX,
        "hashes": hashes,
        "route": {"lut": 11146, "ff": 9927, "ramb36": 4, "ramb18": 2, "wns": 0.528, "whs": 0.046},
        "TIMING_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "BOARD_PASS": "NO",
        "PACK_ABI_24_24_PASS": "NO",
    }
    dump_json("INVENTORY.json", rec)
    print(json.dumps({k: rec[k] for k in ("when", "bit_match", "rx_match", "got_bit", "got_rx")}, indent=2))
    if not rec["bit_match"] or not rec["rx_match"]:
        raise SystemExit("IDENTITY_MISMATCH")
    return rec


def liveness(ser) -> dict:
    drain_until_idle(ser)
    send_words(ser, [CLR_CMD])
    cap = read_raw_stamped(ser, 3.0)
    rec = {"test": "LIVENESS", "phase": "CLEAR", "tx": f"{CLR_CMD:08x}", "tx_n": 4, **cap}
    dump_json("T1_LIVENESS.json", rec)
    print(f"T1 LIVENESS n={cap['n']} word={cap['word']} sub={cap['sub']}")
    return rec


def h11(ser, n: int = 8) -> list[dict]:
    words = load_mem("PA24-V-04")
    recs = []
    prev = None
    for i in range(n):
        drain_until_idle(ser, idle_s=0.15, max_s=1.0)
        send_words(ser, [CLR_CMD])
        cap_c = read_raw_stamped(ser, 3.0)
        rec_c = {
            "i": i,
            "phase": "CLEAR",
            "case": "PA24-V-04",
            "tx_n": 4,
            "previous": prev,
            **cap_c,
        }
        recs.append(rec_c)
        print(f"H11 {i} CLEAR {cap_c['sub']} n={cap_c['n']} word={cap_c['word']}")
        prev = rec_c
        if cap_c["n"] == 0:
            break
        if cap_c.get("word") != f"{CLR_ACK:08x}":
            continue
        send_words(ser, words)
        cap_p = read_raw_stamped(ser, UART_TIMEOUT_S)
        rec_p = {
            "i": i,
            "phase": "PACK",
            "case": "PA24-V-04",
            "tx_n": 4 * len(words),
            "tx_expect": 4 * len(words),
            "exact_tx": True,
            "expect": f"{GOLD_OK:08x}",
            "previous": "CLEAR_ACK",
            **cap_p,
        }
        recs.append(rec_p)
        print(f"H11 {i} PACK {cap_p['sub']} n={cap_p['n']} word={cap_p['word']}")
        prev = rec_p
        if cap_p["n"] == 0:
            break
    append_jsonl("T2_H11.jsonl", recs)
    dump_json(
        "T2_H11.json",
        {
            "historical": "i0 UNSUP 0200075a, i2 MAG 0200015a on identity H V-04",
            "n_recs": len(recs),
            "first_unexpected": next(
                (
                    r
                    for r in recs
                    if r["phase"] == "PACK" and r.get("word") != f"{GOLD_OK:08x}"
                ),
                None,
            ),
        },
    )
    return recs


def one_case(ser, cid: str, mode: str, previous: str) -> dict:
    exp = tsv_expect(cid)
    words = load_mem(cid)
    drain_until_idle(ser, idle_s=0.15, max_s=1.0)
    send_words(ser, [CLR_CMD])
    cap_c = read_raw_stamped(ser, 3.0)
    if cap_c.get("word") != f"{CLR_ACK:08x}":
        rec = {
            "case_id": cid,
            "mode": mode,
            "previous": previous,
            "phase": "CLEAR",
            "expect_clear": f"{CLR_ACK:08x}",
            **cap_c,
            "ok": False,
        }
        print(f"{mode} {cid} CLEAR FAIL {cap_c['sub']} n={cap_c['n']}")
        return rec
    t0 = time.time()
    if mode == "paced":
        send_paced(ser, words, PACED_GAP_S)
    else:
        send_words(ser, words)
    cap_p = read_raw_stamped(ser, UART_TIMEOUT_S)
    rec = {
        "case_id": cid,
        "mode": mode,
        "previous": "CLEAR_ACK",
        "phase": "PACK",
        "expect": f"{exp:08x}",
        "tx_n": 4 * len(words),
        "gap_s": PACED_GAP_S if mode == "paced" else 0,
        "gold_match": cap_p.get("word") == f"{exp:08x}",
        **cap_p,
        "pack_dt_s": round(time.time() - t0, 4),
        "clear": cap_c,
    }
    print(
        f"{mode} {cid} exp={exp:08x} got={cap_p.get('word')} sub={cap_p['sub']} "
        f"{'MATCH' if rec['gold_match'] else 'MISS'}"
    )
    return rec


def t5_clear(ser) -> list[dict]:
    recs = []
    drain_until_idle(ser)
    send_words(ser, [CLR_CMD])
    recs.append(
        {
            "setup": "idle_high_after_drain",
            "RX_PHYSICAL_LEVEL": "MARK_ASSUMED_HOST_IDLE_HIGH",
            "IDLE_OUTPUT": "NOT_ON_WIRE_NO_ILA",
            "CLEAR_LOGICAL_STATE": "unknown_internal",
            **read_raw_stamped(ser, 3.0),
        }
    )
    drain_until_idle(ser)
    ser.write(bytes([0x11, 0x22, 0x33]))
    ser.flush()
    time.sleep(0.05)
    send_words(ser, [CLR_CMD])
    recs.append(
        {
            "setup": "partial_3_bytes_then_CLEAR",
            "RX_PHYSICAL_LEVEL": "MARK_BETWEEN_BYTES_THEN_START",
            "IDLE_OUTPUT": "NOT_ON_WIRE_NO_ILA",
            "CLEAR_LOGICAL_STATE": "preload_bix_maybe_3",
            **read_raw_stamped(ser, 3.0),
        }
    )
    drain_until_idle(ser)
    ser.write(bytes([0xAA] * 8))
    ser.flush()
    time.sleep(0.05)
    send_words(ser, [CLR_CMD])
    recs.append(
        {
            "setup": "fifo_maybe_nonempty_8_bytes_then_CLEAR",
            "RX_PHYSICAL_LEVEL": "MARK_AFTER_BYTES",
            "IDLE_OUTPUT": "NOT_ON_WIRE_NO_ILA",
            "CLEAR_LOGICAL_STATE": "fifo_or_assembler_dirty",
            **read_raw_stamped(ser, 3.0),
        }
    )
    drain_until_idle(ser)
    ser.send_break(duration=0.2)
    time.sleep(0.05)
    recs.append(
        {
            "setup": "BREAK_then_CLEAR_without_wait",
            "RX_PHYSICAL_LEVEL": "WAS_LOW_BREAK_THEN_HOST_MARK",
            "IDLE_OUTPUT": "NOT_ON_WIRE_NO_ILA",
            "CLEAR_LOGICAL_STATE": "need_mark_then_CLEAR",
            "tx_clear_after_break": True,
        }
    )
    send_words(ser, [CLR_CMD])
    recs[-1].update(read_raw_stamped(ser, 3.0))
    append_jsonl("T5_CLEAR.jsonl", recs)
    dump_json("T5_CLEAR.json", {"note": "idle output not observable without ILA", "n": len(recs)})
    for r in recs:
        print(f"T5 {r.get('setup')} n={r.get('n')} word={r.get('word')} sub={r.get('sub')}")
    return recs


def t6_framing(ser) -> dict:
    recs = []
    drain_until_idle(ser)
    ser.send_break(duration=0.25)
    time.sleep(0.1)
    recs.append({"setup": "BREAK_no_command", **read_raw_stamped(ser, 1.0)})
    send_words(ser, [CLR_CMD])
    recs.append({"setup": "valid_CLEAR_after_BREAK", **read_raw_stamped(ser, 3.0)})
    rec = {
        "STOP_low": "NOT_RUN_FTDI_8N1_ALWAYS_STOP1",
        "short_LOW_glitch": "NOT_RUN_NO_BITBANG",
        "BREAK": recs,
        "malformed_must_not_commit": "BREAK produced no pack token before CLEAR"
        if recs[0].get("n", 0) == 0
        else "BREAK produced RX bytes; inspect raw",
    }
    dump_json("T6_FRAMING.json", rec)
    print(f"T6 BREAK n={recs[0].get('n')} then CLEAR {recs[1].get('sub')}")
    return rec


def t7_h20() -> dict:
    rec = {
        "status": "NOT_RUN_NO_CONTROLLED_DOWNSTREAM_STALL",
        "note": "Board host cannot force w_ready=0 at 4th STOP without ILA/observe. "
        "H16 XSim already showed clr_hold << 1 UART word.",
        "H20_FIX_SUPPORTED_ON_U3_BOARD": "NO_CLAIM",
        "H20_WAS_ROOT_CAUSE_OF_H": "NOT_CLAIMED",
    }
    dump_json("T7_H20.json", rec)
    print("T7 H20 NOT_RUN_NO_CONTROLLED_DOWNSTREAM_STALL")
    return rec


def t8_h19(ser) -> dict:
    drain_until_idle(ser)
    send_words(ser, [CLR_CMD])
    cap_c = read_raw_stamped(ser, 3.0)
    ser.write(b"\x00")
    ser.flush()
    time.sleep(0.02)
    words = load_mem("PA24-A-01")
    send_words(ser, words)
    cap_p = read_raw_stamped(ser, UART_TIMEOUT_S)
    reproduced = cap_p.get("word") == f"{UNSUP:08x}"
    rec = {
        "clear": cap_c,
        "injected": "00",
        "pack": cap_p,
        "expect_if_aligned": f"{NAK_R02:08x}",
        "H19_MECHANISM_REPRODUCED": reproduced,
        "note": "Deliberate extra 0x00 after CLEAR. Does not identify extra-byte SOURCE on identity H.",
    }
    dump_json("T8_H19.json", rec)
    print(
        f"T8 H19 CLEAR={cap_c.get('sub')} pack={cap_p.get('word')} "
        f"reproduced={reproduced}"
    )
    return rec


def t9_pack24(ser) -> dict:
    rows = list(csv.DictReader(TSV.open(encoding="utf-8"), delimiter="\t"))
    recs = []
    first_fail = None
    prev = None
    for row in rows:
        cid = row["case_id"]
        rec = one_case(ser, cid, "burst", previous=prev or "none")
        recs.append(rec)
        prev = cid
        ok = bool(rec.get("gold_match"))
        if not ok and first_fail is None:
            first_fail = rec
            break
    n_ok = sum(1 for r in recs if r.get("gold_match"))
    n = sum(1 for r in recs if r.get("phase") == "PACK")
    summary = {
        "UART_R2_U3_PACK24": f"{n_ok}/{n} MATCH" if n else "0/0",
        "stopped_on_first_fail": first_fail is not None,
        "first_fail": first_fail,
        "n_pack": n,
        "n_ok": n_ok,
        "PACK_ABI_24_24_PASS": "NO",
        "BOARD_PASS": "NO",
    }
    append_jsonl("T9_PACK24.jsonl", recs)
    dump_json("T9_PACK24.json", summary)
    print(f"T9 PACK24 {summary['UART_R2_U3_PACK24']} stop={bool(first_fail)}")
    return summary


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--phase",
        choices=[
            "inventory",
            "liveness",
            "h11",
            "a01v04",
            "clear",
            "framing",
            "h20",
            "h19",
            "pack24",
            "all_after_program",
            "campaign_pack_first",
        ],
        required=True,
    )
    args = ap.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    if args.phase == "inventory":
        inventory()
        return 0
    if args.phase == "h20":
        t7_h20()
        return 0
    port = find_port()
    if port is None:
        dump_json("NO_COM.json", {"when": now_iso(), "err": "FTDI 776EB not found"})
        print("SKIP no COM")
        return 2
    print(f"PORT={port}")
    # BREAK/UNSUP leftover mutes later CLEARs. Pack must run on one COM
    # session, 12s settle BEFORE open, no BREAK until after Pack.
    if args.phase == "campaign_pack_first":
        print("SETTLE_12S_BEFORE_OPEN")
        time.sleep(12.0)
    ser = open_ser(port)
    try:
        if args.phase == "liveness":
            rec = liveness(ser)
            return 0 if rec.get("word") == f"{CLR_ACK:08x}" else 1
        if args.phase == "h11":
            h11(ser)
            return 0
        if args.phase == "a01v04":
            recs = [
                one_case(ser, "PA24-A-01", "burst", "liveness_or_prior"),
                one_case(ser, "PA24-A-01", "paced", "A-01_BURST"),
                one_case(ser, "PA24-V-04", "burst", "A-01_PACED"),
                one_case(ser, "PA24-V-04", "paced", "V-04_BURST"),
            ]
            append_jsonl("T3_T4_A01_V04.jsonl", recs)
            dump_json("T3_T4_A01_V04.json", recs)
            return 0
        if args.phase == "clear":
            t5_clear(ser)
            return 0
        if args.phase == "framing":
            t6_framing(ser)
            return 0
        if args.phase == "h19":
            t8_h19(ser)
            return 0
        if args.phase == "pack24":
            t9_pack24(ser)
            return 0
        if args.phase == "campaign_pack_first":
            live = liveness(ser)
            dump_json("T1_LIVENESS.json", live)
            if live.get("word") != f"{CLR_ACK:08x}":
                dump_json(
                    "STOP.json",
                    {
                        "reason": "T1 liveness failed after reprogram; Pack not run",
                        "live": live,
                        "order": "campaign_pack_first",
                    },
                )
                print("STOP Pack: CLEAR not ACK")
                return 1
            time.sleep(0.2)
            h11_recs = h11(ser)
            if (
                not h11_recs
                or h11_recs[0].get("phase") != "CLEAR"
                or h11_recs[0].get("word") != f"{CLR_ACK:08x}"
            ):
                dump_json(
                    "STOP.json",
                    {
                        "reason": "H11 first CLEAR not ACK; Pack24 not run",
                        "h11": h11_recs,
                    },
                )
                print("STOP Pack24: H11 CLEAR not ACK")
                t7_h20()
                return 1
            recs = [
                one_case(ser, "PA24-A-01", "burst", "H11"),
                one_case(ser, "PA24-A-01", "paced", "A-01_BURST"),
                one_case(ser, "PA24-V-04", "burst", "A-01_PACED"),
                one_case(ser, "PA24-V-04", "paced", "V-04_BURST"),
            ]
            append_jsonl("T3_T4_A01_V04.jsonl", recs)
            dump_json("T3_T4_A01_V04.json", recs)
            if any(r.get("ok") is False for r in recs) or any(
                r.get("gold_match") is False for r in recs
            ):
                dump_json(
                    "STOP.json",
                    {
                        "reason": "A-01/V-04 CLEAR or gold miss; Pack24 not run",
                        "recs": recs,
                    },
                )
                print("STOP Pack24: A-01/V-04 failed")
                t7_h20()
                return 1
            t9_pack24(ser)
            t7_h20()
            # Destructive BREAK / extra-byte only AFTER Pack.
            t5_clear(ser)
            t6_framing(ser)
            t8_h19(ser)
            return 0
        # all_after_program
        live = liveness(ser)
        dump_json("T1_LIVENESS.json", live)
        if live.get("word") != f"{CLR_ACK:08x}":
            dump_json(
                "STOP.json",
                {
                    "reason": "T1 liveness failed; Pack not run",
                    "live": live,
                },
            )
            return 1
        time.sleep(0.2)
        h11(ser)
        recs = [
            one_case(ser, "PA24-A-01", "burst", "H11"),
            one_case(ser, "PA24-A-01", "paced", "A-01_BURST"),
            one_case(ser, "PA24-V-04", "burst", "A-01_PACED"),
            one_case(ser, "PA24-V-04", "paced", "V-04_BURST"),
        ]
        append_jsonl("T3_T4_A01_V04.jsonl", recs)
        dump_json("T3_T4_A01_V04.json", recs)
        t5_clear(ser)
        t6_framing(ser)
        t7_h20()
        t8_h19(ser)
        t9_pack24(ser)
        return 0
    finally:
        ser.close()


if __name__ == "__main__":
    sys.exit(main())
