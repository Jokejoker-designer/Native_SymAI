---
version: "1.1-candidate"
owner: AGENT_D
status: AUDITED_CANDIDATE
category: REFERENCE
last_modified: "2026-09-17T01:38:00+07:00"
---

# §23 — HARDWARE FACTS

> Canonical physical facts for the Arty A7-100T target. This document separates
> board/device facts from machine-local environment state. Only the former are
> architecture facts.

## 23.1 Canonical Board Facts

| Parameter | Canonical value | Evidence class |
|---|---:|---|
| Board | Digilent Arty A7-100T | Board identity |
| FPGA | XC7A100T-CSG324-1 | Board/device fact |
| Family | Artix-7 | Device fact |
| Logic cells | 101,440 | Device fact |
| 6-input LUTs | 63,400 | Device fact |
| Flip-flops | 126,800 | Device fact |
| DSP48E1 | 240 | Device fact |
| BRAM36 blocks | 135 | Device fact |
| Maximum block RAM | 4,860 Kb as specified by AMD/Digilent | Device fact |
| External memory | 256 MB DDR3L | Board fact |
| Physical DDR bus | 16 bit | Board fact |
| Memory clock | ~333 MHz | Board fact |
| Effective transfer rate | ~667 MT/s | Derived from DDR signaling |
| Theoretical peak transfer bandwidth | ~1.334 GB/s decimal, ~1.24 GiB/s | `667e6 × 2 bytes` |

### BRAM unit normalization

AMD/Digilent specify the device as **4,860 Kb** block RAM and 135 × 36-Kb
blocks. Do not equate decimal `KB` and binary `KiB` casually. Using the FPGA
block-RAM convention:

```text
135 × 36 × 1024 bits = 4,976,640 bits
                     = 622,080 bytes
                     ≈ 607.5 KiB
```

The architectural statement is therefore:

> The XC7A100T has 135 BRAM36 blocks, approximately 607.5 KiB of raw block-RAM capacity before implementation overhead and allocation to other subsystems.

## 23.2 DDR3L Performance Truth Boundary

The **1.334 GB/s** figure is a theoretical physical peak for ideal sustained
transfers. It is **not** measured semantic-graph throughput and it is not a
random-read guarantee.

Do not freeze any universal end-to-end DDR latency such as `50 ns`, `100 ns`,
`200–400 ns`, or `N cycles/hop` into the architecture without measurement from
the exact generated MIG configuration and workload.

Observed user-visible latency depends on, among other things:

- MIG user-interface ratio and scheduling;
- row/bank state and refresh;
- command/data handshakes;
- burst length and alignment;
- arbitration and outstanding requests;
- CDC and buffering;
- directory/posting indirection;
- cache hit/miss behavior;
- proof/provenance fetches.

Required measurements before a performance claim:

```text
sequential read bandwidth
sequential write bandwidth
mixed read/write bandwidth
random-address latency distribution
random posting-page latency
cache hit latency
cache miss penalty
forward lookup latency
reverse lookup latency
bounded multi-hop latency
DDR bytes/query
outstanding-request occupancy
```

## 23.3 Memory-Device Revision Rule

The board-level canonical contract is capacity/bus/rate, not a single memory
part number across all manufacturing revisions. Use the exact Digilent board
files/reference design for the physical board revision being built.

## 23.4 Board Interfaces

Canonical board capabilities include:

- shared USB-JTAG / USB-UART bridge;
- 4 user switches;
- 4 user push buttons;
- 4 standard LEDs;
- 4 RGB LEDs;
- 4 Pmod connectors;
- Arduino/chipKIT headers;
- 10/100 Ethernet.

User push buttons are active-high on the Arty design. Do **not** assume hardware
debounce; debounce is an RTL/software responsibility when required.

## 23.5 Local Environment Snapshot — NOT Architecture Authority

The following values are local-lab state and may change without changing the
Native AI architecture:

```text
Vivado/Vitis installation path
Vivado/Vitis version
COM port number
JTAG serial selected for a run
license location
MCP server path/port
local drive letters
```

