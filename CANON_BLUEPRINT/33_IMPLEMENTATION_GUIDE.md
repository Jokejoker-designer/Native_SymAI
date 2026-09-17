---
version: "1.1-candidate"
owner: AGENT_D
status: AUDITED_CANDIDATE
category: OPERATIONAL
last_modified: "2026-09-17T16:20:00+07:00"
---

# §33 — IMPLEMENTATION GUIDE

> This guide separates architecture locks from Arty-MVP engineering choices.
> No parameter choice becomes semantic truth merely because it is convenient for
> the first FPGA build.

## 33.1 Recommended implementation order

1. M1 Runtime Pack ABI / production loader / DDR write-drain/readback.
2. M2 Exact directory + forward/reverse posting indices.
3. M3 Bounded retrieval/walker + completeness tracking.
4. M4 ASTRA proof/status/conflict path.
5. M5 Pack/ABI + FE256 static acceptance.
6. M6 Human UART E2E with frozen host adapter.
7. M7 NSPF-X0 falsification.
8. M8 Developmental learning + capability/action binding.

Defer multi-walker, HDC proposal sidecar, DFX and HBM until profiling/causal
needs justify them.

## 33.2 CANON-LOCKED architecture rules

```text
binary/native core ABI; human language remains adapter-side
32-bit semantic references on R0.1 wire records (namespace/generation explicit)
FACT/SKILL/EPISODE/FAILURE/WEIGHT separation
T0/T1/T2 physical placement != epistemic class
forward + reverse indexes are first-class capabilities
Top-K/ranking != answer/proof
logical tick != physical clock
ASTRA owns legality/proof/conflict/completeness/status/promotion
host may map aliases/intents/units -> IDs but may not inject answer/winner/proof
semantic ACTION_INTENT must pass capability binding + legality/safety before actuation
```

Live record widths (do not fork): [§02.4] / [§20.9] — HotDirectory 128, Node/Edge/Context/Provenance 256, Value 128, PostingPageHeader 128, PostingEntry 64.

## 33.3 Arty-MVP engineering choices — versioned, not timeless locks

| Parameter | R0.1 starting point | Rule |
|---|---|---|
| Board oscillator | 100 MHz board source | internal domains may differ; record actual clocks per build |
| Semantic ID active range | may use subset of 32-bit field | do not change wire/ontology meaning to save local memory |
| Relation ID | 16-bit candidate | change only by ABI version if exceeded |
| UART | 115200-8-N-1 common lab baseline | transport parameter; discover actual COM/JTAG per run |
| Cache | simple set-associative/LRU baseline acceptable | benchmark admission/eviction; TinyLFU/CMS only after evidence |
| Graph storage | indexed forward + reverse postings | page/record layouts versioned in pack ABI |
| HDC/CAM | optional accelerators | no truth authority; exact key verification required |

## 33.4 RTL/module skeleton

```text
rtl/native_ai/
  protocol/      frame_rx_tx, crc, sequence/txn
  loader/        manifest, region loader, write-drain, readback
  memory/        mig_adapter, cache, generation/coherence
  directory/     exact directory, forward/reverse postings
  working/       bindings, frontier, visited, candidate queues
  walker/        direct/reverse/value/context/provenance/multihop
  astra/         proof builder, status/conflict/completeness
  strategy/      qstar, spear (after semantic core stabilizes)
  skill/         skill table/executor
  fem/           failure capture/prototypes
  capability/    registry, binding, safety veto, primitive executor, effect readback
  event/         semantic event router/trajectory
  common/        shared types, counters, fixed-point helpers
```

Exact filenames/language (.sv/.v) are implementation choices; module contracts
and evidence are authoritative, not directory spelling.

## 33.5 Capability/action execution boundary

Physical control must follow [§05]:

```text
semantic ACTION_INTENT
→ capability class / target constraints
→ CapabilityDescriptor match (ModuleManifest is install-time names only [§01.7 / §05.3])
→ ASTRA legality + safety veto
→ capability binding
→ Primitive Executor
→ physical command
→ effect/readback observation
→ episode/evidence
```

`NO_BINDING` or failed safety contract means `NO_ACTION`. A Knowledge Pack or
GEMINI message cannot invent a physical actuator.

## 33.6 Per-milestone workflow

```text
1 freeze CONTRACT + vectors/gold
2 record source lineage/tool versions
3 run reference/unit tests
4 run XSim integration
5 run OOC synthesis + assertions/CDC
6 run post-route when required
7 run board only for required silicon evidence
8 preserve raw logs/UART/bit/timing/readback
9 emit RESULT/EVIDENCE/SHA256SUMS
10 after any functional patch, rerun required lower gates + fresh full campaign
```

## 33.7 MIG/DDR rule

