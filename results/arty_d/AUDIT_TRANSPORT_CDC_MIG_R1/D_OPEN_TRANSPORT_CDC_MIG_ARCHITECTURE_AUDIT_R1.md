# D-OPEN-TRANSPORT-CDC-MIG-ARCHITECTURE-AUDIT-R1

OWNER: AGENT_D
MODE: OPEN INVESTIGATION + ARCHITECTURE REVIEW
RUN_ID: 20260917T064130Z
PRODUCT_RTL_CHANGED=NO
PROGRAM=NO
NEW_IDENTITY=NO

Claim ceiling (unchanged):

```text
PACK_ABI_24_24_PASS = NO
BOARD_PASS = NO
FEM_PERSIST_PASS = NO
CURRENT_SILICON_EXTRA_BYTE_SOURCE = UNKNOWN
TIMING_PASS = NO_SELF_STAMP
MIG_PASS = NO
PROGRAM_PASS = NO
```

H/H11/ILA root-cause investigation remains authoritative. This audit does not replace ILA-A.

Identity used for implemented netlist (FACT):

| Artifact | SHA256 |
|---|---|
| `post_route_clear.dcp` | `beab0263e094dbf2e7bdebfaffb120d1cdc379492b1cc68b82c851183c6e17a9` |
| identity-H bit | `cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9` |
| live top `arty_a7_r2_top_m4_mig_candidate.sv` | `382ac125eec20578101a62b88ffe4be4baab408ce188a2b6550742ae0362cf40` |
| `uart_rx_word.sv` | `638f9719732f971828205c43b9894cc2b93529fb6e1e39ab90f6970ca0790823` |
| `word_fifo32.sv` | `5d35ad1eac6bf259168a7e8e8137f4404abb9064aafddef02c3e858e221e7363` |
| `word_cdc32.sv` | `8e356cf46b97100c5437c247da044c8964924bcfc4d814ccbf32e40892c310a3` |
| `pack_debug_clear.sv` | `77e3dc26cebacbc2e975fb8748635b7c364263f3f52a5f31538ac7e49fd752ec` |
| `uart_fe256_host.sv` | `95f273fa18d30746cc1f81c0518e415c8749332c9e14e3c10715a9ac709639c9` |
| `mig_ui_mux.sv` | `28ef597ed36d20ee76785b94bc235aaef28f342262101a7a48ac7e8157a096d2` |

XPR: `D:/FPGA/arty_d/m4_mig_clear/m4_mig_clear.xpr`
Static reports: `D:/FPGA/arty_d/AUDIT_TRANSPORT_CDC_MIG_R1/STATIC_IMPLEMENTATION_DIAGNOSTICS/`
Impl-time copies: `.../IMPL_PROVENANCE_20260917T0546/` (do not mix with H11 runtime jsonl).

---

## TASK / STATUS

```text
TASK: D-OPEN-TRANSPORT-CDC-MIG-ARCHITECTURE-AUDIT-R1
STATUS: COMPLETE_AUDIT_NO_RTL
DOES_ANY_CURRENT_EVIDENCE_JUSTIFY_RTL_CHANGE: NO
PREFERRED_DIRECTION: KEEP_CURRENT_WITH_GUARDS
  (operational; not an authorized redesign)
FIRST_DIVERGENCE_STATUS: OPEN
  Named mechanism (PASS_XSIM): extra 0x00 after ACK → bix=1 → BEGIN 00800001 becomes 80000100 → R_UNSUP
  Silicon extra-byte SOURCE: UNKNOWN (below Python; H19 board tx_n=132/132)
OWNER_AUTH_REQUIRED: YES for any prototype / ILA identity / program
```

---

## ACTUAL_DATA_PATH

The user sketch placed `uart_fe256_host` after `word_cdc32`. Implemented RTL and the H netlist contradict that.

Correct hierarchy (FACT from live top + DCP cells `u_rx`, `u_rfifo`, `u_cdc`=`word_cdc32__xdcDup__1`, `u_cdc_tx`, `u_qhost`, `u_ld`, `u_mux`, `u_mig`):

```text
HOST TX
  → FTDI (A9 uart_rx / D10 uart_tx, 115200 8N1)
  → input uart_rx
  → uart_rx_word u_rx          [sys_clk_pin 100 MHz]
        2FF pin sync rx_s/rx_d
        START/BITS/STOP assembler
        bix[1:0] byte phase
        w_valid/w_data[31:0] LE words
  → split BEFORE FIFO:
        pack_debug_clear u_clr sniffs w_valid/w_data
        take = (IDLE && w_data==32'h44524743)
  → word_fifo32 u_rfifo         [SAME clk100; NOT a CDC]
        wr = w_valid && !clr_take && !clr_hold
        flush = uart_flush (CLEAR S_CDC|S_QUIET only)
  → FIFO read f_valid/f_data:
        uart_fe256_host u_qhost  if in_data[15:0]==0x4E51 (clk100)
        else word_cdc32 u_cdc    clk100 → ui_clk (clk_pll_i 83.333 MHz)
  → pack_mig_bind u_ld          [ui_clk]
  → mig_ui_mux u_mux            pack(A) vs fem_on_mig(B)
  → mig0 app_*                  APP_ADDR_WIDTH=28, APP_W=128
  → DDR3
response:
  pack status ui_clk → word_cdc32 u_cdc_tx → clk100
  query StructuredResult words from uart_fe256_host (clk100)
  CLEAR ACK/BUSY/ERR from pack_debug_clear (clk100)
  TX mux: CLEAR > query > pack status
  → uart_tx_word u_tx → uart_tx
```

