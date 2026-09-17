"""UART hop-1 smoke against programmed M4+mig candidate. Not BOARD_PASS."""
import sys
import time

def crc16_ccitt_false(data: bytes) -> int:
    c = 0xFFFF
    for b in data:
        c ^= b << 8
        for _ in range(8):
            c = ((c << 1) ^ 0x1021) & 0xFFFF if c & 0x8000 else (c << 1) & 0xFFFF
    return c

def pack_q(sid: int, hops: int, txn: int) -> bytes:
    q = bytearray(32)
    q[0] = 0x51
    q[1] = 0x4E
    q[2] = 0x01
    q[4] = txn & 0xFF
    q[5] = (txn >> 8) & 0xFF
    meta = (hops & 0xF) << 5
    q[12] = meta & 0xFF
    q[13] = (meta >> 8) & 0xFF
    q[14:18] = sid.to_bytes(4, "little")
    crc = crc16_ccitt_false(q[:30])
    q[30] = crc & 0xFF
    q[31] = (crc >> 8) & 0xFF
    return bytes(q)

def main() -> int:
    try:
        import serial
        from serial.tools import list_ports
    except ImportError:
        print("UART_SMOKE_SKIP no pyserial")
        return 2
    ports = list(list_ports.comports())
    print("PORTS", [(p.device, p.serial_number, p.description) for p in ports])
    port = None
    for p in ports:
        sn = (p.serial_number or "").upper()
        if "210319BE776EB" in sn or sn.endswith("776EB"):
            port = p.device
            break
    if port is None:
        for p in ports:
            if p.device.upper() == "COM12":
                port = p.device
                break
    if port is None:
        print("UART_SMOKE_SKIP no FTDI UART")
        return 2
    print("USING", port)
    q = pack_q(0x000A0101, 1, 0x0001)
    with serial.Serial(port, 115200, timeout=3.0, write_timeout=2.0) as ser:
        ser.reset_input_buffer()
        ser.write(q)
        ser.flush()
        t0 = time.time()
        got = bytearray()
        while len(got) < 48 and (time.time() - t0) < 5.0:
            chunk = ser.read(48 - len(got))
            if chunk:
                got.extend(chunk)
    print("GOT", len(got), got.hex() if got else "empty")
    if len(got) < 48:
        print("UART_SMOKE_FAIL short")
        return 1
    magic = int.from_bytes(got[0:2], "little")
    status = got[16] if len(got) > 16 else None
    print("MAGIC", hex(magic), "status_byte16", None if status is None else hex(status))
    if magic == 0x4E52:
        print("UART_BOARD_SMOKE_CANDIDATE magic_ok (not BOARD_PASS)")
        return 0
    print("UART_SMOKE_FAIL magic")
    return 1

if __name__ == "__main__":
    sys.exit(main())
