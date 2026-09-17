---
version: "1.1-candidate"
owner: AGENT_D
status: AUDITED_CANDIDATE
category: OPERATIONAL
last_modified: "2026-09-17T16:20:00+07:00"
---

# §30 — MILESTONE ROADMAP

> One milestone answers one primary causal question. Historical negative evidence
> is retained; milestone success cannot rewrite earlier FAIL evidence.

## 30.1 Evidence package law

Every milestone has at least four **control artifacts**:

```text
CONTRACT.md
RESULT.json
EVIDENCE.md
SHA256SUMS.txt
```

These are a minimum, not a maximum. A board/transport/memory milestone must also
retain the raw evidence needed to reproduce its claim, for example UART bytes,
program logs, bitstream/hash, timing/utilization reports, DDR readback, pack and
schema identities, test vectors and waveform traces.

Standard progression:

```text
SPEC / preregistration
→ independent/reference gold
→ RTL unit
→ XSim integration
→ OOC synth/timing
→ post-route when required
→ board only when silicon evidence is required
```

## 30.2 Arty MVP milestones

| # | Milestone | Primary causal question | Required output |
|---|---|---|---|
| M1 | **Runtime Pack ABI & Loader** | Can the production loader receive a versioned pack, commit it to DDR, drain outstanding writes, verify integrity/generation and read back sentinels? | loader + manifest/integrity + write-drain/readback evidence |
| M2 | **Exact Directory / Posting Index** | Can exact native IDs resolve to forward/reverse posting locations without semantic collision? | directory/index + full-key verification + cache/miss parity |
| M3 | **Bounded Retrieval / Walker** | Can a bounded walker retrieve direct/reverse/value/context/provenance and bounded multi-hop evidence with explicit completeness? | traversal + proof-parent tracking + SEARCH_INCOMPLETE behavior |
| M4 | **ASTRA Core** | Does ASTRA map machine evidence to legal proof/status/conflict/completeness outputs without utility/host override? | proof/status engine + attack vectors |
| M5 | **Full Evidence FE256** | Does the static semantic core pass all 256 preregistered FE256 cases plus Pack/ABI/runtime-load/readback requirements? | FE256/pack integrity evidence; 256 cases, not 256 nodes |
| M6 | **Human UART E2E** | Can human text pass through frozen host adapter→QueryRecord→UART→FPGA→StructuredResult→renderer with no host answer/proof authority? | 32-case human E2E + adapter hash/version |
| M7 | **NSPF Falsification** | Does behavior survive representational/timing/cache perturbations while remaining causally dependent on real support? | NSPF-X0 campaign |
| M8 | **Developmental Loop + Capability Binding** | Can executed physical experience create candidate relation/skill/failure state, survive reset/restore and transfer without teacher/host becoming truth authority? | bounded learning/skill/grounding/capability evidence |

## 30.3 Dependencies

```text
M1 → M2 → M3 → M4 → M5 → M6
                         ├→ M7
                         └→ M8 (with M6 and capability gate)
```

M7 and M8 may share infrastructure but their claims remain separate: static
semantic correctness does not prove developmental learning, and learning does
not retroactively certify FE256.

## 30.4 Resource-budget discipline

Any LUT/FF/BRAM/DSP table before synthesis is an **engineering estimate only**.
The actual budget is set by OOC/post-route reports for the exact candidate.
Reserve capacity for MIG/interface buffers, event FIFOs, proof scratch and
future debug/observability; do not allocate all 135 BRAM36 to semantic cache.

The implementation clock is likewise a measured design parameter. The Arty
board provides a 100 MHz system oscillator, but an internal semantic/MIG domain
may differ. Frequency is not semantic identity.

## 30.5 Developmental continuation after M8

Only after M8 evidence should the project consider:

```text
multi-walker / HBM partitioning
optional HDC proposal sidecar
advanced cache admission/profiler
sensor concept formation at larger scale
offline Semantic Hardware Specialization
DFX research
```

These are not prerequisites for the Arty correctness MVP.

## 30.6 M1 first slice — scientific gate (2026-09-16)

Classification: **architectural RCA for owned-txn M1**, not a big-bang A01–A17 build.
XSim ≠ board. One unknown per patch.

| Slot | Content |
|---|---|
| **OBSERVATION** | No production pack loader RTL exists in this candidate tree. M1 causal question is runtime pack receive → DDR commit → write-drain → integrity → sentinel readback. GOAL_AGENT_D path `rtl/native_graph/loader/pack_loader.v` would collide with frozen A7-NATIVE-GRAPH RTL. |
| **UNKNOWN** | Agent B PACK_ABI_24 gold is now in-tree (`verification/pack_abi24/`) but the 24-case hardware compare is not run. RegionDescriptor wire layout is not frozen. Vivado MCP is not in this Cursor session namespace. MIG `app_data` width UNKNOWN until generated IP is read. |
| **H_CANDIDATE** | Treat `header_length=128` as the M1 wire size: CRC over bytes `[0:112)`, CRC field at `[112:116)`, reserved `[116:128)` must be zero. Live [§04.6] locks 128 B / reserved=12; 132 B is a failed candidate. RegionDescriptor is 32 bytes as in [§33.9]. First XSim uses a memory **model**, not MIG. Integrity labels: `FPGA_MANIFEST_ID_VERIFIED` + `FPGA_PAGE_CRC_VERIFIED` + `FPGA_SENTINEL_READBACK_VERIFIED`. Not `FPGA_SHA256_VERIFIED`. |
| **H_RIVAL** | Pack/ABI-24 hardware compare fails (wrong CRC endianness/region layout) even though header length matches. |
| **FALSIFIER** | Agent B gold + PACK_ABI_24. First local falsifier: ACK while `wr_outstanding!=0` (R07). Valid pack must not ACK before drain+sentinel. Mismatch packs must not flip `active_generation`. |
| **UNIT** | `pack_loader` + CRC32 ISO-HDLC + mock memory. Not UART, not MIG, not SHA-256, not FE256. |
| **CONTROL** | Same five preregistered vectors before any extra corpus. Candidate Python gold in `python/m1/` is **CANDIDATE**, not Agent B verified FACT. |
| **METRICS** | XSim vector pass/fail; OOC LUT/FF/BRAM vs engineering estimate ≤500 LUT / 2 BRAM; `load_ack` only when outstanding writes = 0. |

