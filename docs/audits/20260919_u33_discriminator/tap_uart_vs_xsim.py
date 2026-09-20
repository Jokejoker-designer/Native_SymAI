"""Compare silicon U33TAP MAG dump bytes to XSim DUP4 TAP UART words.
Not PACK_ABI_24_24_PASS.
"""
from __future__ import annotations

import json
from pathlib import Path

OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\U33TAP_CAPTURE_20260920")
# XSim DUP4_DUMP words after MAG (u33tap_sof.log)
XSIM = [
    0x31504154,
    0x00800001,
    0x00800001,
    0x3149414E,
    0x00010001,
    0xA108011A,
]


def le(w: int) -> bytes:
    return w.to_bytes(4, "little")


def main() -> int:
    cap = json.loads((OUT / "CAPTURE.json").read_text(encoding="utf-8"))
    dup = next(c for c in cap["cells"] if c["cell"] == "CELL_DUP4")
    hx = dup["RX"]["raw_hex"]
    raw = bytes.fromhex(hx)
    mag, rest = raw[:4], raw[4:]
    xsim_b = b"".join(le(w) for w in XSIM)
    rec = {
        "mag_word": mag.hex(),
        "silicon_after_mag": rest.hex(),
        "xsim_tap_uart": xsim_b.hex(),
        "silicon_words": dup["RX"]["words"][1:],
        "xsim_words": [f"{w:08x}" for w in XSIM],
        "p3_match": rest[16:20] == xsim_b[16:20] if len(rest) >= 20 and len(xsim_b) >= 20 else False,
        "meta_match": rest[20:24] == xsim_b[20:24] if len(rest) >= 24 and len(xsim_b) >= 24 else False,
        "first_diff": None,
        "note": "Programmed TAP bit was not rebuilt after TAP CDC hold XDC; dump p1 untrusted as loader beat.",
        "PACK_ABI_24_24_PASS": "NO",
    }
    n = min(len(rest), len(xsim_b))
    for i in range(n):
        if rest[i] != xsim_b[i]:
            rec["first_diff"] = {"byte_i": i, "si": f"{rest[i]:02x}", "xsim": f"{xsim_b[i]:02x}"}
            break
    # rest[0:4]=TAP1, rest[4:8]=p0 BEGIN, rest[8:]=p1...
    rec["p0_begin_both"] = rest[4:8] == le(0x00800001) and xsim_b[4:8] == le(0x00800001)
    rec["p1_match"] = rest[8:12] == xsim_b[8:12] if len(rest) >= 12 and len(xsim_b) >= 12 else False
    (OUT / "TAP_UART_VS_XSIM.json").write_text(json.dumps(rec, indent=2), encoding="utf-8")
    print(json.dumps(rec, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