Idle-tied on this identity (FACT `ing_valid=0`, `prop_start=0`, `prof_wr_valid=0`): `qstar_select`, `spear_profile_bind`, `fem_on_mig` (FEM still occupies mux B and MIG address pins). `query_result_bind.s_valid=0` → ASTRA fail-closed SEARCH_INCOMPLETE.

### Boundary table

Clocks are not inferred from module names. `u_mig/ui_clk` is `clk_pll_i` (period 12.000 ns) in the H DCP. Hierarchical `u_rx/clk` pins are optimized away; `u_rx` cell exists; XDC targets `u_rx/rx_s_reg`. UART/FIFO/CLEAR/query/TX are RTL-tied to `clk100 = CLK100MHZ = sys_clk_pin`.

| Boundary | SOURCE_CLOCK | DEST_CLOCK | DATA_WIDTH | VALID | READY | BUFFERING | RESET_SOURCE | RESET_RELEASE | OWNERSHIP | BACKPRESSURE | DROP_BEHAVIOR | DUPLICATE_RISK | ORDERING |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pin `uart_rx` → `rx_d` | async pin | sys_clk_pin | 1 | n/a | n/a | 2FF | `rst100_n` async | unsync deassert `ck_rst & clk_locked` | D `uart_rx_word` | none | none | n/a | bit order 8N1 |
| bytes → word | sys_clk_pin | sys_clk_pin | 8→32 LE | implicit STOP commit | `w_ready` only on 4th byte | `acc`,`bix` | `rst100_n` or `uart_flush` | async / flush sync in FSM | D | if `bix==3` and `w_valid && !w_ready` **drop completed word, still `bix<=0`** | drop on 4th-byte stall | no | byte order inside word preserved; **phase not recovered** |
| word → CLEAR sniff | sys_clk_pin | sys_clk_pin | 32 | `w_valid` | `w_ready=clr_take \|\| (!clr_hold && fifo_wr_ready)` | none | `rst100_n` (CLEAR FSM never self-resets) | async | D `pack_debug_clear` | hold blocks FIFO | CLEAR word not written to FIFO | n/a | exact `32'h44524743` only |
| word → FIFO | sys_clk_pin | sys_clk_pin | 32 | `wr_valid` | `wr_ready` | DEPTH=128 LUTRAM | `rst100_n` or flush | async pointers; flush zeros used | D `word_fifo32` | stall producer | producer may drop (see uart_rx_word) | no if handshake honored | FIFO order |
| FIFO → query | sys_clk_pin | sys_clk_pin | 32 | `f_valid && !pack_lock && magic` | `qh_in_ready` | 8-word `qw[]` | `rst100_pack_n` | 1FF `~cdc_rst_100` | D `uart_fe256_host` | holds FIFO | none | n/a | 8 words then CRC in walk |
| FIFO → CDC A | sys_clk_pin | sys_clk_pin | 32 | `f_valid && !q_taking && !clr_*` | `cdc_a_ready` | 1-word `hold` | `rst100_pack_n` | see CDC | D `u_cdc` | 1-inflight | none at CDC A (stalls) | reset toggle (see Part D) | word order |
| CDC B → pack | clk_pll_i | clk_pll_i | 32 | `p_valid` | `p_ready` | `b_data` until ready | `rst_ui_pack_n`=`~debug_clear` 1FF | ui domain | D `pack_mig_bind` | loader | none | reset | word order |
| pack → mux → MIG | clk_pll_i | clk_pll_i | addr28 / data128 | `app_en` / `app_wdf_wren` | `app_rdy` / `app_wdf_rdy` | MIG native UI | `ui_clk_sync_rst` + local `rst_loc` | MIG sync rst; local 1FF | D mux + generated mig0 | native | n/a | n/a | beat order |
| pack status CDC TX | clk_pll_i | sys_clk_pin | 32 | `st_valid_*` | handshake | 1-word | both pack resets | same as RX CDC | D `u_cdc_tx` | 1-inflight | none | reset | word order |
| TX mux → UART | sys_clk_pin | sys_clk_pin | 32→8 | `mux_valid` | `mux_ready` | `uart_tx_word` shifter | `rst100_n` / flush | flush during CLEAR CDC/QUIET **aborts TX** | D | CLEAR > query > pack | flush mid-frame | n/a | LE bytes |