Path lock for this candidate: `rtl/native_ai/loader/` per [§33.4]. `rtl/native_graph/` remains the frozen A7 lane and is not overwritten.

## 30.7 M1 first-slice execution (2026-09-16)

| Gate | Result | Class |
|---|---|---|
| XSIM_SMOKE (5 vectors) | PASS (D-01 and D-02) | FACT (XSim log) |
| OOC synth D-01 BRAM | PASS, 644 LUT, 652 FF, 0.5 BRAM tile, WNS -1.663 ns | FACT |
| OOC synth D-02 CRC-byte | PASS, 552 LUT, 678 FF, 0.5 BRAM tile, 0 DSP, WNS **+2.004 ns** | FACT unplaced OOC; `HD.CLK_SRC` unset |
| OOC 100 MHz | constraints reported MET at synth; not post-route | CANDIDATE; not TIMING_PASS |
| PACK_ABI_24 / board | not run | UNKNOWN pending 24-case compare / silicon |

D-01 causal class: FF array `buf_w[80]` → simple-dual-port BRAM. D-02 causal class: 4-byte CRC combo → 1 `crc_byte`/cycle + `S_CRC_WAIT`. Do not promote OOC WNS to board timing.

## 30.8 D-06 bind status (2026-09-16, CANDIDATE)

Not `MIG_PASS` / `BOARD_PASS` / `TIMING_PASS` / `FEM_PERSIST_PASS`. `PROGRAM=NO`.

| Gate | Result | Class |
|---|---|---|
| `PACK_ABI24_XSIM_PASS` 24-case | exists (pack_loader word-atomic model) | CANDIDATE ≠ `PACK_ABI_24_24_PASS` |
| `PACK_ABI24_MIG_DUT_XSIM_PASS` 24/24 dest-complete | `pack_mig_bind` + `mig_ui_bram` vs B mem/expect; finish 21965 ns | CANDIDATE ≠ `PACK_ABI_24_24_PASS` |
| `FE256_XSIM_PASS` 256/256 | exists (R1 DUT vs B gold TB) | CANDIDATE; no gold oracle; ≠ `FE256_PASS` |
| FE256 OOC R0 `xc7a100t` 100 MHz | LUT 13003 FF 11504 RAMB 0; unplaced WNS −75.723 (Logic Levels **144**) | historical FAIL mapping; retained; not on r2_top |
| FE256 OOC R1 `xc7a100t` 100 MHz | LUT 2985 FF 3864 RAMB36=1; unplaced WNS **+0.568** (Logic Levels **11**); isolated route WNS **+0.223** | CANDIDATE isolated; freeze still unbound |
| D-FE256-R1-SHADOW-BIND | `arty_a7_r2_top_fe256_r1_candidate`; XSim 256/256; route WNS **+0.368** WHS **+0.037**; RAMB36=17 | promoted into 30.13; engine reference 30.14 |
| D-FE256-ARCH-RCA-01 | ANALYSIS_COMPLETE; E=B+C; BENCHMARK KEEP; RTL REARCHITECT; `DO_NOT_BIND` | RCA closed into HW-R1; see 30.11 |
| `PACK_MIG_UI32_XSIM_PASS` 5/5 | dest-complete through `mig_ui32` | CANDIDATE ≠ `MIG_PASS` |
| `FEM_MIG_UI32_XSIM_PASS` | FEM muxed with pack onto UI stand-in | CANDIDATE ≠ `FEM_PERSIST_PASS` |
| fabric `arty_a7_r2_top` post-synth bag2+`uart_tx` | WNS +1.549 TNS 0; SPEAR `desc_ok` | CANDIDATE |
| fabric `arty_a7_r2_top` post-route bag2+`uart_tx` | WNS +0.375 WHS +0.021; Vivado MET | CANDIDATE; not bitstream; not TIMING_PASS |
| `UART_WORD_XSIM_PASS` | 2/2 TX→RX loopback | CANDIDATE ≠ board |
| `UART_PACK_XSIM_PASS` | 2/2 UART pack ACK `010000A5` / NAK `0200015A` dest-complete | CANDIDATE ≠ board |
| `UART_FE256_XSIM_SMOKE` | 2/2 cases 0+255 via 115200 UART on shadow candidate (no `tb_steer`) | CANDIDATE ≠ `FE256_PASS` ≠ board |
| `M2_DIR_XSIM_PASS` | hit=235 miss_ok=4 (`tb_exact_directory`) | CANDIDATE ≠ `M2_PASS` |
| `M2_POST_XSIM_PASS` | rows=235 (`tb_posting_walk`) | CANDIDATE ≠ `M2_PASS` |
| `M3_WALK_XSIM_PASS` | hop1 (`tb_bounded_walk`) | CANDIDATE ≠ `M3_PASS` |
| `M2_QUERY_POST_XSIM_PASS` | QueryRecord → `posting_walk` rows=235 at 1153925 ns (UG901 1R); no FE256 engine | CANDIDATE ≠ `M2_PASS` |
| M2 QueryRecord OOC R1 | LUT 492 FF 620 RAMB36=4 RAMB18=1 DSP 0; isolated route WNS **+0.935** WHS **+0.124** | CANDIDATE isolated; freeze unbound |
| `M3_QUERY_WALK_XSIM_PASS` | QueryRecord → `bounded_walk` hop1=122 at 194855 ns | CANDIDATE ≠ `M3_PASS` |
| M3 QueryRecord OOC R1 | LUT 500 FF 629 RAMB36=4 RAMB18=1 DSP 0; isolated route WNS **+1.899** WHS **+0.132** | CANDIDATE isolated; freeze unbound |
| `M4_QUERY_RESULT_XSIM_PASS` | QueryRecord → StructuredResult hop1=122; fail-closed 0x04/0x06 | CANDIDATE ≠ `ASTRA_PASS` |
| M4 QueryResult OOC R1 | LUT 558 FF 896 RAMB36=4 RAMB18=1 DSP 0; isolated route WNS **+1.203** WHS **+0.135** | CANDIDATE isolated; freeze unbound |
| `M4_QUERY_RESULT_SHADOW_XSIM_PASS` | UART candidate top hop1=122; no FE256 engine | CANDIDATE ≠ `ASTRA_PASS` |
| M4 UART candidate route | LUT 6421 FF 6277 RAMB36=20 RAMB18=2 DSP 8; WNS **+0.555** WHS **+0.049** | CANDIDATE; freeze unbound; not TIMING_PASS |
| M4+mig0 candidate route | LUT 10609 FF 9773 RAMB36=4 RAMB18=2 DSP 8; WNS **+0.233** WHS **+0.016** | CANDIDATE; `mig0` dest; not MIG_PASS |
| M4+mig0 bitstream | 2003005 B; DRC 0 Errors; `write_bitstream` then JTAG program | CANDIDATE ≠ `BOARD_PASS` |
| `arty_a7_mig_top` post-synth (old Q* @ 100 MHz) | WNS −1.482 `mask_r→q_sel` | CANDIDATE; superseded |
| `arty_a7_mig_top` post-route (pre-bag2, pre-`ui_clk` Q*) | WNS −1.160 TNS −27.251; WHS +0.028 | CANDIDATE; not bitstream |
| `arty_a7_mig_top` post-synth bag2+`ui_clk` | setup WNS +1.277 TNS 0; `clk_pll_i` +3.575 | CANDIDATE |
| `arty_a7_mig_top` post-route bag2+`ui_clk` | WNS +1.032 WHS +0.008; Vivado MET | CANDIDATE; not bitstream; not TIMING_PASS |
| `arty_a7_mig_top` post-synth +`uart_tx` CDC (`mig_tx`) | setup WNS +1.277 TNS 0; `clk_pll_i` +3.575; unplaced WHS −1.631 | CANDIDATE |
| `arty_a7_mig_top` post-route +`uart_tx` CDC (`mig_tx`) | WNS +0.673 WHS +0.008; Vivado MET; `clk_pll_i` +2.377; `u_cdc_tx` max_delay +6.929 | CANDIDATE; not bitstream; not TIMING_PASS |
| `mig_tx` `report_cdc` | handshake `CDC-3` ASYNC_REG; `CDC-1`/`CDC-7` dominated by async `ck_rst` + MIG PHY | CANDIDATE; not a CDC pass |
| UART CDC `word_cdc32` | handshake `set_max_delay`; `u_cdc_tx` present in flatten | CANDIDATE |
| generated `mig0` | instantiated; pack+FEM muxed | CANDIDATE; no calib |

