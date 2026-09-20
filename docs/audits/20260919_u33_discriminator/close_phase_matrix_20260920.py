"""Separate COM close from dummy mark/purge on resident U33.

No programming, no server kills, no RTL changes, no retries except the
protocol's one prescribed CLEAR reopen after a missing ACK.
"""
from __future__ import annotations

import hashlib
import json
import time
from pathlib import Path
import serial
from serial.tools import list_ports

BASE = Path(r"D:\FPGA\arty_d\UART_R2")
CANON = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
BIT = BASE / "build_u33" / "uart_r2_u33_candidate.bit"
MEM = CANON / "verification" / "pack_abi24" / "out" / "PA24-V-04.mem"
OUT = BASE / "results" / "U33_CLOSE_PHASE_MATRIX_20260920"
WANT_BIT = "ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350"
WANT_MEM = "01bb177e88cfb93eaf9e50b2a91420d489fafba6032644c58f3fa8629c3c2e60"
PORT, FTDI = "COM12", "210319BE776EB"
CLEAR, ACK, GOLD = 0x44524743, 0xC1EA50A5, 0x010000A5


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def open_port() -> serial.Serial:
    ps = [p for p in list_ports.comports() if (p.serial_number or "").upper() == FTDI]
    if len(ps) != 1 or ps[0].device.upper() != PORT:
        raise RuntimeError("port identity mismatch")
    s = serial.Serial()
    s.port, s.baudrate, s.bytesize = PORT, 115200, serial.EIGHTBITS
    s.parity, s.stopbits, s.timeout, s.write_timeout = serial.PARITY_NONE, serial.STOPBITS_ONE, 0.05, 8.0
    s.dtr, s.rts, s.dsrdtr, s.rtscts, s.xonxoff = False, False, False, False, False
    s.open()
    s.setDTR(False)
    s.setRTS(False)
    return s


def read_for(s: serial.Serial, sec: float) -> bytes:
    end = time.monotonic() + sec
    b = bytearray()
    while time.monotonic() < end:
        x = s.read(max(1, s.in_waiting))
        if x: b.extend(x)
    return bytes(b)


def reply(s: serial.Serial, sec: float) -> bytes:
    end = time.monotonic() + sec
    b = bytearray()
    while time.monotonic() < end:
        x = s.read(max(1, s.in_waiting))
        if x:
            b.extend(x)
            if len(b) >= 4:
                quiet = time.monotonic() + 0.05
                while time.monotonic() < quiet:
                    y = s.read(max(1, s.in_waiting))
                    if y: b.extend(y); quiet = time.monotonic() + 0.05
                break
    return bytes(b)


def tx(s: serial.Serial, words: list[int]) -> tuple[str, int]:
    p = b"".join(w.to_bytes(4, "little") for w in words)
    n = s.write(p); s.flush()
    return hashlib.sha256(p).hexdigest(), n


def arm(name: str, dummy_mode: str, v04: list[int]) -> dict:
    r = {"arm": name, "dummy_mode": dummy_mode}
    if dummy_mode == "baseline":
        s = open_port()
        r["pre_open_mark_n"] = None
    else:
        d = open_port()
        if dummy_mode == "mark_close":
            r["dummy_mark_hex"] = read_for(d, 2.0).hex()
        else:
            r["dummy_mark_hex"] = "NOT_READ"
        d.reset_input_buffer()
        d.close(); time.sleep(0.2)
        s = open_port()
        r["real_mark_hex"] = read_for(s, 2.0).hex()
        s.reset_input_buffer()
    try:
        _, n = tx(s, [CLEAR]); r["clear_nwritten"] = n
        c = reply(s, 3.0); r["clear_rx_hex"] = c.hex(); r["clear_word"] = f"{int.from_bytes(c[:4], 'little'):08x}" if len(c) >= 4 else None
        if c[:4] != ACK.to_bytes(4, "little"):
            r["verdict"] = "CLEAR_NOT_EXACT_ACK"; return r
        h, n = tx(s, v04); r["v04_sha256"], r["v04_nwritten"] = h, n
        p = reply(s, 12.0); r["v04_rx_hex"] = p.hex(); r["v04_word"] = f"{int.from_bytes(p[:4], 'little'):08x}" if len(p) >= 4 else None
        d = read_for(s, 0.2); r["drain_hex"] = d.hex(); r["verdict"] = "GOLD" if p[:4] == GOLD.to_bytes(4, 'little') and not d else "V04_FAIL"
        return r
    finally:
        s.close()


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / "CLOSE_PHASE_MATRIX.json"
    if path.exists(): raise RuntimeError("refuse overwrite")
    if sha(BIT) != WANT_BIT or sha(MEM) != WANT_MEM: raise RuntimeError("identity mismatch")
    vals = [int(x.strip(), 16) for x in MEM.read_text().splitlines() if x.strip()]
    v04 = vals[1:]
    arms = []
    for spec in (("BASELINE", "baseline"), ("CLOSE_IMMEDIATE", "close_immediate"), ("MARK_PURGE_CLOSE", "mark_close")):
        print("ARM", *spec); arms.append(arm(*spec, v04)); time.sleep(1.0)
    result = {"bit_sha256": sha(BIT), "mem_sha256": sha(MEM), "port": PORT, "ftdi": FTDI,
              "programmed_by_this_script": False, "product_rtl": "UNCHANGED", "arms": arms,
              "PACK_ABI_24_24_PASS": "NO", "PROGRAM_PASS": "NO", "BOARD_PASS": "NOT_EVIDENCED"}
    path.write_text(json.dumps(result, indent=2), encoding="utf-8")
    print("WROTE", path)
    for a in arms: print(a["arm"], a["verdict"], a.get("clear_word"), a.get("v04_word"))
    return 0


if __name__ == "__main__": raise SystemExit(main())
