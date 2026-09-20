"""Single-open DTR/RTS matrix for the resident U33 board identity.

This is a bounded diagnostic only. It does not program, reset, kill servers,
retry V04, or modify product RTL. Each arm opens COM12 once, records bytes seen
during a 2-second mark window, then performs CLEAR -> one canonical V04.
"""
from __future__ import annotations

import hashlib
import json
import time
from datetime import datetime, timezone
from pathlib import Path

import serial
from serial.tools import list_ports

BASE = Path(r"D:\FPGA\arty_d\UART_R2")
CANON = Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT")
BIT = BASE / "build_u33" / "uart_r2_u33_candidate.bit"
MEM = CANON / "verification" / "pack_abi24" / "out" / "PA24-V-04.mem"
OUT = BASE / "results" / "U33_DTR_RTS_MATRIX_20260920"
EXPECTED_BIT = "ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350"
EXPECTED_MEM = "01bb177e88cfb93eaf9e50b2a91420d489fafba6032644c58f3fa8629c3c2e60"
SERIAL = "210319BE776EB"
PORT = "COM12"
CLEAR = 0x44524743
ACK = 0xC1EA50A5
GOLD = 0x010000A5


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_v04() -> list[int]:
    if sha(BIT) != EXPECTED_BIT or sha(MEM) != EXPECTED_MEM:
        raise RuntimeError("identity_or_mem_hash_mismatch")
    vals = [int(x.strip(), 16) for x in MEM.read_text(encoding="utf-8").splitlines() if x.strip()]
    if vals[0] != 52 or len(vals[1:]) != 52 or vals[1] != 0x00800001 or vals[2] != 0x3149414E:
        raise RuntimeError("canonical_v04_check_failed")
    return vals[1:]


def find_port() -> str:
    matches = [p for p in list_ports.comports() if (p.serial_number or "").upper() == SERIAL]
    if len(matches) != 1 or matches[0].device.upper() != PORT:
        raise RuntimeError(f"port_identity_mismatch matches={[(p.device, p.serial_number) for p in matches]}")
    return matches[0].device


def read_for(ser: serial.Serial, seconds: float) -> bytes:
    deadline = time.monotonic() + seconds
    buf = bytearray()
    while time.monotonic() < deadline:
        part = ser.read(max(1, ser.in_waiting))
        if part:
            buf.extend(part)
    return bytes(buf)


def read_reply(ser: serial.Serial, seconds: float) -> bytes:
    deadline = time.monotonic() + seconds
    buf = bytearray()
    while time.monotonic() < deadline:
        part = ser.read(max(1, ser.in_waiting))
        if part:
            buf.extend(part)
            if len(buf) >= 4:
                quiet = time.monotonic() + 0.05
                while time.monotonic() < quiet:
                    extra = ser.read(max(1, ser.in_waiting))
                    if extra:
                        buf.extend(extra)
                        quiet = time.monotonic() + 0.05
                break
    return bytes(buf)


def send_words(ser: serial.Serial, words: list[int]) -> tuple[bytes, int]:
    payload = b"".join(w.to_bytes(4, "little") for w in words)
    nwritten = ser.write(payload)
    ser.flush()
    return payload, nwritten


def arm(name: str, dtr: bool, rts: bool, v04: list[int]) -> dict:
    ser = serial.Serial()
    ser.port = PORT
    ser.baudrate = 115200
    ser.bytesize = serial.EIGHTBITS
    ser.parity = serial.PARITY_NONE
    ser.stopbits = serial.STOPBITS_ONE
    ser.timeout = 0.05
    ser.write_timeout = 8.0
    ser.dtr = dtr
    ser.rts = rts
    ser.dsrdtr = False
    ser.rtscts = False
    ser.xonxoff = False
    rec: dict = {"arm": name, "dtr": dtr, "rts": rts}
    try:
        t0 = time.monotonic_ns()
        ser.open()
        # Make the requested final levels explicit and record them. This is a
        # diagnostic of the host line state, not an assertion about FTDI pins.
        ser.setDTR(dtr)
        ser.setRTS(rts)
        rec["open_t_ns"] = time.monotonic_ns() - t0
        mark = read_for(ser, 2.0)
        rec["mark_rx_hex"] = mark.hex()
        rec["mark_rx_n"] = len(mark)
        ser.reset_input_buffer()
        payload, nwritten = send_words(ser, [CLEAR])
        rec["clear_tx_hex"] = payload.hex()
        rec["clear_nwritten"] = nwritten
        clear = read_reply(ser, 3.0)
        rec["clear_rx_hex"] = clear.hex()
        rec["clear_rx_n"] = len(clear)
        rec["clear_word"] = f"{int.from_bytes(clear[:4], 'little'):08x}" if len(clear) >= 4 else None
        if clear[:4] != ACK.to_bytes(4, "little"):
            rec["verdict"] = "CLEAR_NOT_EXACT_ACK"
            return rec
        payload, nwritten = send_words(ser, v04)
        rec["v04_tx_sha256"] = hashlib.sha256(payload).hexdigest()
        rec["v04_nbytes"] = len(payload)
        rec["v04_nwritten"] = nwritten
        reply = read_reply(ser, 12.0)
        rec["v04_rx_hex"] = reply.hex()
        rec["v04_rx_n"] = len(reply)
        rec["v04_word"] = f"{int.from_bytes(reply[:4], 'little'):08x}" if len(reply) >= 4 else None
        drain = read_for(ser, 0.2)
        rec["drain_hex"] = drain.hex()
        rec["drain_n"] = len(drain)
        rec["verdict"] = "GOLD" if reply[:4] == GOLD.to_bytes(4, "little") and not drain else "V04_FAIL"
        return rec
    finally:
        ser.close()


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / "DTR_RTS_MATRIX.json"
    if path.exists():
        raise RuntimeError(f"refuse overwrite {path}")
    v04 = load_v04()
    find_port()
    arms = []
    # Known-good baseline first, then one line level at a time, then both.
    for name, dtr, rts in (("BASE_FALSE_FALSE", False, False), ("DTR_TRUE", True, False),
                           ("RTS_TRUE", False, True), ("BOTH_TRUE", True, True)):
        print("ARM", name, dtr, rts)
        arms.append(arm(name, dtr, rts, v04))
        time.sleep(1.0)
    result = {
        "iso": datetime.now(timezone.utc).isoformat(),
        "bit_sha256": sha(BIT),
        "mem_sha256": sha(MEM),
        "port": PORT,
        "ftdi": SERIAL,
        "programmed_by_this_script": False,
        "product_rtl": "UNCHANGED",
        "arms": arms,
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "BOARD_PASS": "NOT_EVIDENCED",
    }
    path.write_text(json.dumps(result, indent=2), encoding="utf-8")
    print("WROTE", path)
    for row in arms:
        print(row["arm"], row["verdict"], row.get("clear_word"), row.get("v04_word"), row.get("v04_rx_n"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