C bag2 `P_EXP1`/`P_EXP2` consumed (`d4f64e65`). `mask_r→q_sel` is not the flatten worst. Do not freeze `ui_clk` or WNS. `PROGRAM=NO`. Not `TIMING_PASS`.

## 30.9 D-TIMING-HOLD-FREEZE-R2 (2026-09-16, two rounds only)

Frozen working fabric: `R2_TOP_ROUTE_BASELINE_WHS_0P021`
(`D:/FPGA/arty_d/hold_r2/R2_TOP_ROUTE_BASELINE_WHS_0P021/post_route.dcp`
sha256 `b48b7c8858a39d2a7da0e005b1fb0cc01c2de6e0b1e829f2dbe14531a4b73388`).
WNS +0.375 TNS 0 WHS +0.021 THS 0. Vivado MET. Not `TIMING_PASS`.

| Round | Method | WNS | WHS | vs freeze |
|---|---|---:|---:|---|
| 1 | `phys_opt_design -hold_fix` | +0.375 | +0.021 | 0 / 0; LUT1/ZHOLD gain 0 |
| 2 | `route_design -directive Explore` + `phys_opt -directive ExploreWithHoldFix` | +0.375 | +0.021 | 0 / 0; hold_fix skipped (WHS already ≥ 0) |

SELECTED = BASELINE. `HOLD_OPTIMIZATION_STOPPED`. `BASELINE_ACCEPTED`.
No ROUND 3. No RTL/constraint change. `PROGRAM=NO`.

## 30.10 D-FE256-ARCH-RCA-01 (2026-09-16, ANALYSIS_COMPLETE)

OOC evidence only. Unplaced. Not `FE256_PASS` / `TIMING_PASS` / `BOARD_PASS` /
`FINAL_PASS`. Gold not imported. Not instantiated on frozen
`R2_TOP_ROUTE_BASELINE_WHS_0P021`. `PROGRAM=NO`.

| Field | Value |
|---|---|
| PRIMARY_QUESTION | **E** = B+C (RTL poor + FPGA mapping wrong). Not A. D not primary. |
| BENCHMARK_VALIDITY | `VALID_WITH_LIMITATIONS` |
| BENCHMARK_ACTION | KEEP (256 cases / Q-eval law) |
| ROOT_CAUSE_PRIMARY | `RTL_MICROARCHITECTURE` (`S_FINISH` combo → `pref_reg/R`, 144 levels) |
| ROOT_CAUSE_SECONDARY | `MEMORY_MAPPING` (async `rom[a]` → LUT; `ram_style=block` already present) |
| RTL_ACTION | REARCHITECT (FE256_HW_R1 after owner auth) |
| INTEGRATION_ACTION | `DO_NOT_BIND` |
| Logic Levels (worst path) | **144** (`hit_prov_reg[0][2]/C` → `pref_reg[0]/R`) |
| “723 levels” | **not a Vivado levels metric**; WNS decimal −75.723 / net 79.723 ns |
| JSON | `D:/FPGA/arty_d/fe256_ooc/D_FE256_ARCH_RCA_01.json` |

No project law requires one-cycle FE256 (`RTL_PIPELINE_DEPTH=IMPLEMENTATION_DEFINED`;
XSim handshake). `(* ram_style="block" *)` alone cannot infer BRAM. Owner authorized
FE256_HW_R1; see 30.11. RCA `DO_NOT_BIND` remains until a later bind gate.