`w_valid` can remain high more than one cycle (FACT). It is a **word** handshake, not a per-byte `rx_valid`. Each accepted `w_valid && w_ready` is one 32-bit word.

---

## CLOCK_DOMAIN_MAP

Implemented clocks (FACT `netlist_probe.txt` + `clock_interaction.rpt`):

| Name | Period | Frequency | Role |
|---|---|---|---|
| `sys_clk_pin` | 10.000 ns | 100 MHz | `CLK100MHZ`; UART RX/TX, FIFO, CLEAR, query, Q*, SPEAR |
| `clk166_u` | 6.000 ns | 166.667 MHz | MMCM `clk_sys166` → MIG `sys_clk_i` |
| `clk200_u` | 5.000 ns | 200 MHz | MMCM `clk_ref200` → MIG `clk_ref_i` |
| `clk_pll_i` | 12.000 ns | 83.333 MHz | `u_mig/ui_clk`; pack, FEM UI, mux, `u_cdc` B, `u_cdc_tx` A |
| MIG PHY clocks | 1.5–12 ns | DDR3 PHY | generated mig0 only |

UART domain = Pack assembler domain = Query domain = **sys_clk_pin**.
Pack MIG / FEM UI / mux = **clk_pll_i**.
There is **no separate UART clock**.

Clock-pair classification (FACT `clock_interaction.rpt`):

- `sys_clk_pin` ↔ `sys_clk_pin`: Timed, Clean, WNS +0.50
- `clk_pll_i` ↔ `clk_pll_i`: Timed, Clean, WNS +2.53
- `sys_clk_pin` → `clk_pll_i`: **Max Delay Datapath Only**, Classification **Ignored**, WNS +6.18 (8 ns requirement)
- `clk_pll_i` → `sys_clk_pin`: Max Delay Datapath Only, Ignored, WNS +6.27
- PHY pairs: Timed Clean or False Path (MIG)

XSim H19: `always #5 clk100` / `always #6.25 ui_clk` → 100 MHz vs **80 MHz independent**. Silicon is 100 vs **83.333** and MMCM/PLL-related but constrained **asynchronous** (max_delay). XSim **does** exercise two clocks; it does **not** model MMCM lock, `ck_rst`, or generated `mig0`.

---

## RESET_DOMAIN_MAP

| Reset | ASSERTION_MODE | DEASSERTION_MODE | CLOCK_DOMAIN | SYNCHRONIZER | RESET_STRETCH | DEPENDENCIES |
|---|---|---|---|---|---|---|
| `ck_rst` (JP2 C2) | async pin (active-low board) | unsync; `set_false_path -from ck_rst` | n/a | none on fabric `rst100_n` | none | physical jumper |
| MMCM `RST=~ck_rst` | async | lock | MMCM | `clk_locked` | MMCM lock time | `ck_rst` |
| `rst100_n = ck_rst & clk_locked` | async combinational | unsync | sys_clk_pin async PRE/CLR | **none** | none | JP2 + lock |
| `sys_rst_i` to mig0 | same as `rst100_n` | MIG internal | MIG | generated | MIG | calib |
| `ui_rst_h = ui_clk_sync_rst` | MIG | MIG-synchronized | clk_pll_i | generated | MIG | `sys_rst_i` |
| `rst_ui_n = ~ui_rst_h` | inverted MIG | follows MIG | clk_pll_i | MIG | MIG | |
| UART RX/TX / FIFO / CLEAR / query_result_bind / Q* / SPEAR | async `rst100_n` | unsync | sys_clk_pin | none | none | PROGRAM/JP2/lock |
| `rst100_pack_n` | 1FF `~cdc_rst_100` | sync to clk100 | sys_clk_pin | 1FF, not XPM | CLEAR S_CDC 4 cycles | VALIDATION_CLEAR only |
| `rst_ui_pack_n` | 1FF `~debug_clear` | sync to ui_clk | clk_pll_i | 1FF | held until 100-side drops `req` (pack_clear_ui) | SUCCESS CLEAR, not BUSY |
| FIFO pointers extra | `uart_flush` | sync FSM | sys_clk_pin | n/a | S_CDC+S_QUIET | success CLEAR |
| MIG IP / DDR contents | not cleared by VALIDATION_CLEAR | n/a | n/a | n/a | n/a | dest persist FACT |

XPM_CDC_SYNC_RST would standardize **ck_rst/lock release into clk100** and is **not** what currently exists. It would not name the extra byte. JP2 correlation (H9) remains CLASS B liveness, not proven CLASS A extra-byte root.

---

## UART_RX_WORD_ASSESSMENT

```text
CLASS:
  STRUCTURALLY_SAFE     for 8N1 bit sampling when the line is a legal byte
  FUNCTIONALLY_SENSITIVE  bix / acc / no STOP-high check / no phase resync
  NEEDS_ILA             first RX byte after ACK (ILA-A)
  POSSIBLE_ROOT_CAUSE   of R_UNSUP **given** an extra byte (H19 PASS_XSIM)
  NOT_CURRENTLY_SUSPECT as the silicon extra-byte *generator*
                        (STOP does not emit a synthetic data 0x00)
```

