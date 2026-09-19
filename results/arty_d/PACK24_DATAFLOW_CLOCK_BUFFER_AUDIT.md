# PACK24 DATAFLOW / CLOCK / BUFFER ROOT AUDIT

OWNER: AGENT_D
DATE: 2026-09-19
RUN_ID: 20260919T050700Z
CONSTRAINTS: NO RTL edit, NO overlay, NO program, NO UART change, NO dest_accept change, NO dest_ui_* product strip.
CLAIM CEILING: not PACK_ABI_24_24_PASS / BOARD_PASS / MIG_PASS / TIMING_PASS / PROGRAM_PASS.
SCOPE: live U32 product path `D:/FPGA/arty_d/UART_R2/u32/` plus PACKAGE live bind without dest_ui AND.

## O. One sentence

Pack24 fails because the system uses MIG cycle-accept (`app_rdy` / `app_wdf_rdy`) as dest-idle/quiescent; the same UART/CDC/MIG dest path GOLD-completes in XSim when `dest_ui_*` are forced 1, so uneven clock rates are not the unique root.

## 1. ACTUAL_DATA_PATH

```
Host 8N1 @115200
  -> uart_rx pin (async)
  -> uart_rx_word 2FF + baud CE assembler     [clk100]
  -> w_valid/w_ready
  -> pack_debug_clear intercept (CLEAR token) [clk100]
  -> word_fifo32 DEPTH=128                    [clk100]
  -> rd_valid/rd_ready + steer_pack/lock
  -> word_cdc32 toggle handshake              [clk100 -> ui_clk]
  -> pack_mig_bind.pack_loader s_*            [ui_clk]
  -> page_ram[64] then mem_cmd_*
  -> mig_ui32                                 [ui_clk]
  -> mig_ui_mux grant A (else G_NONE a_rdy=0) [ui_clk]
  -> generated mig0 app_*                     [ui_clk]
  -> DDR3 PHY (ddr3_ck)

Readback / status:
  mig0 app_rd_data_valid
  -> mig_ui32 S_WAIT compare -> S_RSP
  -> pack_loader S_COMMIT load_ack
  -> harness st_valid_ui (ack/nak edge)
  -> word_cdc32 status                       [ui_clk -> clk100]
  -> uart_tx_word                            [clk100 + baud CE]
  -> uart_tx pin -> Host

CLEAR control (not payload):
  pack_debug_clear SAMPLE pack_quiescent=qsc_100
  -> ui_req 2FF -> pack_clear_ui(pack_quiescent=qsc_ui)
  -> ack/nack 2FF back to clk100
```

### Hops (U32 product)

HOP H0: Host line -> uart_rx
FILE: `arty_d/UART_R2/u32/arty_a7_r2_top_m4_mig_candidate.sv` port `uart_rx`
SOURCE CLOCK: async
DEST CLOCK: sampled in uart_rx_word on clk100
DATA WIDTH: 1 bit
VALID/READY: UART framing
BUFFER: none
RESET: n/a
WHO OWNS: host
CONSUMED: STOP bit sample
CLASS: FACT

HOP H1: uart_rx_word
FILE: `CANON_BLUEPRINT/rtl/native_ai/board/uart_rx_word.sv` (live copy used by U32)
SOURCE CLOCK: clk100; bit timing = DIV=CLK_HZ/BAUD clock-enable
DEST CLOCK: clk100
DATA WIDTH: 32
VALID: `w_valid`
READY: `w_ready` from harness `clr_take || (!clr_hold && fifo_wr_ready)`
BUFFER: 1 assembled word (`w_data` / `acc`)
RESET: `rst_n`, `flush`
WHO OWNS: RX FSM until `w_valid && w_ready`
CONSUMED: `if (w_valid && w_ready) w_valid <= 0`
HOLD ON READY=0: YES for an already-raised `w_valid`
CRITICAL DROP: 4th STOP if `w_valid && !w_ready` skips emit (`bix==3`) then IDLE
CLASS: FACT

HOP H2: word_fifo32
FILE: `CANON_BLUEPRINT/rtl/native_ai/board/word_fifo32.sv`
SRC=DST: clk100
WIDTH: 32
VALID: `rd_valid`
READY: `wr_ready` / `rd_ready`
BUFFER: DEPTH=128 LUTRAM (`ram_style distributed`)
RESET/FLUSH: `flush` from CLEAR / status fire
CONSUMED: `rd_valid && rd_ready`
HOLD: YES while empty/full flags
CLASS: FACT