These belong in an evidence/run manifest, not in a timeless hardware-constants
table. A board run must record its actual values at execution time.

Current project convention may use UART 115200-8-N-1 as the R0 laboratory
baseline, but baud rate is a transport parameter, not semantic identity.

## 23.6 DFX Scope

XC7A100T is supported by AMD Dynamic Function eXchange flows. This establishes
**feasibility of partial reconfiguration as a future tool**, not a requirement
for the Arty MVP and not a mechanism for autonomous runtime synthesis.

R0/R1 default remains full-bitstream rebuild for hardware specialization unless
a later experiment proves a DFX partition, rollback, timing, and lineage flow.

## 23.7 Claim Rules

- Peak bandwidth != sustained application bandwidth.
- Sustained bandwidth != random graph performance.
- Device capacity != available subsystem budget.
- Tool installation state != silicon capability.
- `PROGRAM_PASS` != semantic correctness.
- Hardware numbers must be sourced or measured, never inferred from metaphors.

## 23.8 M1 run-manifest pointer (not architecture)

M1 OOC/XSim records tool/part/source hashes in
`vivado/m1_pack_loader/run_manifest.json`. That file is local-run evidence.
It must not be copied into this hardware-facts table.

Discovered this session (lab state, may change):

```text
vivado_bat = C:\2026.1\Vivado\bin\vivado.bat
fpga_part  = xc7a100tcsg324-1
PROGRAM    = YES (owner 2026-09-17; configuration only; not BOARD_PASS)
```

## 23.9 Generated MIG IP snapshot (CANDIDATE, not freeze, not MIG_PASS)

Local generated IP: `D:/FPGA/miggen` module `mig0`, `PortInterface=NATIVE`.
This is a run-manifest / hardware-facts **candidate table**, not an architecture
lock and not persist authority. Do not copy these numbers into NCG record widths.
`APP_ADDR_WIDTH=28` is the MIG physical address, not `SEMANTIC_ID_WIDTH` and not
the §04 pointer ABI. Do not resize HotDirectory (128), Node/Edge (256), or
PostingEntry (64).

| Parameter | Generated value | Notes |
|---|---|---|
| `APP_DATA_WIDTH` | 128 | `2 * nCK_PER_CLK * PAYLOAD_WIDTH` = `2*4*16` |
| `APP_MASK_WIDTH` | 16 | `APP_DATA_WIDTH/8` |
| `APP_ADDR_WIDTH` / `ADDR_WIDTH` | 28 | physical MIG address |
| `DATA_WIDTH` | 16 | board DQ width |
| `nCK_PER_CLK` | 4 | PHYRatio 4:1 |
| `ECC` | OFF | D implementation choice |
| `BURST_MODE` / MR BL | 8 (fixed) | from `mig0.prj` `mrBurstLength` 8-Fixed |
| `InputClkFreq` | 166.666 MHz | `CLKIN_PERIOD=6000` ps; **not** board oscillator |
| `BOARD_OSC` | 100 MHz | `CLK100MHZ`; must not feed `sys_clk_i` |
| expected `ui_clk` | ~83.3 MHz | derived, not board-measured |
| `PortInterface` | NATIVE | not AXI |

`clk_arty_mig` (100 → 166.667 sys + 200 ref) is the intended clock adapter.
Generated `mig0` `app_*` is still **unbound** in `arty_a7_r2_top`. Pack dest in
that top is `mig_ui_bram` (128-bit beat stand-in) through `mig_ui_mux`
(`pack_mig_bind` + `fem_on_mig`, `FEM_BASE=28'h0200000` bit 21, not slot 0/1).
`arty_a7_mig_top` instantiates generated `mig0` and muxes pack + FEM onto that
UI on `ui_clk`. Q*/SPEAR/`bounded_walk` on that top also sit on `ui_clk`
(implementation clocking, not a freeze, not `TIMING_PASS`). That bind is
**CANDIDATE**. Not `MIG_PASS` and not `FEM_PERSIST_PASS`. XSim through
`mig_ui_bram` is not board persist.

