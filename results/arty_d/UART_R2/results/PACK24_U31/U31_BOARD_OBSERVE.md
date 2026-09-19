# U31 board observe — not PACK_ABI_24_24_PASS

BIT_SHA256 `08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d`
JTAG `210319BE776EA` End of startup HIGH
PROGRAM_PASS=NO BOARD_PASS=NOT_EVIDENCED PACK_ABI_24_24_PASS=NO

## FACT
- Exclusive nwp4p5 after 12s settle: CLEAR n=0 including reopen (`BOARD_BASELINE_NWP4P5_FIRST_N0.json`).
- Extra settle + p4p5 warmup 02:08: WARMUP BUSY n=4; CLEAR1 ACK; V-04 GOLD n=4; p5 r0 CLEAR n=8 BUSY+GOLD (`CLEAR_V04_24_P4P5_BUSY_LEFTOVER.json`).
- BUSY-retry on same SRAM: sticky BUSY+GOLD n=8; reopen ACK; V-04 n=0.
- Reprogram 02:13 + settle: warmup n=0, BUSY/n=0 mix, reopen ACK, V-04 n=0 12.007s (`BOARD_BASELINE.json`).
- SRAM p4p5 02:15: Phase4 GOLD; p5 r0 leftover BUSY+GOLD then V-04 n=0 (`CLEAR_V04_24.json`).

## INFERENCE
CLEAR TX mux can preempt pending pack GOLD. BUSY is ABI. First-ACK-miss after JTAG still present.

## NOT
Not UART PHY absence of GOLD. Not AXI UART. Not TIMING_PASS. Not 24/24.