HOP H3: steer
FILE: `UART_R2/u32/pack_uart_dualclk_harness.sv` (top duplicates same wires)
SRC=DST: clk100
`dest_accept = qsc_c1 && rst100_pack_n`
`steer_pack = pack_lock || (f_valid && pack_begin && dest_accept)`
`f_ready = steer_pack ? cdc_a_ready : ((f_valid && pack_begin && !dest_accept) ? 0 : 1)`
NON-BEGIN when !steer_pack: `f_ready=1` → FIFO pop discarded
BEGIN when !dest_accept: `f_ready=0` → hold in FIFO
CDC a_valid gated: `f_valid && !q_taking && !clr_take && !clr_hold && steer_pack`
CLASS: FACT

HOP H4: word_cdc32 payload
FILE: `CANON_BLUEPRINT/rtl/native_ai/board/word_cdc32.sv`
SRC: clk100 (`a_*`) DST: ui_clk (`b_*`)
WIDTH: 32 `hold`
`a_ready = a_rst_n && (req_a == ack_a1)` — 1 in-flight
TRANSFER: `a_valid && a_ready` toggles `req_a` and captures `hold`
DELIVER: `b_valid` until `b_ready`
HOLD ON READY=0: YES (req stays until ack)
BUFFER: 1 word
XSIM: `WORD_CDC32_XSIM_RESULT.json` a=12 ns b=10 ns 2/2 vectors
CLASS: FACT

HOP H5: pack_loader
FILE: `CANON_BLUEPRINT/rtl/native_ai/loader/pack_loader.sv`
CLOCK: ui_clk
WIDTH: 32
VALID/READY: `s_valid`/`s_ready`
`s_ready` only IDLE/RX/REJECT/EDRAIN and !crc_busy
BUFFER: `PAGE_RAM_WORDS=64`
CONSUMED: `s_valid && s_ready`
WHO OWNS: loader FSM; `loader_busy` except IDLE/OK/REJECT
CLASS: FACT

HOP H6: mig_ui32
FILE: `CANON_BLUEPRINT/rtl/native_ai/memory/mig_ui32.sv`
CLOCK: ui_clk
`mem_cmd_ready = (st==S_IDLE) && calib_done && rst_n` — NOT app_rdy
Then S_WR waits `app_en && app_rdy` and `app_wdf_wren && app_wdf_rdy`
BUFFER: one command (`wdata_r`/`beat_r`); `wr_outstanding` counter
`ui_busy = (st != S_IDLE)`
CLASS: FACT

HOP H7: mig_ui_mux
FILE: `CANON_BLUEPRINT/rtl/native_ai/memory/mig_ui_mux.sv`
CLOCK: ui_clk
G_NONE: `a_rdy=0`, `a_wdf_rdy=0` (defaults then empty case)
G_A: `a_rdy = d_rdy`
Idle pack: grant G_NONE so pack `app_rdy` pin (`p_rdy`) is 0
CLASS: FACT

HOP H8: generated mig0
FILE: top instantiates `mig0`; `sys_clk_i=clk_sys166`, `clk_ref_i=clk_ref200`
UI CLOCK: `ui_clk` out of mig0
`app_rdy` = MIG can accept command THIS CYCLE (UG586)
`app_wdf_rdy` = MIG can accept write-data beat THIS CYCLE
U32 top: `dest_ui_rdy(app_rdy)`, `dest_ui_wdf_rdy(app_wdf_rdy)` — raw mig0, not mux `a_rdy`
CLASS: FACT

HOP R1–R4: readback compare in mig_ui32 S_WAIT; load_ack in pack_loader S_COMMIT; status CDC; uart_tx_word holds `w_ready=0` while serializing (`acc`).
CLASS: FACT

## 2. CLOCK_DOMAIN_MAP

| Clock | Frequency | Source | Relation to clk100 | CE vs async CDC |
|---|---|---|---|---|
| clk100 | 100 MHz | pin CLK100MHZ | self | system |
| clk_sys166 | 166.667 MHz | `clk_arty_mig` MMCM CLKOUT0 DIV 6 after ×10, CLKIN 10 ns | same MMCM, deterministic ratio, different net | MIG sys only |
| clk_ref200 | 200 MHz | same MMCM CLKOUT1 DIV 5 | same MMCM | IDELAYCTRL |
| ui_clk | 83.333 MHz (period 12.000 ns) | mig0 internal PLL; nCK_PER_CLK=4 (`mig_uiclk` timing + synth bind) | independent PLL, asynchronous phase | MUST CDC for pack data |
| ddr3_ck | 333.33 MHz | MIG PHY (INFERENCE from 667 MT/s / nCK=4) | async to clk100 | PHY |
| UART baud tick | 115200 (product) | `DIV=CLK_HZ/BAUD` on clk100 | clock-enable | already CE |

