"""H18 offline classifier. No board. Does not edit frozen host scripts."""
from __future__ import annotations

import json
from pathlib import Path

CLR_ACK = 0xC1EA50A5
CLR_BUSY = 0xC1EA50B5
CLR_ERR = 0xC1EA50E5
MAG = 0x0200015A
UNSUP = 0x0200075A
SENTINEL = 0x0200085A

ROOT = Path(r"D:\FPGA\arty_d\first_divergence_01")
FR = ROOT / "FROZEN_20260917T004100Z"
H9 = ROOT / "H9_JP2_INSTALLED"


def sub_of(w: int) -> str:
    if w == CLR_ACK:
        return "ACK"
    if w == CLR_BUSY:
        return "BUSY"
    if w == CLR_ERR:
        return "ERR"
    if w == MAG:
        return "MAG"
    if w == UNSUP:
        return "UNSUP"
    if w == SENTINEL:
        return "SENTINEL"
    if (w & 0xFFFF) in (0x4E52, 0x524E):
        return "STREAM_4E52"
    if (w & 0xFF) == 0xA5 and ((w >> 24) & 0xFF) == 0x01:
        return "GOLD"
    if (w & 0xFF) == 0x5A and ((w >> 24) & 0xFF) == 0x02:
        return f"NAK_R{(w >> 8) & 0xFF:02x}"
    return f"OTHER_{w:08x}"


def classify(got: str | None, hexstr: str | None, expect: str | None) -> dict:
    h = hexstr or ""
    n = 0
    if h:
        try:
            n = len(bytes.fromhex(h))
        except ValueError:
            n = 0
    w: int | None = None
    if got:
        w = int(got, 16)
        if n == 0:
            n = 4
    elif n >= 4:
        w = int.from_bytes(bytes.fromhex(h)[:4], "little")
    if n == 0 and w is None:
        return {"h18": "NO_BYTE", "sub": "NONE", "n": 0, "word": None}
    if 0 < n < 4 and w is None:
        return {"h18": "PARTIAL_RESPONSE", "sub": "NONE", "n": n, "word": None, "hex": h}
    assert w is not None
    word = f"{w:08x}"
    sub = sub_of(w)
    if expect and word == expect:
        h18 = "CORRECT_4BYTE"
    else:
        h18 = "WRONG_VALID_4BYTE"
    return {"h18": h18, "sub": sub, "n": n, "word": word, "hex": h or None}


def load_jsonl(path: Path) -> list[dict]:
    if not path.exists():
        return []
    return [json.loads(ln) for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]


def tally(rows: list[dict]) -> dict[str, int]:
    c: dict[str, int] = {}
    for r in rows:
        k = f"{r['h18']}:{r['sub']}"
        c[k] = c.get(k, 0) + 1
    return dict(sorted(c.items()))


def main() -> None:
    iso = []
    for r in load_jsonl(FR / "UART_PACK24_ISO_BOARD.jsonl"):
        iso.append(
            {"src": "ISO", "case": r.get("case_id"), "expect": r.get("expect"), **classify(r.get("got"), None, r.get("expect"))}
        )
    hist = []
    for r in load_jsonl(FR / "UART_PACK24_CLEAR_BOARD.jsonl"):
        hist.append(
            {
                "src": "CLEAR_H_HIST",
                "round": r.get("round"),
                "case": r.get("case_id"),
                "phase": r.get("phase"),
                "expect": r.get("expect"),
                **classify(r.get("got"), r.get("raw_hex"), r.get("expect")),
            }
        )
    h9 = []
    for r in load_jsonl(H9 / "UART_PACK24_CLEAR_BOARD.jsonl"):
        h9.append(
            {
                "src": "H9_JP2_INSTALLED",
                "round": r.get("round"),
                "case": r.get("case_id"),
                "phase": r.get("phase"),
                "expect": r.get("expect"),
                **classify(r.get("got"), r.get("raw_hex"), r.get("expect")),
            }
        )

    def first(rows: list[dict], h18: str) -> dict | None:
        for r in rows:
            if r["h18"] == h18:
                return {k: r[k] for k in r if k != "hex" or r.get("hex")}
        return None

    out = {
        "task": "D-PACK-SILICON-FIRST-DIVERGENCE-01",
        "step": "H18_OFFLINE",
        "DELAYED_RESPONSE": "UNKNOWN_NO_TIMESTAMPS",
        "iso_tally": tally(iso),
        "iso_no_byte": sum(1 for r in iso if r["h18"] == "NO_BYTE"),
        "iso_first_wrong": first(iso, "WRONG_VALID_4BYTE"),
        "hist_tally": tally(hist),
        "hist_first_wrong": first(hist, "WRONG_VALID_4BYTE"),
        "hist_first_no_byte": first(hist, "NO_BYTE"),
        "h9_tally": tally(h9),
        "h9_first_wrong": first(h9, "WRONG_VALID_4BYTE"),
        "h9_first_no_byte": first(h9, "NO_BYTE"),
        "FAILURE_CLASS_A": "WRONG_VALID_4BYTE",
        "FAILURE_CLASS_B": "NO_BYTE",
        "COMMON_ROOT": "UNKNOWN",
        "iso_rows": iso,
        "hist_rows": hist,
        "h9_rows": h9,
        "not_claimed": ["PACK_ABI_24_24_PASS", "BOARD_PASS", "PROGRAM_PASS"],
    }
    (ROOT / "H18_OFFLINE.json").write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
    print("ISO", json.dumps(out["iso_tally"]))
    print("HIST", json.dumps(out["hist_tally"]))
    print("H9", json.dumps(out["h9_tally"]))
    print("hist_first_wrong", out["hist_first_wrong"])
    print("hist_first_no_byte", out["hist_first_no_byte"])
    print("h9_first_wrong", out["h9_first_wrong"])
    print("h9_first_no_byte", out["h9_first_no_byte"])


if __name__ == "__main__":
    main()
