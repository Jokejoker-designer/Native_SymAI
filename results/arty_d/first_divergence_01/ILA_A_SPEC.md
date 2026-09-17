# ILA-A spec — NOT synthesized (would be a new bitstream; Identity I not authorized)

H9 A/B, H10, H11 UART logged. H17/H11 XSim on BRAM dest GOLD (silicon CLASS A not in that model).

Preferred silicon ILA sequence (JP2 removed, bit H):
H11 V-04: ACK → PACK UNSUP → ACK GOLD → ACK MAG → ACK GOLD → CLEAR UNSUP → CLEAR n=0.

PASS_XSIM CLASS A: one extra RX byte then CLEAR → `0200075a` UNSUP (`52474300`). extra 2–3 → MUTE. Probe `uart_rx_word.bix`, `clr_take`, `w_data`.

Probe also: `loader_busy`, `pack_quiescent`, `debug_clear` vs CLEAR BUSY path, `s_ready` in S_RX (CLEAR word can be eaten as payload). Do not assume leftover CLEAR in FIFO (`n_cmd_fifo=0` on complete-pack 115200 XSim).

Do not `mark_debug` until owner authorizes a debug bitstream (not a product Identity I).

Trigger: CLEAR after N Pack ops, or `clr_take==0` after CLEAR word `44524743`.

clk100 probes (ingress → CLEAR):

- uart_rx (pin) if available
- u_rx.w_valid, w_ready, w_data, bix if visible
- fifo wr_valid/wr_ready/wr_data, empty
- clr_take, clr_hold, uart_flush, cdc_rst_100
- pack_lock

Do not add ILA-B/C until ILA-A shows CLEAR word reached (or not).