clk100 vs ui_clk: TRULY INDEPENDENT after MIG PLL. Ratio ~10 ns : 12 ns is stable in the CDC TB (`WORD_CDC32_XSIM_RESULT.json`) but phase is not locked to the board oscillator in a way that allows `clk100 + CE` to replace `ui_clk` on `app_*`.

Do not replace ui_clk with 100 MHz + dummy cycles: receiver is the MIG UI contract on ui_clk.

## 3. BUFFER_MAP

| Stage | Depth | Clock | Notes |
|---|---|---|---|
| uart_rx_word | 1 word | clk100 | drop if 4th byte and prior word not taken |
| word_fifo32 | 128 | clk100 | LUTRAM; flush on CLEAR/status |
| word_cdc32 | 1 | dual | handshake, not Gray FIFO |
| pack_loader page_ram | 64 words | ui_clk | PAGE opcode payload |
| mig_ui32 | 1 cmd | ui_clk | no cmd FIFO |
| mig0 | IP internal | ui_clk/PHY | UNKNOWN depth without MIG report |
| uart_tx_word | 1 word | clk100 | `w_ready=0` during serialize |

Producer UART 115200 8N1: 115200/10/4 ≈ 2880 words/s ≈ 347 µs/word.
Consumer ui_clk 83.3 MHz when MIG ready: orders of magnitude faster.

TIME_TO_FULL ≈ 128 × 347 µs ≈ 44 ms at 115200 if consumer stopped.
app_rdy low 100 ns / 1 µs / 10 µs / 100 µs: NO drop; FIFO/backpressure holds.
Drop only if stall > ~FIFO fill time AND RX presents a 4th byte while `w_valid` stuck.

## 4. CDC_MAP

| ID | Signals | Dir | Primitive | Verdict |
|---|---|---|---|---|
| C1 | `req_a`,`hold[31:0]`,`ack_b` | clk100→ui_clk | toggle + 2FF req/ack | SAFE exact-once, depth 1 |
| C2 | status word_cdc32 | ui_clk→clk100 | same | SAFE; BUSY path resets TX CDC (lifecycle) |
| C3 | `qsc_ui_r` → `qsc_c0`/`qsc_c1` | ui_clk→clk100 | 2FF level | SAFE copy of level; UNSAFE meaning |
| C4 | `clr_ui_req` → `req_u0`/`req_u1` | clk100→ui_clk | 2FF | SAFE if req held (it is) |
| C5 | `ack`/`nack` 2FF | ui_clk→clk100 | 2FF | SAFE if held through SAMPLE/REQ |
| C6 | `uart_rx` → `rx_s`/`rx_d` | async→clk100 | 2FF | SAFE |
| C7 | `app_rdy` into `pack_quiescent` | same ui_clk then C3 | AND then 2FF | CDC does not corrupt; semantic wrong |

1-cycle pulse miss: payload CDC does not use a 1-cycle pulse; `a_ready` stays 0 until ack. qsc is a registered level. A 24 ns `app_rdy` dip (OBS01) is 2 ui_clk cycles and is visible after 2FF onto clk100. Slow side missing a fast pulse is CONTRADICTED for this qsc path.

## 5. FIRST_POSSIBLE_DROP_POINT

1. Silent data drop (always present in RTL): `uart_rx_word` STOP `bix==3` skip emit if `w_valid && !w_ready`. NOT evidenced as Pack24 CLEAR1 root (CLEAR fails before BEGIN ingest).
2. Intentional discard: FIFO pop of non-BEGIN when `!steer_pack`.
3. Intentional flush: FIFO `flush` on CLEAR/status.
4. Pack24 U32 CLEAR1: **not a word drop**. `pack_debug_clear` SAMPLE_N=8 sees `!qsc_100` → token `32'hC1EA50B5` BUSY. BEGIN never `steer_pack`.

FIRST CAUSAL DEFECT (CLEAR1 class):
`pack_quiescent` in U32 `pack_mig_bind.sv` ANDs `dest_ui_rdy && dest_ui_wdf_rdy` where those nets are `mig0.app_rdy` / `app_wdf_rdy` (cycle accept), while mux G_NONE already zeros pack `p_rdy`. Idle dest still toggles accept-ready → qsc false → 2FF → SAMPLE BUSY.

PACKAGE-qsc TB forces dest ready 1 → CLEAR1 ACK `c1ea50a5`, GOLD1/GOLD2 `010000a5`, Q4 NEW_COMMIT, `$finish` 4958414625 ps. Same UART/CDC/MIG dest. CDC did not invent BUSY.