Post-route of the **pre-`ui_clk`-move / pre-bag2** netlist
(`D:/FPGA/arty_d/mig_bind/post_route.dcp`, 2026-09-16 18:43, `PROGRAM=NO`, no
bitstream): WNS −1.160 TNS −27.251 (34 failing, all `sys_clk_pin`); WHS +0.028
MET. Worst path was C-owned `qstar_select` `mask_r` → `q_sel` at 100 MHz.

C bag2 (`qstar_select.v` `d4f64e65…`, commit `e3d59ab`, `P_EXP1`/`P_EXP2`) +
`ui_clk` flatten (`D:/FPGA/arty_d/mig_uiclk/post_synth.dcp`, 20:27): setup WNS
**+1.277** TNS 0. Post-route of that bag (`post_route.dcp`, 20:36, `PROGRAM=NO`,
no bitstream): Vivado **constraints reported MET** WNS **+1.032** TNS 0 WHS
**+0.008**; `clk_pll_i` WNS **+1.976** (`u_q/f_i→m2_r/PCIN` 8.621 ns). Not
`TIMING_PASS` (D does not self-issue). Not `MIG_PASS`.

Fabric `arty_a7_r2_top` bag2 + `uart_tx_word` (`D:/FPGA/arty_d/fabric_bag2`,
100 MHz, `mig0` unbound, dest `mig_ui_bram`): post-synth WNS **+1.549** TNS 0.
Post-route (`post_route.dcp`, 21:06, `PROGRAM=NO`, no bitstream): Vivado
**constraints reported MET** WNS **+0.375** WHS **+0.021**. Worst SPEAR
`feat_r[22]→sl_sc[5][2]/CE` 9.044 ns. `UART_WORD_XSIM_PASS` 2/2 (loopback, not
board). `UART_PACK_XSIM_PASS` 2/2 (UART ACK `010000A5` / NAK `0200015A` through
dest-complete slice, not board). Not `TIMING_PASS`. Immutable freeze copy:
`R2_TOP_ROUTE_BASELINE_WHS_0P021` (DCP sha256
`b48b7c8858a39d2a7da0e005b1fb0cc01c2de6e0b1e829f2dbe14531a4b73388`). Two
post-route hold rounds did not raise WHS above +0.021; selected freeze
unchanged. Not `TIMING_PASS`.

`arty_a7_mig_top` + `uart_tx_word` + `u_cdc_tx` (`D:/FPGA/arty_d/mig_tx`,
21:35, `PROGRAM=NO`, no bitstream): Vivado **constraints reported MET** WNS
**+0.673** TNS 0 WHS **+0.008**; `clk_pll_i` WNS **+2.377**; UART CDC
`req_a→req_b0` max_delay slack **+6.929**. Does not clobber `mig_uiclk` or
`R2_TOP_ROUTE_BASELINE_WHS_0P021`. Not `TIMING_PASS`. Not `MIG_PASS`.

FE256 OOC R0 (`fe256_query_path`, `D:/FPGA/arty_d/fe256_ooc`, 2026-09-16 21:50,
`PROGRAM=NO`, not on `r2_top`): LUT **13003** (LUT-as-logic; LUT-as-memory 0)
FF **11504** RAMB **0** DSP 0. Unplaced `create_clock -period 10`: WNS
**−75.723** TNS −63466.285 WHS +0.266. Worst path `hit_prov_reg[0][2]/C` →
`pref_reg[0]/R`, **Logic Levels 144** (logic 29.176 ns + unplaced route
55.906 ns). ROM `256x256` Implemented As **LUT** despite `ram_style=block`.
D-FE256-ARCH-RCA-01: ANALYSIS_COMPLETE; `DO_NOT_BIND`. JSON
`D_FE256_ARCH_RCA_01.json`. Historical mapping FAIL; retained.

