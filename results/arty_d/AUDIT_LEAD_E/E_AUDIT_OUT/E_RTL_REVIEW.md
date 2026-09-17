# AGENT_E full RTL inference audit — no board

```text
TASK_ID: D-PACK-VALIDATION-RESET-01 / E-RTL-FULL-AUDIT
RUN_ID: 20260917T055616Z
OWNER_AGENT: AGENT_E
MANDATE: ANALYSIS_ONLY + XSim/ILA-plan allowed; BOARD forbidden
XSIM: E_RTL_AUDIT_XSIM_PASS 8 at 7705 ns (local TB label only)
NOT: PACK_ABI_24_24_PASS / BOARD_PASS / TIMING_PASS / MIG_PASS / PROGRAM_PASS
     FE256_PASS / ASTRA_PASS / PACK_VALIDATION_CLEAR_PASS
BOARD_LEASE: FREE. E does not GRANT. Identity H bit not programmed.
C_RTL_MODIFIED: false
freeze_dcp_overwritten: false
```

Using **vivado-debug** (ILA/VIO plan, no program) and **multi-agent** (E lead; directory/FEM specialists in parallel). One writer: E_AUDIT_OUT only. No synthesizable RTL patch this wake.

---

## 0. Claim ceiling

Independent XSim **confirms structural defects** on snapshot handshake (identity D SRAM `bbba86c1`) and **confirms D’s live-source handshake formula stops FIFO flood**. Live formula is **not** on SRAM. Board mute root remains **UNKNOWN**.

---

## 1. Inventory

| Set | Count | Role |
|---|---|---|
| Snapshot `AUDIT_LEAD_E/snapshot/.../rtl` | 17 | Identity D CLEAR candidate sources (programmed) |
| Live PACKAGE `CANON_BLUEPRINT/rtl/native_ai` | 38 | Includes handshake patch + directory/FE256/FEM extra |
| C-owned | 3 | Hash-only; do not edit |

C hashes re-checked MATCH locked:

| File | SHA256 |
|---|---|
| `qstar_select.v` | `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240` |
| `spear_rank.v` | `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293` |
| `fem_lifecycle.v` | `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` |

Snapshot and live C copies identical. `spear_profile_bind` `K_HARD_MAX=8` → NSLOT=9. `theta_addr[5:0]` = 64. FEM `ing_valid=0` on M4+mig candidate. **C_SCALE_GUARD not tripped.** Do not rewrite C memory to BRAM.

Snapshot top instantiates `query_result_bind` (live directory; not in the 17-file snapshot tree). Dedicated `fe256_query_path` is **not** in the M4+mig candidate top.

---

## 2. XSim command and result (FACT)

```text
cmd /c D:\FPGA\arty_d\AUDIT_LEAD_E\E_AUDIT_OUT\run_xsim_e_rtl.bat
xvlog/xelab/xsim 2026.1 → E_RTL_AUDIT_XSIM_PASS 8  $finish 7705 ns
log: E_AUDIT_OUT/xsim_e_rtl/xsim.log
NDJSON: D:/FPGA/debug-463f7f.log
DUT: snapshot pack_debug_clear + pack_clear_ui + word_fifo32 + pack_loader
     + live crc32_iso_hdlc.sv
No mig0. No JTAG. Not PACK_ABI_24_24_PASS.
```

| Test | Hypothesis | Result | NDJSON |
|---|---|---|---|
| T1 snapshot hold, no pop | H3 flood | **CONFIRMED** `max_used=128` `wr_nready=172` `hold=1` | T1 result ts=3135 |
| T1b live formula same stimulus | H3 patch | **CONFIRMED** `used_live=0` | same line `max_used_live:0` |
| T2 snapshot hold, pop | H3 void-pop | **CONFIRMED** `max_used=1` `pops=199` | T2 ts=5235 |
| T3 snapshot pack fill 129 | H3 silent drop | **CONFIRMED** used=128 **`w_ready=1`** | T3 + `$display` |
| T3b live fill 129 | H3 backpressure | **CONFIRMED** used=128 **`w_ready_live=0`** | T3 `w_ready_live:0` |
| T4 leftover `44524743` | H2 R_UNSUP | **CONFIRMED** reject=1 reason=`07` | T4 ts=6755 |
| T5 MAGIC `3149414E` as opcode | H2 | **CONFIRMED** reject=1 reason=`07` | T5 ts=6905 |
| T6 S_REJECT 2nd CLEAR | H5 mute-class | **CONFIRMED** `load_reject=1` `new_ack=0` `busy=0` | T6 ts=7705 |

Two handshake formulas in one TB:

