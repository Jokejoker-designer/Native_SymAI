# D-PACK-SILICON-FIRST-DIVERGENCE-01 — H14 reset-domain table (RTL, not board proof)

Not PACK_ABI_24_24_PASS / BOARD_PASS. Identity H `cf62102f`. No Identity I.

`ck_rst` (JP2/CK_RST) feeds `rst100_n = ck_rst & clk_locked` and `sys_rst_i` into mig0. CLEAR does not drive `ck_rst`.

| STATE | OWNER | CLOCK | PROGRAM_RESET | CK_RST_RESET | CLEAR_RESET | PACK_MODIFIES | PERSISTS_AFTER_CLEAR |
|---|---|---|---|---|---|---|---|
| UART RX bit/byte FSM, `bix` | uart_rx_word | clk100 | YES `rst100_n` | YES | YES if `uart_flush` (S_CDC/S_QUIET) | YES | NO after successful CLEAR path; YES if CLEAR BUSY (no flush) |
| word assembler `acc` | uart_rx_word | clk100 | YES | YES | flush | YES | same as row above |
| FIFO wr/rd/occ | word_fifo32 | clk100 | YES `rst100_n` | YES | flush | YES | NO after flush CLEAR; dest payload not in this FIFO |
| CDC `req_a`/`hold` RX path | word_cdc32 u_cdc | clk100→ui_clk | `rst100_pack_n` / `rst_ui_pack_n` | indirect (sys) | `cdc_rst_100` then `debug_clear` | YES | designed NO after S_CDC; UNKNOWN if CLEAR never takes |
| CDC TX status | word_cdc32 u_cdc_tx | ui→clk100 | pack rst | indirect | pack rst | YES | UNKNOWN if mute is TX-side |
| pack_lock | top | clk100 | YES | YES | flush or cdc_rst | YES BEGIN opcode | NO after successful CLEAR; YES if CLEAR never flush |
| pack_debug_clear FSM | pack_debug_clear | clk100 | YES `rst_n` only | YES | self | YES | **FACT RTL: never reset by debug_clear** |
| pack_clear_ui | pack_clear_ui | ui_clk | `rst_ui_n` | via MIG ui_rst | self | CLEAR req | — |
| pack_loader / mig_ui32 `rst_loc` | pack_mig_bind | ui_clk | `rst_ui_n` then `rst_loc<=~debug_clear` | via MIG | YES debug_clear | YES | NO after successful CLEAR |
| dest BRAM/DDR contents | mig0 / ui | ui_clk | YES program | MIG sys_rst | **NO** | YES | **YES (SENTINEL class)** |
| calib_done / MIG FSM | mig0 | ui_clk | YES | YES sys_rst | NO | maybe stalls | YES vs CLEAR |
| response mux / uart_tx_word | top / uart_tx_word | clk100 | YES | YES | flush | YES | flush during CLEAR can abort TX |

Prime sticky-mute candidates (program restores, Pack can dirty, CLEAR may not):

1. dest persist (already named SENTINEL; not n=0 by itself)
2. pack_debug_clear FSM if stuck off IDLE without taking new CLEAR
3. CDC leftover if CLEAR BUSY skips S_CDC
4. MIG outstanding / ui_busy so pack_quiescent=0 → CLEAR BUSY forever, or TX mux starve
5. uart_tx_word stuck if flush/ready history (H3 local, not sufficient)

This table is RTL_FACT / INFERENCE. Not ROOT_CAUSE_STICKY_MUTE.