## 30.11 D-FE256-HW-R1 (2026-09-16, isolated CANDIDATE)

Owner-authorized RTL rearchitecture. Isolated OOC + XSim only. Not instantiated
on frozen `R2_TOP_ROUTE_BASELINE_WHS_0P021`. Gold / 256-case set / QueryRecord /
StructuredResult unchanged. `PROGRAM=NO`. Not `FE256_PASS` / `TIMING_PASS` /
`BOARD_PASS` / `FINAL_PASS`.

| Field | Value |
|---|---|
| RTL | sync 1R UG901 BRAM (`store_q <= store[store_addr]`); no async reset on RAM process; no `S_FINISH` 16×16 combo |
| XSim | 256/256 bit-exact vs B TB; FAIL=0; mean **581.36** cycles/query (TB 10 ns; 1488285 ns wall) |
| OOC synth | LUT 2985 FF 3864 RAMB36=1 RAMB18=0 DSP 0; WNS **+0.568** TNS 0 WHS +0.177; levels **11** |
| Isolated route | LUT 2953 FF 3866 RAMB36=1; WNS **+0.223** TNS 0 WHS +0.092; 5876/5876 nets; 0 routing errors |
| Worst path (synth) | `qb_reg[1][1]/C` → `fq_node_reg[0][10]/S` (CRC/GUARD, not uniqueness cone) |
| MEMORY_INFERENCE | `store_q_reg` RAMB36E1 (Synth 8-7052 Block RAM) |
| INTEGRATION_ACTION | engine reference 30.14; integrated top freeze 30.13 |
| JSON | `D:/FPGA/arty_d/fe256_ooc_r1/D_FE256_HW_R1.json` |

R0 mapping evidence is retained in 30.8 / 30.10. Do not freeze R1 OOC WNS into
`r2_top`. Owner later authorized INTEGRATION_CANDIDATE_ONLY shadow-bind; see 30.12.

## 30.12 D-FE256-R1-SHADOW-BIND (2026-09-16, INTEGRATION_CANDIDATE)

Isolated fabric copy. Frozen `R2_TOP_ROUTE_BASELINE_WHS_0P021` and
`arty_a7_r2_top.sv` not overwritten. `PROGRAM=NO`. Not `FE256_PASS` /
`TIMING_PASS` / `BOARD_PASS`. B gold/TB files not modified.

| Field | Value |
|---|---|
| Top | `arty_a7_r2_top_fe256_r1_candidate` + `uart_fe256_host` (magic `0x4E51` vs pack `NAI1`) |
| Store vs RAMB36 | declared 256×256; 218 live; unread `edge_id[31:0]`; 77 varying+read bits; `store_q_reg` RAMB36E1 36/36 |
| XSim | 256/256 hierarchical (`tb_steer`); UART smoke 2/2 cases 0+255 at 13959585 ns |
| Routed 100 MHz | WNS **+0.368** TNS 0 WHS **+0.037** THS 0; LUT 9360 FF 9695 RAMB36=17 RAMB18=1 DSP 8 |
| vs freeze | ΔLUT +3197 ΔFF +4507 ΔRAMB36 +1 ΔWNS −0.007; freeze DCP sha `b48b7c88…` unchanged |
| Worst setup | `u_q/m2_r_reg/CLK` → `u_q/theta_reg[17][7]/D` (11 levels; Q* DSP, not FE256 cone) |
| JSON | `D:/FPGA/arty_d/fe256_r1_shadow/D_FE256_R1_SHADOW_BIND.json` |

B-CLASS 20260916T160212: absorb as INTEGRATION_CANDIDATE only; no ladder
PASS. Owner later authorized `R2_FE256_R1_INTEGRATED_FREEZE` (30.13) without
overwriting `R2_TOP_ROUTE_BASELINE_WHS_0P021`. Engine reference freeze is 30.14.
Do not PROGRAM.

## 30.13 D-FE256-R1-PROMOTION-FREEZE (2026-09-16, INTEGRATED_BASELINE_FREEZE)

Owner-authorized **new** freeze revision. Previous freeze **preserved**.
`PROGRAM=NO`. Not `FE256_PASS` / `TIMING_PASS` / `MIG_PASS` / `BOARD_PASS` /
`FINAL_PASS`.

| Field | Value |
|---|---|
| OLD_FREEZE | `R2_TOP_ROUTE_BASELINE_WHS_0P021` DCP sha256 `b48b7c8858a39d2a7da0e005b1fb0cc01c2de6e0b1e829f2dbe14531a4b73388` PRESERVED=YES |
| NEW_FREEZE | `R2_FE256_R1_INTEGRATED_FREEZE` |
| Top | `arty_a7_r2_top_fe256_r1_candidate` |
| DCP sha256 | `858d0e997214e36074cc67f66f42af85c7f4da18f0590148ea509e8bb276d6dd` |
| XSim | `FE256_SHADOW_BIND_XSIM` 256/256 FAIL=0 (simulation only) |
| Routed | WNS **+0.368** TNS 0 WHS **+0.037** THS 0; routing errors 0 |
| Resource (Vivado `util_route.rpt`) | Slice LUT **9360**; FF **9695**; Block RAM Tile **17.5**; RAMB36/FIFO **17** (RAMB36E1 only); RAMB18 **1** (RAMB18E1 only); DSP **8** |
| CDC | single `sys_clk_pin`; `report_cdc` empty; `no_clock`=0 |
| JSON | `D:/FPGA/arty_d/hold_r2/R2_FE256_R1_INTEGRATED_FREEZE/BASELINE.json` |

Dedicated FE256 is instantiated on this freeze top. That is **not** a
permanent product-architecture decision; see 30.14.

## 30.14 D-FE256-POST-GUARD-R1 (2026-09-16, ACTIVE_AFTER_FE256_R1)

`FE256_R1_REFERENCE_FREEZE` is a **reference implementation**, not automatically
the final production reasoning path. Isolated OOC DCP copied (not moved) from
`fe256_ooc_r1`. Do not overwrite. Do not polish FE256 R1 for LUT/WNS.