```text
SNAPSHOT (SRAM bbba86c1): wr_valid=w_valid&&!clr_take
                          w_ready=clr_take||!clr_hold
LIVE source (not programmed): wr_valid=w_valid&&!clr_take&&!clr_hold
                               w_ready=clr_take||(!clr_hold&&fifo_wr_ready)
```

D already reported `PACK_HOLD_FLOOD_XSIM_PASS HOLD_WR_MAX=0` on live. E independently reproduces the same formula split. **Identity H** `cf62102f…` on disk, SRAM still D. E **does not GRANT**.

---

## 3. Hypothesis board after XSim

| ID | After this run |
|---|---|
| H1 gold packing hang-root | **REJECTED** (unchanged) |
| H2 leftover/misaligned opcode → R_UNSUP | **CONFIRMED** PASS_XSIM T4/T5. Board V-02 injector still **UNKNOWN** |
| H3 snapshot FIFO flood / silent drop | **CONFIRMED** PASS_XSIM T1/T3 |
| H3 live formula stops flood + backpressures UART | **CONFIRMED** PASS_XSIM T1b/T3b. **Not on SRAM** |
| H4 V-03 SENTINEL dest persist | **SUPPORTED** (CLEAR does not wipe dest; not re-XSim dest here) |
| H5 CLEAR UART mute (`got=None`) | Symptom **FACT**. Root **UNKNOWN** without ILA/raw UART. T6 is **pack-status** mute-class, not CLEAR ACK |
| H6 QMAGIC steal | **WEAKENED** this campaign |
| H7 STALE_INDEX | **CONFIRMED** earlier; D later wrote JSON `bbba86c1` — re-check if claiming index |
| uart_rx STOP drop | **RTL_FACT** (`!w_valid \|\| w_ready` else drop word, reset bix). Not in this TB |

---

## 4. Module-by-module (snapshot CLEAR path)

### 4.1 `arty_a7_r2_top_m4_mig_candidate.sv`

- UART: `uart_rx_word` → CLEAR sniff → `word_fifo32` → `uart_fe256_host` if `[15:0]==0x4E51` && !pack_lock else `word_cdc32` → `pack_mig_bind` → `mig_ui_mux` vs FEM → `mig0`.
- Snapshot handshake: **H3**. Live file patched (see §2).
- `qsc_100 = qsc_c1 && cdc_a_idle && tx_b_idle && !st_valid_100 && !uart_tx_valid` — **omits** `fifo_empty` / `pack_lock` / `used`. **FACT**. Leftover can sit in FIFO while CLEAR samples quiescent.
- `pack_lock` set on BEGIN (`f_data[7:0]==8'h01`) pop; cleared on flush/CDC rst/status consume.
- TX mux: CLEAR ACK > query TX > pack status. `clr_ack_ready = mux_ready && !uart_flush`.
- C cores `keep_hierarchy`: Q*/SPEAR/FEM **tied off** (`prop_start=0`, `q_start=0`, `ing_valid=0`). Not on pack UART path.
- `query_result_bind` `s_valid=0` — hop-1 fail-closed SEARCH_INCOMPLETE (UART smoke 0x04/0x20). Not ASTRA_PASS.
- `debug_clear` resets loader+`mig_ui32` via `rst_loc`, **not** dest BRAM/DDR/`mig0`.

### 4.2 `pack_debug_clear.sv`

- `take` 1-cycle IDLE+CMD. `hold=(st!=IDLE)`.
- `uart_flush` registered S_CDC\|\|S_QUIET. ACK after quiet (~20000 clk @100 MHz) then DROP.
- If `ui_ack` never (stall / CDC lost): S_REQ until TO_N=65535 → ERR `C1EA50E5`. Host looking only for `C1EA50A5` can classify as mute. **HYPOTHESIS** for mute, not proven on board.
- Controller never self-resets on `debug_clear` (comment). **FACT**.

### 4.3 `pack_clear_ui.sv`

- 4-phase. `debug_clear` held until 100-side drops `req`. NACK if !`pack_quiescent`.
- Does not reset `mig0`. Dest persist = contract.

### 4.4 `word_fifo32.sv`

- DEPTH=128 LUTRAM. `wr_ready=rst_n && !flush && used!=DEPTH`.
- Flush zeros pointers. Writes ignored while flush.

### 4.5 `uart_rx_word.sv` — **RTL_FACT remaining after live handshake patch**

On STOP of 4th byte: new word accepted only if `!w_valid || w_ready`. During `clr_hold`, live `w_ready=0` (no take). First post-CLEAR UART word can sit in `w_valid`; **later bytes of later words are dropped** (`bix` still clears). After hold ends, leftover `w_data` is the first held word — **H2 injector** even if FIFO no longer floods.

### 4.6 `uart_tx_word.sv`

- Flush aborts in-flight TX (`st<=IDLE`). By design ACK is after QUIET so flush is low in S_ACK. If ACK overlaps leftover flush (older identities), ACK swallow. Live gates `clr_ack_ready` with `!uart_flush`.