Use the Digilent/AMD board reference configuration appropriate to the exact
board revision. Wait for calibration before semantic DDR traffic. Do not assume
fixed random-access latency; instrument and measure command/data handshakes,
bytes/query, cache hits/misses and outstanding occupancy.

The R0.1 architecture does not require AXI specifically. Native MIG `app_*`, AXI
or another wrapper is acceptable if its contract is verified and does not hide
write completion/ordering.

## 33.8 Local toolchain/run manifest

Do **not** hard-code local paths, COM number, JTAG serial or license location in
architecture authority. Each run manifest discovers and records:

```text
repo/head/dirty state
Vivado version
board + FPGA part
JTAG identity
UART endpoint/config
clock domains
source/constraint/IP hashes
bit SHA256
ABI/schema/pack/case/adapter hashes
```

## 33.9 M1 first-slice engineering freeze (versioned, not ontology)

These are Arty-MVP engineering choices for the first `pack_loader` XSim/OOC bag.
They are **CANDIDATE** until Agent B signs PACK_ABI_24 gold. A later ABI major
version may replace them. They do not change FACT/SKILL/EPISODE meaning.

### Tree

```text
rtl/native_ai/loader/pack_loader.sv     production loader FSM
rtl/native_ai/common/crc32_iso_hdlc.sv
rtl/native_ai/memory/mig_ui32.sv        32b fabric word <-> 128b native UI
rtl/native_ai/memory/pack_mig_bind.sv  pack_loader mem_* on mig_ui32
rtl/native_ai/memory/mig_ui_bram.sv    128b beat dest stand-in (not mig0)
rtl/native_ai/memory/mig_ui_mux.sv     exclusive pack vs FEM native UI grant
rtl/native_ai/memory/fem_req_ui.sv     FEM 4-bit word -> mig_ui32 at FEM_BASE
rtl/native_ai/memory/fem_on_mig.sv     C lifecycle on mig_ui32; not FEM_PERSIST_PASS
rtl/native_ai/board/uart_rx_word.sv
rtl/native_ai/board/uart_tx_word.sv      pack load_ack/NAK 32-bit LE on uart_tx
rtl/native_ai/board/word_cdc32.sv      UART 100 MHz <-> ui_clk toggle CDC
rtl/native_ai/board/arty_a7_mig_cdc.xdc handshake max_delay; not TIMING_PASS
rtl/native_ai/board/arty_a7_mig_top.sv Q*/SPEAR/walk on ui_clk; PROGRAM=NO
vivado/tcl/09c_synth_arty_mig_tx.tcl    mig_top + uart_tx CDC; out mig_tx; no bitstream
vivado/tcl/10c_impl_arty_mig_tx.tcl      place/route mig_tx; do not clobber mig_uiclk
tb/native_ai/board/tb_word_cdc32.sv     ui_clk-like→100 MHz CDC; not BOARD_PASS
vivado/tcl/11_hold_r2_round1.tcl        phys_opt -hold_fix from freeze DCP; no bitstream
vivado/tcl/11_hold_r2_round2.tcl        route Explore + ExploreWithHoldFix; no bitstream
# hold_r2/R2_TOP_ROUTE_BASELINE_WHS_0P021 freeze; HOLD_OPTIMIZATION_STOPPED; not TIMING_PASS
vivado/tcl/09b_synth_arty_mig_uiclk.tcl Q* on ui_clk + C bag2; separate out dir
vivado/tcl/10_impl_arty_mig.tcl         place/route old mig_bind; no bitstream
vivado/tcl/10b_impl_arty_mig_uiclk.tcl  place/route bag2+ui_clk; no bitstream
# mig_bind/post_route.dcp pre-bag2; mig_uiclk/post_route.dcp bag2+ui_clk (Vivado MET, not TIMING_PASS, PROGRAM=NO)
tb/native_ai/board/tb_uart_word.sv      TX/RX 32-bit loopback; not BOARD_PASS
vivado/tcl/13_ooc_fe256.tcl             fe256_query_path OOC R0; not r2_top; not TIMING_PASS
vivado/tcl/13b_ooc_fe256_r1.tcl         FE256_HW_R1 OOC synth; out fe256_ooc_r1; not r2_top
vivado/tcl/14_impl_fe256_r1.tcl         isolated OOC place/route R1; no bitstream; not TIMING_PASS
rtl/native_ai/board/uart_fe256_host.sv  UART 32-bit LE QueryRecord/StructuredResult
rtl/native_ai/board/arty_a7_r2_top_fe256_r1_candidate.sv  integrated freeze top; old r2_top rollback
# hold_r2/R2_FE256_R1_INTEGRATED_FREEZE new freeze; R2_TOP_ROUTE_BASELINE_WHS_0P021 preserved
# hold_r2/FE256_R1_REFERENCE_FREEZE engine reference; no FE256 polish; not FE256_PASS
rtl/native_ai/directory/exact_directory.sv     M2 exact semantic_id; UG901 1R BRAM
rtl/native_ai/directory/posting_walk.sv       M2 ID → posting page; UG901 1R BRAM
rtl/native_ai/directory/query_posting_bind.sv QueryRecord → posting_walk; not FE256
tb/native_ai/directory/tb_query_posting_bind.sv  rows=235 XSim; not M2_PASS
vivado/tcl/17_ooc_m2_query_post.tcl            query_posting_bind OOC; out m2_query_post_ooc
vivado/tcl/18_impl_m2_query_post.tcl          isolated OOC P&R; no bitstream; not TIMING_PASS
rtl/native_ai/directory/bounded_walk.sv        M3 hop-budget walk; incomplete ≠ ASTRA
rtl/native_ai/directory/query_walk_bind.sv   QueryRecord → bounded_walk; not FE256
tb/native_ai/directory/tb_query_walk_bind.sv hop1=122 XSim; not M3_PASS
vivado/tcl/19_ooc_m3_query_walk.tcl            query_walk_bind OOC; out m3_query_walk_ooc
vivado/tcl/20_impl_m3_query_walk.tcl          isolated OOC P&R; no bitstream; not TIMING_PASS
rtl/native_ai/directory/query_result_bind.sv QueryRecord → StructuredResult; fail-closed
tb/native_ai/directory/tb_query_result_bind.sv hop1=122; not ASTRA_PASS
vivado/tcl/21_ooc_m4_query_result.tcl          query_result_bind OOC; out m4_query_result_ooc
vivado/tcl/22_impl_m4_query_result.tcl        isolated OOC P&R; no bitstream; not TIMING_PASS
rtl/native_ai/board/arty_a7_r2_top_m4_query_result_candidate.sv  UART QueryRecord→result; no FE256
tb/native_ai/board/tb_m4_query_result_shadow_bind.sv hop1=122 hierarchical; not ASTRA_PASS
tb/native_ai/board/tb_m4_query_result_uart_smoke.sv UART 115200 2-case; not BOARD_PASS
vivado/tcl/23_synth_m4_query_result_shadow.tcl candidate synth; out m4_query_result_shadow
vivado/tcl/24_impl_m4_query_result_shadow.tcl  candidate P&R; no bitstream; not TIMING_PASS
rtl/native_ai/board/arty_a7_r2_top_m4_mig_candidate.sv Query@100MHz + mig0 dest; not MIG_PASS
vivado/tcl/25_synth_m4_mig.tcl                 out m4_mig; does not clobber freeze
vivado/tcl/26_impl_m4_mig.tcl                  candidate P&R; no bitstream; not TIMING_PASS
vivado/tcl/27_bit_m4_mig.tcl               bitstream from m4_mig DCP; PROGRAM=NO
vivado/tcl/28_program_m4_mig.tcl           JTAG program candidate; not BOARD_PASS
verification/fe256/tb_fe256_r1_shadow_bind.sv  D TB vs B gold hex; not B TB
verification/fe256/tb_fe256_r1_uart_smoke.sv  UART 115200 2-case smoke; not BOARD_PASS
vivado/tcl/15_synth_fe256_r1_shadow.tcl shadow synth; out fe256_r1_shadow; no bitstream
vivado/tcl/16_impl_fe256_r1_shadow.tcl   shadow place/route; no bitstream; not TIMING_PASS
tb/native_ai/loader/tb_pack_loader.sv
tb/native_ai/loader/tb_pack_mig.sv      dest-complete through UI; not MIG_PASS
tb/native_ai/loader/tb_pack_abi24_mig_dut.sv  24-case dest-complete; not PACK_ABI_24_24_PASS
verification/pack_abi24/pack_abi24_mig_dut.sv pack_mig_bind + mig_ui_bram wrapper
tb/native_ai/memory/tb_fem_mig.sv      FEM dest-complete through mux; not FEM_PERSIST_PASS
python/m1/pack_vectors.py               CANDIDATE vectors, not verified FACT
vivado/tcl/01_create_project_m1.tcl
vivado/tcl/02_ooc_synth_pack_loader.tcl
rtl/native_ai/m1_pack_loader/CONTRACT.md
```