Answers:

- **bix update:** on STOP midpoint, if `bix!=3`: `acc<={sh,acc[31:8]}; bix<=bix+1`. If `bix==3`: optionally write `w_data`, **always** `bix<=0`.
- **Reset:** `!rst100_n` or `flush` (`uart_flush`). Not reset by BUSY. Not reset in S_ACK/S_DROP.
- **CLEAR:** success path flush in S_CDC/S_QUIET zeros bix. BUSY path: **no flush**.
- **`w_valid` duration:** can be many cycles until `w_ready`. Not a 1-cycle pulse.
- **Each `w_valid` cycle:** not a new byte. New bytes only on STOP commit. Holding `w_valid` does not consume extra bytes into `acc` except the 4th-byte drop case.
- **STOP/framing synthetic 0x00:** STOP does **not** check `rx_d==1`. A framing error still commits `sh` from BITS. STOP does not sample a 9th data bit. Synthetic 0x00 from STOP-low is **not** supported by this FSM. A real 0x00 byte on the wire **is** assembled.
- **Malformed START:** sample high at START midpoint → IDLE, no byte.
- **Byte-phase recovery:** **none**.
- **Partial word into next transaction:** **yes**, if `bix!=0` and no flush/rst.
- **CLEAR while `bix!=0`:** possible; `take` requires an already-assembled exact CLEAR word. Misaligned CLEAR is not detected.
- **Bytes after reject:** BUSY does not flush; later bytes continue shifting `bix`. After success ACK, flush is **already off**; a stray byte during S_ACK/S_DROP/S_IDLE **survives**.

This last point is the architectural **containment hole** that makes H19’s extra 0x00 lethal, not proof that `uart_rx_word` created the 0x00.

---

## WORD_FIFO32_ASSESSMENT

```text
WHAT: synchronous DEPTH=128 distributed-RAM (LUTRAM) register-file FIFO
      SAME clock wr/rd. NOT a CDC component.
WRITE CLOCK: sys_clk_pin
READ CLOCK:  sys_clk_pin
wr: wr_valid/wr_ready   rd: rd_valid/rd_ready
full: used==DEPTH        empty: used==0
reset: async rst_n zeros pointers; flush same
overflow: wr_ready=0; producer (uart_rx_word) may DROP a completed word
underflow: rd_valid=0 when empty; consumers gated by rd_valid
```

Invariant: accepted writes (`wr_valid && wr_ready`) equal eventual reads unless `flush` or `rst_n`. FACT from pointer FSM.

Producer **may** present `wr_valid=1` while `wr_ready=0` at the UART side (`w_valid` during FIFO full or `clr_hold`). FIFO itself does not increment `used` then. UART may still drop the 4th-byte word.

Read-side consume while empty: not if `rd_valid` is honored. `f_ready = q_taking ? qh_in_ready : cdc_a_ready`.

CLASS: STRUCTURALLY_SAFE as clk100 elastic buffer. NOT_CURRENTLY_SUSPECT for extra 0x00. FUNCTIONALLY_SENSITIVE overflow-drop.

---

## WORD_CDC32_ASSESSMENT

Instance `u_cdc` in H DCP: `REF_NAME=word_cdc32__xdcDup__1` (schematic name). `u_cdc_tx` is `word_cdc32`.

1. **Yes, two clocks.** A=`sys_clk_pin` 100 MHz, B=`clk_pll_i` 83.333 MHz (netlist `u_mig/ui_clk`).
2. **Toggle + 2FF (plus extra `req_b2`) + hold register.** One word in flight. `a_ready = (req_a == ack_a1)`.
3. **Payload stability:** `hold` written only when `a_valid && a_ready`; next write blocked until ack. Dest copies `hold` when `req_b2 != last_b` and `!b_valid`.
4. **32-bit coherency:** not gray-coded. Guaranteed by handshake + `set_max_delay -datapath_only 8.0` on `hold_reg[*]` → `b_data_reg[*]`. Timing met (WNS of that pair +6.18 vs 8 ns). `report_cdc` CDC-15 Warning on those bits = clock-enable dest capture. Classified **INTENTIONAL / SAFE_KNOWN_STRUCTURE**, not proof of silicon extra-byte.
5. **Faster than ack:** no; `a_ready` blocks.
6. **Overwrite:** not while handshake intact. Reset of one side without the other can make a **stale toggle / duplicate** (HYPOTHESIS, not observed as H19 cause).
7. **XSim async:** H19 dualclk 100 vs 80 independent. Yes async. Not MMCM.

`report_cdc` CLEAN on this pair would still not prove protocol. Here the pair is **Warning CDC-15 + Info CDC-3**, with max_delay, **not** Critical.

CLASS: STRUCTURALLY appropriate for 1-word handshake. NOT_CURRENTLY_SUSPECT for extra 0x00 (failure is **before** FIFO). FUNCTIONALLY_SENSITIVE dual-reset. Replacing with XPM does not PREVENT H19.

