# U31 FAIL — leftover BUSY+GOLD / ACK then V-04 n=0

UART_R2_U31 = CANDIDATE_FAIL_BOARD_24_24

U31_PROGRAMMED = FACT
BIT_SHA256 = 08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d
DCP_SHA256 = 72855dfe7feeae1c2b6e0c3cafbe296b2fb4f5d19bdfb4c56c3435f13ffc371d
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH
UART = COM12 115200 FTDI 210319BE776EB
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO

Do not patch U31 RTL. Frozen identity. Do not overlay dest_ui_rdy / dest_accept from mute cells.

## LAST_GOOD_EVENT
Phase4 V-04 GOLD n=4 `a5000001` (E5/E7)

## FIRST_BAD_EVENT
p5 r0 CLEAR leftover n=8 `b550eac1a5000001` then V-04 n=0; or ACK then first V-04 n=0 (E6)

## NOTE
Worse GOLD-then-next than frozen U30 (U30 two GOLD then r1 n=0; U31 never two GOLD in one campaign).
Live leftover shape on BRAM: S_REQ then dest_stall nack → BUSY+GOLD (`xsim_u31r`), not dest_stall-only (BUSY n=4).
