"""Decode H-ILA-A capture: UART frame on rx sample vs bix/sh/w_data assembly.

Not PACK_ABI_24_24_PASS / BOARD_PASS.
"""
from __future__ import annotations

import csv
import json
import re
from pathlib import Path

ILA = Path(r"D:\FPGA\arty_d\H_ILA_A")
DIV = 100_000_000 // 115200  # 868
MID = DIV // 2


def load_samples_txt(path: Path) -> dict[str, list[str]]:
    probes: dict[str, list[str]] = {}
    if not path.exists():
        return probes
    text = path.read_text(encoding="utf-8", errors="replace")
    chunks = re.split(r"(?m)^PROBE ", text)
    for chunk in chunks[1:]:
        lines = chunk.splitlines()
        if not lines:
            continue
        m = re.match(r"(\S+)\s+N=(\d+)", lines[0])
        if not m:
            continue
        name = m.group(1)
        rest = " ".join(lines[1:]).split()
        probes[name] = rest
    return probes


def as_bits(seq: list[str]) -> list[int]:
    out = []
    for s in seq:
        t = s.strip().lower()
        if t in ("0", "1"):
            out.append(int(t))
        elif t.startswith("0x"):
            out.append(int(t, 16))
        elif re.fullmatch(r"[01]+", t):
            out.append(int(t, 2))
        else:
            try:
                out.append(int(t, 0))
            except ValueError:
                out.append(0)
    return out


def uart_bytes(rx: list[int], start: int = 0) -> list[dict]:
    found = []
    i = max(1, start)
    n = len(rx)
    while i < n - 9 * DIV:
        if rx[i - 1] == 1 and rx[i] == 0:
            mid = i + MID
            if mid >= n:
                break
            if rx[mid] != 0:
                found.append({"kind": "FALSE_START", "i": i})
                i += 1
                continue
            bits = []
            ok = True
            for b in range(8):
                si = i + DIV + b * DIV + MID
                if si >= n:
                    ok = False
                    break
                bits.append(rx[si])
            stop_i = i + 9 * DIV + MID
            stop = rx[stop_i] if stop_i < n else None
            if not ok:
                break
            val = 0
            for k, bit in enumerate(bits):
                val |= bit << k
            kind = "BYTE"
            if stop == 0:
                kind = "BREAK_OR_BAD_STOP"
            found.append(
                {
                    "kind": kind,
                    "i": i,
                    "byte": val,
                    "hex": f"{val:02x}",
                    "stop": stop,
                    "bits": bits,
                }
            )
            i = i + 10 * DIV - 4
            continue
        i += 1
    return found


def first_bix_events(bix: list[int], w_valid: list[int] | None) -> list[dict]:
    ev = []
    prev = bix[0] if bix else 0
    for i, v in enumerate(bix):
        if v != prev:
            rec = {"i": i, "bix": v, "prev": prev}
            if w_valid is not None and i < len(w_valid):
                rec["w_valid"] = w_valid[i]
            ev.append(rec)
            prev = v
    return ev


def classify(frames: list[dict], bix_ev: list[dict]) -> dict:
    bytes_ = [f for f in frames if f["kind"] in ("BYTE", "BREAK_OR_BAD_STOP")]
    first = bytes_[0] if bytes_ else None
    false_starts = [f for f in frames if f["kind"] == "FALSE_START"]
    if first is None:
        verdict = "NO_UART_BYTE_IN_WINDOW"
        layer = "UNKNOWN"
    elif first["hex"] == "00" and first["kind"] == "BYTE":
        verdict = "EXTRA_00_ON_UART_RX"
        layer = "UART_RX_SAMPLE"
    elif first["hex"] == "00" and first["kind"] == "BREAK_OR_BAD_STOP":
        verdict = "LINE_LOW_ASSEMBLED_00"
        layer = "UART_RX_SAMPLE"
    elif first["hex"] == "01":
        verdict = "FIRST_WIRE_BYTE_IS_BEGIN_01"
        layer = "NOT_AT_RX_IN_THIS_WINDOW"
    else:
        verdict = f"FIRST_WIRE_BYTE_{first['hex']}"
        layer = "UART_RX_SAMPLE"
    return {
        "verdict": verdict,
        "layer": layer,
        "first_frame": first,
        "n_frames": len(bytes_),
        "n_false_start": len(false_starts),
        "n_bix_change": len(bix_ev),
        "first_bytes": [f["hex"] for f in bytes_[:8]],
    }


def load_csv(path: Path) -> dict[str, list[str]]:
    if not path.exists():
        return {}
    with path.open(encoding="utf-8", newline="") as fh:
        reader = csv.reader(fh)
        rows = list(reader)
    if len(rows) < 2:
        return {}
    hdr = rows[0]
    cols: dict[str, list[str]] = {h: [] for h in hdr}
    for row in rows[1:]:
        for h, v in zip(hdr, row):
            cols[h].append(v)
    return cols


def main() -> int:
    probes = load_samples_txt(ILA / "capture_samples.txt")
    if not probes:
        probes = load_csv(ILA / "capture.csv")
    rx_name = None
    for key in probes:
        kl = key.lower()
        if "rx_d" in kl or kl.endswith("probe0") or "uart_rx" in kl:
            rx_name = key
            break
    if rx_name is None and probes:
        rx_name = next(iter(probes))
    result = {
        "probe_names": list(probes.keys()),
        "rx_probe": rx_name,
        "n_probes": len(probes),
    }
    if rx_name:
        rx = as_bits(probes[rx_name])
        result["n_rx_samples"] = len(rx)
        frames = uart_bytes(rx, start=max(0, 1024 - 200))
        bix = None
        wv = None
        for key, seq in probes.items():
            kl = key.lower()
            if "bix" in kl and bix is None:
                bix = as_bits(seq)
            if "w_valid" in kl and wv is None:
                wv = as_bits(seq)
        bix_ev = first_bix_events(bix, wv) if bix else []
        result["uart_frames"] = frames[:16]
        result["bix_events"] = bix_ev[:32]
        result["class"] = classify(frames, bix_ev)
    (ILA / "D_H_ILA_A.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result.get("class", result), indent=2))
    print("wrote", ILA / "D_H_ILA_A.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
