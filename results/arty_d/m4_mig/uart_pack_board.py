"""UART Pack/ABI-24 smoke on programmed M4+mig candidate. Not BOARD_PASS."""
from __future__ import annotations

import sys
import time
from pathlib import Path

MEM_V = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\pack_abi24\out\PA24-V-01.mem"
)
MEM_R = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\tb\native_ai\board\build_uart_pack\v2_bad_magic.mem"
)


def load_mem(path: Path) -> list[int]:
    lines = [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines() if ln.strip()]
    nwords = int(lines[0], 16)
    words = [int(x, 16) for x in lines[1 : 1 + nwords]]
    if len(words) != nwords:
        raise ValueError(f"{path} short {len(words)}/{nwords}")
    return words


def send_words(ser, words: list[int]) -> None:
    blob = b"".join(w.to_bytes(4, "little") for w in words)
    ser.write(blob)
    ser.flush()


def read_word(ser, timeout_s: float) -> int | None:
    ser.timeout = timeout_s
    got = bytearray()
    t0 = time.time()
    while len(got) < 4 and (time.time() - t0) < timeout_s:
        chunk = ser.read(4 - len(got))
        if chunk:
            got.extend(chunk)
    if len(got) < 4:
        return None
    return int.from_bytes(got, "little")


def main() -> int:
    import serial
    from serial.tools import list_ports

    port = None
    for p in list_ports.comports():
        sn = (p.serial_number or "").upper()
        if "210319BE776EB" in sn:
            port = p.device
            break
    if port is None:
        print("UART_PACK_SKIP no FTDI UART")
        return 2

    vwords = load_mem(MEM_V)
    rwords = load_mem(MEM_R)
    print("PORT", port, "V_N", len(vwords), "R_N", len(rwords))

    cases = [
        ("PA24-V-01", vwords, 0x010000A5),
        ("v2_bad_magic", rwords, 0x0200015A),
    ]
    n_pass = 0
    n_fail = 0
    with serial.Serial(port, 115200, timeout=1.0, write_timeout=5.0) as ser:
        time.sleep(0.5)
        ser.reset_input_buffer()
        for name, words, exp in cases:
            ser.reset_input_buffer()
            t0 = time.time()
            send_words(ser, words)
            got = read_word(ser, 25.0)
            dt = time.time() - t0
            print(f"{name} exp={exp:08x} got={None if got is None else f'{got:08x}'} dt={dt:.3f}s")
            if got == exp:
                n_pass += 1
            else:
                n_fail += 1
            time.sleep(0.3)

    print(f"UART_PACK_BOARD_SMOKE pass={n_pass} fail={n_fail} (not BOARD_PASS / PACK_ABI_24_24_PASS)")
    if n_fail:
        print("UART_PACK_BOARD_SMOKE_FAIL")
        return 1
    print("UART_PACK_BOARD_SMOKE_CANDIDATE")
    return 0


if __name__ == "__main__":
    sys.exit(main())