Do **not** write this module into `rtl/native_graph/` (frozen A7 lane).

### ManifestHeader M1 (128 B)

Live R1 [§04.6] lock: ManifestHeader is **128 B**, `reserved=12`, CRC-32/ISO-HDLC
over `[0:112)`. `reserved=16` / 132-byte BEGIN is illegal (`HEADER_LENGTH`).
`pack_generation` is u32 and is not `knowledge_generation` u16.

Field list:

| Offset | Size | Field |
|---|---:|---|
| 0 | 4 | magic `NAI1` little-endian `32'h3149414E` |
| 4 | 2 | manifest_version = 1 |
| 6 | 2 | abi_version = 1 |
| 8 | 2 | schema_version = 1 |
| 10 | 2 | flags |
| 12 | 4 | pack_generation |
| 16 | 4 | node_count |
| 20 | 4 | edge_count |
| 24 | 4 | value_count |
| 28 | 4 | context_count |
| 32 | 4 | provenance_count |
| 36 | 4 | region_count |
| 40 | 32 | schema_sha256 (host-verified identity; FPGA stores, does not hash) |
| 72 | 32 | content_sha256 (same integrity-label rule) |
| 104 | 4 | page_size (M1: 256) |
| 108 | 2 | header_length = 128 |
| 110 | 2 | page_crc_scheme = 1 (CRC-32/ISO-HDLC) |
| 112 | 4 | manifest_crc32 over bytes `[0:112)` |
| 116 | 12 | reserved = 0 |