Wake FE256 R1 only for functional regression, evidence corruption, owner
experiment, or common-runtime comparison. No FE256-only feature creep without
owner. Target: QueryRecord → directory/posting → bounded walk → ASTRA →
StructuredResult **without** a dedicated FE256 engine. If common runtime later
reaches 256/256 + legal timing: `DEDICATED_FE256_ENGINE = RETIRE_FROM_FINAL_TOP`.
If it fails FE256: classify DIRECTORY\|POSTING\|BOUNDED_WALK\|CONTEXT\|PROVENANCE\|IDENTITY\|CONFLICT\|COMPLETENESS\|ASTRA_STATUS\|MEMORY\|TIMING and repair the common runtime. Do not weaken gold.

| Field | Value |
|---|---|
| Label | `FE256_R1_REFERENCE_FREEZE` |
| RTL sha256 | `4c69e8fbfafe7d75d667b653639bec453c0510bf7d032ec6ce27b870568d0241` |
| store sha256 | `6a1815c6be9baf5bdbcc5a74209f9e9b9f82a8230996e36b520a298165150ee8` |
| Isolated DCP sha256 | `f25fdf64596a5fd0b02250f129b96abdc75a32703d146acb7894d652251762c7` |
| Isolated route | WNS +0.223 WHS +0.092 LUT 2953 FF 3866 RAMB36=1 DSP 0 |
| FE256_DEVELOPMENT | CLOSED |
| D_MAIN_ROADMAP | RESUMED (M2 first) |
| JSON | `D:/FPGA/arty_d/hold_r2/FE256_R1_REFERENCE_FREEZE/BASELINE.json` |

## 30.15 D-M2-QUERY-POSTING-BIND (2026-09-16, CANDIDATE)

POST-GUARD roadmap item 1: common QueryRecord → directory/posting. Isolated
XSim only. Does **not** instantiate `fe256_query_path`. Does not modify FE256
256-case gold, B gold, status law, QueryRecord layout, or freeze DCPs.
`PROGRAM=NO`. Not `M2_PASS` / `FE256_PASS` / `TIMING_PASS` / `BOARD_PASS`.

| Field | Value |
|---|---|
| RTL | `rtl/native_ai/directory/query_posting_bind.sv` sha256 `fb8eea24f9e15142c44e3ad6bd94a4000bba9f84e4b429c7fa6855629cefddaf` |
| TB | `tb/native_ai/directory/tb_query_posting_bind.sv` sha256 `c8819ec51ed0e18d9180a286a920736d02fb0d65853d7c47aaed994ce0a5adf8` |
| XSim | `M2_QUERY_POST_XSIM_PASS` rows=235 FAIL=0; finish 1153925 ns (after UG901 1R) |
| Vectors | `post_expect.hex` fwd+rev; magic fail; CRC16-CCITT-FALSE fail; `active_id_max=0` oop |
| Direction pack | `query_meta[10]` = reverse (CANDIDATE; [§04.3] `[11:10]` not otherwise locked) |
| Freeze tops | unchanged; `bounded_walk` on integrated freeze remains tied-off |
| FE256_DEVELOPMENT | CLOSED |
| JSON | `D:/FPGA/arty_d/m2_query_posting/D_M2_QUERY_POSTING.json` |

Next D: isolated OOC mapping is 30.16. Owner auth required before freeze-top bind.
T2/MIG remains open.

## 30.16 D-M2-QUERY-POST-OOC (2026-09-16, isolated CANDIDATE)

UG901 sync 1R BRAM on D-owned `exact_directory` / `posting_walk` (no async reset
on RAM). Isolated OOC of `query_posting_bind`. Not on freeze tops. Not FE256
engine. `PROGRAM=NO`. Not `M2_PASS` / `TIMING_PASS` / `BOARD_PASS`.

| Field | Value |
|---|---|
| dir RTL sha256 | `699fb145720259c5b720b21213a19eaad4f1bb46110e0d441d2dc354d58a3d28` |
| post RTL sha256 | `c1617ec259dac3bfe4f752bc2669b83dc3aa66526a167d12836c1276c559d59a` |
| bind RTL sha256 | `fb8eea24f9e15142c44e3ad6bd94a4000bba9f84e4b429c7fa6855629cefddaf` (unchanged) |
| XSim after retemplate | DIR 235+4; POST 235; QUERY_POST 235 @1153925 ns; M3 hop1 |
| OOC synth | LUT 496 FF 617 RAMB36=4 RAMB18=1 DSP 0; WNS **+2.945** levels 7 |
| Isolated route | LUT **492** FF **620** RAMB36=4 RAMB18=1 DSP 0; WNS **+0.935** WHS **+0.124**; 1105/1105; 0 errors |
| Route DCP sha256 | `bdca41d96b4cea9406cfd6b5e322e4294189cb30f05741311620e7db3c8df97a` |
| MEMORY_INFERENCE | `rom_q_reg` / `post_q_reg` RAMB (Synth 8-7052); not LUT ROM |
| JSON | `D:/FPGA/arty_d/m2_query_post_ooc/D_M2_QUERY_POST_OOC.json` |

Next D: M3 QueryRecord bind is 30.17. Owner auth before freeze-top bind.
Do not polish FE256. T2/MIG remains open.

## 30.17 D-M3-QUERY-WALK-BIND (2026-09-16, isolated CANDIDATE)

QueryRecord → `bounded_walk`. Isolated XSim + OOC. Not FE256 engine. Not on
freeze tops. `incomplete` is a walker observable, not an ASTRA status.
`PROGRAM=NO`. Not `M3_PASS` / `TIMING_PASS` / `BOARD_PASS`.

