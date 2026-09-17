"""H_OBS UART-dump host. H_OBS != identity H. Does not explain H.

CLEAR then PA24-A-01 exact. Parse pack token + 16-byte OBS1 dump.
No pad/resync. H20 classifier-only. Not PACK_ABI_24_24_PASS / BOARD_PASS.
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
    OUT,
    find_port,
    load_mem,
    open_ser,
    read_raw,
)

EVID = Path(r"D:\FPGA\arty_d\H_OBS")
CLR_CMD = 0x44524743
MAGIC = 0x3153424F
BEGIN = 0x00800001
SHIFT = 0x80000100
NAI1 = 0x3149414E
IDENTITY_H = "cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9"
IDENTITY_ILA = "b037b355a7098c99b9a995554756122e09569230d3b8d02698c255e6a64f8cef"


def read_kv(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    if not path.is_file():
        return out
    for line in path.read_text(encoding="utf-8").splitlines():
        if "=" in line:
            k, v = line.split("=", 1)
            out[k.strip()] = v.strip()
    return out


def refuse_wrong_identity(rec: dict) -> str | None:
    prog = read_kv(EVID / "PROGRAM.txt")
    build = read_kv(EVID / "BUILD.txt")
    sha = (prog.get("SHA256") or build.get("SHA256") or "").lower()
    rec["h_obs_bit_sha256"] = sha or None
    rec["program_identity"] = prog.get("IDENTITY")
    rec["explains_identity_h"] = False
    rec["h_obs_equals_h"] = False
    if not prog:
        return "REFUSE_NO_PROGRAM_TXT"
    if sha == IDENTITY_H:
        return "REFUSE_IDENTITY_H"
    if sha == IDENTITY_ILA:
        return "REFUSE_H_ILA_A"
    if prog.get("IDENTITY") != "H_OBS":
        return "REFUSE_NOT_H_OBS"
    if prog.get("EXPLAINS_IDENTITY_H") == "YES":
        return "REFUSE_EXPLAINS_H_STAMP"
    if not sha:
        return "REFUSE_NO_BIT_SHA"
    return None


def tok_name(w: int | None) -> str:
    if w is None:
        return "NO_BYTE"
    table = {
        CLR_ACK: "ACK",
        0x0200075A: "UNSUP",
        0x0200025A: "NAK_R02",
        0x0200015A: "MAG",
        0x010000A5: "GOLD",
    }
    return table.get(w, f"OTHER_{w:08x}")


def u32le(b: bytes, off: int = 0) -> int:
    return int.from_bytes(b[off : off + 4], "little")


def decode_dump(raw: bytes) -> dict:
    if len(raw) < 16:
        return {"ok": False, "n": len(raw), "hex": raw.hex()}
    w0, w1, w2, w3 = u32le(raw, 0), u32le(raw, 4), u32le(raw, 8), u32le(raw, 12)
    sh = [(w2 >> (8 * i)) & 0xFF for i in range(4)]
    return {
        "ok": w0 == MAGIC,
        "magic": f"{w0:08x}",
        "bix_at_arm": w1 & 3,
        "bix_at_first_pack": (w1 >> 2) & 3,
        "bix_gap": (w1 >> 4) & 3,
        "sh0_meta": f"{(w1 >> 6) & 0xFF:02x}",
        "n_bytes": (w1 >> 14) & 0xF,
        "have_pack_word": bool((w1 >> 18) & 1),
        "cap_fresh": bool((w1 >> 19) & 1),
        "drop_seen": bool((w1 >> 20) & 1),
        "sh": [f"{x:02x}" for x in sh],
        "first_pack_word": f"{w3:08x}",
        "raw16": raw[:16].hex(),
    }


def classify_h_obs(dump: dict) -> str:
    if not dump.get("ok") or not dump.get("have_pack_word"):
        return "UNKNOWN"
    fp = int(dump["first_pack_word"], 16)
    if fp == SHIFT:
        return "H19"
    if fp == NAI1:
        return "H20"
    if fp == BEGIN:
        return "OTHER_ALIGNED_BEGIN"
    return "OTHER"


def main() -> int:
    EVID.mkdir(parents=True, exist_ok=True)
    port = find_port()
    rec: dict = {
        "task": "H_OBS_UART_DUMP",
        "identity": "H_OBS",
        "identity_h": IDENTITY_H,
        "h_obs_equals_h": False,
        "explains_identity_h": False,
        "h20_role": "CLASSIFIER_ONLY_NOT_SILICON_SOLUTION",
        "classifier_applies_to": "H_OBS_ONLY",
        "pad": "NO",
        "resync": "NO",
        "guard_added": "NO",
        "product_rtl_changed": False,
        "when": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "port": port,
        "not_claimed": [
            "PACK_ABI_24_24_PASS",
            "BOARD_PASS",
            "PROGRAM_PASS",
            "IDENTITY_H_CLASS",
            "H20_SILICON_ROOT",
        ],
    }
    lock = refuse_wrong_identity(rec)
    if lock:
        rec["status"] = lock
        rec["classifier_h_obs"] = "LOCKED_OUT"
        rec["classifier_applies_to"] = "H_OBS_ONLY"
        (EVID / "D_H_OBS.json").write_text(json.dumps(rec, indent=2) + "\n", encoding="utf-8")
        print(f"LOCKED {lock} EXPLAINS_IDENTITY_H=NO")
        return 3
    if port is None:
        rec["status"] = "SKIP_NO_COM"
        (EVID / "D_H_OBS.json").write_text(json.dumps(rec, indent=2) + "\n", encoding="utf-8")
        print("SKIP no COM 776EB")
        return 2

    words = load_mem(OUT / "PA24-A-01.mem")
    payload = b"".join(w.to_bytes(4, "little") for w in words)
    ser = open_ser(port)
    try:
        n_clr = ser.write(CLR_CMD.to_bytes(4, "little"))
        ser.flush()
        raw_c = read_raw(ser, 3.0, idle_s=0.15)
        cw = u32le(raw_c) if len(raw_c) >= 4 else None
        rec["clear"] = {
            "tx_n": n_clr,
            "rx_n": len(raw_c),
            "rx_hex": raw_c.hex(),
            "tok": tok_name(cw),
            "got": None if cw is None else f"{cw:08x}",
        }
        print(f"H_OBS CLEAR tok={rec['clear']['tok']} got={rec['clear']['got']}", flush=True)
        if cw != CLR_ACK:
            rec["status"] = "NO_ACK"
            rec["classifier_h_obs"] = "UNKNOWN"
        else:
            n_p = ser.write(payload)
            ser.flush()
            raw_p = read_raw(ser, 12.0, idle_s=0.25)
            pw = u32le(raw_p) if len(raw_p) >= 4 else None
            dump = decode_dump(raw_p[4:20]) if len(raw_p) >= 20 else decode_dump(b"")
            rec["pack"] = {
                "tx_n": n_p,
                "tx_expect": len(payload),
                "exact_tx": n_p == len(payload),
                "host_first_word_sent": f"{words[0]:08x}",
                "rx_n": len(raw_p),
                "rx_hex": raw_p.hex(),
                "tok": tok_name(pw),
                "got": None if pw is None else f"{pw:08x}",
            }
            rec["dump"] = dump
            rec["first_pack_word"] = dump.get("first_pack_word") if dump.get("ok") else None
            rec["bix"] = dump.get("bix_gap") if dump.get("ok") else None
            rec["bix_at_arm"] = dump.get("bix_at_arm") if dump.get("ok") else None
            rec["bix_at_first_pack"] = dump.get("bix_at_first_pack") if dump.get("ok") else None
            rec["classifier_h_obs"] = classify_h_obs(dump)
            rec["status"] = "UART_DONE"
            rec["note"] = (
                "classifier_h_obs applies only to this H_OBS bit. "
                "It must not be copied onto identity H."
            )
            print(
                f"H_OBS PACK tok={rec['pack']['tok']} dump_ok={dump.get('ok')} "
                f"first_pack_word={rec['first_pack_word']} bix_gap={rec['bix']} "
                f"class={rec['classifier_h_obs']}",
                flush=True,
            )
    finally:
        ser.close()

    jsonl = EVID / "UART_H_OBS.jsonl"
    with jsonl.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(rec) + "\n")
    rec["jsonl_sha256"] = hashlib.sha256(jsonl.read_bytes()).hexdigest()
    outp = EVID / "D_H_OBS.json"
    outp.write_text(json.dumps(rec, indent=2) + "\n", encoding="utf-8")
    print(f"WROTE {outp} EXPLAINS_IDENTITY_H=NO", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
