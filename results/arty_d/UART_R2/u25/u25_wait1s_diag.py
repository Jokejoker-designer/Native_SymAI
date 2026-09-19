"""Host-only diagnostic on frozen U25 SRAM. Not a product fix. Not PACK_ABI_24_24_PASS."""
from pathlib import Path
import sys

sys.path.insert(0, r"D:\FPGA\arty_d\UART_R2\u25")
import u25_campaign as c

c.WAIT_AFTER_ACK_S = 1.0
c.WAIT_AFTER_GOLD_S = 1.0
c.OUT = Path(r"D:\FPGA\arty_d\UART_R2\results\PACK24_U25\WAIT1S")
c.RAW = c.OUT / "RAW_UART"
c.u9mod.OUT = c.OUT

if __name__ == "__main__":
    raise SystemExit(c.main())