| Field | Value |
|---|---|
| RTL sha256 | `3972af8baa9c3dff0f472a53258834d7f2eb8f5a980d4777efdc8fafe746a3aa` |
| XSim | `M3_QUERY_WALK_XSIM_PASS` hop1=122 FAIL=0; finish 194855 ns |
| Direction / hops | `query_meta[10]` reverse; `query_meta[8:5]` hop_budget (CANDIDATE) |
| OOC synth | LUT 505 FF 624 RAMB36=4 RAMB18=1 DSP 0; WNS **+2.955** |
| Isolated route | LUT **500** FF **629** RAMB36=4 RAMB18=1 DSP 0; WNS **+1.899** WHS **+0.132**; 1167/1167; 0 errors |
| Route DCP sha256 | `d9a85433346814209bf15726a52a8b818a2194776c63252fa32a9ae1532386c0` |
| JSON | `D:/FPGA/arty_d/m3_query_walk_ooc/D_M3_QUERY_WALK.json` |

Next D: StructuredResult pack is 30.18. Owner auth before freeze-top bind.
T2/MIG remains open.

## 30.18 D-M4-QUERY-RESULT-BIND (2026-09-17, isolated CANDIDATE)

QueryRecord → `query_walk_bind` → 48-byte StructuredResult. `q_ready` is live;
`s_ready` is tied 1 (no extra stream). Fail-closed ASTRA pack: hop-1 walk does
not establish completeness, so **never** `ANSWER`/`UNKNOWN`. Not FE256 engine.
`PROGRAM=NO`. Not `ASTRA_PASS` / `TIMING_PASS` / `BOARD_PASS`.

| Field | Value |
|---|---|
| RTL sha256 | `9529fd2792440fc38c5687bedc40fe90034ac789f7aaa2f77d5ebab954c2b036` |
| XSim | `M4_QUERY_RESULT_XSIM_PASS` hop1=122 FAIL=0; finish 198455 ns |
| Status map | CRC/magic → `0x06`+`0x55` `NOT_APPLICABLE`; else `0x04`+`0x20` PARTIAL |
| OOC synth | LUT 564 FF 893 RAMB36=4 RAMB18=1 DSP 0; WNS **+2.969** |
| Isolated route | LUT **558** FF **896** RAMB36=4 RAMB18=1 DSP 0; WNS **+1.203** WHS **+0.135**; 1484/1484; 0 errors |
| Route DCP sha256 | `430c9f66aabc984cf633a7a3210d09113930831b94a4e7d08c3bcd2ccb91e86a` |
| JSON | `D:/FPGA/arty_d/m4_query_result_ooc/D_M4_QUERY_RESULT.json` |

Next D: T2/MIG; owner auth before freeze-top bind or bitstream.

## 30.19 D-M4-QUERY-RESULT-SHADOW (2026-09-17, isolated CANDIDATE)

NEW Arty candidate `arty_a7_r2_top_m4_query_result_candidate`: UART QueryRecord
(`uart_fe256_host` packing only) → `query_result_bind`. No `fe256_query_path`.
Does not overwrite freeze tops. Fail-closed pack unchanged. `PROGRAM=NO`.
B-CLASS `20260916T170724` on isolated M4 pack absorbed as CANDIDATE only.

| Field | Value |
|---|---|
| Hierarchical XSim | `M4_QUERY_RESULT_SHADOW_XSIM_PASS` hop1=122; finish 199735 ns |
| UART smoke | `M4_QUERY_RESULT_UART_SMOKE_XSIM_PASS` 2/2; 115200; 13881355 ns |
| Synth | LUT 6590 FF 6565 RAMB36=20 RAMB18=2 DSP 8; WNS **+1.548** |
| Isolated route | LUT **6421** FF **6277** RAMB36=20 RAMB18=2 DSP 8; WNS **+0.555** WHS **+0.049**; 11387/11387; 0 errors |
| Route DCP sha256 | `f81b2e6582d0018c526d4b12e2a9a0ba3e28137c56124a6db5241d27450484b2` |
| Candidate RTL sha256 | `d622e8aa12a9df0225b0f428d41487447966f6aa8fd9eb91475e88f8688be4f2` |
| JSON | `D:/FPGA/arty_d/m4_query_result_shadow/D_M4_QUERY_RESULT_SHADOW.json` |

Next D: FEM persist / Pack-ABI24 DUT compare. Owner auth before freeze-top bind or bitstream.

## 30.20 D-M4-MIG-CANDIDATE (2026-09-17, isolated CANDIDATE)

NEW Arty candidate `arty_a7_r2_top_m4_mig_candidate`: QueryRecord→StructuredResult
on 100 MHz + pack/FEM on generated `mig0` `ui_clk`. UART CDC `word_cdc32`.
No `fe256_query_path`. Does not overwrite freeze / `mig_uiclk` / `mig_tx`.
`PROGRAM=NO`. `calib` is IP output, not board evidence. Not `MIG_PASS`.

| Field | Value |
|---|---|
| Synth | LUT 11111 FF 10102 RAMB36=4 RAMB18=2 DSP 8; WNS **+1.277**; unplaced WHS **−1.631** |
| Isolated route | LUT **10609** FF **9773** RAMB36=4 RAMB18=2 DSP 8; WNS **+0.233** WHS **+0.016**; 18686/18686; 0 errors |
| Route DCP sha256 | `91c9f08409cd7a5fc2822e99688562dcd8331353430077fbbb3b66ed9216d2ce` |
| Candidate RTL sha256 | `9e63e9702a2339c95a3a53cb3e1f655e8d24e7b1fb4f32892ccbc9298dffdeaf` |
| JSON | `D:/FPGA/arty_d/m4_mig/D_M4_MIG.json` |

Next D: FEM persist media/recovery. Owner auth before PROGRAM.

## 30.21 D-PACK-ABI24-MIG-DUT (2026-09-17, CANDIDATE)

24 B-owned Pack/ABI-24 cases through `pack_mig_bind` dest-complete
(`mig_ui_bram`, not isolated `pack_loader` word-atomic model). B TB
`tb_pack_abi24_xsim_compare.sv` not modified. Dest-complete = dest
readback + matching txn/generation. `PROGRAM=NO`. Not
`PACK_ABI_24_24_PASS`. Dest is UI stand-in, not generated `mig0`.