---

## PACK_DEBUG_CLEAR_ASSESSMENT

- CLEAR detected on **assembled 32-bit words** at `uart_rx_word` output, not raw bytes, not FIFO contents.
- Shared stream: sniff is **before** FIFO. CLEAR word is **not** written to FIFO (`!clr_take`). Pack cannot consume that beat from FIFO. A CLEAR pattern **already queued in FIFO** is **not** sniffed (INFERENCE: leftover FIFO words can still reach pack/query).
- Success: SAMPLE 8 → UI 4-phase → S_CDC `cdc_rst_100` 4 cycles + flush → S_QUIET 20000 idle marks → S_ACK TX `C1EA50A5` → S_DROP. dest/MIG **not** cleared.
- BUSY: no CDC rst, no UART flush, no long hold-flush.
- FIFO on CLEAR: flushed only success S_CDC/S_QUIET.
- Byte phase: restored only by flush/rst, **not** by ACK completion.
- CDC/FIFO pointers: success CDC+flush; BUSY neither.
- TX: flushed in S_CDC/S_QUIET (can abort TX); ACK sent after flush off.

### PROGRAM_RESET vs CLEAR_RESET

| State | PROGRAM / `rst100_n` / MIG sys_rst | VALIDATION_CLEAR success | VALIDATION_CLEAR BUSY |
|---|---|---|---|
| `uart_rx_word` bix/acc/FSM | reset | flush zeros | **survives** |
| `word_fifo32` pointers | reset | flush | **survives** |
| `word_cdc32` req/ack/hold | reset both domains | both pack resets overlapped by design | **not reset** |
| `pack_loader` / `mig_ui32` | reset | `debug_clear` local | not |
| `uart_fe256_host` | via `rst100_pack_n` on CLEAR CDC; also `rst100_n` | CDC rst | not |
| TX shifter | reset | flush then ACK | ACK BUSY, no flush |
| dest DDR / generation payload | MIG reset (destructive) | **intentionally survives** | survives |
| `mig0` calib / `ui_clk_sync_rst` | yes | **no** | no |
| mux grant | reset | not specifically | not |
| Q*/SPEAR/FEM lifecycle | `rst100_n` / `rst_ui_n` | not CLEAR | not |

CLASS: FUNCTIONALLY_SENSITIVE. CONTAINMENT gap after ACK is **relevant** to UNSUP. Not proven extra-byte source. NEEDS_ILA `clr_take` vs `bix`.

---

## QUERY_LAYER_ASSESSMENT

Do not disturb. Confirmed:

1. `uart_fe256_host` takes only if `in_data[15:0]==16'h4E51`.
2. Collects **8 words** (`wix` 0..7) then `q_valid`.
3. `query_walk_bind` checks magic `0x4E51` / abi `0x01` and **CRC16 over first 30 bytes vs `qb[31:30]`**.
4. Result CRC16 is packed on StructuredResult (46+2), fail-closed `0x04/0x20`.

BYTE/WORD TRANSPORT INTEGRITY ≠ QUERY RECORD INTEGRITY. A passing QueryRecord CRC does not prove UART byte phase for Pack, which has **no** CRC on opcode words.

CLASS: STRUCTURALLY_SAFE accuracy-first at record layer. NOT_CURRENTLY_SUSPECT for Pack MAG/UNSUP.

---

## MIG_UI_MUX_ASSESSMENT

Exclusive grant `G_NONE/G_A/G_B`. `a_req = a_busy|a_en|a_wdf_wren`. Pack wins when both request. Grant held while winner `*_req`.

- Command and WDF **can** complete on different cycles (`mig_ui32` `cmd_acc`/`wdf_acc`). Grant stays because `ui_busy=(st!=S_IDLE)` through S_WR/S_RD/S_WAIT.
- Ownership switch mid-handshake: not while `ui_busy`. If `ui_busy` were wrong, address vs WDF split would be possible — **not evidenced**. Both clients always see `d_rd_data`; only granted client gets `rd_valid`.
- Outstanding: `mig_ui32` is one fabric txn at a time; MIG may have its own queue. No txn-ID on native UI; association is by grant+FSM.
- CLEAR: `debug_clear` only when `pack_quiescent`. Should not switch mid-txn if quiescent is honest.
- FEM starvation: pack priority. On this identity FEM `ing_valid=0` (FACT). RTSTAT-10: FEM/Q* nets have no loads.

CLASS: STRUCTURALLY appropriate exclusive native-UI arbiter. NOT_CURRENTLY_SUSPECT for UART extra byte. Distinguish **MIG IP** vs **mux**. Do not assume MIG is faulty.

---

## MIG_IP_ASSESSMENT

Generated `mig0` (`mig0_mig.v`): `ADDR_WIDTH=28`, `BANK_WIDTH=3`, `ROW_WIDTH=14`, `COL_WIDTH=10`, `nCK_PER_CLK=4`, `APP_DATA_WIDTH=128`, `MEM_ADDR_ORDER=BANK_ROW_COLUMN`. Wrapper port `app_addr[27:0]`.