## 6. PACK24_CURRENT_CAUSAL_CLASS

| Class | Rating |
|---|---|
| A BANDWIDTH LIMIT | CONTRADICTED (Pack24 UART vs 83 MHz + FIFO 128) |
| B UART BAUD/TIMING | SUPPORTED as wall-time; CONTRADICTED as unique loss root |
| C CLOCK RATIO | CONTRADICTED as unique root (PACKAGE-qsc same clocks) |
| D CDC EVENT LOSS | CONTRADICTED for CLEAR1/GOLD class |
| E BUFFER OVERFLOW | NOT TESTED on board GOLD (CLEAR1 first) |
| F READY/VALID PROTOCOL | CONFIRMED (`app_rdy` used as idle) |
| G RESET/LIFECYCLE | SUPPORTED (cdc_rst, dest_accept, TX CDC reset on BUSY) |
| H QUIESCENCE SEMANTICS | CONFIRMED (U32 BUSY vs PACKAGE-qsc ACK+CLEAN) |
| I MIG CMD/WDF HANDSHAKE | POSSIBLE after ACK (leftover); CONTRADICTED as CLEAR1 unique root |
| J OTHER | POSSIBLE board-only identity H; NOT TESTED this audit |

Do not merge READY / IDLE / QUIESCENT / COMPLETE / COMMITTED.

## 7. MINIMAL_ARCHITECTURE_OPTIONS (no code)

Option A: keep word_fifo32 + word_cdc32; redefine quiescence to loader/ui/outstanding/reset only. Do not product-strip dest_ui_* without owner overlay identity. Do not change dest_accept.

Option B: deeper async FIFO clk100→ui_clk. Not required for Pack24 UART rate. word_cdc32 already exact-once. Add only if Ethernet/burst producer exceeds 128+1 absorption.

Option C: ping-pong. Pack24 (~52 words) already fits PAGE_RAM 64. Whole-pack double buffer ≈ 2×52×4 B LUTRAM/BRAM — not a CLEAR1 fix. Chunk ping-pong is a later Ethernet option.

## 8. NEXT_DECISIVE_EXPERIMENT

1. Do not rerun dest-AND vs PACKAGE-qsc as if unknown: that pair already splits H/F vs C/D.
2. On any remaining BUSY capture: log `dest_ui_rdy`, `loader_busy`, `ui_busy`, `wr_outstanding`, `qsc_ui`, `qsc_100` in the SAMPLE window. dest_ui=0 with others idle → H/F. dest_ui=1 with qsc_100=0 → extra `qsc_100` terms (`cdc_a_idle` etc.).
3. Conservation counters `N_FIFO_PUSH` vs `N_PACK_S_ACCEPT` vs RX skip — only on an ACK/GOLD path. Harness already has `fifo_wr_fire` / `fifo_rd_fire` / `p_fire`.

## Ready meaning (do not upgrade)

- `uart w_ready`: RX may complete a 32-bit word this cycle without skip-drop.
- `fifo wr_ready`: used != DEPTH and not flush.
- `fifo rd_ready` (f_ready): consumer will pop this cycle (including discard).
- `cdc a_ready`: no in-flight toggle; may accept a new word.
- `cdc b_ready`: pack `s_ready` this cycle.
- `pack s_ready`: loader in IDLE/RX/REJECT/EDRAIN and !crc_busy — not “MIG idle”.
- `mem_cmd_ready`: mig_ui32 S_IDLE and calib — not app_rdy.
- `app_rdy`: MIG can accept a command this ui_clk cycle.
- `app_wdf_rdy`: MIG can accept a WDF beat this ui_clk cycle.
- `pack_quiescent` U32: AND of idle-ish bits PLUS dest cycle-ready (semantic mix).
- `qsc_100`: `qsc_c1 && cdc_a_idle && tx_b_idle && !st_valid_100 && !uart_tx_valid` — extra transport idle, not dest-idle alone.
- `dest_accept`: `qsc_c1 && rst100_pack_n` — not `qsc_100`.

## Accounting (instrument)

Present: `fifo_wr_fire`, `fifo_rd_fire`, `p_fire` in U32 harness.
Absent as named N_*: UART complete, CDC accept/deliver, MIG cmd/wdf, commit.
PACKAGE-qsc GOLD2 proves 52-word dest path can conserve when CLEAR is ACK. Board Pack24 CLEAR1 never reaches that invariant.

## Claim ceiling

PACK_ABI_24_24_PASS = NO
BOARD_PASS = NO
This audit is RTL+XSim causal map only.