### 4.7 `word_cdc32.sv`

- Toggle CDC. Split reset: `rst100_pack_n` ~4 cycles S_CDC; `rst_ui_pack_n` follows `debug_clear` until UI ACK drop. **HYPOTHESIS**: `req_a`/`last_b` desync → stuck `a_ready` or sticky `b_valid`. Not XSim’d with real two clocks this TB (single clk).

### 4.8 `pack_loader.sv` / `pack_mig_bind.sv`

- Opcode `[7:0]` `{01,02,03,04}` else `R_UNSUP` → S_EDRAIN → **S_REJECT absorbing**.
- `s_ready` stays 1 in S_REJECT (drain ABI-24). Incoming words **consumed with no new `load_ack` edge**. T6 **CONFIRMED**. Pack status FF is edge on `load_reject`; sticky 1 → **no second NAK** on UART.
- `loader_busy` false in S_REJECT → `pack_quiescent` can be 1 while stream is eaten.
- `debug_clear` → `rst_loc` FF (LUTAR-1 avoidance). Does not clear dest.

### 4.9 `uart_fe256_host.sv`

- Steals FIFO if `in_data[15:0]==16'h4E51`. Gold only R-04 has `03014e51`. Campaign never reached R-04. H6 WEAKENED.
- `taking` combinational on IDLE+QMAGIC; `f_ready` switches to `qh_in_ready`. If QMAGIC false-positive mid-pack, CDC starved. **HYPOTHESIS** for other campaigns.

### 4.10 `mig_ui32` / `mig_ui_mux` / `mig_ui_bram`

- Mux: pack wins vs FEM. FEM idle this top. Pack SENTINEL is dest readback vs first word — **H4**.
- `mig_ui_bram` is DUT stand-in in some TBs, **not** generated `mig0`.

### 4.11 `clk_arty_mig.sv`

- clk100 + UI clock. ILA hub should use **clk100** (~100 MHz). JTAG < 40 MHz (2.5× rule). No program this wake.

---

## 5. Live extra RTL (not CLEAR implement; no edits)

Merged from [Directory RTL audit](2a6f2cd4-711e-4e2d-84ab-9678a1f0e73e) and [FEM and FE256 RTL](f2ed8f7c-fc77-4af8-82e7-7057bf75258f). Specialists did not write reasoning files; E absorbs below. No XSim on these paths this merge. No PASS.

| Block | Verdict |
|---|---|
| `directory/*` + `query_result_bind` | Common-runtime CANDIDATE. Fail-closed SEARCH_INCOMPLETE unless ASTRA completeness. `s_valid=0` on M4+mig top. COMMON_RUNTIME_FE256_STATUS=NOT_RUN |
| `fe256/fe256_query_path.sv` + FE256 tops | Dedicated engine **instantiated** in FE256 R1 candidate top (also 30.13 freeze top). Absent from M4 UART / M4+mig. Do not polish. Do not overwrite freeze DCP |
| `fem_on_mig` + `fem_t2_*` / `fem_media_*` | C T2 is `t2_ready`-aware. Persist media is tied-off D candidate. `t2_ready` ≠ persist done. NEXT_MAIN_D_TASK blocked until Pack board class |
| `spear_profile_bind` | K_HARD_MAX=8. Tied off. C_SCALE_GUARD OK |
| Older tops `arty_a7_r2_top.sv` / `arty_a7_mig_top.sv` | Historical candidates. Not identity D/H |

### 5.1 Directory / query (RTL_FACT unless noted)

- M4 query top instantiates `query_result_bind`, **not** `fe256_query_path`. Directory/posting are `$readmemh` ROM, not FE256 store.
- Packer: CRC/magic fail → `0x06/0x55`; else **always** `0x04/0x20` PARTIAL. Walk `hit/oop/inc` connected and **unread**. Never ANSWER/UNKNOWN. Fail-closed **and** blind to walk outcome.
- Inner `rsp_ready=1'b1` on walk/posting/directory children. Outer bind is one-cycle ready. Not the same defect as pack H3. Second-outstanding silent-drop is **HYPOTHESIS** (no second-outstanding FSM coded).
- `query_result_bind.s_ready=1` always; this top ties `s_valid=0`. If `s_valid` were used: silent drop.
- **H10 UART taking window (strongest query handshake):** `uart_fe256_host.taking` is 0 in `S_ISSUE`/`S_WAIT`/`S_TX`. Query top: `w_ready = q_taking ? qh_in_ready : pack_ready`. A second UART word during query in-flight is offered to **pack**, not held. M4+mig analogue: `f_ready = q_taking ? qh_in_ready : cdc_a_ready` so FIFO pops to CDC while query is in ISSUE/WAIT/TX. **WEAKENED as CLEAR-campaign H6** (no `4E51` in S-01). **RTL_FACT** for query/pack mux. Not PASS_XSIM.
- No timeout: hang, not false ANSWER.
- `posting_walk` `ptr[15:4]` has no `N_POST` check. OOR BRAM **HYPOTHESIS**; packer still SEARCH_INCOMPLETE.
- C_SCALE_GUARD: `N_DIR=235` / `N_POST=2048` are D ROM sizes, not Q*/SPEAR/FEM scale. Not tripped.
- Hashes (specialist `Get-FileHash`): `query_result_bind` `9529fd27…`; `query_posting_bind` `fb8eea24…` MATCH recorded M2 candidate; M4 query top `d622e8aa…`; `uart_fe256_host` `95f273fa…`.