LUTAR-1 is **inside generated MIG** `rstdiv2_sync_r` (methodology). REQP-1709 PLL CLKOUT3 buffer mix is MIG. Not UART.

XSim dest is `mig_ui_bram`, **not** this IP.

---

## ADDRESS_WIDTH_AUDIT

| Site | Width |
|---|---|
| generated `mig0` `app_addr` | **28 pins [27:0]** FACT netlist |
| `fem_on_mig` `app_addr` | 28 pins FACT |
| `mig_ui_mux` / `pack_mig_bind` RTL | `logic [27:0]` |
| `mig_ui32` beat `{mem_addr[27:4],4'b0}` | 28, `[3:0]=0` lane in data |
| schematic `[26:0]` | **not** the implemented MIG port |

RANK+BANK+ROW+COL = 0/1 + 3 + 14 + 10. Parameter is 28; pin `[27]` **exists**. Unused-constant high bit is possible (INFERENCE), **not** proven truncation. **Not labeled a bug.**

---

## STATIC_REPORT_SUMMARY

Folder `STATIC_IMPLEMENTATION_DIAGNOSTICS` regenerated 2026-09-17T13:41+07 from H DCP. Vivado 2026.1 syntax used (`report_clock_interaction -delay_type min_max`, `report_cdc -details`, `report_high_fanout_nets -max_nets 30`).

### TIMING

```text
WNS = +0.497 ns
TNS = 0
WHS = +0.014 ns
THS = 0
unconstrained_internal_endpoints = 0
no_clock = 0
All user specified timing constraints are met.
NO STATIC TIMING VIOLATION OBSERVED
```

Do **not** infer UART protocol correctness.

check_timing: `no_input_delay` 2 with false path (`ck_rst`, `uart_rx`). `no_output_delay` includes `uart_tx` (TIMING-18).

### CDC

Critical bucket is **`input port clock` → `sys_clk_pin`**: False Path, 4158 endpoints, 103 unsafe, 4054 unknown. Dominated by `ck_rst` async reset fanout (CDC-1/CDC-7/CDC-13). **FALSE_POSITIVE / MIG-RESET / UNKNOWN fabric async-rst**, not a Pack-word protocol fail.

`sys_clk_pin` ↔ `clk_pll_i`: Safely Timed, Max Delay Datapath Only, 35+11 endpoints, **0 unsafe**. Details: CLEAR `ui_req` 2FF (CDC-3 Info); `u_cdc`/`u_cdc_tx` hold bus CDC-15 Warning.

Tool note: “Consider XPM_CDC modules to avoid Critical severities” — applies to the **ck_rst/unknown** class, **not** a mandate to replace `word_cdc32`.

`report_cdc` is **not** protocol-correctness.

### CLOCK_INTERACTION

See CLOCK_DOMAIN_MAP. Pack CDC path is **Ignored + Max Delay**, not Timed-synchronous. PHY internals Clean/False Path.

### METHODOLOGY

38 checks: LUTAR-1 (MIG), PDRC-190 (tempmon), SYNTH-6 (RAM), TIMING-18 (`uart_tx` delay), XDCB-5 (MIG XDC), REQP-1959 SERDES RST.

### DRC

59 checks. DSP pipeline on idle Q*/SPEAR. REQP-1839/1840 async-reset into directory ROM / pack page RAM. RTSTAT-10 unused FEM/Q* nets. Not extra-byte evidence.

### HIGH_FANOUT

Not a defect by itself. Notable:

| Net | Fanout | Note |
|---|---|---|
| `u_q/prop_done_i_1_n_0` | 1860 | idle Q* |
| `u_ld/u_ld/rst_loc_reg` | 960 | CLEAR local pack reset |
| `u_qhost/rst100_pack_n_reg` | 447 | CLEAR pack/query reset on clk100 |
| `u_mux/g[1:0]` | 186 each | mux grant |
| MIG `app_wdf_rdy` copies | ~290 | MIG UI |

No unexpected UART `bix` replication. CLEAR reset **is** high-fanout by construction.

Utilization (same DCP): LUT 10932, FF 9855, RAMB36=4, RAMB18=2, DSP=8.

---

## TEST_VS_SILICON_GAP

| Models | WORD TB | UART TB / H16 / H19 XSim | POST-ROUTE/NETLIST SIM | REAL BOARD identity H |
|---|---|---|---|---|
| physical UART / FTDI | no | behavioral `uart_rx` bit stream | if done: still no FTDI | yes |
| byte timing 115200 | no | H16/H19 yes (ideal) | unknown / not used here | analog + FTDI |
| bix | if word-push, no | yes | would | hidden |
| word assembly | skip | yes | would | yes |
| FIFO | often skip | harness yes | would | yes |
| actual CDC clocks | no | independent 100/80 | would use implemented | 100 vs 83.333 MMCM/PLL |
| reset release / JP2 | no | TB rst_n | no JP2 | JP2 removed; lock |
| MIG IP | no | **BRAM dest** | possible, not run | yes mig0 |
| MIG arbitration | no | mux+idle FEM | possible | yes |
| host pacing | no | scripted | no | pyserial / campaign |
| TX backpressure | limited | mux in harness | | FTDI |
| long campaigns | no | H12_24 limited | no | sticky mute CLASS B |