FE256 OOC R1 (`fe256_query_path` HW-R1, `D:/FPGA/arty_d/fe256_ooc_r1`,
2026-09-16 22:22 synth / 22:25 isolated route, `PROGRAM=NO`, not on `r2_top`):
XSim 256/256 bit-exact (B TB; ≠ `FE256_PASS`). Synth LUT **2985** FF **3864**
RAMB36 **1** RAMB18 0 DSP 0; unplaced WNS **+0.568** TNS 0 WHS +0.177; worst
`qb_reg[1][1]/C` → `fq_node_reg[0][10]/S`, **Logic Levels 11**. Isolated
place/route WNS **+0.223** WHS +0.092; LUT 2953 FF 3866; 0 routing errors.
`store_q_reg` implemented as RAMB36E1 (Synth 8-7052). Still `DO_NOT_BIND` freeze.
Not `TIMING_PASS`. JSON `D_FE256_HW_R1.json`.

FE256 shadow-bind (`arty_a7_r2_top_fe256_r1_candidate`,
`D:/FPGA/arty_d/fe256_r1_shadow`, 2026-09-16 22:59 route, `PROGRAM=NO`):
integrated XSim 256/256 vs B gold (D TB; ≠ `FE256_PASS`). Routed WNS **+0.368**
TNS 0 WHS **+0.037**; LUT **9360** FF **9695** RAMB36 **17** RAMB18 1 DSP 8.
Worst setup `u_q/m2_r_reg` → `theta_reg[17][7]` 11 levels. Freeze DCP
`b48b7c8858a39d2a7da0e005b1fb0cc01c2de6e0b1e829f2dbe14531a4b73388` unchanged.
JSON `D_FE256_R1_SHADOW_BIND.json`. Promoted as **new** freeze
`R2_FE256_R1_INTEGRATED_FREEZE` (DCP
`858d0e997214e36074cc67f66f42af85c7f4da18f0590148ea509e8bb276d6dd`). Old freeze
`R2_TOP_ROUTE_BASELINE_WHS_0P021` DCP `b48b7c88…` PRESERVED. `PROGRAM=NO`. Not
`FE256_PASS` / `TIMING_PASS`.

FE256 engine **reference** (`FE256_R1_REFERENCE_FREEZE`, isolated OOC DCP
`f25fdf64596a5fd0b02250f129b96abdc75a32703d146acb7894d652251762c7`): RTL
`4c69e8fb…` store `6a1815c6…`. Isolated route WNS +0.223 LUT 2953 RAMB36=1.
Not a second product architecture. D-FE256-POST-GUARD-R1: FE256_DEVELOPMENT
CLOSED. JSON `D:/FPGA/arty_d/hold_r2/FE256_R1_REFERENCE_FREEZE/BASELINE.json`.
UART FE256 smoke (`tb_fe256_r1_uart_smoke`, 115200 8N1, no `tb_steer`): cases
0 and 255 bit-exact vs B hex; finish 13959585 ns. CANDIDATE ≠ `FE256_PASS` /
`BOARD_PASS`. JSON `D_UART_FE256_XSIM_SMOKE.json`.

Common-runtime QueryRecord → posting (`query_posting_bind`, not `fe256_query_path`):
XSim `M2_QUERY_POST_XSIM_PASS` rows=235 at 1153925 ns after UG901 1R BRAM
retemplate (`exact_directory` `699fb145…`, `posting_walk` `c1617ec2…`).
Isolated OOC `xc7a100tcsg324-1` 100 MHz: synth WNS **+2.945** RAMB36=4 RAMB18=1
LUT 496; isolated route WNS **+0.935** WHS **+0.124** LUT **492** FF **620**
RAMB36=4 RAMB18=1 DSP 0; 1105/1105 nets; 0 routing errors. DCP sha256
`bdca41d96b4cea9406cfd6b5e322e4294189cb30f05741311620e7db3c8df97a`.
Does not use FE256 256-case gold. Not on freeze tops. Not `M2_PASS` /
`TIMING_PASS`. JSON `D:/FPGA/arty_d/m2_query_post_ooc/D_M2_QUERY_POST_OOC.json`.

