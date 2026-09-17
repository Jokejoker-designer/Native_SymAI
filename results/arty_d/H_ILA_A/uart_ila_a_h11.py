"""H-ILA-A host: same frozen send_words/open_ser as uart_pack24_clear_board.

H11 V-04 i=0 then DUMP 0x504D5544 to read observe capture.
BASIC license: not Vivado ILA IP. Not PACK_ABI_24_24_PASS / BOARD_PASS.
"""
from __future__ import annotations

import json
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\m4_mig")
from uart_pack24_clear_board import (  # noqa: E402
    CLR_ACK,
    CLR_CMD,
    OUT,
    load_mem,
    open_ser,
    send_words,
)
from serial.tools import list_ports

sys.path.insert(0, r"D:\FPGA\arty_d\first_divergence_01")
from uart_h18_stamp import h18_class, read_raw_stamped  # noqa: E402

ILA = Path(r"D:\FPGA\arty_d\H_ILA_A")
CASE = "PA24-V-04"
DUMP_CMD = 0x504D5544
MAGIC = 0x31414C48


def find_port() -> str | None:
    for p in list_ports.comports():
        if (p.serial_number or "").upper().endswith("776EB"):
            return p.device
    return None


def decode_dump(raw: bytes) -> dict:
    if len(raw) < 16:
        return {"ok": False, "n": len(raw), "hex": raw.hex()}
    w0 = int.from_bytes(raw[0:4], "little")
    w1 = int.from_bytes(raw[4:8], "little")
    w2 = int.from_bytes(raw[8:12], "little")
    w3 = int.from_bytes(raw[12:16], "little")
    n_bytes = w1 & 0xF
    bix_arm = (w1 >> 4) & 0x3
    sh0 = (w1 >> 6) & 0xFF
    flags = (w1 >> 14) & 0x3F
    wire10 = (w1 >> 20) & 0x3FF
    sh = [(w2 >> (8 * i)) & 0xFF for i in range(4)]
    captured = bool(flags & 1)
    false_start = bool(flags & 2)
    stop_bit = bool(flags & 4)
    have_word = bool(flags & 8)
    start_bit = wire10 & 1
    data_bits = (wire10 >> 1) & 0xFF
    wire_stop = (wire10 >> 9) & 1
    wire_byte = data_bits
    if captured and sh[0] == 0 and start_bit == 0 and data_bits == 0 and wire_stop == 1 and not false_start:
        verdict = "EXTRA_00_ON_UART_RX"
        layer = "UART_RX_SAMPLE"
    elif captured and sh[0] == 0 and data_bits == 0x43:
        verdict = "POST_CLEAR_SH0_00_FIRST_WIRE_IS_CLEAR_43"
        layer = "UART_RX_SAMPLE_AFTER_CLEAR"
    elif captured and sh[0] == 0 and (start_bit != 0 or false_start or wire_stop == 0):
        verdict = "ASSEMBLED_00_NOT_CLEAN_UART_FRAME"
        layer = "STATE_OR_ASSEMBLY"
    elif captured and sh[0] == 0x01:
        verdict = "FIRST_POST_CLEAR_BYTE_IS_BEGIN_01"
        layer = "NOT_AT_RX_IN_THIS_WINDOW"
    elif captured and sh[0] == 0x43:
        verdict = "FIRST_BYTE_IS_CLEAR_43"
        layer = "NO_LEADING_00"
    elif captured:
        verdict = f"FIRST_POST_CLEAR_BYTE_{sh[0]:02x}"
        layer = "UART_RX_SAMPLE"
    else:
        verdict = "NO_BYTE_CAPTURED"
        layer = "UNKNOWN"
    return {
        "ok": w0 == MAGIC,
        "magic": f"{w0:08x}",
        "n_bytes": n_bytes,
        "bix_at_arm": bix_arm,
        "sh": [f"{x:02x}" for x in sh],
        "sh0_from_w1": f"{sh0:02x}",
        "flags": {
            "captured": captured,
            "false_start": false_start,
            "stop_flag": stop_bit,
            "have_word": have_word,
            "raw": flags,
        },
        "wire10": f"{wire10:03x}",
        "wire": {
            "start": start_bit,
            "data": f"{wire_byte:02x}",
            "stop": wire_stop,
        },
        "first_word": f"{w3:08x}",
        "verdict": verdict,
        "layer": layer,
        "raw16": raw[:16].hex(),
    }


def main() -> int:
    ILA.mkdir(parents=True, exist_ok=True)
    port = find_port()
    if port is None:
        print("SKIP no COM FTDI 776EB")
        return 2
    ser = open_ser(port)
    recs: list[dict] = []
    try:
        send_words(ser, [CLR_CMD])
        cap_c = read_raw_stamped(ser, 3.0)
        cls_c = h18_class(bytes.fromhex(cap_c["raw_hex"] or ""), CLR_ACK)
        recs.append({"i": 0, "phase": "CLEAR", "case": CASE, **cap_c, **cls_c})
        print(f"H11 0 CLEAR {cls_c['h18']} {cls_c['sub']} n={cap_c['n']}", flush=True)
        if cls_c.get("word") == f"{CLR_ACK:08x}":
            words = load_mem(OUT / f"{CASE}.mem")
            send_words(ser, words)
            cap_p = read_raw_stamped(ser, 12.0)
            raw_p = bytes.fromhex(cap_p["raw_hex"] or "")
            cls_p = h18_class(raw_p[:4] if raw_p else b"", 0x010000A5)
            dump = {}
            if len(raw_p) >= 20:
                dump = decode_dump(raw_p[4:20])
            recs.append({"i": 0, "phase": "PACK", "case": CASE, **cap_p, **cls_p, "dump": dump})
            print(f"H11 0 PACK {cls_p['h18']} {cls_p['sub']} n={cap_p['n']}", flush=True)
            if dump:
                print(
                    f"DUMP verdict={dump.get('verdict')} layer={dump.get('layer')} "
                    f"sh={dump.get('sh')} wire={dump.get('wire')} word={dump.get('first_word')}",
                    flush=True,
                )
        if not recs or not recs[-1].get("dump", {}).get("ok"):
            send_words(ser, [DUMP_CMD])
            cap_d = read_raw_stamped(ser, 3.0)
            dump = decode_dump(bytes.fromhex(cap_d["raw_hex"] or ""))
            recs.append({"i": 0, "phase": "DUMP", **cap_d, **dump})
            print(
                f"DUMP verdict={dump.get('verdict')} layer={dump.get('layer')} "
                f"sh={dump.get('sh')} wire={dump.get('wire')} word={dump.get('first_word')}",
                flush=True,
            )
    finally:
        ser.close()
    outp = ILA / "H11_ILA_A.jsonl"
    outp.write_text("".join(json.dumps(r) + "\n" for r in recs), encoding="utf-8")
    (ILA / "D_H_ILA_A.json").write_text(json.dumps(recs, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {outp} (not PACK_ABI_24_24_PASS)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
