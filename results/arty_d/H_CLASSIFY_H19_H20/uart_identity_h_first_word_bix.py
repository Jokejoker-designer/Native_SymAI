"""Identity H after CLEAR ACK: record UART. Do not pad/resync. Do not edit RTL.

first_pack_word and bix are FPGA-internal on identity H (no dump, no ILA).
This script only records what the UART actually carries. H20 is classifier-only.
Not PACK_ABI_24_24_PASS / BOARD_PASS / PROGRAM_PASS.
"""
from __future__ import annotations

import hashlib
import json
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\m4_mig")
from uart_pack24_clear_board import (  # noqa: E402
    CLR_ACK,
    CLR_BUSY,
    CLR_ERR,
    OUT,
    find_port,
    load_mem,
    open_ser,
    read_raw,
)

EVID = Path(r"D:\FPGA\arty_d\H_CLASSIFY_H19_H20")
CLR_CMD = 0x44524743
UNSUP = 0x0200075A
NAK_R02 = 0x0200025A
MAG = 0x0200015A
GOLD = 0x010000A5
BEGIN = 0x00800001
MAGIC_NAI1 = 0x3149414E
SHIFTED_BEGIN = 0x80000100
IDENTITY_H = "cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9"


def tok_name(w: int | None) -> str:
    if w is None:
        return "NO_BYTE"
    table = {
        CLR_ACK: "ACK",
        CLR_BUSY: "BUSY",
        CLR_ERR: "ERR",
        UNSUP: "UNSUP",
        NAK_R02: "NAK_R02",
        MAG: "MAG",
        GOLD: "GOLD",
    }
    return table.get(w, f"OTHER_{w:08x}")


def first_word(raw: bytes) -> int | None:
    if len(raw) < 4:
        return None
    return int.from_bytes(raw[:4], "little")


def classify(first_pack_word: int | None, bix: int | None) -> str:
    if first_pack_word is None or bix is None:
        return "UNKNOWN"
    if first_pack_word == SHIFTED_BEGIN and bix == 1:
        return "H19"
    if first_pack_word == MAGIC_NAI1 and bix == 0:
        return "H20"
    if first_pack_word == BEGIN and bix == 0:
        return "OTHER_ALIGNED_BEGIN"
    return "OTHER"


