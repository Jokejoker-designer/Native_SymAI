# U31 XSim — leftover + four V-04

Dest = `mig_ui_bram` (not generated `mig0`, not board).
PACK_ABI_24_24_PASS = NO.

First XSim FAIL CLEAR1 BUSY: `pack_quiescent` used mux `a_rdy`, which is 0 in `G_NONE`. Fixed: `dest_ui_rdy` from dest, not mux.

## leftover opcode-01
PASS_XSIM `UART_R2_U31_LEFTOVER_XSIM_PASS` at 4893695 ns

## four V-04
PASS_XSIM `UART_R2_U31_TWO_V04_XSIM_PASS four GOLD` at 9666815 ns

Overlay: ui_req/cdc_rst without S_ACK; drain 64 ui cycles before debug_clear; qsc uses dest app_rdy. PACKAGE live bind/clear_ui not overwritten. U30 frozen.
