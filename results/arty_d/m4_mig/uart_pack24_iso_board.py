"""D-PACK-BOARD-ISO-01: reprogram then one Pack/ABI-24 case.

Isolated-reset law (same as B XSim: clean DUT per case).
Not PACK_ABI_24_24_PASS / BOARD_PASS. B classifies.
"""
from __future__ import annotations

import csv
import json
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(r"D:\FPGA\arty_d\m4_mig")
OUT = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)
TSV = OUT / "pack_abi24_expect.tsv"
PROG_BAT = ROOT / "run_program.bat"
PROG_TXT = ROOT / "PROGRAM.txt"
PROG_LOG = ROOT / "program.log"
JSONL = ROOT / "UART_PACK24_ISO_BOARD.jsonl"
TXT = ROOT / "UART_PACK24_ISO_BOARD.txt"
JSON = ROOT / "D_PACK_BOARD_ISO.json"
WANT_SHA = "f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7"
POST_PROG_S = 5.0
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


def run_case(port: str, words: list[int]) -> tuple[int | None, float]:
    import serial

    time.sleep(POST_PROG_S)
    ser = serial.Serial()
    ser.port = port
    ser.baudrate = 115200
    ser.timeout = 0.2
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
        ser.write(b"".join(w.to_bytes(4, "little") for w in words))
        ser.flush()
        got = read_word(ser, UART_TIMEOUT_S)
        dt = time.time() - t0
    finally:
        ser.close()
    time.sleep(0.3)
    return got, dt


def main() -> int:
    port = find_port()
    if port is None:
        print("SKIP no COM")
        return 2

    rows = list(csv.DictReader(TSV.open(encoding="utf-8"), delimiter="\t"))
    JSONL.write_text("", encoding="utf-8")
    lines: list[str] = []
    recs: list[dict] = []
    n_pass = 0
    n_fail = 0

    for row in rows:
        cid = row["case_id"]
        words = load_mem(OUT / f"{cid}.mem")
        exp = expect_word(int(row["ack"]), int(row["reject"]), int(row["reason"]))
        prog = program_once()
        if not prog["ok"]:
            prog = program_once()
        if not prog["ok"]:
            rec = {
                "case_id": cid,
                "expect": f"{exp:08x}",
                "got": None,
                "dt_s": None,
                "ok": False,
                "cut": "PROGRAM_FAIL",
                "program": prog,
            }
            n_fail += 1
            recs.append(rec)
            JSONL.open("a", encoding="utf-8").write(json.dumps(rec) + "\n")
            line = f"{cid} PROGRAM_FAIL rc={prog['returncode']} status={prog['status']} high={prog['startup_high']}"
            print(line, flush=True)
            lines.append(line)
            continue

        got, dt = run_case(port, words)
        ok = got == exp
        n_pass += int(ok)
        n_fail += int(not ok)
        rec = {
            "case_id": cid,
            "expect": f"{exp:08x}",
            "got": None if got is None else f"{got:08x}",
            "dt_s": round(dt, 3),
            "ok": ok,
            "tsv_outcome": row["outcome"],
            "tsv_reason": int(row["reason"]),
            "program": prog,
        }
        recs.append(rec)
        JSONL.open("a", encoding="utf-8").write(json.dumps(rec) + "\n")
        line = (
            f"{cid} exp={exp:08x} got={'None' if got is None else f'{got:08x}'} "
            f"dt={dt:.3f}s prog={prog['dt_s']:.1f}s {'OK' if ok else 'FAIL'}"
        )
        print(line, flush=True)
        lines.append(line)

    banner = (
        f"UART_PACK24_BOARD_ISO pass={n_pass} fail={n_fail}/24 "
        "(1 reprogram per case; PACK_ABI24_BOARD_ISOLATED_CANDIDATE; "
        "not PACK_ABI_24_24_PASS; B classifies)"
    )
    print(banner, flush=True)
    TXT.write_text("\n".join(lines + [banner, "BOARD_PASS=NO", "PACK_ABI_24_24_PASS=NO"]) + "\n", encoding="utf-8")
    JSON.write_text(
        json.dumps(
            {
                "task": "D-PACK-BOARD-ISO-01",
                "class": "PACK_ABI24_BOARD_ISOLATED_CANDIDATE",
                "pass": n_pass,
                "fail": n_fail,
                "n": 24,
                "bit_sha256": WANT_SHA,
                "uart": port,
                "expect_source": str(TSV).replace("\\", "/"),
                "log": str(TXT).replace("\\", "/"),
                "jsonl": str(JSONL).replace("\\", "/"),
                "rows": recs,
                "not_claimed": [
                    "PACK_ABI_24_24_PASS",
                    "BOARD_PASS",
                    "MIG_PASS",
                    "PROGRAM_PASS",
                ],
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    return 0 if n_fail == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