| Field | Value |
|---|---|
| XSim | `PACK_ABI24_MIG_DUT_XSIM_PASS` 24/24; finish **21965 ns** |
| DUT | `pack_abi24_mig_dut` → `pack_mig_bind` + `mig_ui_bram` |
| TB | `tb/native_ai/loader/tb_pack_abi24_mig_dut.sv` (D-owned) |
| JSON | `D:/FPGA/arty_d/pack_abi24_mig_dut/D_PACK_ABI24_MIG_DUT.json` |

Next D: FEM persist media/recovery. Owner auth before PROGRAM.

## 30.22 D-M4-MIG-BITSTREAM (2026-09-17, CANDIDATE)

`write_bitstream` from `m4_mig/post_route.dcp` into
`D:/FPGA/arty_d/m4_mig/arty_a7_r2_top_m4_mig_candidate.bit`. DRC 0 Errors.
Compression saved 14584128 bits. No `open_hw_manager`. Freeze /
`mig_uiclk` / `mig_tx` DCPs not overwritten. `PROGRAM=NO`. Not
`BOARD_PASS` / `TIMING_PASS` / `MIG_PASS`.

| Field | Value |
|---|---|
| Bit size | 2003005 B |
| Bit sha256 | `f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7` |
| Source DCP sha256 | `91c9f08409cd7a5fc2822e99688562dcd8331353430077fbbb3b66ed9216d2ce` |
| Tcl | `vivado/tcl/27_bit_m4_mig.tcl` |
| JSON | `D:/FPGA/arty_d/m4_mig/D_M4_MIG.json` |

Next D: FEM persist. UART board smoke optional; not BOARD_PASS.

## 30.23 D-M4-MIG-PROGRAM (2026-09-17, CANDIDATE)

Owner `PROGRAM=YES`. JTAG programmed `xc7a100t_0` on Digilent
`210319BE776EA` with `arty_a7_r2_top_m4_mig_candidate.bit`. Labtools
**End of startup status: HIGH**. Bit sha256 match. Freeze DCPs not
overwritten. D does not self-stamp `PROGRAM_PASS`. Not `BOARD_PASS` /
`MIG_PASS` / `TIMING_PASS`.

| Field | Value |
|---|---|
| JTAG | `localhost:3121/xilinx_tcf/Digilent/210319BE776EA` |
| Device | `xc7a100t_0` |
| Startup | HIGH |
| Bit sha256 | `f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7` |
| Tcl | `vivado/tcl/28_program_m4_mig.tcl` |
| Log | `D:/FPGA/arty_d/m4_mig/PROGRAM.txt` |
| UART smoke | COM12 115200; 48 B StructuredResult magic `0x4E52` status `0x04` reason `0x20` cmpl `0x02` txn=1 CRC `0x36F0` match |

Next D: FEM persist. Not BOARD_PASS.

## 30.24 D-M4-MIG-REPROGRAM (2026-09-17, CANDIDATE)

On-disk bit hash still `f6a6091f…` (not rewritten). FPGA SRAM reprogrammed
01:13 after another chat overwrote the device. Startup HIGH. UART hop-1
reconfirmed `0x4E52`/`0x04`/`0x20`. UART pack 2/2: PA24-V-01 ACK
`010000A5`, bad-magic NAK `0200015A`. Not `BOARD_PASS` /
`PACK_ABI_24_24_PASS` / `MIG_PASS`.

## 30.25 D-PACK-BOARD-SEQ-01 (2026-09-17, CANDIDATE)

One reprogram of `arty_a7_r2_top_m4_mig_candidate.bit`, then 24 Pack/ABI-24
cases sequential on COM12 with **no per-case reset**. Diagnostic only.
Not B isolated-reset law. Not `PACK_ABI_24_24_PASS`.

| Field | Value |
|---|---|
| Class | `PACK_ABI24_BOARD_SEQ_CANDIDATE` |
| Result | **2/24** (V-01, V-02 ACK `010000A5`) |
| First divergence | PA24-V-03 NAK `0200085A` (`R_SENTINEL`) at 0.030 s |
| After | V-04..G-04 mostly `got=None` 12 s timeout; R-04 `06014e52` (0x4E52 fragment) |
| Log | `D:/FPGA/arty_d/m4_mig/UART_PACK24_BOARD.txt` |
| JSON | `D:/FPGA/arty_d/m4_mig/D_PACK_BOARD_SEQ.json` |

Next D: D-PACK-BOARD-ISO-01. FEM persist deferred until Pack board closed.

## 30.26 D-PACK-BOARD-ISO-01 (2026-09-17, CANDIDATE)

24 × (reprogram + one case) vs B `pack_abi24_expect.tsv`. Same bit sha256
`f6a6091f…`. Each program End of startup HIGH. Official ISO: POST_PROG=5 s,
DTR/RTS off, RX drain. D does **not** stamp `PACK_ABI_24_24_PASS`. B classifies
raw ACK/NAK. FEM persist not started.

| Field | Value |
|---|---|
| Class | `PACK_ABI24_BOARD_ISOLATED_CANDIDATE` |
| Result | **14/24** |
| Elapsed | 616.953 s (~10.3 min) |
| Fail | V-02/V-03/S-01/S-04/C-01/R-02/R-03/G-02 `0200015A` (`R_BAD_MAGIC`); V-04/R-04 `0200075A` (`R_UNSUP`, dt 0.002/0.011 s) |
| Log | `D:/FPGA/arty_d/m4_mig/UART_PACK24_ISO_BOARD.txt` |
| JSONL | `D:/FPGA/arty_d/m4_mig/UART_PACK24_ISO_BOARD.jsonl` |
| JSON | `D:/FPGA/arty_d/m4_mig/D_PACK_BOARD_ISO.json` |

Next D: await B classification of raw board ACK/NAK. Do not self-stamp
`PACK_ABI_24_24_PASS`. FEM persist remains deferred.

## 30.27 D-PACK-VALIDATION-CLEAR (2026-09-17, CANDIDATE)