This gap is **why** H19 XSim can name the UNSUP mechanism while silicon extra-byte SOURCE stays UNKNOWN.

---

## STANDARD_IP_CANDIDATES

Evaluated against **this** datapath. None selected for implementation.

### XPM_FIFO_ASYNC

```text
SUITABILITY=PARTIAL (CDC span only); UNSUITABLE as drop-in for word_fifo32+word_cdc32
BENEFIT=gray occupancy, wr_rst_busy/rd_rst_busy, overflow/underflow flags, vendor CDC
LIMITATION=query reads the clk100 FIFO; one async FIFO clk100→ui_clk would starve uart_fe256_host
PREVENT extra 0x00 / bix: NOT_ADDRESS
DETECT: UNKNOWN (overflow flags help FIFO_DROP only)
CONTAIN: NOT_ADDRESS for pre-FIFO phase
Would preserve Pack ABI words if depth/order kept.
Would preserve order.
Would MASK extra-byte root: NO (it never sees bytes).
wr_clk/rd_clk would be sys_clk_pin / clk_pll_i if used as CDC.
```

CURRENT `word_fifo32` is **not** crossing clocks. Replacing FIFO+CDC with one XPM_FIFO_ASYNC is **illegal** without splitting query vs pack.

### XPM_CDC_HANDSHAKE

```text
SUITABILITY=HIGH structural match to word_cdc32 (1 x 32b hold until ack)
BENEFIT=XPM attribute, DEST_SYNC_FF 2–10, src_send/src_rcv protocol, less custom toggle
LIMITATION=still 1-inflight; does not see UART bytes; reset still needs both domains
Traffic is handshake-not-burst at the CDC pin (FIFO may burst on clk100; CDC serializes). Handshake is a fit.
PREVENT extra 0x00: NOT_ADDRESS
```

Do not choose it merely because it is official. Custom CDC is already the same class.

### XPM_CDC_SYNC_RST

```text
SUITABILITY=MEDIUM for rst100_n / ck_rst deassert into sys_clk_pin (currently unsync)
BENEFIT=standard dest-clock release; may reduce CDC-1/CDC-7 noise and JP2 chatter effects
LIMITATION=does not restore bix after ACK; does not name extra byte
JP2 is not proven CLASS A root.
```

### AXIS_DATA_FIFO

```text
SUITABILITY=LOW now; FUTURE study only
BENEFIT=TVALID/TREADY/TLAST packet mode, vendor FIFO
LIMITATION=no TLAST on current Pack ABI stream; high migration; added state; debug complexity
Does not address extra 0x00 unless a new packetizer exists **before** bix (that would be a new UART parser).
ABI impact HIGH if TLAST/packet meaning is invented.
```

### OTHER_CANDIDATES

- FIFO Generator: same role as XPM_FIFO_ASYNC; extra IP GUI; BASIC license — no reason over XPM.
- AXI UARTLite / AXI UART16550: would **replace** `uart_rx_word` (blast radius HIGH, ABI/host change, **masks** current reproducer). Not justified.
- Keep `word_cdc32` + add `bix` flush on S_DROP: **guard**, not IP.

---

## FAILURE_CLASS_IMPACT_MATRIX

Legend: PREVENTS / DETECTS / CONTAINS / RECOVERS / NOT_RELEVANT / UNKNOWN

| Failure | Keep+guards (flush bix after ACK) | XPM_FIFO_ASYNC as CDC-only | XPM_CDC_HANDSHAKE | XPM_CDC_SYNC_RST | Harden mux | AXIS FIFO future |
|---|---|---|---|---|---|---|
| EXTRA_BYTE | NOT_RELEVANT (source) | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT |
| BIX_PHASE_SHIFT | CONTAINS / RECOVERS | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | UNKNOWN |
| MAG | CONTAINS if MAG is phase | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | UNKNOWN |
| UNSUP | CONTAINS if UNSUP is phase (H19) | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | UNKNOWN |
| PARTIAL_RESPONSE | UNKNOWN | NOT_RELEVANT | NOT_RELEVANT | UNKNOWN | UNKNOWN | UNKNOWN |
| TRANSIENT_MUTE | UNKNOWN | NOT_RELEVANT | NOT_RELEVANT | UNKNOWN | NOT_RELEVANT | UNKNOWN |
| STICKY_MUTE | UNKNOWN | NOT_RELEVANT | NOT_RELEVANT | UNKNOWN | NOT_RELEVANT | UNKNOWN |
| FIFO_DROP | DETECTS if we add used/ovf observe | DETECTS overflow | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | DETECTS |
| FIFO_DUPLICATE | NOT_RELEVANT | UNKNOWN reset | UNKNOWN reset | UNKNOWN | NOT_RELEVANT | UNKNOWN |
| CDC_CORRUPTION | NOT_RELEVANT | CONTAINS / PREVENTS (gray) | CONTAINS vendor hsk | NOT_RELEVANT | NOT_RELEVANT | CONTAINS |
| RESET_STATE_DIVERGENCE | UNKNOWN | CONTAINS rst_busy | UNKNOWN | CONTAINS release | NOT_RELEVANT | UNKNOWN |
| MIG_ARBITRATION_ERROR | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | NOT_RELEVANT | PREVENTS if real | NOT_RELEVANT |