Common-runtime QueryRecord → bounded walk (`query_walk_bind`): XSim
`M3_QUERY_WALK_XSIM_PASS` hop1=122 at 194855 ns. Isolated OOC route WNS
**+1.899** WHS **+0.132** LUT **500** FF **629** RAMB36=4 RAMB18=1 DSP 0;
1167/1167 nets. DCP sha256
`d9a85433346814209bf15726a52a8b818a2194776c63252fa32a9ae1532386c0`.
`query_meta[8:5]` hop / `[10]` reverse are CANDIDATE packs. Not `M3_PASS`.
JSON `D:/FPGA/arty_d/m3_query_walk_ooc/D_M3_QUERY_WALK.json`.

Common-runtime QueryRecord → StructuredResult (`query_result_bind`): XSim
`M4_QUERY_RESULT_XSIM_PASS` hop1=122 at 198455 ns. Fail-closed: never
`ANSWER`/`UNKNOWN` from hop-1 walk; CRC/magic → `0x06`+`0x55`; else
`SEARCH_INCOMPLETE` `0x04`+`0x20` PARTIAL. `q_ready` implemented; `s_ready`
tied 1. Isolated OOC route WNS **+1.203** WHS **+0.135** LUT **558** FF **896**
RAMB36=4 RAMB18=1 DSP 0; 1484/1484 nets. DCP sha256
`430c9f66aabc984cf633a7a3210d09113930831b94a4e7d08c3bcd2ccb91e86a`.
Not `ASTRA_PASS`. JSON `D:/FPGA/arty_d/m4_query_result_ooc/D_M4_QUERY_RESULT.json`.

Common-runtime UART candidate (`arty_a7_r2_top_m4_query_result_candidate`,
`D:/FPGA/arty_d/m4_query_result_shadow`, 2026-09-17 00:22 route, `PROGRAM=NO`):
no `fe256_query_path`. Hierarchical XSim `M4_QUERY_RESULT_SHADOW_XSIM_PASS`
hop1=122 at 199735 ns (not FE256 gold). UART smoke 2/2 at 115200 8N1
`M4_QUERY_RESULT_UART_SMOKE_XSIM_PASS` finish 13881355 ns (no `tb_steer`).
Synth LUT **6590** FF **6565** RAMB36=20 RAMB18=2 DSP 8; unplaced WNS **+1.548**.
Routed WNS **+0.555** TNS 0 WHS **+0.049**; LUT **6421** FF **6277** RAMB36=20
RAMB18=2 DSP 8; 11387/11387 nets; 0 routing errors. Worst setup
`u_spear/spear/feat_r_reg[22]` → `sl_seq_reg[2][0]/CE` 7 levels. Freeze DCPs
`858d0e99…` / `b48b7c88…` unchanged. `DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP=YES`
on freeze; this candidate = NO dedicated engine. Not `ASTRA_PASS` /
`TIMING_PASS` / `BOARD_PASS`. JSON
`D:/FPGA/arty_d/m4_query_result_shadow/D_M4_QUERY_RESULT_SHADOW.json`.

Common-runtime + `mig0` candidate (`arty_a7_r2_top_m4_mig_candidate`,
`D:/FPGA/arty_d/m4_mig`, 2026-09-17 00:44 route, `PROGRAM=NO`): QueryRecord
path stays on 100 MHz; pack+FEM mux onto generated `mig0` `app_*` on `ui_clk`;
`calib` from MIG IP (not board-measured). Unplaced WHS **−1.631** recovered.
Routed WNS **+0.233** TNS 0 WHS **+0.016**; LUT **10609** FF **9773** RAMB36=4
RAMB18=2 DSP 8; 18686/18686 nets; 0 routing errors. Worst setup `u_q/m2_r_reg` →
`theta_reg[19][15]` 12 levels. No `fe256_query_path`. Freeze/`mig_uiclk`/`mig_tx`
DCPs not overwritten. Not `MIG_PASS` / `TIMING_PASS` / `BOARD_PASS`. JSON
`D:/FPGA/arty_d/m4_mig/D_M4_MIG.json`.

