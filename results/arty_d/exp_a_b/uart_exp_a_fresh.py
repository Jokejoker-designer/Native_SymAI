"""Experiment A — fresh single-case discriminator. Independent of Exp B.

Reprogram ISO bit f6a6091f before each attempt. Send one case (default V-02).
Capture host TX bytes/words and UART RX bytes/words.
Internal FIFO/loader stages are XSim/ILA, not this host.

No 24-case campaign. No CLEAR. Not PACK_ABI_24_24_PASS / BOARD_PASS / PROGRAM_PASS.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
import time
from pathlib import Path

import serial
from serial.tools import list_ports

ROOT = Path(r"D:\FPGA\arty_d\m4_mig")
EVID = Path(r"D:\FPGA\arty_d\exp_a_b")
OUT = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)
PROG_BAT = ROOT / "run_program.bat"
PROG_TXT = ROOT / "PROGRAM.txt"
PROG_LOG = ROOT / "program.log"
WANT_SHA = "f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7"
GOLD = 0x010000A5
MAG = 0x0200015A
POST_PROG_S = 5.0
UART_TIMEOUT_S = 12.0
LEASE = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\_COORDINATION\board_lease.json"
)


def load_mem(path: Path) -> list[int]:
    lines = [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]
    nwords = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + nwords]]
    if len(words) != nwords:
        raise ValueError(f"{path.name} short {len(words)}/{nwords}")
    return words


def find_port() -> str | None:
    for p in list_ports.comports():
        if (p.serial_number or "").upper().endswith("776EB"):
            return p.device
    return None


def classify(got: int | None) -> str:
    if got is None:
        return "MUTE"
    if got == GOLD:
        return "GOLD"
    if got == MAG:
        return "MAG"
    return f"OTHER_{got:08x}"


def program_once() -> dict:
    t0 = time.time()
    proc = subprocess.run(
        ["cmd", "/c", str(PROG_BAT)],
        cwd=str(ROOT),
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
                "purpose": "EXP_A_FRESH_V02 then EXP_B_LIVENESS exclusive",
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


def run_attempt(port: str, words: list[int]) -> dict:
    tx_bytes = b"".join(w.to_bytes(4, "little") for w in words)
    time.sleep(POST_PROG_S)
    ser = serial.Serial()
    ser.port = port
    ser.baudrate = 115200
    ser.timeout = 0.05
    ser.write_timeout = 8.0
    ser.dtr = False
    ser.rts = False
    ser.open()
    try:
        t_drain = time.time()
        while time.time() - t_drain < 0.4:
            ser.read(4096)
        ser.reset_input_buffer()
        time.sleep(0.4)
        ser.reset_input_buffer()
        t0 = time.time()
        ser.write(tx_bytes)
        ser.flush()
        raw = bytearray()
        last = None
        t_end = time.time() + UART_TIMEOUT_S
        while True:
            chunk = ser.read(4096)
            now = time.time()
            if chunk:
                raw.extend(chunk)
                last = now
            elif last is not None and now - last >= 0.25:
                break
            elif last is None and now >= t_end:
                break
        dt = time.time() - t0
    finally:
        ser.close()
    rx = bytes(raw)
    rx_words = []
    for i in range(0, len(rx) - 3, 4):
        rx_words.append(int.from_bytes(rx[i : i + 4], "little"))
    got = rx_words[0] if rx_words else None
    return {
        "dt_s": round(dt, 3),
        "host_tx_n_bytes": len(tx_bytes),
        "host_tx_n_words": len(words),
        "host_tx_words": [f"{w:08x}" for w in words[:8]],
        "host_tx_bytes_hex_head": tx_bytes[:16].hex(),
        "uart_rx_n_bytes": len(rx),
        "uart_rx_bytes_hex": rx.hex(),
        "uart_rx_words": [f"{w:08x}" for w in rx_words],
        "got": None if got is None else f"{got:08x}",
        "class": classify(got),
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--case", default="PA24-V-02")
    ap.add_argument("--attempts", type=int, default=3)
    args = ap.parse_args()

    EVID.mkdir(parents=True, exist_ok=True)
    take_board()
    mem_path = OUT / f"{args.case}.mem"
    words = load_mem(mem_path)
    mem_sha = hashlib.sha256(mem_path.read_bytes()).hexdigest()
    port = find_port()
    if port is None:
        print("SKIP no COM")
        return 2

    print(
        f"EXP_A case={args.case} nwords={len(words)} w0={words[0]:08x} "
        f"w1={words[1]:08x} mem_sha={mem_sha} port={port} attempts={args.attempts}",
        flush=True,
    )

    recs = []
    mag_n = 0
    gold_n = 0
    mute_n = 0
    for k in range(args.attempts):
        prog = program_once()
        if not prog["ok"]:
            prog = program_once()
        rec = {
            "attempt": k,
            "program": prog,
        }
        if not prog["ok"]:
            rec["ok"] = False
            rec["cut"] = "PROGRAM_FAIL"
            recs.append(rec)
            print(f"A{k} PROGRAM_FAIL rc={prog['returncode']} status={prog['status']}", flush=True)
            continue
        run = run_attempt(port, words)
        rec.update(run)
        rec["ok"] = run["class"] == "GOLD"
        mag_n += int(run["class"] == "MAG")
        gold_n += int(run["class"] == "GOLD")
        mute_n += int(run["class"] == "MUTE")
        recs.append(rec)
        print(
            f"A{k} class={run['class']} got={run['got']} rx_n={run['uart_rx_n_bytes']} "
            f"tx_w0={words[0]:08x} tx_w1={words[1]:08x} dt={run['dt_s']}",
            flush=True,
        )

    banner = (
        f"EXP_A_FRESH {args.case} gold={gold_n} mag={mag_n} mute={mute_n} "
        f"n={args.attempts} bit={WANT_SHA} (not PACK_ABI_24_24_PASS / not BOARD_PASS)"
    )
    print(banner, flush=True)
    payload = {
        "task": "EXP_A_FRESH_SINGLE_CASE",
        "independent_of": "EXP_B_LIVENESS",
        "case": args.case,
        "mem_sha256": mem_sha,
        "bit_sha256": WANT_SHA,
        "reprogram_each_attempt": True,
        "clear": False,
        "host_tx_w0": f"{words[0]:08x}",
        "host_tx_w1": f"{words[1]:08x}",
        "same_blob_as_G01_FACT": mem_sha
        == "3bfa5eb4e1368072ed8f378941576d5a15b4cf025c41be8d5879148668b9e210",
        "gold": gold_n,
        "mag": mag_n,
        "mute": mute_n,
        "attempts": args.attempts,
        "uart": port,
        "rows": recs,
        "not_claimed": [
            "PACK_ABI_24_24_PASS",
            "BOARD_PASS",
            "MIG_PASS",
            "PROGRAM_PASS",
        ],
        "internal_fifo_loader": "XSim/ILA only; host sees UART TX/RX only",
    }
    (EVID / "EXP_A_FRESH.json").write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    (EVID / "EXP_A_FRESH.txt").write_text(
        banner + "\n" + json.dumps(recs, indent=2) + "\nBOARD_PASS=NO\nPACK_ABI_24_24_PASS=NO\n",
        encoding="utf-8",
    )
    return 0 if mag_n + gold_n + mute_n == args.attempts else 1


if __name__ == "__main__":
    sys.exit(main())