Agent B [§04.6] locks this 128-byte layout. M1 loader is bound to it as
**CANDIDATE** until PACK_ABI_24 (24 cases) is compared. Board sequential
`PACK_ABI24_BOARD_SEQ_CANDIDATE` and isolated
`PACK_ABI24_BOARD_ISOLATED_CANDIDATE` are raw UART ACK/NAK on programmed
`mig0`; B classifies. Do not self-stamp `PACK_ABI_24_24_PASS`.

### RegionDescriptor M1 (32 B)

| Offset | Size | Field |
|---|---:|---|
| 0 | 1 | region_id |
| 1 | 1 | region_kind (1 NODE, 2 EDGE, 3 VALUE, 4 CONTEXT, 5 PROVENANCE, 6 FWD, 7 REV, 8 SENTINEL) |
| 2 | 2 | flags |
| 4 | 4 | ddr_offset (bytes from inactive generation slot base) |
| 8 | 4 | byte_length |
| 12 | 2 | record_width |
| 14 | 2 | page_count |
| 16 | 4 | record_count |
| 20 | 4 | region_crc32 |
| 24 | 4 | sentinel_word |
| 28 | 4 | reserved = 0 |

### Stream opcodes (32-bit command word)

```text
[7:0]   opcode     0x01 BEGIN_PACK / 0x02 REGION_TABLE / 0x03 DATA_PAGE / 0x04 END_PACK
[15:8]  flags
[31:16] payload_bytes
```

DATA_PAGE payload header (16 B) then `length` bytes, 32-bit padded:

```text
u16 seq, u8 region_id, u8 flags, u32 region_byte_offset, u16 length, u16 reserved, u32 payload_crc32
```

### Memory / commit rules

- Writes target the **inactive** generation slot only (`0x000000` or `0x100000`).
- `load_ack` is forbidden until `wr_outstanding==0` and sentinel readback matches.
- Fail-closed: mismatch → `load_reject`, no `active_generation` flip (R07, R17).
- FPGA does **not** compute SHA-256 in this slice ([§04.7] integrity labels).

### Resource estimate (not budget)

Loader-only OOC estimate: ≤500 LUT, ≤2 BRAM36, 0 DSP. Actual budget is the OOC
report. Clock constraint for this bag: 100 MHz from the board oscillator as a
**measured domain target**, not a semantic lock. `PROGRAM=NO`.

## 33.6 Live skeleton vs this PACKAGE (2026-09-17)

Status only. Does not change [§33.2] locks or [§33.4] target tree.

| Path / bind | Live PACKAGE |
|---|---|
| `rtl/native_ai/astra/` | `astra_qeval.sv` pre-search; `astra_edge_qeval.sv` store-scan Q-eval (XSim DUT) |
| M4 pack | `query_result_bind` fail-closed `0x04`/`0x20` (integrity `0x06`/`0x55`) |
| C SPEAR/Q*/FEM | Instantiated on m4_mig candidate; `q_start`/`prop_start`/`ing_valid` tied 0 |
| Common-runtime FE256 | XSim **256/256** CANDIDATE on `astra_edge_qeval`; not `FE256_PASS`; not on M4 top |
| M1 Pack board | not B-classifiable; FEM persist blocked |

`PROGRAM=NO`. Not `ASTRA_PASS` / `M1_PASS` / `BOARD_PASS`.

## Tóm tắt tiếng Việt

Implementation guide R0.1 phân biệt luật kiến trúc với lựa chọn MVP. Wire dùng
32-bit semantic ref; 24-bit/50 MHz/LRU không còn là chân lý canon. Physical action
bắt buộc qua capability binding + ASTRA/safety + effect readback.
