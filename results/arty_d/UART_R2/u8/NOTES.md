# UART_R2_U8 — CLEAR CDC overlap + ACK handshake

Identity != H, != U3 RX. New bit under `build_u8` only.

## What must change in RTL

| File | Change | Why |
|---|---|---|
| `pack_debug_clear.sv` (this dir) | `cdc_rst_100` = S_CDC\|S_QUIET\|S_ACK | PACKAGE only resets CDC A 4 cycles; UI `debug_clear` holds B until req drops. Toggle CDC A-live/B-reset is a desync class. |
| `pack_debug_clear.sv` | S_ACK/S_BUSY/S_ERR wait `ack_ready` only | PACKAGE DROP after 65535 cycles (~0.66 ms) without handshake. |
| `uart_rx_word` U3 | **no change** | First CLEAR ACK already works with U3 RX. |
| AGENT_C qstar/spear/fem | **no change** | MODE ON_DEMAND. |
| `uart_tx_word` flush-abort | **not this identity** | Separate G3 class. Do not mix. |

## Exact root cause?

| Claim | Class |
|---|---|
| Identity H silicon root | UNKNOWN |
| First CLEAR ACK under T1 recipe | FACT (U3 board) |
| V-04 after ACK → n=0 12 s; CLEAR2 n=0 ≠ BUSY | FACT (board) |
| PACKAGE `cdc_rst` not overlapping UI `debug_clear` | FACT (RTL) |
| PACKAGE ACK timeout-without-ready | FACT (RTL) |
| Those two **are** the silicon root of V-04 mute | HYPOTHESIS (U8 is the decisive test) |

Do not stamp BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS / MIG_PASS.
