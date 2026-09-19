# U18 BUILD_MANIFEST — product path generated mig0

IDENTITY = UART_R2_U18_PACK24_CANDIDATE
Vivado = 2026.1 SW Build 6511674
part = xc7a100tcsg324-1
top = arty_a7_r2_top_m4_mig_candidate (U17 overlay reused)
CLEAR = UART_R2/u18/pack_debug_clear.sv
RX = UART_R2/u11/uart_rx_word.sv
TX = UART_R2/u14/uart_tx_word.sv
dest = generated mig0 (not mig_ui_bram)
XDC = arty_a7_mig.xdc + arty_a7_mig_cdc.xdc + arty_a7_mig_clear_cdc.xdc + mig0.xdc

BIT = D:/FPGA/arty_d/UART_R2/build_u18/uart_r2_u18_candidate.bit
BIT_SHA256 = aca343792c09feaaef3ab5dcbb6326f784d7ef80ac518bff15b32513a7238949
DCP = D:/FPGA/arty_d/UART_R2/build_u18/post_route.dcp
DCP_SHA256 = afca676ad8f54c97a6d811244a684eb4258c2e551007441372851ef026e23bde
CLEAR_SHA256 = 0847962fe199653ca9410606b8421dfde27f0847fa0c2f428df7d7ba71efd18c

WNS = +0.498 ns (observation)
WHS = +0.014 ns (observation)
TNS = 0.000
THS = 0.000
LUT = 11173
FF = 9945
RAMB = 5 tiles
DSP = 8

TIMING_PASS = NO (not self-stamped)
MIG_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
Not identity H / U17 bit. Freeze DCPs not overwritten.