Pack `VALIDATION_CLEAR` on M4+mig candidate top. **Not** freeze overwrite.
Not `PACK_ABI_24_24_PASS` / `BOARD_PASS` / `TIMING_PASS` / `MIG_PASS` /
`PROGRAM_PASS`. AGENT_E ANALYSIS_ONLY 20260916T223500Z. D handshake fix is
XSim-only this row (no JTAG; board lease FREE for E).

| Field | Value |
|---|---|
| CLEAR_REQ / ACK | `32'h44524743` / `32'hC1EA50A5` |
| Live programmed bit (identity D, **pre-handshake**) | sha256 `bbba86c10a40f502611e18d98fbdcd0565238f28f891fa8747e6a0aa29b23dd0` |
| Route (that bit) | WNS +0.608 WHS +0.008 LUT 10926 FF 9855; TIMING_PASS=NO |
| Board campaign that bit | pack_ok=2/5; CLEAR `got=None` from r0 S-02; jsonl `UART_PACK24_CLEAR_BOARD.jsonl` |
| E audit | `D:/FPGA/arty_d/AUDIT_LEAD_E/E_AUDIT_OUT/E_AUDIT_REPORT.md` packing-as-root REJECTED; H3 handshake RTL_FACT |
| Handshake RTL (not on board at 30.27 write) | `wr_valid=w_valid&&!clr_take&&!clr_hold`; `w_ready=clr_take\|\|(!clr_hold&&fifo_wr_ready)` |
| Handshake bit on disk (identity H, **not SRAM**) | sha256 `cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9` |
| Handshake DCP | `beab0263e094dbf2e7bdebfaffb120d1cdc379492b1cc68b82c851183c6e17a9` |
| Handshake route | WNS +0.497 WHS +0.014 LUT 10932 FF 9855 nets 19115/19115; LUTAR-1=mig0 only; TIMING_PASS=NO |
| SRAM at bitgen | still identity D `bbba86c1`; PROGRAM.txt not rewritten; no JTAG this row |
| Word CLEAR XSim after handshake | T1-T8+round0 24/24 round1 23/24 finish 10673555 ns |
| Top sha256 | `382ac125eec20578101a62b88ffe4be4baab408ce188a2b6550742ae0362cf40` |
| `word_fifo32` sha256 | `5d35ad1eac6bf259168a7e8e8137f4404abb9064aafddef02c3e858e221e7363` |
| `PACK_HOLD_FLOOD_XSIM_PASS` | HOLD_WR_MAX=0 used=0; finish 240195 ns |
| UART XSim after fix | `PACK_DEBUG_CLEAR_UART_XSIM_PASS` **17** (T10 HOLD_WR_MAX=0) finish 16077475 ns |
| UART XSim 115200 (pre-handshake TB copy) | PASS 15 finish 126203745 ns dest=`mig_ui_bram` |
| `PACK_ABI24_MIG_DUT_XSIM_PASS` re-run | 24/24 finish 21965 ns (pack_mig_bind; not UART) |
| Board this handshake RTL | NOT_PROGRAMMED |
| FEM persist | still blocked |

Next D: new CLEAR identity bitstream only with `BOARD_LEASE_GRANT`. Do not mix with bit `bbba86c1`. Do not B-classify Pack CLEAR until a handshake identity is campaigned.

## 30.28 D-04 COMMON-RUNTIME FE256 BIND (2026-09-17, XSIM_256_256_CANDIDATE)

Bind `astra_edge_qeval` (not `fe256_query_path`) to the B 256-case
comparator. Store ROM is pack edges (`fe256_store.mem`), not gold results.
B TB and gold unmodified. `PROGRAM=NO`. Not `FE256_PASS` / `ASTRA_PASS`.
Do not retire the dedicated FE256 engine from freeze top. M4 candidate still
uses hop-1 `query_result_bind`.

| Field | Value |
|---|---|
| XSim | loaded 256 **pass=256 fail=0**; finish **1488295 ns** |
| Banner | `COMMON_RUNTIME_FE256_XSIM` 256/256 bit-exact (simulation only) |
| DUT sha256 | `825b1eafe8c2f002e7904d3bad41759a5c2aeb4ffbf0389c28c38f8728be5872` |
| Store sha256 | `6a1815c6be9baf5bdbcc5a74209f9e9b9f82a8230996e36b520a298165150ee8` n=218 |
| `fe256_query_path` | UNTOUCHED `4c69e8fb…` (not instantiated) |
| JSON | `D:/FPGA/arty_d/common_runtime_fe256/D_COMMON_RUNTIME_FE256.json` |
| Log sha256 | `56fd6f725fbaa7daf5bfab93b9a0304750b61c4e0ba366d38e9f87938dfc4290` |

Next D: bind `astra_edge_qeval` onto an M4 candidate top (not freeze overwrite)
only with owner auth. FEM persist still blocked on Pack board class.
`PROGRAM=NO`. Do not self-stamp `FE256_PASS`.

## 30.29 D-05 C SPEAR/Q*/FEM (2026-09-17, STRUCTURAL)

C hashes match publish. Instantiated on the live PACKAGE m4_mig candidate
with `keep_hierarchy`/`dont_touch`. Query/ingress starts tied 0.
`FUNCTIONAL_QUERY_PATH=NO`. No C RTL edits. `C_SCALE_GUARD` profile unchanged.
Not `SPEAR_PASS` / `FEM_PERSIST_PASS`.

| Field | Value |
|---|---|
| qstar | `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240` |
| spear | `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293` |
| fem | `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` |
| top sha256 | `382ac125eec20578101a62b88ffe4be4baab408ce188a2b6550742ae0362cf40` |
| JSON | `D:/FPGA/arty_d/d05_c_integration/D_D05_C_INTEGRATION.json` |

Next D: do not start FEM persist until Pack is B-classifiable. `PROGRAM=NO`.

## Tóm tắt tiếng Việt

Roadmap R0.1 sửa M1 thành runtime load vào DDR + write-drain/readback; FE256 là
256 case, không phải 256 node; UART E2E bắt đầu từ text người dùng; bốn artifact
chỉ là bộ control tối thiểu, raw evidence vẫn bắt buộc khi cần.
