"""Post-JTAG exclusive UART settle then p4p5. No reprogram."""
from __future__ import annotations

import subprocess
import sys
import time

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u9")
from uart_r2_u9_board_test import find_port, kill_jtag_usb_servers

SETTLE_S = 12.0


def main() -> int:
    kill_jtag_usb_servers()
    print("SETTLE", SETTLE_S)
    time.sleep(SETTLE_S)
    port = find_port()
    print("PORT", port)
    if not port:
        return 2
    return subprocess.call(
        [sys.executable, r"D:\FPGA\arty_d\UART_R2\u29\u29_campaign.py", "p4p5"]
    )


if __name__ == "__main__":
    raise SystemExit(main())
