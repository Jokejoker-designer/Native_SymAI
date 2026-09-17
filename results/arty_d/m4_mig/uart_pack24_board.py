"""24-case Pack/ABI-24 UART on programmed M4+mig. Sequential, one bitstream.
Not isolated-reset XSim. Not PACK_ABI_24_24_PASS / BOARD_PASS."""
from __future__ import annotations

import csv
import sys
import time
from pathlib import Path

OUT = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out"
)
TSV = OUT / "pack_abi24_expect.tsv"
LOG = Path(r"D:\FPGA\arty_d\m4_mig\UART_PACK24_BOARD.txt")


def load_mem(path: Path) -> list[int]:
    lines = [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]
    nwords = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + nwords]]
    if len(words) != nwords:
        raise ValueError(f"{path.name} short {len(words)}/{nwords}")
    return words


def expect_word(ack: int, rej: int, reason: int) -> int:
    if ack:
        return (0x01 << 24) | (reason << 8) | 0xA5
    if rej:
        return (0x02 << 24) | (reason << 8) | 0x5A
    raise ValueError("neither ack nor rej")


def read_word(ser, timeout_s: float) -> int | None:
    ser.timeout = 0.2
    got = bytearray()
    t0 = time.time()
    while len(got) < 4 and (time.time() - t0) < timeout_s:
        chunk = ser.read(4 - len(got))
        if chunk:
            got.extend(chunk)
    if len(got) < 4:
        return None
    return int.from_bytes(bytes(got), "little")


def main() -> int:
    import serial
    from serial.tools import list_ports

    port = None
    for p in list_ports.comports():
        if (p.serial_number or "").upper().endswith("776EB"):
            port = p.device
            break
    if port is None:
        print("SKIP no COM")
        return 2

    rows = list(csv.DictReader(TSV.open(encoding="utf-8"), delimiter="\t"))
    n_pass = 0
    n_fail = 0
    lines = []
    with serial.Serial(port, 115200, timeout=0.2, write_timeout=8.0) as ser:
        time.sleep(0.4)
        ser.reset_input_buffer()
        for row in rows:
            cid = row["case_id"]
            words = load_mem(OUT / f"{cid}.mem")
            exp = expect_word(int(row["ack"]), int(row["reject"]), int(row["reason"]))
            ser.reset_input_buffer()
            t0 = time.time()
            ser.write(b"".join(w.to_bytes(4, "little") for w in words))
            ser.flush()
            got = read_word(ser, 12.0)
            dt = time.time() - t0
            ok = got == exp
            n_pass += int(ok)
            n_fail += int(not ok)
            rec = f"{cid} exp={exp:08x} got={'None' if got is None else f'{got:08x}'} dt={dt:.3f}s {'OK' if ok else 'FAIL'}"
            print(rec, flush=True)
            lines.append(rec)
            time.sleep(0.05)

    banner = (
        f"UART_PACK24_BOARD_SEQ pass={n_pass} fail={n_fail}/24 "
        "(sequential no per-case reset; not PACK_ABI_24_24_PASS)"
    )
    print(banner)
    LOG.write_text("\n".join(lines + [banner, "BOARD_PASS=NO"]) + "\n", encoding="utf-8")
    return 0 if n_fail == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
