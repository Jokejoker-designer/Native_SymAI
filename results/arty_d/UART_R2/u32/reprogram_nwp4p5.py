"""Reprogram U32 exclusive, 12s settle, then no-warmup p4+p5."""
from __future__ import annotations

import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u9")
from uart_r2_u9_board_test import find_port, kill_jtag_usb_servers

PROG = Path(r"D:\FPGA\arty_d\UART_R2\u32\run_program_u32.bat")
CAMP = Path(r"D:\FPGA\arty_d\UART_R2\u32\u32_campaign.py")
KILL = Path(r"D:\FPGA\arty_d\UART_R2\u32\kill_com12_holders.py")
SETTLE_S = 12.0


def main() -> int:
    subprocess.call([sys.executable, str(KILL)])
    kill_jtag_usb_servers()
    rc = subprocess.call(["cmd", "/c", str(PROG)])
    print("PROGRAM_RC", rc)
    if rc != 0:
        return rc
    kill_jtag_usb_servers()
    print("SETTLE", SETTLE_S)
    time.sleep(SETTLE_S)
    port = find_port()
    print("PORT", port)
    if not port:
        return 2
    return subprocess.call([sys.executable, str(CAMP), "nwp4p5"])


if __name__ == "__main__":
    raise SystemExit(main())
