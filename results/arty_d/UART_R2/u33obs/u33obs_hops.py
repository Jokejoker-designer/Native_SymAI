"""U33OBS 4-step hops after unique OBS program. Does not Pack24.

generation_flipped only from TAP four-AND. PROGRAM_PASS=NO. PACK_ABI_24_24_PASS=NO.
"""
from __future__ import annotations

import json
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

import serial
from serial.tools import list_ports

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u33obs")
from u33obs_capture import (  # noqa: E402
    BEGINW,
    BIT,
    CLR_CMD,
    DUMPW,
    GOLD,
    MAG,
    OUT,
    TAP1,
    WANT_BIT,
    classify_status,
    collect_words_from_bytes,
    decode_tap,
    mapper,
)

PROG = Path(r"D:\FPGA\arty_d\UART_R2\results\U33OBS_OWNER_PROGRAM\PROGRAM.txt")
V04_MEM = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out\PA24-V-04.mem"
)
CLR_ACK = 0xC1EA50A5
MARK_S = 2.0
BUSY_RETRY = 8


def now_iso() -> str:
    return datetime.now().astimezone().isoformat(timespec="seconds")


def load_v04() -> list[int]:
    lines = [ln.strip() for ln in V04_MEM.read_text(encoding="utf-8").splitlines() if ln.strip()]
    nwords = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + nwords]]
    if len(words) != nwords:
        raise ValueError(f"V-04 short {len(words)}/{nwords}")
    return words


def find_port() -> str | None:
    for p in list_ports.comports():
        if (p.serial_number or "").upper().endswith("776EB"):
            return p.device
    return None


def kill_jtag() -> None:
    subprocess.run(["taskkill", "/F", "/IM", "hw_server.exe"], capture_output=True)
    subprocess.run(["taskkill", "/F", "/IM", "cs_server.exe"], capture_output=True)


def parse_program_txt(path: Path) -> dict:
    rec = {}
    if not path.is_file():
        rec["STATUS"] = "MISSING"
        return rec
    for ln in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if "=" in ln:
            k, v = ln.split("=", 1)
            rec[k.strip()] = v.strip()
    return rec


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
        ser.read(max(1, ser.in_waiting or 1))
    ser.reset_input_buffer()
    return ser


def send_words(ser: serial.Serial, words: list[int]) -> None:
    ser.write(b"".join(w.to_bytes(4, "little") for w in words))
    ser.flush()


def read_buf(ser: serial.Serial, timeout_s: float) -> bytes:
    t0 = time.time()
    buf = bytearray()
    while time.time() - t0 < timeout_s:
        chunk = ser.read(max(1, ser.in_waiting or 1))
        if chunk:
            buf.extend(chunk)
            idle = time.time() + 0.08
            while time.time() < idle:
                extra = ser.read(max(1, ser.in_waiting or 1))
                if extra:
                    buf.extend(extra)
                    idle = time.time() + 0.08
            break
    return bytes(buf)


def rec_of(buf: bytes, step: str) -> dict:
    words = collect_words_from_bytes(buf)
    word = words[0] if words else None
    return {
        "step": step,
        "n": len(buf),
        "raw_hex": buf.hex(),
        "word": None if word is None else f"{word:08x}",
        "status_class": classify_status(word, len(buf)),
        "nwords": len(words),
        "tx_iso": now_iso(),
    }


def send_clear_until_ack(ser: serial.Serial, recs: list, step: str) -> dict:
    last = None
    for k in range(BUSY_RETRY):
        send_words(ser, [CLR_CMD])
        buf = read_buf(ser, 3.0)
        last = rec_of(buf, f"{step}_{k}")
        recs.append(last)
        print(last["step"], last["status_class"], "n", last["n"])
        if last.get("word") == f"{CLR_ACK:08x}" and last["n"] == 4:
            return last
            return last
        if last["n"] == 0:
            continue
    return last or rec_of(b"", step)


def dump_tap(ser: serial.Serial, recs: list, step: str) -> dict:
    send_words(ser, [DUMPW])
    buf = read_buf(ser, 3.0)
    words = collect_words_from_bytes(buf)
    tap = decode_tap(words)
    item = rec_of(buf, step)
    item["tap"] = tap
    recs.append(item)
    print(step, "n", item["n"], "id", tap.get("identity"), "class", tap.get("class"), "flip", tap.get("generation_flipped"))
    return item


def hops_leftover(ser, recs, v04, out) -> None:
    send_clear_until_ack(ser, recs, "2_clear")
    send_words(ser, [BEGINW])
    send_words(ser, v04)
    mbuf = read_buf(ser, 12.0)
    extra = read_buf(ser, 3.0)
    buf = mbuf + extra
    mrec = rec_of(buf, "2_leftover_stream")
    recs.append(mrec)
    print("2_LEFTOVER_STREAM", mrec["status_class"], "n", mrec["n"])
    words = collect_words_from_bytes(buf)
    out["leftover_status"] = classify_status(words[0] if words else None, len(buf) if buf[:4] else 0)
    tap_words = words
    if TAP1 in words:
        tap_words = words[words.index(TAP1) :]
    tap = decode_tap(tap_words)
    out["leftover_tap"] = tap
    out["leftover_hop"] = tap.get("class")
    out["leftover_flip"] = tap.get("generation_flipped")
    print("2_TAP id", tap.get("identity"), "class", tap.get("class"), "flip", tap.get("generation_flipped"))