M4+mig0 bitstream (`arty_a7_r2_top_m4_mig_candidate.bit`, 2026-09-17 00:53,
then JTAG 00:59): size 2003005 B; sha256
`f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7`; DRC 0
Errors; Bitgen Completed Successfully. Freeze DCPs
`858d0e99…` / `b48b7c88…` and `mig_uiclk` / `mig_tx` unchanged. Not
`BOARD_PASS`.

JTAG program 2026-09-17 00:59 owner `PROGRAM=YES`: target
`localhost:3121/xilinx_tcf/Digilent/210319BE776EA` device `xc7a100t_0`;
Labtools End of startup **HIGH**; bit sha256 `f6a6091f…3ba368d7` match.
D does not self-stamp `PROGRAM_PASS`. Not `BOARD_PASS`. `PROGRAM.txt` at
`D:/FPGA/arty_d/m4_mig/PROGRAM.txt`. UART hop-1 smoke COM12 115200: 48 B
StructuredResult magic `0x4E52` status `0x04` reason `0x20` completeness
`0x02` txn=1 CRC16 `0x36F0` match. Fail-closed hop-1; not `ASTRA_PASS` /
`BOARD_PASS`.

Reprogram 2026-09-17 01:13 (FPGA SRAM overwritten by another session; on-disk
bit hash unchanged `f6a6091f…`): startup HIGH again. UART hop-1 reconfirmed
same 48 B `0x4E52`/`0x04`/`0x20` CRC `0x36F0`. UART pack board smoke 2/2
PA24-V-01 ACK `010000A5` + bad-magic NAK `0200015A` on COM12. CANDIDATE.
Not `PACK_ABI_24_24_PASS` / `MIG_PASS` / `BOARD_PASS`.
`UART_PACK_BOARD_SMOKE.txt`.

Pack/ABI-24 board sequential (2026-09-17 01:18, one bitstream, no per-case
reset): `PACK_ABI24_BOARD_SEQ_CANDIDATE` **2/24**. V-01/V-02 ACK
`010000A5`; V-03 NAK `0200085A` (`R_SENTINEL`); then UART timeouts /
R-04 `06014e52`. Diagnostic only. `UART_PACK24_BOARD.txt`.

Pack/ABI-24 board isolated (2026-09-17 01:27–01:37, 24 reprograms, same bit
`f6a6091f…`, POST_PROG=5 s): `PACK_ABI24_BOARD_ISOLATED_CANDIDATE` **14/24**.
10 fails: eight `R_BAD_MAGIC` `0200015A`; V-04/R-04 `R_UNSUP` `0200075A`.
Elapsed 616.953 s. Raw to B. Not `PACK_ABI_24_24_PASS`.
`UART_PACK24_ISO_BOARD.txt`.

Pack/ABI-24 dest-complete DUT (`pack_abi24_mig_dut`, 2026-09-17 00:49 XSim,
`PROGRAM=NO`): 24/24 vs B mem/expect through `pack_mig_bind` + `mig_ui_bram`
(not isolated `pack_loader` word-atomic model). Banner
`PACK_ABI24_MIG_DUT_XSIM_PASS` finish 21965 ns. Dest is UI stand-in, not
`mig0`. B TB unmodified. Not `PACK_ABI_24_24_PASS` / `MIG_PASS` / board.
JSON `D:/FPGA/arty_d/pack_abi24_mig_dut/D_PACK_ABI24_MIG_DUT.json`.

Do not freeze latency, cycles/hop, `ui_clk`, or OOC WNS from this table.

## Tóm tắt tiếng Việt

Arty A7-100T dùng XC7A100T, có 135 BRAM36 (~607.5 KiB raw), 256 MB DDR3L,
bus 16-bit, khoảng 333 MHz / 667 MT/s, peak lý thuyết ~1.334 GB/s. Peak này
không phải băng thông truy vấn graph thực tế. Không khóa latency DDR bằng số ns
hay số cycle nếu chưa đo trên MIG thật. COM, JTAG serial, đường dẫn Vivado và
license chỉ là local run metadata, không phải chân lý kiến trúc.