### 5.2 FEM / FE256 (RTL_FACT unless noted)

- Dedicated `fe256_query_path` SHA256 `4c69e8fb…` MATCH freeze RTL snapshot. Instantiated in `arty_a7_r2_top_fe256_r1_candidate.sv` `93457014…`. **Not** freeze-DCP-only. M4+mig live top `382ac125…` uses `query_result_bind`. Binding FE256 into M4+mig without owner wake would be feature-creep (**HYPOTHESIS**, not observed).
- C `fem_lifecycle.v` `45b9b930…` MATCH. `t2_ready` from `fem_t2_ce`, not adapter IDLE. Adapter txn/gen is **echo**, not DDR-stored generation. `fem_media_bridge` is a reg dest MODEL (`txn_r != txn_r` write-err term always false). Tops: `ing_valid=0` `rec_start=0`. Recorded `FEM_MIG_UI32_XSIM_PASS` is JSON marker on `mig_ui_bram`, **not** re-run, **not** `FEM_PERSIST_PASS`.
- Live `pack_mig_bind` `581777cf…` has `debug_clear`/`rst_loc`. Freeze snapshot bind `c686bebf…` does **not**. CLEAR resets pack UI, **not** `fem_on_mig` (`rst_ui_n` only).
- `mig_ui_mux`: pack wins from `G_NONE` if `a_req`; no preemption of in-flight FEM grant. Persist-on **HYPOTHESIS**: late MIG beat after grant switch can steer to the wrong client. Dormant while FEM tied off.
- C_SCALE_GUARD not fired: theta[0:63], K_HARD_MAX=8, N_RAW=4, FE256 `FQ=64` is not Q* theta.

ILA add (still no program): clk100 `q_taking` falling while `f_valid` / `w_valid` (H10). Do not ILA-insert into freeze FE256 top.

---

## 6. ILA plan (UG908) — do not program

See `E_ILA_PLAN.md` and `33_ila_clear_netlist.tcl.TEMPLATE`.

Decision: **ILA v6.2** on clk100 (full-speed handshake). **ILA** on ui_clk with **TRIGIN** from clk100. **VIO** optional for `clr_hold`/`used`/`pack_lock`. No JTAG-to-AXI (not AXI-lite debug of CLEAR). Artix-7 BSCAN hub; not Versal.

Minimum clk100 probes: `w_valid w_ready w_data clr_take clr_hold uart_flush fifo_wr_ready used[7:0] pack_lock q_taking qsc_100 mux_valid mux_ready clr_ack_valid rx_idle`.

Triggers: `clr_take`; `clr_hold && w_valid`; `used==128`; `clr_ack_valid`; `!q_taking && f_valid` (H10 taking gap).

**Do not** `mark_debug` C RTL. Netlist insertion on CLEAR candidate synth only. Never write freeze DCPs `858d0e99` / `b48b7c88` / `f25fdf64`. Never overwrite hist bit `f6a6091f`.

---

## 7. What E did not do

- JTAG / COM12 / GRANT / program identity H
- Patch live or snapshot synthesizable RTL
- FE256 polish / FEM persist
- B gold / QueryRecord / StructuredResult edits
- Stamp any ladder PASS

---

## 8. Next (owner/D)

1. Owner GRANT **or** keep SRAM on D: board mute still UNKNOWN until 1-CLEAR hex/ILA.
2. If programming H: one identity, READ_ONLY 1 CLEAR, 3 s raw UART, no pack burst, no 3-retry.
3. Handshake patch does **not** remove uart_rx STOP-drop or S_REJECT absorbing — still need those tests on the programmed identity.
4. FEM persist remains blocked. Do not enable `ing_valid`/`rec_start` on M4+mig until Pack identity is classified (shared UI vs CLEAR).
5. Query H10 (taking window) is a **separate** XSim from CLEAR T1–T6; do not mix campaigns. COMMON_RUNTIME_FE256_STATUS stays NOT_RUN.
