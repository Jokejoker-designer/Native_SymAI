# E ILA plan — ANALYSIS_ONLY. Do not program. Not BOARD_PASS.

Artix-7 (not Versal). Debug hub clock = clk100 (free-running 100 MHz). JTAG must be < 40 MHz (2.5x rule).

XSim 20260917T055616Z already split snapshot flood vs live formula. ILA is for **board mute** and **uart_rx leftover** on whichever identity is actually in SRAM. Identity H `cf62102f` is on disk only. E does not GRANT.

## Core choice (UG908)

| Need | Core |
|---|---|
| Capture handshake at 100 MHz | ILA v6.2 on clk100 |
| Capture UI debug_clear / loader state | ILA v6.2 on ui_clk + TRIGIN from clk100 ILA |
| Live status without waveform | VIO on clk100: `clr_hold`, `fifo_empty`, `pack_lock`, `used[8:0]` |
| AXI into mig0 | Not needed for CLEAR mute; JTAG-to-AXI skipped |

Flow: **TCL netlist insertion after synth** (do not `mark_debug` C RTL). Owner-authorized debug bit only. Do not overwrite freeze DCP or historical `f6a6091f`.

## clk100 ILA

- C_DATA_DEPTH: 4096 (protocol). 1024 first if BRAM tight (CLEAR candidate already RAMB36=4).
- C_ADV_TRIGGER: true (state: take → hold&&w_valid → used==128)
- C_INPUT_PIPE_STAGES: 1 (timing)
- C_TRIGOUT_EN: true → ui ILA TRIGIN
- Probe Data+Trigger: `w_valid w_ready w_data[31:0] clr_take clr_hold uart_flush cdc_rst_100 fifo_wr_ready f_valid f_ready fifo_empty pack_lock q_taking qsc_100 uart_tx_valid mux_ready clr_ack_valid st_valid_100 rx_idle`
- Probe Data: `u_clr.st[3:0] u_rfifo.used[8:0] f_data[31:0] st_data_100[31:0] mux_data[31:0]`
- Trigger only: `uart_rx uart_tx` if BRAM tight skip data

Trigger A: `clr_take == 1`
Trigger B: `clr_hold && w_valid` (leftover sitting in uart_rx)
Trigger C: `used == 128`
Trigger D: `clr_ack_valid` (did CLEAR ACK reach mux?)
Trigger E: `st_valid_100` (pack NAK/ACK CDC)
Trigger F: `!q_taking && f_valid` (H10 query taking gap → pack/CDC)

Also probe `u_rx.st` / `w_valid && !w_ready` for STOP-drop (RTL_FACT, not XSim’d). Do not insert ILA into freeze FE256 top.

## ui_clk ILA

Probes: `debug_clear rst_ui_pack_n load_ack load_reject reason_code[7:0] s_valid s_ready s_data[31:0] pack_quiescent wr_outstanding[15:0]`
C_TRIGIN_EN: true
C_DATA_DEPTH: 1024

## Do not

- Program this bit without BOARD_LEASE_GRANT
- Insert ILA into freeze top
- Increase dedicated FE256 LUT/BRAM