def main() -> int:
    EVID.mkdir(parents=True, exist_ok=True)
    port = find_port()
    rec: dict = {
        "task": "IDENTITY_H_FIRST_PACK_WORD_AND_BIX",
        "when": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "identity_h": IDENTITY_H,
        "product_rtl_changed": False,
        "pad": "NO",
        "resync": "NO",
        "guard_added": "NO",
        "program_this_script": "NO",
        "h20_role": "CLASSIFIER_ONLY_NOT_SILICON_SOLUTION",
        "port": port,
        "not_claimed": [
            "PACK_ABI_24_24_PASS",
            "BOARD_PASS",
            "PROGRAM_PASS",
            "H20_SILICON_ROOT",
            "H19_SILICON_ROOT",
        ],
    }
    if port is None:
        rec["status"] = "SKIP_NO_COM"
        rec["first_pack_word"] = None
        rec["bix"] = None
        rec["classifier"] = "UNKNOWN"
        (EVID / "D_IDENTITY_H_FIRST_WORD_BIX.json").write_text(
            json.dumps(rec, indent=2) + "\n", encoding="utf-8"
        )
        print("SKIP no COM 776EB")
        return 2

    words = load_mem(OUT / "PA24-A-01.mem")
    payload = b"".join(w.to_bytes(4, "little") for w in words)
    ser = open_ser(port)
    try:
        clr = CLR_CMD.to_bytes(4, "little")
        n_clr = ser.write(clr)
        ser.flush()
        raw_c = read_raw(ser, 3.0, idle_s=0.15)
        cw = first_word(raw_c)
        rec["clear"] = {
            "tx_n": n_clr,
            "tx_expect": 4,
            "rx_n": len(raw_c),
            "rx_hex": raw_c.hex(),
            "tok": tok_name(cw),
            "got": None if cw is None else f"{cw:08x}",
            "in_waiting_after": ser.in_waiting,
        }
        print(
            f"CLEAR tx={n_clr} rx_n={len(raw_c)} tok={rec['clear']['tok']} "
            f"got={rec['clear']['got']}",
            flush=True,
        )
        if cw != CLR_ACK:
            rec["status"] = "NO_ACK"
            rec["first_pack_word"] = None
            rec["bix"] = None
            rec["pack_status_token"] = None
            rec["classifier"] = "UNKNOWN"
            rec["observability"] = {
                "first_pack_word": "NOT_ON_WIRE",
                "bix": "NOT_ON_WIRE",
                "note": "CLEAR did not ACK; first pack word window not entered",
            }
        else:
            n_p = ser.write(payload)
            ser.flush()
            raw_p = read_raw(ser, 12.0, idle_s=0.2)
            pw = first_word(raw_p)
            rec["pack"] = {
                "tx_n": n_p,
                "tx_expect": len(payload),
                "tx_nwords": len(words),
                "exact_tx": n_p == len(payload),
                "host_first_word_sent": f"{words[0]:08x}",
                "rx_n": len(raw_p),
                "rx_hex": raw_p.hex(),
                "tok": tok_name(pw),
                "got": None if pw is None else f"{pw:08x}",
                "in_waiting_after": ser.in_waiting,
            }
            rec["status"] = "UART_DONE"
            rec["pack_status_token"] = None if pw is None else f"{pw:08x}"
            rec["first_pack_word"] = None
            rec["bix"] = None
            rec["w_valid"] = None
            rec["w_ready"] = None
            rec["drop_evt"] = None
            rec["classifier"] = classify(None, None)
            rec["observability"] = {
                "first_pack_word": "NOT_ON_WIRE",
                "bix": "NOT_ON_WIRE",
                "w_valid": "NOT_ON_WIRE",
                "w_ready": "NOT_ON_WIRE",
                "drop_evt": "NOT_ON_WIRE",
                "pack_status_token": "ON_WIRE",
                "why": (
                    "identity H UART returns ACK then pack status 02rr00/0100.. only; "
                    "uart_rx_word.bix and the first assembled pack word are not exported. "
                    "H-ILA-A dump is a different P&R bit, not identity H. "
                    "create_debug_core is not used here (would not be identity H)."
                ),
            }
            rec["classifier_rule"] = {
                "H19": "first_pack_word==80000100 AND bix==1",
                "H20": "first_pack_word==3149414e AND bix==0 (lost BEGIN)",
                "OTHER": "anything else, including 00800001 AND bix==0",
                "token_0200075a": "NOT a classifier; both H19 and H20 emit it",
            }
            print(
                f"PACK tx={n_p}/{len(payload)} exact={rec['pack']['exact_tx']} "
                f"rx_n={len(raw_p)} tok={rec['pack']['tok']} got={rec['pack']['got']}",
                flush=True,
            )
            print(
                "first_pack_word=NOT_ON_WIRE bix=NOT_ON_WIRE classifier=UNKNOWN "
                "(H20 classifier-only, not silicon solution)",
                flush=True,
            )
    finally:
        ser.close()

    jsonl = EVID / "UART_IDENTITY_H_FIRST_WORD_BIX.jsonl"
    jsonl.write_text(json.dumps(rec) + "\n", encoding="utf-8")
    rec["jsonl_sha256"] = hashlib.sha256(jsonl.read_bytes()).hexdigest()
    outp = EVID / "D_IDENTITY_H_FIRST_WORD_BIX.json"
    outp.write_text(json.dumps(rec, indent=2) + "\n", encoding="utf-8")
    print(f"WROTE {outp} jsonl={jsonl} sha256={rec['jsonl_sha256']}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
