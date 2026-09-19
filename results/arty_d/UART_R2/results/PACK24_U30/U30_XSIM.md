# U30 XSim — leftover + four V-04

Dest = `mig_ui_bram` (not generated `mig0`, not board).
PACK_ABI_24_24_PASS = NO. PROGRAM_PASS = NO. BOARD_PASS = NOT_EVIDENCED.

## leftover opcode-01
PASS_XSIM `UART_R2_U30_LEFTOVER_XSIM_PASS` at 4892095 ns
CLEAR2 ACK `c1ea50a5`; V04_1 GOLD `010000a5` first_p=`00800001`

## four V-04
PASS_XSIM `UART_R2_U30_TWO_V04_XSIM_PASS four GOLD` at 9663615 ns
V04_1/2/3 GOLD `010000a5` first_p=`00800001`

Overlay: `pack_quiescent && rst_loc && !debug_clear`; `dest_accept = qsc_c1 && rst100_pack_n`; park BEGIN only if `f_valid`.
PACKAGE live `pack_mig_bind` not overwritten. U29 `c02c3343…` not patched.
