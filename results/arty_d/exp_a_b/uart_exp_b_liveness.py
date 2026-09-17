"""Experiment B — liveness accumulation. Independent of Exp A.

Program CLEAR identity H once. Repeat CLEAR then the same known-good PACK.
No 24-case diversity. Stop at first MUTE.

Not PACK_ABI_24_24_PASS / BOARD_PASS / PROGRAM_PASS.
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

import serial
from serial.tools import list_ports

sys.path.insert(0, r"D:\FPGA\arty_d\m4_mig")
from uart_pack24_clear_board import (
    CLR_ACK,
    CLR_BUSY,
    CLR_ERR,
    OUT,
    do_clear,
    load_mem,
    open_ser,
    read_raw,
)

ROOT_H = Path(r"D:\FPGA\arty_d\m4_mig_clear")
EVID = Path(r"D:\FPGA\arty_d\exp_a_b")
PROG_BAT = ROOT_H / "run_program.bat"
PROG_TXT = ROOT_H / "PROGRAM.txt"
PROG_LOG = ROOT_H / "vivado_prog.log"
WANT_SHA = "cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9"
GOLD = 0x010000A5
LEASE = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\_COORDINATION\board_lease.json"
)


def find_port() -> str | None:
    for p in list_ports.comports():
        if (p.serial_number or "").upper().endswith("776EB"):
            return p.device
    return None


def classify_pack(got: int | None) -> str:
    if got is None:
        return "MUTE"
    if got == GOLD:
        return "GOLD"
    if got == 0x0200015A:
        return "MAG"
    if got == 0x0200075A:
        return "UNSUP"
    if got == 0x0200085A:
        return "SENTINEL"
    return f"OTHER_{got:08x}"


def first_word(raw: bytes) -> int | None:
    if len(raw) < 4:
        return None
    return int.from_bytes(raw[:4], "little")


def program_once() -> dict:
    t0 = time.time()
    proc = subprocess.run(
        ["cmd", "/c", str(PROG_BAT)],
        cwd=str(ROOT_H),
        capture_output=True,
        text=True,
        timeout=180,
    )
    dt = time.time() - t0
    txt = PROG_TXT.read_text(encoding="utf-8", errors="replace") if PROG_TXT.exists() else ""
    log = PROG_LOG.read_text(encoding="utf-8", errors="replace") if PROG_LOG.exists() else ""
    status = ""
    sha = ""
    for line in txt.splitlines():
        if line.startswith("STATUS="):
            status = line.split("=", 1)[1].strip()
        if line.startswith("SHA256="):
            sha = line.split("=", 1)[1].strip()
    high = "End of startup status: HIGH" in log
    sha_ok = sha.lower() == WANT_SHA
    ok = proc.returncode == 0 and status == "PROGRAMMED" and high and sha_ok
    return {
        "ok": ok,
        "dt_s": round(dt, 3),
        "returncode": proc.returncode,
        "status": status,
        "sha256": sha,
        "sha_ok": sha_ok,
        "startup_high": high,
    }


def take_board() -> None:
    now = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    LEASE.write_text(
        json.dumps(
            {
                "resource": "ARTY_A7_100T",
                "part": "xc7a100tcsg324-1",
                "jtag_serial": "210319BE776EA",
                "uart_ftdi_serial": "210319BE776EB",
                "uart_hint": "COM12 115200 8N1 DTR/RTS off",
                "state": "HELD",
                "holder": "AGENT_D",
                "granted_at": now,
                "until": None,
                "purpose": "EXP_B_LIVENESS exclusive",
                "program": True,
                "jtag": True,
                "uart": True,
                "dispatcher": "NONE",
                "granted_by": "OWNER",
                "released_by": None,
                "released_at": None,
                "note": (
                    "Owner 2026-09-17: board lease protocol dropped. "
                    "AGENT_D holds exclusively. Do not give to E or anyone else."
                ),
                "do_not_overwrite": [
                    "D:/FPGA/arty_d/m4_mig/arty_a7_r2_top_m4_mig_candidate.bit",
                    "freeze DCP sha256 858d0e997214e36074cc67f66f42af85c7f4da18f0590148ea509e8bb276d6dd",
                    "rollback DCP sha256 b48b7c8858a39d2a7da0e005b1fb0cc01c2de6e0b1e829f2dbe14531a4b73388",
                ],
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--case", default="PA24-V-04")
    ap.add_argument("--n", type=int, default=16)
    ap.add_argument("--no-program", action="store_true")
    args = ap.parse_args()

    EVID.mkdir(parents=True, exist_ok=True)
    take_board()
    words = load_mem(OUT / f"{args.case}.mem")
    port = find_port()
    if port is None:
        print("SKIP no COM")
        return 2

    prog = {"ok": True, "skipped": True}
    if not args.no_program:
        prog = program_once()
        if not prog["ok"]:
            prog = program_once()
        if not prog["ok"]:
            print(f"EXP_B PROGRAM_FAIL {prog}", flush=True)
            (EVID / "EXP_B_LIVENESS.json").write_text(
                json.dumps({"cut": "PROGRAM_FAIL", "program": prog}, indent=2) + "\n",
                encoding="utf-8",
            )
            return 1
        time.sleep(5.0)

    ser = open_ser(port)
    recs = []
    mute_at = None
    try:
        for i in range(args.n):
            tok, hexdump = do_clear(ser, retries=1, capture_s=3.0)
            raw_w = None
            if hexdump:
                try:
                    raw_b = bytes.fromhex(hexdump)
                    if len(raw_b) >= 4:
                        raw_w = int.from_bytes(raw_b[:4], "little")
                except ValueError:
                    raw_w = None
            if tok is not None:
                clr_class = f"{tok:08x}"
            elif raw_w == 0x0200075A:
                clr_class = "UNSUP"
            elif raw_w is None and not hexdump:
                clr_class = "MUTE"
            else:
                clr_class = f"OTHER_{hexdump[:8]}"
            pack_raw = b""
            got = None
            if tok == CLR_ACK:
                ser.write(b"".join(w.to_bytes(4, "little") for w in words))
                ser.flush()
                pack_raw = read_raw(ser, 12.0, idle_s=0.25)
                got = first_word(pack_raw)
            rec = {
                "i": i,
                "clear_tok": None if tok is None else f"{tok:08x}",
                "clear_class": clr_class,
                "clear_busy": tok == CLR_BUSY,
                "clear_err": tok == CLR_ERR,
                "clear_hex": hexdump[:128],
                "pack_got": None if got is None else f"{got:08x}",
                "pack_class": classify_pack(got),
                "pack_rx_n": len(pack_raw),
                "pack_rx_hex": pack_raw.hex(),
            }
            recs.append(rec)
            print(
                f"B{i} CLEAR={clr_class} PACK={rec['pack_class']} "
                f"pack_n={len(pack_raw)}",
                flush=True,
            )
            if clr_class == "MUTE" or (tok == CLR_ACK and got is None):
                mute_at = i
                break
    finally:
        ser.close()

    banner = (
        f"EXP_B_LIVENESS case={args.case} n={len(recs)} mute_at={mute_at} "
        f"bit={WANT_SHA} (not PACK_ABI_24_24_PASS / not BOARD_PASS)"
    )
    print(banner, flush=True)
    payload = {
        "task": "EXP_B_LIVENESS",
        "independent_of": "EXP_A_FRESH",
        "case": args.case,
        "semantic_diversity": False,
        "reprogram_between": False,
        "bit_sha256": WANT_SHA,
        "program": prog,
        "mute_at": mute_at,
        "rows": recs,
        "not_claimed": [
            "PACK_ABI_24_24_PASS",
            "BOARD_PASS",
            "MIG_PASS",
            "PROGRAM_PASS",
        ],
    }
    (EVID / "EXP_B_LIVENESS.json").write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    (EVID / "EXP_B_LIVENESS.txt").write_text(
        banner + "\n" + json.dumps(recs, indent=2) + "\nBOARD_PASS=NO\nPACK_ABI_24_24_PASS=NO\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