No candidate is a universal fix.

---

## ARCHITECTURE_OPTIONS

### OPTION_A — KEEP_CURRENT_WITH_GUARDS

Failure addressed: none of the extra-byte **source**; optional later flush-on-S_DROP would CONTAIN bix shift.
Not addressed: SOURCE UNKNOWN, CLASS B mute, MIG persist.
Blast radius: 0 now. ABI 0. Test 0. Resource 0. Masking risk if a flush-guard ships **before** ILA: **HIGH**.
MIG/FEM/Query: unchanged.
**Preferred operationally until first-divergence is named.**

### OPTION_B — REPLACE_CUSTOM_CDC_ONLY (`word_cdc32` → `XPM_CDC_HANDSHAKE` or small XPM_FIFO_ASYNC CDC)

Addresses: maintainability, CDC-15 hygiene, reset-busy if FIFO.
Not addressed: EXTRA_BYTE, BIX, MAG/UNSUP from phase.
Blast: `word_cdc32` + top + XDC + dualclk TB. ABI preserved if 32-bit word order kept.
Masking: LOW for extra-byte (doesn’t touch UART) but **destroys apples-to-apples with identity H**.
Do **not** do this before ILA-A.

### OPTION_C — ADD_TRANSPORT_RESYNC (flush bix / require idle after ACK, or magic hunt)

Addresses: CONTAINS BIX_PHASE_SHIFT / UNSUP-from-shift.
Not addressed: extra-byte source; may hide it forever.
Masking: **HIGH**. Rollback: easy if isolated. Still OWNER_AUTH.

FUTURE_AXIS_MIGRATION and HARDEN_MIG_ARBITRATION are not indicated by current UART evidence. STANDARDIZE_RESET_ONLY is a later hygiene item for `rst100_n`, not CLASS A.

---

## PREFERRED_DIRECTION

```text
PREFERRED_DIRECTION: KEEP_CURRENT_WITH_GUARDS
or, for redesign authorization: INSUFFICIENT_EVIDENCE
WHY:
  1. Extra 0x00 is assembled before FIFO (H19 PASS_XSIM). FIFO/CDC/mux/MIG IP
     cannot PREVENT it.
  2. Custom CDC is a legitimate 1-word handshake with max_delay met, not a
     failed report_cdc protocol on the pack word path.
  3. XPM_FIFO_ASYNC cannot replace the clk100 FIFO+query split.
  4. Replacing UART/FIFO/CDC now would destroy the identity-H reproducer.
  5. Silicon extra-byte SOURCE is still UNKNOWN. ILA-A remains decisive.
```

```text
DOES_ANY_CURRENT_EVIDENCE_JUSTIFY_RTL_CHANGE: NO
IF_YES: (not applicable)
EXACT_CAUSAL_EVIDENCE: none that names the silicon extra byte inside FPGA RTL
ROOT_CAUSE_MASKING_RISK: HIGH if UART/CLEAR/bix “hardening” ships first
NEXT_DECISIVE_EXPERIMENT: ILA-A on identity H (or owner-authorized equivalent)
  uart_rx_valid(w_valid), uart_rx_data=sh/w_data bytes, bix, word_valid/data,
  clr_detect/take. Optional fifo_wr_*. No MIG probes on ILA-A.
  rx_frame_error: NOT implemented — do not invent the net.
OWNER_AUTH_REQUIRED: YES
PRODUCT_RTL_CHANGED=NO
PROGRAM=NO
NEW_IDENTITY=NO
PACK_ABI_24_24_PASS=NO
BOARD_PASS=NO
FEM_PERSIST_PASS=NO
```

No prototype is recommended. If later authorized:

```text
PROTOTYPE_NAME: (none)
OWNER_AUTH_REQUIRED=YES
```

---

## PART V — ILA RELATION

Static reports **cannot** locate the runtime extra byte. ILA-A remains:

`w_valid`, `w_data[7:0]` or sampled `sh`, `bix`, `word` after assemble, `clr_take`, `clr` detect, optional `fifo_wr_*`.

H bit has no soft debug core (Labtools). ILA requires a **new identity** and owner auth. This audit did not implement it.

---

## PART U

UART, FIFO, CDC, reset, and MIG mux were **not** replaced.
