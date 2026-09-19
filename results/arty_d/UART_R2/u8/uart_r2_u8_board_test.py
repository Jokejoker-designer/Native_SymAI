"""UART_R2_U8 board: 12s settle, CLEAR, V-04, CLEAR2. Writes only build_u8/board_test.
Not PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
"""
from __future__ import annotations

import csv
import hashlib
import json
import sys
import time
from datetime import datetime
from pathlib import Path

import serial
from serial.tools import list_ports

OUT = Path(r"D:\FPGA\arty_d\UART_R2\build_u8\board_test")
BIT = Path(r"D:\FPGA\arty_d\UART_R2\build_u8\uart_r2_u8_candidate.bit")
GOLD = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)
TSV = GOLD / "pack_abi24_expect.tsv"
CLR_CMD = 0x44524743
CLR_ACK = 0xC1EA50A5
CLR_BUSY = 0xC1EA50B5
GOLD_OK = 0x010000A5
NAK_R02 = 0x0200025A
UNSUP = 0x0200075A
UART_TIMEOUT_S = 12.0
BAN = {
    "cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9",
    "f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7",
    "17494f2cd18ca885fca74968b9182091d637508d720d56ef7bc09928af1aa213",
}


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


def load_mem(cid: str) -> list[int]:
    path = GOLD / f"{cid}.mem"
    lines = [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]
    nwords = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + nwords]]
    if len(words) != nwords:
        raise ValueError(f"{path.name} short {len(words)}/{nwords}")
    return words


def tsv_expect(cid: str) -> int:
    for row in csv.DictReader(TSV.open(encoding="utf-8"), delimiter="\t"):
        if row["case_id"] == cid:
            ack = int(row["ack"])
            rej = int(row["reject"])
            reason = int(row["reason"])
            if ack:
                return (0x01 << 24) | (reason << 8) | 0xA5
            if rej:
                return (0x02 << 24) | (reason << 8) | 0x5A
    raise KeyError(cid)


def sub_of(w: int | None) -> str:
    if w is None:
        return "NONE"
    table = {
        CLR_ACK: "ACK",
        CLR_BUSY: "BUSY",
        GOLD_OK: "GOLD",
        NAK_R02: "NAK_R02",
        UNSUP: "UNSUP",
    }
    return table.get(w, f"OTHER_{w:08x}")


def send_words(ser: serial.Serial, words: list[int]) -> None:
    payload = b"".join(w.to_bytes(4, "little") for w in words)
    ser.write(payload)
    ser.flush()


def read_raw_stamped(ser: serial.Serial, timeout_s: float) -> dict:
    ser.timeout = 0.05
    t0 = time.time()
    buf = bytearray()
    chunks = []
    t_first = None
    t_last = None
    while time.time() - t0 < timeout_s:
        n_wait = max(1, ser.in_waiting)
        chunk = ser.read(n_wait)
        if chunk:
            now = time.time() - t0
            if t_first is None:
                t_first = now
            t_last = now
            chunks.append({"t": round(now, 4), "n": len(chunk), "hex": chunk.hex()})
            buf.extend(chunk)
            if len(buf) >= 4:
                # keep reading a short idle so a 4-byte token is complete
                idle_end = time.time() + 0.05
                while time.time() < idle_end:
                    extra = ser.read(max(1, ser.in_waiting))
                    if extra:
                        buf.extend(extra)
                        idle_end = time.time() + 0.05
                break
    word = None
    if len(buf) >= 4:
        word = int.from_bytes(bytes(buf[:4]), "little")
    return {
        "raw_hex": bytes(buf).hex(),
        "n": len(buf),
        "dt_s": round(time.time() - t0, 4),
        "t_first_s": None if t_first is None else round(t_first, 4),
        "t_last_s": None if t_last is None else round(t_last, 4),
        "chunks": chunks,
        "word": None if word is None else f"{word:08x}",
        "sub": sub_of(word),
        "tx_iso": now_iso(),
    }


def main() -> int:
    if not BIT.is_file():
        dump_json("NO_BIT.json", {"when": now_iso(), "err": str(BIT)})
        print("NO_BIT")
        return 2
    sha = sha256_file(BIT)
    if sha in BAN:
        dump_json("REFUSE_IDENTITY.json", {"when": now_iso(), "sha": sha})
        print("REFUSE other identity", sha)
        return 3
    port = find_port()
    if port is None:
        dump_json("NO_COM.json", {"when": now_iso(), "err": "FTDI 776EB not found"})
        print("SKIP no COM")
        return 2
    print("U8_BIT_SHA", sha)
    print("SETTLE_12S_BEFORE_OPEN", port)
    time.sleep(12.0)
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
    t_drain = time.time()
    while time.time() - t_drain < 0.25:
        ser.read(4096)
    ser.reset_input_buffer()
    recs = []
    try:
        send_words(ser, [CLR_CMD])
        c1 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR1", **c1})
        print("CLEAR1", c1["sub"], "n=", c1["n"], "word=", c1["word"])
        if c1.get("word") != f"{CLR_ACK:08x}":
            dump_json(
                "T1_THEN_PACK.json",
                {"stop": "CLEAR1 not ACK", "sha": sha, "recs": recs},
            )
            print("STOP no pack")
            return 1

        v04 = load_mem("PA24-V-04")
        send_words(ser, v04)
        p1 = read_raw_stamped(ser, UART_TIMEOUT_S)
        recs.append(
            {
                "step": "PACK_V04",
                "expect": f"{GOLD_OK:08x}",
                "gold_match": p1.get("word") == f"{GOLD_OK:08x}",
                "tx_n": 4 * len(v04),
                **p1,
            }
        )
        print("V04", p1["sub"], "n=", p1["n"], "word=", p1["word"], "match=", recs[-1]["gold_match"])

        send_words(ser, [CLR_CMD])
        c2 = read_raw_stamped(ser, 3.0)
        recs.append({"step": "CLEAR2_AFTER_V04", **c2})
        print("CLEAR2", c2["sub"], "n=", c2["n"], "word=", c2["word"])

        dump_json(
            "T1_THEN_PACK.json",
            {
                "when": now_iso(),
                "port": port,
                "sha": sha,
                "class": "UART_R2_U8_CANDIDATE",
                "PROGRAM_PASS": "NO",
                "BOARD_PASS": "NOT_EVIDENCED",
                "PACK_ABI_24_24_PASS": "NO",
                "recs": recs,
            },
        )
        return 0
    finally:
        ser.close()


if __name__ == "__main__":
    raise SystemExit(main())