def hops_gold_dump(ser, recs, v04, out) -> None:
    send_clear_until_ack(ser, recs, "4_clear")
    send_words(ser, v04)
    gbuf = read_buf(ser, 12.0)
    grec = rec_of(gbuf, "4_gold_v04")
    recs.append(grec)
    print("4_GOLD", grec["status_class"], "n", grec["n"])
    out["gold_status"] = grec["status_class"]
    d4 = dump_tap(ser, recs, "4_gold_tap")
    out["gold_flip"] = d4["tap"].get("generation_flipped")
    out["gold_tap"] = {
        k: d4["tap"].get(k)
        for k in (
            "identity",
            "commit_event",
            "same_capture_epoch",
            "capture_valid",
            "generation_flipped",
            "generation_before",
            "generation_after",
        )
    }
    if grec["status_class"] == "GOLD" and d4["tap"].get("generation_flipped") == 1:
        m = mapper()
        row = m.map_row("PA24-V-04", GOLD, 4, generation_flipped=1)
        out["dut_v04"] = m.dut_compare_fields(row)
        out["dut_v04"]["source"] = "BOARD_U33OBS_GOLD_DUMP_NOT_PACK24"


def hops_v04x4(ser, recs, v04, out) -> None:
    gold_n = mag_n = mute_n = other = 0
    for rnd in range(4):
        send_clear_until_ack(ser, recs, f"v04x4_clear_{rnd}")
        send_words(ser, v04)
        buf = read_buf(ser, 12.0)
        rec = rec_of(buf, f"v04x4_{rnd}")
        recs.append(rec)
        cls = rec["status_class"]
        print("V04x4", rnd, cls, "n", rec["n"])
        if cls == "GOLD":
            gold_n += 1
        elif cls == "MAG":
            mag_n += 1
        elif cls == "MUTE_n0":
            mute_n += 1
        else:
            other += 1
    out["v04x4"] = {"gold": gold_n, "mag": mag_n, "mute": mute_n, "other": other, "not_pack24": True}


def hops_run(mode: str) -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    prog = parse_program_txt(PROG)
    out = {
        "when": now_iso(),
        "want_sha256": WANT_BIT,
        "program_txt": prog,
        "PACK_ABI_24_24_PASS": "NO",
        "PROGRAM_PASS": "NO",
        "no_pack24": True,
        "recs": [],
    }
    if prog.get("STATUS") != "PROGRAMMED" or prog.get("SHA256") != WANT_BIT:
        out["stop"] = "NEED_PROGRAMMED_OBS"
        (OUT / "U33OBS_HOPS.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
        print("HOPS_REFUSED need PROGRAM.txt STATUS=PROGRAMMED SHA", WANT_BIT)
        print("PACK_ABI_24_24_PASS=NO")
        return 4
    v04 = load_v04()
    kill_jtag()
    time.sleep(1.0)
    port = find_port()
    if not port:
        out["stop"] = "NO_COM"
        (OUT / "U33OBS_HOPS.json").write_text(json.dumps(out, indent=2), encoding="utf-8")
        print("NO_COM")
        return 2
    recs = out["recs"]
    out["mode"] = mode
    dummy = open_mark(port)
    dummy.close()
    time.sleep(0.2)
    ser = open_mark(port)
    json_name = "U33OBS_HOPS.json"
    try:
        if mode == "leftover":
            json_name = "U33OBS_HOPS_LEFTOVER.json"
            hops_leftover(ser, recs, v04, out)
            out["stop"] = "LEFTOVER_DONE_NO_PACK24"
        elif mode == "gold":
            json_name = "U33OBS_HOPS_GOLD.json"
            hops_gold_dump(ser, recs, v04, out)
            out["stop"] = "GOLD_DUMP_DONE_NO_PACK24"
        elif mode == "v04x4":
            json_name = "U33OBS_HOPS_V04x4.json"
            hops_v04x4(ser, recs, v04, out)
            out["stop"] = "V04x4_DONE_NO_PACK24"
        else:
            out["stop"] = "BAD_MODE"
            return 2
    finally:
        ser.close()
    (OUT / json_name).write_text(json.dumps(out, indent=2), encoding="utf-8")
    print("HOPS_JSON", OUT / json_name)
    print("PACK_ABI_24_24_PASS=NO PROGRAM_PASS=NO")
    return 0


def main(argv: list[str]) -> int:
    if len(argv) >= 3 and argv[1] == "--run" and argv[2] in {"leftover", "gold", "v04x4"}:
        return hops_run(argv[2])
    print("usage: u33obs_hops.py --run leftover|gold")
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
