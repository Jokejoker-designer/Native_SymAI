---
version: "1.7-candidate"
owner: AGENT_A
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-17T04:25:00+07:00"
---

# §00 — MASTER INDEX

> Entry point for the audited candidate. Authority precedence is defined in
> `AUTHORITY_PRECEDENCE.md`.

## Governance

| File | Purpose |
|---|---|
| `PROJECT_GOAL_LOCK.md` | forward research North Star / invariants |
| `AUTHORITY_PRECEDENCE.md` | conflict/authority ordering for this candidate |
| `AUDIT_REPORT_R0_1.md` | full audit findings against GOAL |
| `R0_1_ERRATA_AND_PATCHES.md` | P0/P1/P2/P3 patch register |
| `README.md` | package status and entry instructions |
| `MASTER_CANON_BLUEPRINT_R0_1.md` | concatenated convenience view of audited top-level canon |

## Primary architecture

| § | File | Scope |
|---|---|---|
| 01 | `01_MASTER_ARCHITECTURE.md` | dual semantic/event planes, Working Mind, authority partition |
| 02 | `02_MEMORY_STRATIFICATION.md` | T0/T1/T2, NCG widths, D implementation contract [§02.9] |
| 03 | `03_ASTRA_AUTHORITY.md` | legality/proof/status/conflict/promotion |
| 04 | `04_ABI_AND_PROTOCOL.md` | native records, manifest, framing, runtime load |
| 05 | `05_CAPABILITY_AND_ACTION_BINDING.md` | semantic action→verified physical capability→effect/readback |

## Cognitive / learning research

| § | File | Scope |
|---|---|---|
| 10 | `10_LEARNING_AND_STRATEGY.md` | Q*/SPEAR, reward/credit boundaries |
| 11 | `11_FAILURE_EXPERIENCE_MEMORY.md` | runtime FEM capture/prototypes/compaction/reopen |
| 12 | `12_SKILL_AND_TEACHING.md` | skill lifecycle, teacher boundary, grounding |
| 13 | `13_INFORMATION_NEURONALIZATION.md` | central research hypothesis and falsification |

## Reference

| § | File | Scope |
|---|---|---|
| 20 | `20_GLOSSARY_AND_LOCKED_TERMS.md` | canonical definitions/invariants |
| 21 | `21_PRIOR_ART_AND_NOVELTY.md` | prior-art/novelty boundary |
| 22 | `22_RTL_RISK_REGISTER.md` | implementation/evidence risks |
| 23 | `23_HARDWARE_FACTS.md` | Arty A7 hardware facts and measurement boundaries |

## Operational / evidence

| § | File | Scope |
|---|---|---|
| 30 | `30_MILESTONE_ROADMAP.md` | M1–M8 causal roadmap |
| 31 | `31_VERIFICATION_AND_CAUSAL_TESTS.md` | Pack/ABI, FE256, E2E, NSPF-X0 |
| 32 | `32_ACCEPTANCE_LADDER.md` | separate Full Evidence / NSPF / Developmental acceptance |
| 33 | `33_IMPLEMENTATION_GUIDE.md` | implementation sequence and MVP choices |

## Source preservation

- `_ARCHIVE/` contains source/historical packages and must not be silently used
  as newer authority over audited top-level files.
- `_COORDINATION/` contains non-authoritative workflow metadata.
- `.agents/` preserves request/session context, not semantic authority.

## Coordination note (not semantic authority)

Dated 2026-09-16. This ledger is coordination metadata only. It does not
create or override semantic authority. There is **no third canon**.

### A-05 LIVE TREES (coordination map only)

Not semantic authority. Use this table when a path, SHA, or version
disagrees. Do not treat a second folder as a second live canon.

| Tree | This-goal role |
|---|---|
| AGENT_A worktree numbered A-owned files (`00_INDEX.md`, `01_MASTER_ARCHITECTURE.md`, `02_MEMORY_STRATIFICATION.md`, `05_CAPABILITY_AND_ACTION_BINDING.md`, `20_GLOSSARY_AND_LOCKED_TERMS.md`) | **A live**. `READING_ORDER.md` is A-owned with those files and is copied to R1 so SHA WT==R1. |
| R1 PACKAGE numbered unowned files (`03`, `04`, `10`–`13`, `31`–`33`) and `_COORDINATION/schema_lock.json` at `d:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT` | **B/C/D live** for this goal |
| `d:\FPGA\NATIVE_AI\CANON_BLUEPRINT` | convenience / repo copy; **NOT** package live |
| `MASTER_CANON_BLUEPRINT_R0_1.md` and `CANON_BLUEPRINT_R0_1_AUDITED_CANDIDATE/` | **NOT** live widths |

A does not rewrite unowned live files. A does not copy B/C/D files onto
the package. A does not merge other agent branches.

### A-ID-PROFILE-01 (architecture lock; pointer into [§02.4.1b])

Not a PASS. Compact contract mailed to B/C/D:

| Key | Lock |
|---|---|
| `SEMANTIC_ID_WIDTH` | 32 |
| `ACTIVE_RANGE_SOURCE` | loaded board/knowledge-pack profile (`active_id_bits` / `active_id_max`); D implements; B owns wire field if any |
| `AUTHORITATIVE_RANGE_CHECKER` | T1 directory / materialization admit |
| `DEFENSE_IN_DEPTH_ALLOWED` | yes (SPEAR/Q*/walkers vs same profile; not identity law) |
| `K_HARD_PROFILE_OWNER` | same loaded profile; D wires; C consumes; A does not freeze the integer |

Live R1 [§04.2] locks `SEMANTIC_ID_WIDTH = 32` and `ACTIVE_ID_RANGE` = profile
(B-LAW-SYNC 18:50). MASTER_CANON nested `semantic_id \| 24` is **NOT LIVE**.
Live R1 [§04.13] binds `K_hard` to the same profile and keeps action-lane
objects off Query/Result UART.

### Absorbed 2026-09-17 (B ACCEPT_CANDIDATE + D reprogram + Pack board SEQ/ISO; FACT; no PASS)

3 mails (B×1 + D×2) + live `22`/`23`/`30`/`33`
`last_modified 2026-09-17T01:38:00+07:00` (SHA `0B494F78…` / `BE81CAF1…` /
`E7595573…` / `3784D40A…`). CANDIDATE.
`NOT_CLAIMED: BOARD_PASS PROGRAM_PASS PACK_ABI_24_24_PASS MIG_PASS M2_PASS
M3_PASS ASTRA_PASS TIMING_PASS FE256_PASS FEM_PERSIST_PASS FINAL_PASS`.
- B-NGHIEM-THU: ACCEPT at **CANDIDATE only** for M2/M3/M4/Pack-MIG-DUT /
  M4+mig0 packages; freeze DCPs untouched `DO_NOT_BIND`; reject all ladder
  PASS names listed above.
- D-M4-MIG-REPROGRAM 01:13: same bit sha `f6a6091f…` reloaded after foreign
  overwrite; startup HIGH; UART hop-1 `0x04`/`0x20` + Pack smoke 2/2 ACK/NAK
  ≠ `BOARD_PASS` / `PROGRAM_PASS` / `PACK_ABI_24_24_PASS`.
- Pack board SEQ-01: **2/24** OK; first divergence `PA24-V-03` expect
  `010000a5` got `0200085a` (`R_SENTINEL`); then mostly timeout/None —
  `PACK_ABI24_BOARD_SEQ_CANDIDATE` ≠ `PACK_ABI_24_24_PASS`.
- Pack board ISO-01: per-case reprogram; **14/24** reported OK class
  `PACK_ABI24_BOARD_ISOLATED_CANDIDATE` ≠ `PACK_ABI_24_24_PASS` / `BOARD_PASS`.
- FE256 development CLOSED; FEM persist deferred until Pack board closed by B.
  `SEMANTIC_ID_WIDTH=32`; omit-05 OPEN.

### Absorbed 2026-09-17 (D/B M4 shadow→MIG program + Pack/ABI24; FACT; no PASS)

11 mails (D×5 + B×6) + live `22`/`23`/`30`/`33`
`last_modified 2026-09-17T01:04:00+07:00` (SHA `CCBAD0F5…` / `FAF2541C…` /
`2127690B…` / `D5C96CDB…`). CANDIDATE.
`NOT_CLAIMED: TIMING_PASS MIG_PASS BOARD_PASS FEM_PERSIST_PASS FE256_PASS
FE256_FULL_PASS M2_PASS M3_PASS ASTRA_PASS PACK_ABI_24_24_PASS PROGRAM_PASS
FINAL_PASS`.
- M4 query-result shadow candidate (no `fe256_query_path`): route WNS
  **+0.555** WHS **+0.049**; XSim + UART smoke XSim ≠ `ASTRA_PASS` /
  `BOARD_PASS`; freeze DCPs untouched.
- M4+`mig0` candidate: route WNS **+0.233** WHS **+0.016**; calib=IP not
  board; ≠ `MIG_PASS` / `TIMING_PASS`.
- Bitstream write (2 003 005 B, sha `f6a6091f…`) ≠ `PROGRAM_PASS` /
  `BOARD_PASS` while unprogrammed.
- Owner `PROGRAM=YES` JTAG config + startup HIGH: programmed-config event
  only; D/B do not stamp `PROGRAM_PASS` (DONE readback NA); ≠ `BOARD_PASS`.
- UART board smoke COM12 1-txn fail-closed `0x04`+`0x20` ≠ `BOARD_PASS` /
  `ASTRA_PASS` / `UART_E2E_32_32_PASS`.
- `PACK_ABI24_MIG_DUT_XSIM_PASS` 24/24 via `mig_ui_bram` stand-in ≠
  `PACK_ABI_24_24_PASS` / `MIG_PASS` (not B harness `PACK_ABI24_XSIM_PASS`).
- FE256 reference freeze + retirement law unchanged. `SEMANTIC_ID_WIDTH=32`.
  omit-05 OPEN (not rematched).

### Absorbed 2026-09-17 (D/B FE256_HW_R1→POST-GUARD + M2/M3/M4; FACT; no PASS)

17 mails (D×9 + B×8) + live `22`/`23`/`30`/`33`
`last_modified 2026-09-17T00:06:00+07:00` (SHA `FA23FEEF…` / `F583D272…` /
`5C5EAE73…` / `81E3E1E9…`; `22` R22/R23). CANDIDATE. `PROGRAM=NO`.
`NOT_CLAIMED: TIMING_PASS MIG_PASS BOARD_PASS FEM_PERSIST_PASS FE256_FULL_PASS
FE256_PASS M2_PASS M3_PASS ASTRA_PASS FINAL_PASS`.
- FE256 HW-R1 isolated: XSim 256/256; OOC synth WNS **+0.568** / route
  **+0.223**; RAMB36=1; levels 11; still `DO_NOT_BIND` old freeze.
- Shadow-bind `arty_a7_r2_top_fe256_r1_candidate`: INTEGRATION_CANDIDATE;
  route WNS **+0.368** WHS **+0.037**; RAMB36=17; old freeze DCP `b48b7c88…`
  PRESERVED; new lab freeze `R2_FE256_R1_INTEGRATED_FREEZE` DCP `858d0e99…`
  ≠ product-architecture permanent; ≠ TIMING/BOARD/FE256_PASS.
- `FE256_R1_REFERENCE_FREEZE` = REFERENCE_IMPLEMENTATION; FE256_DEVELOPMENT
  CLOSED; D_MAIN_ROADMAP RESUMED (M2); retirement law = common-runtime
  256/256 + legal timing only (else repair common path; do not weaken gold).
- `UART_FE256_XSIM_SMOKE` 2/2 ≠ `BOARD_PASS` / `FE256_PASS`.
- Common-runtime CANDIDATE path (no FE256 engine): M2 QueryRecord→posting
  (`query_posting_bind` `fb8eea24…`; `query_meta[10]` reverse CANDIDATE);
  M2 OOC UG901 1R WNS **+0.935**; M3 walk hop1=122 (`incomplete` ≠ ASTRA);
  M4 fail-closed StructuredResult (never ANSWER/UNKNOWN from hop-1).
  XSim banners ≠ `M2_PASS` / `M3_PASS` / `ASTRA_PASS`.
- Prior 22:13 RCA/hold baseline facts remain. `SEMANTIC_ID_WIDTH=32`.
  omit-05 OPEN (not rematched).

### Absorbed 2026-09-16 (D/B 22:13 route+hold+FE256 RCA; FACT; no PASS)

D mails 140709…151139 + B-CLASS 151248 + live `22`/`23`/`30`/`33`
`last_modified 2026-09-16T22:13:00+07:00` (SHA `e12ec27a…` / `ca563fc9…` /
`9163938e…`; `22` R21/R22). CANDIDATE. `PROGRAM=NO`. No bitstream.
`NOT_CLAIMED: TIMING_PASS MIG_PASS BOARD_PASS FEM_PERSIST_PASS FE256_FULL_PASS`.
- Fabric r2_top bag2+`uart_tx` post-route Vivado MET WNS **+0.375** WHS
  **+0.021**; lab baseline `R2_TOP_ROUTE_BASELINE_WHS_0P021` /
  `HOLD_OPTIMIZATION_STOPPED` ≠ `TIMING_PASS`.
- `mig_tx` post-route MET WNS **+0.673**; does not clobber baseline/`mig_uiclk`.
- `UART_PACK_XSIM_PASS` 2/2 ≠ `BOARD_PASS`.
- FE256 OOC WNS **−75.723**, Logic Levels **144** (not 723); `DO_NOT_BIND`;
  B: no ladder promotion; owner auth before FE256 RTL rewrite.
- `SEMANTIC_ID_WIDTH=32`. omit-05 OPEN (not rematched).

### Absorbed 2026-09-16 (D 21:05 fabric bag2+uart_tx + UART_WORD XSim; FACT; not TIMING/BOARD_PASS)

Live-canon wake (no A mail yet): `23`/`30`/`33` `last_modified
2026-09-16T21:05:00+07:00` (SHA `8288c469…` / `9896d8f8…` / `ac9e83d3…`).
CANDIDATE. `PROGRAM=NO`. No bitstream.
`NOT_CLAIMED: TIMING_PASS MIG_PASS BOARD_PASS FEM_PERSIST_PASS`.
- [§23.9]/[§30.8] fabric `arty_a7_r2_top` bag2 + `uart_tx_word` post-synth
  WNS **+1.549** TNS 0; worst SPEAR `desc_ok`; `mig0` unbound; dest
  `mig_ui_bram`.
- `UART_WORD_XSIM_PASS` 2/2 loopback ≠ board / `BOARD_PASS`.
- Prior mig_top bag2+`ui_clk` route +1.032 MET remains CANDIDATE ≠ TIMING_PASS.
- Do not freeze WNS/`ui_clk`. `SEMANTIC_ID_WIDTH=32`. omit-05 OPEN (not rematched).

### Absorbed 2026-09-16 (D 20:40 bag2+ui_clk post-route WNS +1.032 MET; FACT; not TIMING_PASS)

D mail `20260916T133821` + live `23`/`30`/`33` `last_modified
2026-09-16T20:40:00+07:00` (SHA `e975b10e…` / `e46eb1c1…` / `84d55eb0…`).
CANDIDATE. `PROGRAM=NO`. No bitstream.
`NOT_CLAIMED: TIMING_PASS MIG_PASS BOARD_PASS FEM_PERSIST_PASS`.
- [§23.9]/[§30.8] bag2+`ui_clk` post-route Vivado constraints **MET**
  WNS **+1.032** WHS **+0.008**; `clk_pll_i` +1.976. D does not self-issue
  `TIMING_PASS`; A does not either.
- Pre-bag2 post-route −1.160 and synth +1.277 remain prior snapshots.
- Do not freeze `ui_clk`/WNS. `SEMANTIC_ID_WIDTH=32`. omit-05 OPEN (not rematched).

### Absorbed 2026-09-16 (D 20:35 bag2+ui_clk synth WNS +1.277; FACT; not TIMING_PASS)

D mail `20260916T132944` + live `23`/`30`/`33` `last_modified
2026-09-16T20:35:00+07:00` (SHA `1c202f6c…` / `e0dc1ab3…` / `7eb0e7a3…`).
CANDIDATE. `PROGRAM=NO`. No bitstream.
`NOT_CLAIMED: TIMING_PASS MIG_PASS BOARD_PASS FEM_PERSIST_PASS`.
- [§23.9]/[§30.8] C bag2 `d4f64e65` + `ui_clk` flatten post-synth setup
  WNS **+1.277** TNS 0; `clk_pll_i` +3.575; synth hold −1.631 = MIG PHY.
- Pre-bag2 post-route WNS −1.160 remains **old** netlist.
- Do not freeze `ui_clk`/WNS. `APP_ADDR_WIDTH=28` ≠ `SEMANTIC_ID_WIDTH=32`.
- `schema_lock` still omits `05` (not rematched). `SEMANTIC_ID_WIDTH=32`.

### Absorbed 2026-09-16 (B-LAW-SYNC 114850 + D 18:50 ui_clk / post-route; FACT)

B mail `20260916T114850` + live `03`/`04`/`31`/`32` `last_modified
2026-09-16T18:50:00+07:00` (SHA `eddd7453…` / `1e626ede…` / `83a10dc4…` /
`16d65812…`). Closes OPEN rows for action-precheck / ID-profile / §05.8 echo
(074024 / 072711 bodies not rematched). Not PASS.
- [§03.12] ACTION_INTENT + descriptor + safety_contract; verdicts ≠ query
  `0x01–0x06`. [§03.1] Skill may originate `ACTION_INTENT`; does not authorize pins.
- [§04.2] `SEMANTIC_ID_WIDTH = 32`; `ACTIVE_ID_RANGE` = profile; ≠ each other.
- [§31.12]/[§32.5] name the seven [§05.8] passes; X0-15 explicitly not that set.
D live `23`/`30`/`33` 18:50 SHA MATCH `24e34deb…` / `75401c2c…` / `7cd76d28…`.
- [§23.9] `arty_a7_mig_top` Q*/SPEAR/`bounded_walk` on `ui_clk` CANDIDATE;
  not freeze; not TIMING_PASS. Post-route WNS −1.160 is **pre-`ui_clk`-move**
  netlist. Synth −1.482 / CDC handshake MET do not make TIMING_PASS.
- `schema_lock` still omits `05` (072711 not rematched). `SEMANTIC_ID_WIDTH=32`.

### Absorbed 2026-09-16 (D 111919 r2_top FEM-mux flatten WNS +1.549 not TIMING_PASS; FACT)

D mail `20260916T111919`: fabric synth after FEM UI mux. CANDIDATE.
`PROGRAM=NO`. `NOT_CLAIMED: TIMING_PASS BOARD_PASS MIG_PASS FEM_PERSIST_PASS`.
`arty_a7_r2_top` flatten post-synth WNS +1.549 TNS 0 (0 failing) WHS +0.070;
LUT 6072 FF 5107 DSP 8 BRAM 16.5. Same slack as pre-mux keep-hierarchy is
not a freeze. BRAM up from 12-bit dest fold. `mig0` still unbound on this
top. Live `23`/`33` 17:45 SHA unchanged. Do not freeze those counts or
8.315 ns / 10 levels. D-06 −1.490 remains a different top (`arty_a7_mig_top`
with `mig0`). Live `03` still no `ACTION_INTENT`. `schema_lock` omit-05
(072711 not rematched). `SEMANTIC_ID_WIDTH=32`. Not PASS.

### Absorbed 2026-09-16 (D 111118 FEM mux onto pack UI; FEM off local dest on mig_top; FACT)

D mail `20260916T111118` + live `23`/`33` 17:45 SHA MATCH
`10ea7957…aac787` / `81f99f4b…c20440`. CANDIDATE. `PROGRAM=NO`.
`NOT_CLAIMED: FEM_PERSIST_PASS MIG_PASS BOARD_PASS TIMING_PASS`.
- `fem_on_mig` + `fem_req_ui` + `mig_ui_mux`: pack vs FEM exclusive grant; pack wins.
- `FEM_BASE=28'h0200000` (bit 21, not slot 0/1).
- `arty_a7_r2_top`: mux onto `mig_ui_bram`; `mig0` still unbound in that top.
- `arty_a7_mig_top`: mux onto generated `mig0` on `ui_clk`; FEM moved off
  CLK100MHZ local dest. Still not board persist (no calib, no bitstream).
- XSim `FEM_MIG_UI32_XSIM_PASS` / `PACK_MIG_UI32_XSIM_PASS` 5/5 after
  12-bit fold `{addr[21:20], addr[13:4]}` ≠ persist / gold / board.
  Do not freeze 7195 ns. Q*/SPEAR still CLK100MHZ; C ports unchanged.
A restamped [§01.11]/[§02.4.1c] so they no longer say FEM dest is
unconditionally local. Live `03` still no `ACTION_INTENT`.
`schema_lock` omit-05 (072711 not rematched). `SEMANTIC_ID_WIDTH=32`.
Not PASS.

### Absorbed 2026-09-16 (D live §23/§33 17:45; D-06 now in live 23.9; FACT)

No B/C/D mailbox body (CHANGEBOT-only unread). Live R1 `23` and `33`
`last_modified: 2026-09-16T17:45:00+07:00` (was 16:25).
- [§23.9] still unbound `mig0` `app_*` on `arty_a7_r2_top`; pack dest
  `mig_ui_bram` via `mig_ui_mux`. Live text now also records
  `arty_a7_mig_top` instantiates generated `mig0` and muxes the same two
  clients on `ui_clk` — CANDIDATE, not `MIG_PASS` / `FEM_PERSIST_PASS`.
  Closes the “D-06 mail not yet in live 23” gap (105618 body not rematched).
- [§33.9] ManifestHeader offset 12 remains `pack_generation`; tree now
  names `mig_ui32` / `mig_ui_bram` / `mig_ui_mux` / `fem_on_mig` stand-in
  modules (not mig0 persist). Not `MIG_PASS` / `FEM_PERSIST_PASS`.
- [§33.2]/[§33.5] still “capability binding + legality/safety”, not the
  seven [§05.8] names (B [§31]/[§32] OPEN; not rematched).
Live `03` still no `ACTION_INTENT`. `schema_lock` omit-05 SHA `105ee6b2…`
(072711 not rematched). `SEMANTIC_ID_WIDTH=32`. Not PASS.

### Absorbed 2026-09-16 (D-06 mig0 in arty_a7_mig_top CANDIDATE; FACT)

D mail `20260916T105618`: `mig0` instantiated in `arty_a7_mig_top`. CANDIDATE.
`PROGRAM=NO`. `NOT_CLAIMED: MIG_PASS BOARD_PASS TIMING_PASS FEM_PERSIST_PASS`.
FEM dest still local. Live [§23.9] (16:25) still unbound `mig0` on
`arty_a7_r2_top` (085241 not rematched; A does not write 23). Post-synth
WNS −1.490 is not TIMING_PASS; LUT/FF/`ui_clk` not frozen. Live `03` still
no `ACTION_INTENT`. `schema_lock` omit-05 (072711 not rematched).
`SEMANTIC_ID_WIDTH=32`. Not PASS.

### Absorbed 2026-09-16 (D 104154/104208 fabric WNS +1.549 not TIMING_PASS; FACT)

D ACK 100144: live [§22.1] R07 dest-complete confirmed; SHA256 `0371cfec…33350b`
MATCH (104208). D fabric keep-hierarchy post-synth WNS −10.174 → +1.549 TNS 0
(0 failing), pre-place, **not** TIMING_PASS. Integrated ≠ C OOC (+1.703/+1.898).
`NOT_CLAIMED: TIMING_PASS MIG_PASS BOARD_PASS FEM_PERSIST_PASS`. Did not clobber
[§23.9]/[§33.9]. A does not freeze +1.549. Live `03` still no `ACTION_INTENT`.
`schema_lock` omit-05 (072711 not rematched). `SEMANTIC_ID_WIDTH=32`. Not PASS.

### Absorbed 2026-09-16 (C Q*/SPEAR pipeline CANDIDATE + live §22 R07 17:35; FACT)

C mail `20260916T103211`: Q*/SPEAR timing pipelines published CANDIDATE, not
`TIMING_PASS`; ports/arithmetic/vectors unchanged; `RTL_PIPELINE_DEPTH =
IMPLEMENTATION_DEFINED`; 32-bit ID kept; OOC post-synth estimates only; D
re-synths fabric; `NOT_CLAIMED: TIMING_PASS VERIFIED BOARD_PASS`. A does not
freeze those OOC WNS numbers. Integrated −10.174 remains pre-rerun until D
quotes after fabric. Live `22` `last_modified` 17:35 R07 now dest-complete =
readback + matching txn/generation; FIFO-empty is hint only. Closes the
[§22] R07 OPEN row (100144 not rematched). Live `03` still no `ACTION_INTENT`.
`schema_lock` omit-05 (072711 not rematched). `SEMANTIC_ID_WIDTH=32`. Not PASS.

### Absorbed 2026-09-16 (no B/C/D land; A-owned WT==R1 SHA MATCH; FACT)

No real unread from B/C/D. SHA256 prefix WT==R1 MATCH for `00` `01` `02` `05`
`20` `READING_ORDER`. Live `03`/`04`/`31`/`32` still 14:45; no `ACTION_INTENT`.
`10` 12:58; `22` 12:40 R07 FIFO wording unchanged; `23`/`33` 16:25.
`schema_lock` omit-05 (072711 not rematched). `BIT_WIDTH ≠ ONTOLOGY`;
`NCG_RECORD ≠ QUERY_UART_RECORD`; `SEMANTIC_ID_WIDTH=32`. CHANGEBOT
`CB_ARCHITECTURE_20260916T101926_64f902` ACK APPLIED. Not PASS.

### Absorbed 2026-09-16 (no B/C/D land; 01.11 ASTRA+Skill echo; FACT)

No real unread from B/C/D. Live `03` 14:45 still no `ACTION_INTENT`. Live [§22]
R07 FIFO wording unchanged. A-owned verify: `SEMANTIC_ID_WIDTH=32`;
HotDirectory/Value/PostingPageHeader 128; Node/Edge/Context/Provenance 256;
PostingEntry 64; Query/Result/Event 256/384/192 remain [§04] [§20.9].
[§01.11] now echoes ASTRA action-precheck and `SKILL_ENGINE ≠ PRIMITIVE_EXECUTOR`.
CHANGEBOT `CB_ARCHITECTURE_20260916T101809_96d08a` ACK APPLIED. Not PASS.

### Absorbed 2026-09-16 (no B/C/D land; 01.6 critical rule Skill≠pins; FACT)

No real unread from B/C/D. Nested `CANON_BLUEPRINT_R0_1_AUDITED_CANDIDATE`
still has old Skill “executes” wording — **NOT LIVE**. Live A-owned [§01.6]
critical rules now name `SKILL_ENGINE ≠ PRIMITIVE_EXECUTOR`. Live `03` still
no `ACTION_INTENT` (074024 not rematched). CHANGEBOT `101609` `96d08a` /
`64f902` ACK APPLIED. `SEMANTIC_ID_WIDTH=32`. Not PASS.

### Absorbed 2026-09-16 (no B/C/D land; 01.5/01.6 Skill Engine table aligned; FACT)

No real unread from B/C/D. Live stamps unchanged. A-owned leftover: [§01.5]/[§01.6]
still said Skill “executes” / “How do I execute this?”. Aligned to
`SKILL_ENGINE ≠ PRIMITIVE_EXECUTOR`. [§01.6] ASTRA row now includes
action-precheck. Live [§03.1] unchanged (074024 not rematched). CHANGEBOT
`CB_ARCHITECTURE_20260916T101421_ecbdd9` ACK APPLIED. `SEMANTIC_ID_WIDTH=32`.
Not PASS.

### Absorbed 2026-09-16 (no B/C/D land; 20 SKILL_ENGINE ≠ PRIMITIVE_EXECUTOR; FACT)

No real unread from B/C/D. Live `03`/`04`/`31`/`32` still 14:45; `10` 12:58;
`12` 12:55 [§12.8] still `SKILL_STATE != EXECUTION_PERMISSION` (aligned; 082907
not rematched). Live [§03.1] Skill-as-executor wording unchanged (074024 not
rematched). A-owned: [§20.1] `SKILL_ENGINE ≠ PRIMITIVE_EXECUTOR`; [§20.2] Skill
Engine does not drive pins. CHANGEBOT `101234` `f95db8`/`64f902` ACK APPLIED.
`SEMANTIC_ID_WIDTH=32`. `schema_lock` omit-05 / [§22] R07 not rematched. Not PASS.

### Absorbed 2026-09-16 (no B/C/D land; 01.7 Skill≠pins vs live §03.1; FACT)

No real unread from B/C/D. Live `03` still 14:45; no `ACTION_INTENT` (074024 not
rematched). Live [§03.1] still routes “How do I execute this?” to Skill Engine;
A-owned [§01.7] now states that does **not** authorize pins. Not a rematch mail.
Live unowned scan: no `SEMANTIC_ID_WIDTH=24` / `24-bit identity` law in `03`/
`04`/`10`/`31`/`32`/`33`. [§04.2] still *examples* 24 significant bits.
`schema_lock` omit-05 / [§22] R07 / [§31] X0-15 not rematched.
CHANGEBOT `CB_ARCHITECTURE_20260916T101009_67f200` ACK APPLIED.
`SEMANTIC_ID_WIDTH=32`. Not PASS.

### Absorbed 2026-09-16 (no B/C/D land; 20 locks ACTION_PATH_PASS_SET; FACT)

No real unread from B/C/D. Live stamps unchanged. `schema_lock` omit-05 /
[§03] ACTION_INTENT / [§22] R07 / [§31] X0-15 not rematched.
A-owned: [§20.1] `ACTION_PATH_PASS_SET ≠ X0_15_BINDING_FAMILY`. CHANGEBOT
`CB_ARCHITECTURE_20260916T100745_f95db8` ACK APPLIED. `SEMANTIC_ID_WIDTH=32`.
Not PASS.

### Absorbed 2026-09-16 (no B/C/D land; 01/05.8 action-path names locked; FACT)

No real unread from B/C/D. Live `03` still has no `ACTION_INTENT` (074024 not
rematched). Live [§31] X0-15 still `Capability Binding` / `NO_BINDING/NO_ACTION`
(072711 not rematched). `schema_lock` omit-05 and [§22] R07 FIFO wording
not rematched. Live `10` 12:58; `23`/`33` 16:25.
A-owned: [§01.7] / [§05.8] now state the seven names are the action-path
acceptance set; [§31]/[§32] must echo them. CHANGEBOT `100535` `f95db8` /
`64f902` ACK APPLIED. `SEMANTIC_ID_WIDTH=32`. Not PASS.

### Absorbed 2026-09-16 (no B/C/D land; 01/READING_ORDER echo FIFO lock; FACT)

No real unread from B/C/D. Live `22` R07 wording unchanged (100144 not rematched).
Live `03`/`04`/`31`/`32` still 14:45; no `ACTION_INTENT`. `10` still 12:58.
`23`/`33` still 16:25 with [§23.9]/[§33.9]. `schema_lock` omit-05 not rematched.
A-owned: [§01.11] + `READING_ORDER` now echo `FIFO_EMPTY ≠ DEST_COMPLETE`.
CHANGEBOT `CB_ARCHITECTURE_20260916T100259_67f200` ACK APPLIED. Verify
`SEMANTIC_ID_WIDTH=32`; PostingEntry 64; `BIT_WIDTH ≠ ONTOLOGY`. Not PASS.

### Absorbed 2026-09-16 (NEW live §22 R07 FIFO-empty wording; FACT; not rematch)

No B/C land. Live `03`/`04`/`31`/`32` still 14:45; `10` still 12:58; `23`/`33`
still 16:25. NEW unowned quote on live `22` (12:40) R07 mitigation:
`FIFO empty + response completion before ACK`. Architecture:
`FIFO_EMPTY ≠ DEST_COMPLETE` [§02.4.1c] [§20.1]. Mail `20260916T100144` to D
(not a rematch of 072711 / 081526 / 094704). `schema_lock` omit-05 not
rematched. B [§03] ACTION_INTENT not rematched. CHANGEBOT `095904`
`67f200`/`61d77b` ACK APPLIED after this lock.

### Absorbed 2026-09-16 (no B/C/D land; A 02.9 stand-in name aligned; FACT)

No real unread from B/C/D. CHANGEBOT `CB_ARCHITECTURE_20260916T095624_ecbdd9`
on `00`/`20`/`READING_ORDER` ACK APPLIED (A-owned). Live `03`/`04`/`31`/`32`
still 14:45; no `ACTION_INTENT`. Live `10` still 12:58 (C WT same stamp; no
unpublished §10 land). Live `23`/`33` still 16:25. `schema_lock` still omits
`05` (072711 not rematched).
A-owned this pass: [§02.9] must-NOT names `mig_ui_bram` via `mig_ui32` (older
4K `mem_*` stub still a stand-in class, not persist). Verify:
`SEMANTIC_ID_WIDTH=32`; PostingEntry 64; `BIT_WIDTH ≠ ONTOLOGY`;
`RTL_PIPELINE_DEPTH ≠ LOGICAL_STAGE_COUNT`. Not PASS. B [§03]/[§04.2]/[§31]
not rematched.

### Absorbed 2026-09-16 (D 095004 Q*/SPEAR pipeline C-owned; FACT; not TIMING_PASS)

AGENT_D mail `20260916T095004`: C proposed Q* `U_MUL` split + SPEAR `crc_ok`
register. Live [§10.7.2] `RTL_PIPELINE_DEPTH = IMPLEMENTATION_DEFINED`.
D will not edit those modules. D quotes a new integrated WNS only after C
publishes RTL+SHA+OOC and D reruns fabric. Current −10.174 is **pre-fix**.
Not TIMING_PASS. Not a frozen cycle count. A does not write RTL.
Architecture: `RTL_PIPELINE_DEPTH ≠ LOGICAL_STAGE_COUNT`. Mail
`20260916T095522` ACK to D. `schema_lock` omit-05 / B [§03] ACTION_INTENT
not rematched. Live `03`/`04`/`31`/`32` still 14:45; `10` still 12:58;
`23`/`33` still 16:25.

### Absorbed 2026-09-16 (D 094704 pack dest 128b UI stand-in; FACT; not MIG_PASS)

AGENT_D mail `20260916T094704` ACK 093757: will not clobber live [§23.9]/[§33.9];
`BURST_MODE` 8-fixed stays CANDIDATE. Pack dest: `pack_loader` through
`mig_ui32` onto 128-bit `mig_ui_bram` in `arty_a7_r2_top` (replaced 32-bit
`t2ram`). Generated `mig0` `app_*` still unbound. XSim
`PACK_MIG_UI32_XSIM_PASS` 5 vectors ≠ `PACK_ABI_24_24_PASS` / board.
OOC `pack_mig_bind` WNS=+2.383 ≠ integrated Q* WNS=−10.174; **not**
TIMING_PASS. LUT/FF/BRAM counts are implementation snapshots, not freeze.
FEM persist still not T2 MIG. `schema_lock` omit-05 not rematched.
Architecture: `BRAM_STANDIN ≠ FEM_PERSIST_STORE` now names `mig_ui_bram`.
Mail `20260916T094928` ACK to D. B [§03]/[§04.2]/[§31] not rematched.

### Absorbed 2026-09-16 (no B/C land; D 23.9/33.9 stay closed; FACT)

No real unread from B/C/D. Live `03`/`04`/`31`/`32` still 14:45; no
`ACTION_INTENT`. B WT `03` still 08:33. Live `23`/`33` still 16:25 with
[§23.9] MIG snapshot and [§33.9] `pack_generation` (closed last pass).
`schema_lock` still omits `05` (072711 not rematched).
A-owned verify this pass: `SEMANTIC_ID_WIDTH=32`; PostingEntry 64;
`BIT_WIDTH ≠ ONTOLOGY`; `NCG_RECORD ≠ QUERY_UART_RECORD`; `XSIM_PASS ≠
BOARD_PASS`; [§05.8] seven pass names present. Not PASS. CHANGEBOT
`CB_ARCHITECTURE_20260916T093844_ecbdd9` is A's own 00/20/READING_ORDER;
ACK APPLIED. No rematch mail.

### Absorbed 2026-09-16 (D PACKAGE land §23.9 + §33.9 pack_generation; FACT; not MIG_PASS)

Live R1 `23` and `33` landed `last_modified: 2026-09-16T16:25:00+07:00`
(SHA prefix `091f23b83a0eca5d` / `cde1c8677ffd7f48`).
- [§23.9] generated MIG snapshot CANDIDATE: `APP_DATA_WIDTH=128`,
  `ADDR_WIDTH=28`, `ECC=OFF`, `BURST_MODE` 8-fixed, `InputClkFreq=166.666`,
  `BOARD_OSC` 100 MHz must not feed `sys_clk_i`, `mig0` unbound,
  `mig_ui_bram` stand-in. **Not** freeze, **not** MIG_PASS, **not** NCG
  resize. `ui_clk` ~83.3 and WNS not frozen.
- [§33.9] ManifestHeader table offset 12 is `pack_generation`; 128 B /
  `reserved=12`. Quoted `| 12 | 4 | generation |` is **CLOSED**.
D WT `23`/`33` still 08:20 / 13:20 — do **not** clobber live with WT.
`schema_lock` omit-05 remains OPEN (072711 not rematched). B [§03]/[§04.2]/[§31]
not rematched. Mail `20260916T093757` ACK to D.

### Absorbed 2026-09-16 (no B/C/D land; SemanticEvent 24 B ≠ ID; FACT)

No real unread from B/C/D. Live timestamps unchanged (`03`/`04`/`31`/`32`
14:45; `10`/`11` 1.4; `23` 12:40; `33` 13:20). B WT `03` still 08:33, no
`ACTION_INTENT`. D WT `33` still omits [§33.9]. Do not rematch 074024 /
072711 / 085241 / 084806 / 091107.

Architecture: live [§04.5] SemanticEvent **192 bits / 24 bytes** is a
wire size, not a 24-bit identity law. `SEMANTIC_EVENT_BYTES ≠
SEMANTIC_ID_WIDTH`. Same 24-as-not-identity family as Pack/ABI-24 case
count and SPEAR MAC product. No rematch of [§04.2] example. CHANGEBOT
`CB_ARCHITECTURE_20260916T093201_64f902` is A's own [§01]; ACK APPLIED.

### Absorbed 2026-09-16 (no B/C/D land; NCG ≠ Query UART; FACT)

No real unread from B/C/D. Live `03`/`04`/`31`/`32` still 14:45; `10`/`11`
still 1.4; `23` still 12:40; `33` still `| 12 | 4 | generation |`; D WT
`33` still omits [§33.9]; `schema_lock` omit-05. B `TEST_WAKE` `091107`
unread. Do not rematch 074024 / 072711 / 085817 / 085241 / 084806 / 092734.

Architecture: `NCG_RECORD ≠ QUERY_UART_RECORD`. QueryRecord 256 /
StructuredResult 384 / SemanticEvent 192 remain [§04], not NCG T1/T2
types. [§20.9] retitled to match [§02.4] candidate-width table. CHANGEBOT
`CB_ARCHITECTURE_20260916T092824_ecbdd9` is A's own 00/20/READING_ORDER;
ACK APPLIED. No rematch mail.

### Absorbed 2026-09-16 (D 092417 OOC WNS moved; XSIM_PASS ≠ BOARD_PASS; FACT; not TIMING_PASS)

AGENT_D mail `20260916T092417` `D OOC fem_media_sys WNS recovered after C CRC pipe`.
STATUS: CANDIDATE. No architecture conflict. OOC `fem_media_sys` WNS
−1.213 → +3.754 after C registered CRC16. Integrated Q* path still
WNS=−10.174. MIG unbound. **Not** TIMING_PASS.
Architecture: slack numbers are snapshots that **move**; do not freeze
−1.213 or +3.754 or −10.174. `OOC_WNS ≠ TIMING_PASS`. OOC ≠ integrated.
`XSIM_PASS ≠ BOARD_PASS`. Live [§22] R20 already forbids promoting XSim
to board semantic PASS. MIG unbound remains consistent with the
`pack_loader` BRAM stand-in. Live [§23]/[§33.9]/`schema_lock` omit-05
and B [§03]/[§04.2]/[§31] not rematched.
Mail `20260916T092734` ACK to D.

### Absorbed 2026-09-16 (C ACK 091831 MAC≠ID + MIG packing; FACT; not PASS)

AGENT_C mail `20260916T091831` ACK 085453 / 083853. Live [§10.7.5] Q5.19
24-bit stays SPEAR MAC product width (Qm.n C CANDIDATE), **not**
`SEMANTIC_ID_WIDTH`, **not** `ACTIVE_ID_RANGE`; wording kept, no retitle.
MIG `APP_W=128` is D evidence/packing; NCG widths stay [§02.4]; C FSM
word-sequential is local model only. No C delta. **Not** PASS. A does not
freeze Qm.n. `PACK_ABI_24_24_CASES ≠ SEMANTIC_ID_WIDTH` remains (24 gold
cases, not identity). B [§03]/[§04.2]/[§31] and D [§23]/[§33.9] not rematched.
Mail `20260916T092221` ACK to C.

### Absorbed 2026-09-16 (no B/C/D land; PACK_ABI_24_24 = 24 cases ≠ ID; FACT)

No real unread from B/C/D. B `TEST_WAKE` `091107` still unread (B STALE).
Live R1 SHA-unchanged vs last absorb: `03`/`04`/`31`/`32` still 14:45;
`10` v1.4 `0639de2f`; `11` v1.4 `efcd0283`; `12`/`13` v1.3; `23` `6b45d1dd`
no generated-MIG row; `33` still `| 12 | 4 | generation |`; D WT `33`
`33a2e922` still omits [§33.9]; `schema_lock` omit-05.
Do not rematch 074024 / 072711 / 085817 / 085453 / 085241 / 084806 / 091107
bodies.

Architecture (A-owned, not a B rematch): live [§31.2] `PACK_ABI_24_24_PASS`
is **24 gold integrity cases**, not a 24-bit semantic-ID law.
`PACK_ABI_24_24_CASES ≠ SEMANTIC_ID_WIDTH`. Same 24-as-count rule as SPEAR
MAC 24 ≠ identity. No mail.

### Absorbed 2026-09-16 (D-INTEG-01 090254 BRAM stand-in / WNS / K_HARD_MAX=8; FACT; not PASS)

AGENT_D mail `20260916T090254` `D-INTEG-01 no profile conflict; MIG unbound; Q* WNS`.
STATUS: CANDIDATE. PROGRAM=NO. No conflict with A-ID-PROFILE-01 / A-C-14 /
A-D-INTEG-01: SEMANTIC_ID_WIDTH=32; range/`K_HARD` from loaded profile;
`K_HARD_MAX` is SPEAR slot ceiling not a profile field; no silent clamp;
`COMMITTED_CORRUPT` dest-integrity; page pointer 0 remains reserved null.

NEW FACTS (not rematches of 083853 / 085241 / 084806):
- Fabric top still uses a 4K-word BRAM stand-in for `pack_loader` `mem_*`
  (`APP_W=128` not bound on that stub). Stand-in is **not** persist
  authority. Canonical FEM persist remains T2 DDR via MIG.
- Generated MIG still `APP_W=128` / `ADDR=28` / `ECC=OFF` at `D:/FPGA/miggen`.
  Not MIG_PASS (no calib). Burst still UNKNOWN.
- Post-synth not routed: OOC `fem_media_sys` WNS=-1.213 @100 MHz (CRC combo);
  integrated keep_hierarchy top WNS=-10.174 (Q* theta). OOC ≠ integrated.
  **Not** TIMING_PASS. A does **not** freeze those slack numbers.
- D-reported compiled `K_HARD_MAX=8` is a compiled-ceiling candidate, **not**
  an architecture integer (A still does not freeze 16 or 8).
No FEM_PERSIST_PASS / PACK_ABI_24_24_PASS / BOARD_PASS / FINAL_PASS.
Architecture: `BRAM_STANDIN ≠ FEM_PERSIST_STORE`; `OOC_WNS ≠ TIMING_PASS`.
Live [§23] still missing generated-MIG row; [§33.9] still `| 12 | 4 |
generation |`; `schema_lock` omit-05 — not rematched.
Mail `20260916T091107` ACK to D; C notified that 8 is not frozen.
B `TEST_WAKE` retry `20260916T091107` (prior `084446` still unread; not a rematch of 074024 bodies).

### Absorbed 2026-09-16 (D-06 091103 Arty 100 MHz vs MIG 166.666 sys_clk; FACT; not freeze)

AGENT_D mail `20260916T091103` `D-06 Arty 100 MHz vs MIG 166.666 sys_clk`.
STATUS: CANDIDATE. No ID-profile conflict. Generated `mig0`
`InputClkFreq=166.666` (`CLKIN_PERIOD=6000`). Arty A7-100T oscillator is
100 MHz. D added MMCM `clk_arty_mig` (100→166.667 sys + 200 ref). Feeding
100 MHz into `sys_clk_i` is a false path. `pack_loader` `mem_addr` is a
28-bit byte address; `mig_ui32` aligns to 16-byte beats. Page pointer 0
remains reserved null (directory), unrelated to DDR beat 0. MIG still not
instantiated in the fabric top. **Not** MIG_PASS.
Architecture: `BOARD_OSC ≠ MIG_SYS_CLK`; `NULL_T2_PTR ≠ DDR_BEAT_ZERO`.
Do **not** freeze 100 / 166.666 / 200. Live [§23] still missing generated
MIG row (clock + APP_W); 085241 body not re-sent.
Mail `20260916T091439` ACK to D.

### Absorbed 2026-09-16 (D-INTEG-01; FACT; not a PASS)

AGENT_D mail `20260916T075137` `D-INTEG-01 ID-profile and FEM recover class`:
- CONFLICT_1 accepted: high-zero of bits above `ACTIVE_ID_RANGE` is packing/range
  check, **not** a new ID width. D must not shrink wire identity. SPEAR
  `[31:24]==0` hard-code remains rejected as identity law [§02.4.1b].
- CONFLICT_2 locked: C’s three `FEM_COMPACTION_RECOVER` states stay three.
  Dest `COMMITTED_CORRUPT` is `FEM_DEST_INTEGRITY`, not a fourth compaction
  state. Index must not upgrade CORRUPT → `COMMITTED_NEW` [§02.4.1c].
- CONFLICT_3 accepted: FEM canonical store = T2 DDR via MIG; T1 cache only;
  word-atomic local model ≠ DDR crash safety; FIFO-empty ≠ dest complete.
  MIG `app_data` was still UNKNOWN on that ACK.
A does not write [§11] or B status law. C must echo dest class when publishing
live [§11]. D-06 M2_DIR_XSIM remains CANDIDATE, not M2_PASS.

### Absorbed 2026-09-16 (C WT 10/11 v1.4 unpublished; FACT; not live)

C worktree (not R1, not repo):
- `10_LEARNING_AND_STRATEGY.md` v1.4-candidate size 25880 SHA `e6368d0b65e626ba`
- `11_FAILURE_EXPERIENCE_MEMORY.md` v1.4-candidate size 16708 SHA `aa4613ce483fef1c`
Repo copies remain v1.3. Live R1 **was** still v1.1 at this unpublished-C
note (superseded by PACKAGE land 15:10: live `10`/`11`=1.4). A does not merge C.

Accepted as CANDIDATE echo (not live lock):
- [§10.1] `ACT` emits `ACTION_INTENT` into [§01.7]/[§05]; does not drive pins.
- [§10.7.3] `candidate_ref` 32-bit; defensive `active_id_max`; 24 significant
  bits called an Arty **example**, not identity law.
- [§11.12.3] dest class `COMMITTED_CORRUPT` named (COMMITTED+CRC-fail, no
  roll-forward, not `UNKNOWN`).

Rejected namespace collapse: [§11.12.3] still says “exactly one of **three**
states” then lists dest `COMMITTED_CORRUPT` in the same block. W9
`commit_state[1:0]` still names only the three compaction states. Dest
integrity remains parallel, not a fourth `commit_state` code [§02.4.1c].

### Absorbed 2026-09-16 (C PACKAGE land 10/11=1.4, 12/13=1.3; FACT)

Live R1 now SHA-matches C WT/repo:
- `10` v1.4-candidate SHA `e6368d0b65e626ba` size 25880
- `11` v1.4-candidate SHA `aa4613ce483fef1c` size 16708
- `12` v1.3-candidate SHA `eef2292a7f3e1193` size 9416
- `13` v1.3-candidate SHA `b23c2cf575d64369` size 15729

Quoted 1.1 defects are **gone** on live R1: [§10.1] `ACT` → `ACTION_INTENT`;
[§12.1] SkillRecord counts are utility-only / not proof; [§13.2] WM/LTM are
logical class with T1/T2 as typical placement; [§13.7] `SEARCH_INCOMPLETE`.
A does not freeze FailureRecord 128 / SkillRecord 256 into the NCG table.
[§11.12.3] dest-namespace collapse was OPEN on that SHA; **closed** on the
`efcd0283` republish below.

### Absorbed 2026-09-16 (C ACK A-C-14 dest namespace; FACT; not PASS)

AGENT_C mail `20260916T081548`: ACK 080341 / 075748 / 080750 / 081127.
Live R1 `11` republished v1.4 SHA prefix `efcd0283` size 17406 (was
`aa4613ce` / 16708). `10` republished v1.4 SHA prefix `0639de2f` (ACT /
`active_id_max` / `K_HARD_MAX` still present). [§11.12.3] now has a
separate `FEM_DEST_INTEGRITY` block; compaction stays three states; W9
`commit_state[1:0]` compaction-only; dest observable `integrity_fault`;
no index upgrade / retire; `t2_ready` stall. Quoted dest-namespace
collapse on live `11` is **CLOSED**. C claims TB `+STALL=1` PASS; A does
not inspect RTL and does not claim FEM_PERSIST_PASS.

### Absorbed 2026-09-16 (A-owned NCG width set echoed in §01.11; FACT)

No real B/C/D unread. Live §03 still has no `ACTION_INTENT`. §33.9 still
`| 12 | 4 | generation |`. Nested MASTER_CANON `semantic_id | 24` remains
**NOT LIVE**. A-owned [§20.9] table matches the contract (128/256/128/64;
Query/Result/Event 256/384/192 on the wire). [§01.11] now names that set
without forking a second table. CHANGEBOT `CB_ARCHITECTURE_20260916T085907_61d77b`
is A's own [§02] PostingEntry packing lock; ACK APPLIED. No rematch mail.

### Absorbed 2026-09-16 (PostingEntry 64 ≠ 128-bit pack group; FACT)

No B/C/D land. Live R1 [§31] has no `PostingEntry` / 2×64 packing check
(grep miss). Architecture: `POSTING_ENTRY_WIDTH ≠ PACK_GROUP_WIDTH`. 64-bit
entry remains the record; two-per-128-group is packing, not a 128-bit type,
not identity, not MIG freeze. Query/Result/Event stay [§04] (256/384/192).
Mail `20260916T085817` to B. B [§03] action-precheck / [§05.8] names / [§04.2] example not rematched.

### Absorbed 2026-09-16 (SPEAR 24-bit MAC ≠ ID; FACT; not Q-format freeze)

No B/C/D land. Live R1 `10` [§10.7.5] SHA `0639de2f…` uses a signed 24-bit
Q5.19 product then 32-bit acc. Architecture lock: `SPEAR_MAC_PRODUCT_WIDTH ≠
SEMANTIC_ID_WIDTH`. That 24 is ranking arithmetic (C-owned CANDIDATE Qm.n),
not a 24-bit identity law and not `ACTIVE_ID_RANGE`. A does not freeze Qm.n.
Mail `20260916T085453` to C. B [§03]/[§04.2]/[§31] and D [§23]/[§33.9] not rematched.

### Absorbed 2026-09-16 (live §23 missing D-06 MIG candidate row; FACT; not freeze)

No B/C/D land. B `TEST_WAKE` and D `084806` still unread. Live R1
`23_HARDWARE_FACTS.md` v1.1 `12:40` SHA `6b45d1dd…` still has no generated
MIG row. D-06 reported `APP_DATA_WIDTH=128` / `ADDR_WIDTH=28` / `ECC=OFF`
(`D:/FPGA/miggen`); burst still UNKNOWN. [§23.2] correctly forbids freezing
latency; it should **record** that generated-IP candidate in the hardware
facts / run-manifest sense, **not** as architecture ABI. NCG widths stay
128/256/64. CHANGEBOT `CB_ARCHITECTURE_20260916T084915_96d08a` is A's own
`00_INDEX` ledger; ACK APPLIED. Mail `20260916T085241` to D. B [§03]/[§04.2]/[§31] not rematched.

### Absorbed 2026-09-16 (action-lane off §04 UART echo; FACT; not PASS)

No B/C/D land. B `TEST_WAKE` `084446` still unread. D `084806` still unread.
CHANGEBOT `CB_ARCHITECTURE_20260916T084207_f45a2d` is A's own [§01]/[§02]
MIG-evidence publish (hashes `eacc2998`→`9356d439`, `d102b798`→`010a4f25`);
ACK APPLIED. Architecture: [§05.1] now echoes live [§04.13] —
`ACTION_LANE_OBJECT ≠ QUERY_UART_RECORD`; verdicts must not reuse query
`0x01–0x06`. B action-precheck / [§05.8] names / [§04.2] example not rematched.

### Absorbed 2026-09-16 (no B/C land; D WT §33 unpublished; FACT)

No real unread from B/C/D. B did not ACK `TEST_WAKE` `20260916T084446`
(still unread; B presence STALE). Live R1 B/C files SHA-unchanged vs last
absorb (`03`/`04`/`31`/`32` still 14:45; `10`–`13` still 12:55–12:58).
Do not rematch 074024 / 072711 bodies.

NEW FACT-diff (not a rematch of the live `generation` cell): D WT
`33_IMPLEMENTATION_GUIDE.md` SHA `33a2e922…` size 5776 **omits live [§33.9]
M1 ManifestHeader table entirely**. Live R1 `33` SHA `f053be71…` size 8963
still has [§33.9] and `| 12 | 4 | generation |`. If D publishes WT as-is,
do **not** drop the 128 B ManifestHeader echo; rename the offset-12 field
to `pack_generation`. Record D-06 generated MIG in the run manifest only;
do not freeze `APP_DATA_WIDTH`. `schema_lock` omit-05 not rematched.
Mail `20260916T084806` to D.

### Absorbed 2026-09-16 (D-06 ACK K_HARD_MAX + APP_W 128; FACT; not MIG_PASS)

AGENT_D mail `20260916T082717`: K_HARD = loaded profile; K_HARD_MAX =
compiled SPEAR ceiling, not a profile field; `K_HARD > K_HARD_MAX` →
`k_invalid`, no clamp. SEMANTIC_ID_WIDTH stays 32. SPEAR range check is
`prof_active_id_max`, not `[31:24]==0`. COMMITTED_CORRUPT stays
dest-integrity. Generated native MIG: `APP_DATA_WIDTH=128`,
`ADDR_WIDTH=28`, `ECC=OFF` (`D:/FPGA/miggen`). **Not** MIG_PASS / BOARD_PASS.
Architecture: record as D-owned generated-IP evidence; do **not** freeze
`app_data` / `ADDR_WIDTH` / `ECC` as ABI; `MIG_APP_W ≠ NCG_RECORD_WIDTH`;
`MIG_ADDR_WIDTH ≠ SEMANTIC_ID_WIDTH`; burst length still UNKNOWN.
C’s four-32-bit-words-per-beat note is packing arithmetic of that
generated width (D media contract), not an NCG resize. `schema_lock`
omit-05 and [§33] `| 12 | 4 | generation |` not rematched.
Mail `20260916T083853` to D and C.

### Absorbed 2026-09-16 (live §12.8 skill/demo path; FACT; not PASS)

No new B/D land. Live R1 `12` SHA `eef2292a…` [§12.8] matches [§01.7]/[§05]:
lookup is non-actuating; ASTRA legality + `safety_contract` precheck;
`CapabilityBinding == BOUND` else `NO_BINDING`/`NO_ACTION`; then
`PrimitiveCommand` → Primitive Executor → `ObservedEffect`. Architecture
lock: `SKILL_STATE ≠ EXECUTION_PERMISSION`; origins Q*/Skill/`HUMAN_DEMO`
share one path; no teacher-to-actuator side channel. SkillRecord 256-bit
proposal remains C-owned and is **not** frozen into NCG. B [§03]
ACTION_INTENT / [§04.2] 24-bit example / [§31]/[§32] [§05.8] names remain
OPEN (not rematched). Mail `20260916T082907` to C.

### Absorbed 2026-09-16 (live §10.8.4 credit chain; FACT; not PASS)

No new mailbox. Live R1 `10` SHA `0639de2f…` [§10.8.4] is compatible with
[§01.7]/[§05]: proposal ≠ legal ≠ execution ≠ effect ≠ reward ≠ credit;
at most one pending; unexecuted Top-1 gets zero credit; `reward_accepted`
only after matching `(episode_id, step_id, command_id, generation)` plus
`ObservedEffect` citing `command_id`. C local names are not ABI. B
action-precheck / [§05.8] pass names in [§31]/[§32] remain OPEN (not rematched).

### Absorbed 2026-09-16 (C ACK A-ID-PROFILE-01; FACT; not RTL verify)

AGENT_C mail `20260916T080632`: ACK 074024 / 071529. Claims baked
`candidate_ref[31:24]==0` removed from `spear_ref.py` / `spear_rank.v` and
replaced by `prof_active_id_max` (D wires; B Manifest field). Reason
`ID_OUT_OF_ACTIVE_RANGE`. `0x00FFFFFF` is Arty EXAMPLE default only. A does
**not** inspect that RTL and does not claim PASS.
Architecture absorb: `K_HARD` (profile) ≠ `K_HARD_MAX` (C compiled SPEAR
slot ceiling). `K_HARD > K_HARD_MAX` ⇒ fail-closed `k_invalid`; B maps
status [§02.4.1b]. Heading `## 11.2 FailureRecord R0.1` may stay (title,
not an NCG freeze). Dest-namespace on live [§11.12.3] still OPEN.

### Absorbed 2026-09-16 (D-INTEG-01 ACK; FACT; not M2_PASS)

AGENT_D mail `20260916T081054`: CONFLICT_1/2/3 accepted. Claims SPEAR
`d_ref[31:24]==0` hard-code removed; `id_ok = (d_ref <= active_id_max)` from
`runtime_profile`. Pack loader remains ingress. MIG `APP_W` still UNKNOWN
at that mail (later D-06 082717 reported generated 128; not freeze).
M2 path `ID → directory admit → posting page`. XSim
`M2_DIR_XSIM_PASS hit=235`; `M2_POST_XSIM_PASS rows=235`. **Not** M2_PASS /
FEM_PERSIST_PASS / BOARD_PASS. A does not inspect that RTL.
Architecture: T2 address `0` is null/end for page/descriptor/posting
pointers, **not** semantic identity `0`. D’s first-page-at-byte-16 is an
M2 candidate so `0` stays null; **byte 16 is not frozen** [§02.4.8].
`schema_lock` omit-05 and [§33] `| 12 | 4 | generation |` not rematched.

### Absorbed 2026-09-16 (D-06 M2 directory; FACT)

AGENT_D mail `20260916T073637`: `STATUS: CANDIDATE` / `M2_DIR_XSIM_PASS hit=235 miss_ok=4` / `NOT_CLAIMED: M2_PASS BOARD_PASS`. Quotes HotDirectoryEntry 128 [§02.4.2], directory miss ≠ ASTRA status, `PostingEntry.edge_ref` = byte address. **Does not** close `schema_lock` omit-05 or [§33] `| 12 | 4 | generation |`. A does not promote this to M2_PASS.

### Absorbed 2026-09-16 (B freeze; FACT)

R1 `03_ASTRA_AUTHORITY.md` v1.4-candidate `last_modified: "2026-09-16T13:50:00+07:00"`:
- GEMINI xref is `[§01.8]`: `"How do I say this to a human?" → GEMINI / Language Adapter [§01.8]`
- [§03.2] status table uses `` `SEARCH_INCOMPLETE` ``
- [§03.6] flow text is `MISSING / UNKNOWN / SEARCH_INCOMPLETE`
- [§03.9] CONFLICT reason is `` `DISTINCT_VERIFIED_REFS` `0x30` ``

R1 `04_ABI_AND_PROTOCOL.md` v1.4-candidate same stamp:
- [§04.6] heading: `Knowledge Pack Manifest — locked 128-byte ManifestHeader`
- offset 116: `` `reserved` **must be zero** `` size 12
- `` `reserved=16` (132-byte total) is a failed candidate, not an alternate ABI. ``
- `` `pack_generation` `` u32 ≠ `` `knowledge_generation` `` u16
- [§04.12] includes `` `DISTINCT_VERIFIED_REFS=0x30` ``

AGENT_B mail `20260916T063432`: "ManifestHeader 128 B, reserved=12, CRC [0:112),
pack_generation u32 != knowledge_generation u16. reserved=16/132 is illegal.
… GEMINI xref is 01.8. 00_INDEX 128-vs-132 open note is stale vs live 04.6."

AGENT_D mail `20260916T063652`: "28-bit mem_addr remains physical slot offset,
not semantic identity. MIG app_data still UNKNOWN at that mail. M1 OOC after BRAM+CRC:
LUT 552 WNS +2.004 ns unplaced. Not TIMING_PASS." No schema_lock / [§33]
patch claimed.

### Absorbed 2026-09-16 (B 1.5 runtime-law; FACT)

R1 `03`/`04` v1.5-candidate and `31`/`32` v1.4-candidate,
`last_modified: "2026-09-16T14:45:00+07:00"`:
- [§04.13] action-lane objects remain **off** Query/Result UART unless a later
  ABI adds distinct records. Reward identity =
  `(episode_id, step_id, command_id, generation)`.
- [§04.13] `K_hard` is the same loaded profile as `ACTIVE_ID_RANGE` (echo of
  A-ID-PROFILE-01). `K_soft` is not a QueryRecord field.
- [§03.9.2] reason_codes `TIE_OVERFLOW` `0x22`, `K_INVALID` `0x23`,
  `INVALID_DESCRIPTOR` `0x55`, `COMMITTED_CORRUPT` `0x56` are **reasons**,
  not primary status. Status mapping is B-owned.
- Still **no** `ACTION_INTENT` / `SAFETY_VETO` action-precheck in [§03].
- [§04.2] still *examples* “24 significant bits” (range, not type).
- [§31]/[§32] still omit [§05.8] pass names.

Ledger: [§04.13] **closes** the prior “no sentence that action objects are
not UART records” row. Action-precheck and [§05.8] names stay OPEN.
Worktree copies of [§03]/[§04] remain lagging snapshots, not live ABI.

### Closeout 2026-09-16T13:56+07 (FACT; not a new ledger)

Both `_COORDINATION` trees share one mailbox
(`CANON_BLUEPRINT/_COORDINATION/mailbox`; WT mailbox resolve = R1 mailbox).
Unread CHANGEBOT ignored (5 unread PATCH/digest JSON; not marked read).
No new AGENT_B / AGENT_C / AGENT_D architecture JSON to A after
`20260916T064701` (already absorbed last pass).

AGENT_C worktree exists. HEAD still `0cb23dd6ce01ede82de763447a849e289deeb1f5`
on `branch_agent_c`. Live R1 `10`/`11`/`12`/`13` filesystem mtime still
`2026-09-15T18:16:04Z` (sizes 5158/4759/4939/7751). C WT copies mtime
`2026-09-16T06:46:23Z` (sizes 24338/15744/9416/15729), v1.3-candidate.
A does not merge C. A does not copy C files. C candidate bit-budgets
(`FailureRecord` 128 / `FailurePrototype` 320 / `SkillRecord` 256) are
**not** live R1 and are **not** absorbed as A locks. Episode width remains
unlocked in [§01.4]/[§02] (no invented budget).

NEW MAIL C `20260916T065611` HIGH dual-send (shared inbox two files
`…_0a448d.json` / `…_63af9d.json`): live R1 paths still have the
2026-09-15 quotes; A closes C ledger rows only after `10`/`12`/`13`
(or fourth `11`) appear on R1 CANON_BLUEPRINT with the locked wording;
A will not merge `branch_agent_c`. 064243 B/D bodies not re-sent.

B encodings already in A-owned [§20.4]/[§20.5]/[§02.4.10]. Live R1
[§03]/[§04] still have no action-precheck / action-object law — no new
echo into [§01.7]/[§20.5.1]/[§05]. B restamped `03`/`04`/`31`/`32`
`last_modified` to `2026-09-16T13:50:00+07:00` (mtimes 06:52–06:54Z)
without landing those residuals.

D **did** land the three `20260916T064243` [§33] residuals (mtime
`2026-09-16T06:54:13Z`): [§33.2] HotDirectory pointer; [§33.5]
CapabilityDescriptor match; ManifestHeader prose 128 B / `reserved=12`.
A-owned [§02.4]/[§20.9] already had those widths — no 01/02/05/20 edit.
`schema_lock.json` SHA
`105ee6b23a9a46a76eba215368ac2d27c98b3620ed829678d45211d8fc97e640`
mtime `2026-09-16T00:29:49Z` still omits `05`.

### Width-gate 2026-09-16T14:03+07 (FACT; not a new ledger)

Both COORD mailbox paths resolve to one inbox
(`CANON_BLUEPRINT/_COORDINATION/mailbox`). Unread CHANGEBOT ignored
(7 PATCH/digest JSON at end of pass, including two
`CB_ARCHITECTURE_20260916T070316_*` after the A→R1 copy; not marked
read). No new AGENT_B / AGENT_C / AGENT_D architecture JSON to A after
`20260916T064701`. 065611 and 064243 not re-sent.

Live R1 `10`/`11`/`12`/`13` still v1.1-candidate; filesystem mtime
`2026-09-15T18:16:04Z`; sizes 5158/4759/4939/7751. Header
`last_modified` still 08:34/08:36/08:38/08:40+07. C ledger rows stay
OPEN. C WT still `0cb23dd6ce01ede82de763447a849e289deeb1f5` on
`branch_agent_c` (not merged; not copied to R1).

WIDTH GATE vs live [§02.4] (`SKILL`/`EPISODE`/`FAILURE` ≠ NodeRecord
256): C WT [§11.13]/[§12.10] layouts are typed separate records.
Packed word bit-sums are honest: `FailureRecord` 128 / 4 words;
`FailurePrototype` 320 / 10 words; `SkillRecord` 256 / 8 words.
SkillRecord 256 ≠ Node/Edge alias. Utility stays on SkillRecord, not
EdgeRecord. `EpisodeRecord` bit budget unpublished — not invented.
Absorbed as a short CANDIDATE note in A-owned [§02.4] / [§20.9] only;
A does not freeze those widths.

Live R1 `03`/`04`/`33` mtimes/versions unchanged this pass
(`03`/`04` 1.4-candidate `2026-09-16T13:50:00+07:00`; `33`
1.1-candidate `2026-09-16T13:20:00+07:00`). Leftover rows not
re-quoted. 01 / 05 / `READING_ORDER.md` not edited.

### Episode-class lock 2026-09-16T14:12+07 (FACT; not a new ledger)

Both COORD mailbox paths still resolve to one inbox
(`CANON_BLUEPRINT/_COORDINATION/mailbox`). Unread CHANGEBOT ignored
(not marked read). One new AGENT_C HIGH: `20260916T070550` (shared
inbox one file `…_5a96e5.json`); no new AGENT_B / AGENT_D architecture
JSON to A. 065611 and 064243 not re-sent. C mail marked read after
absorb.

C mail claims publish of S10–S13 v1.3 to
`D:/FPGA/NATIVE_AI/CANON_BLUEPRINT`. FACT: those four repo files are
`version: "1.3-candidate"` and SHA-identical to C WT copies. User-defined
R1 package
(`…R1_PACKAGE…/CANON_BLUEPRINT`) `10`/`11`/`12`/`13` remain
`version: "1.1-candidate"`; SHA and the quoted OPEN lines below are
unchanged. C ledger rows stay OPEN. A does not merge C. A does not copy
C files onto R1.

C WT HEAD `f42c58fc3e8b90be458c8575c2ac8671dc8fc1c1` on
`branch_agent_c`. C WT [§11.13] still has no `EpisodeRecord` bit table
and points EPISODE at [§01.4]/[§02].

EPISODE HOLE was unlisted as a class lock (prior notes only said bits
unpublished). Now locked in A-owned prose only:
- [§02.4] next to SKILL/EPISODE/FAILURE ≠ `NodeRecord`
- [§20.4] `EpisodeRecord` row (was missing)
- [§01.4] one sentence so the Temporal Event table is not the whole class
`EpisodeRecord` is a required typed T2 class, not `NodeRecord`, not
`FailureRecord`, not a `SemanticEvent` UART packet. FEM may cite
`episode_id`; FEM is not the episode store. Bit width and field list
remain UNKNOWN until live C/B publish a table A can gate. No numeric
budget assigned.

### Two-path 2026-09-16T14:16+07 (FACT; not a new ledger)

Both COORD mailbox paths still resolve to one inbox
(`CANON_BLUEPRINT/_COORDINATION/mailbox` = R1 package). Unread CHANGEBOT
ignored (3 unread: planned-restart PATCH, PENDING_DIGEST 7, and
`CB_ARCHITECTURE_20260916T071241_f45a2d`; not marked read). No new
AGENT_B / AGENT_C / AGENT_D architecture JSON to A after `20260916T070550`
(already absorbed last pass). 065611 and 064243 bodies not re-sent.

Re-stat 10/11/12/13 this pass:
- R1 PACKAGE still `version: "1.1-candidate"`; mtime `2026-09-15T18:16:04Z`;
  sizes 5158/4759/4939/7751. Quoted 1.1 lines still present.
- Repo `D:\FPGA\NATIVE_AI\CANON_BLUEPRINT` still `version: "1.3-candidate"`
  and SHA-identical to C WT. Repo 1.3 ≠ package live.
- C WT HEAD still `f42c58fc3e8b90be458c8575c2ac8671dc8fc1c1` on
  `branch_agent_c`. A does not merge C. A does not copy C files onto R1.

NEW MAIL C `20260916T071529` HIGH dual-send (shared inbox two files
`…_5f0314.json` / `…_0f8e41.json`): subject
`package 10-13 still 1.1 not repo tree`. Body names both absolute paths.
A closes C rows only after PACKAGE files are 1.3+ without the 1.1 quotes.

B/D PACKAGE residuals not closed — not re-mailed. Live R1 `03` still
1.4-candidate / 13:50 with no `ACTION_INTENT`. `04` last_modified still
13:50 (mtime now `2026-09-16T07:10:21Z`) still has no action objects.
`31`/`32` restamped 1.3-candidate `2026-09-16T14:10:00+07:00` but still
lack [§05.8] pass names. `33` leftover `| 12 | 4 | generation |` remains.
`schema_lock.json` SHA
`105ee6b23a9a46a76eba215368ac2d27c98b3620ed829678d45211d8fc97e640`
still omits `05`. 01 / 05 / `READING_ORDER.md` not edited.

### Live-trees 2026-09-16T14:24+07 (FACT; not a new ledger)

Both COORD mailbox paths still resolve to one inbox
(`CANON_BLUEPRINT/_COORDINATION/mailbox` = R1 package). Unread CHANGEBOT
ignored (3 unread: planned-restart PATCH, PENDING_DIGEST 7, and
`CB_ARCHITECTURE_20260916T071705_96d08a`; not marked read). No new
AGENT_B / AGENT_C / AGENT_D architecture JSON to A after `20260916T070550`
(already absorbed). 071529 / 065611 / 064243 not re-sent.

Re-stat PACKAGE 10/11/12/13 this pass:
- R1 PACKAGE still `version: "1.1-candidate"`; mtime `2026-09-15T18:16:04Z`;
  sizes 5158/4759/4939/7751. Quoted 1.1 lines still present
  (`ACT` = actuator; `SkillRecord` counts; WM = T1 BRAM / LTM = T2 DDR).
- Repo `D:\FPGA\NATIVE_AI\CANON_BLUEPRINT` still `version: "1.3-candidate"`
  and SHA-identical to C WT. Repo 1.3 ≠ package live.
- C WT HEAD still `f42c58fc3e8b90be458c8575c2ac8671dc8fc1c1` on
  `branch_agent_c`. A does not merge C. A does not copy C files onto R1.
C ledger rows stay OPEN. No absorb into [§20]/[§02] this pass.

A-05 LIVE TREES table is now the coordination map at the top of this
note. `READING_ORDER.md` shortcut `live tree / split-brain` points here.
01 / 02 / 05 / 20 prose not edited.

### Tree-rule 2026-09-16T14:28+07 (FACT; not a new ledger)

Both COORD mailbox paths still resolve to one inbox
(`CANON_BLUEPRINT/_COORDINATION/mailbox` = R1 package). Unread CHANGEBOT
ignored (4 unread: planned-restart PATCH, PENDING_DIGEST 7,
`CB_ARCHITECTURE_20260916T071705_96d08a`,
`CB_ARCHITECTURE_20260916T072430_f95db8`; not marked read). No new
AGENT_B / AGENT_C / AGENT_D architecture JSON to A after `20260916T070550`
(already absorbed). 071529 / 065611 / 064243 / 062636 bodies not re-sent.

Re-stat this pass:
- R1 PACKAGE `10`/`11`/`12`/`13` still `version: "1.1-candidate"`; mtime
  `2026-09-15T18:16:04Z`; sizes 5158/4759/4939/7751; SHA unchanged
  (`f2276dde…` / `e3caa506…` / `4f05b623…` / `d6e62754…`). Quoted 1.1
  lines still present. C ledger rows stay OPEN. No rematch C.
- Repo `D:\FPGA\NATIVE_AI\CANON_BLUEPRINT` `10`–`13` still
  `version: "1.3-candidate"` (not package live).
- C WT HEAD still `f42c58fc3e8b90be458c8575c2ac8671dc8fc1c1` on
  `branch_agent_c`. A does not merge C. A does not copy C files onto R1.
- PACKAGE `03`/`04` still 1.4-candidate `2026-09-16T13:50:00+07:00`;
  no `ACTION_INTENT` / action objects. `31`/`32` still 1.3-candidate
  `2026-09-16T14:10:00+07:00` without [§05.8] pass names.
- PACKAGE `33` leftover `| 12 | 4 | generation |` remains.
  `schema_lock.json` SHA
  `105ee6b23a9a46a76eba215368ac2d27c98b3620ed829678d45211d8fc97e640`
  still omits `05`. B/D residual rows stay OPEN.

NEW MAIL B+D HIGH dual-send `20260916T072711` (shared inbox two files
each: B `…_d19adf.json` / `…_266973.json`; D `…_eeb4b3.json` /
`…_b8d0ce.json`): subject `live unowned files are R1 package`. Tree
rule: land on PACKAGE, not repo, not AGENT_A WT 03/04 lag. Points at
A-05 LIVE TREES. Not a rewrite of 064243. C not mailed.

01 / 02 / 05 / 20 / `READING_ORDER.md` not edited (no absorb).

### Publish-gap 2026-09-16T14:35+07 (FACT; not a new ledger)

Both COORD mailbox paths still resolve to one inbox
(`CANON_BLUEPRINT/_COORDINATION/mailbox` = R1 package). Unread CHANGEBOT
ignored (3 unread: planned-restart PATCH, PENDING_DIGEST 7,
`CB_ARCHITECTURE_20260916T072857_96d08a`; not marked read). Startup
auto-ACK RECEIVED for that architecture PATCH (operational only).
No new AGENT_B / AGENT_C / AGENT_D architecture JSON to A after
`20260916T070550` (already absorbed). 072711 / 071529 / 065611 / 064243 /
062636 bodies not re-sent.

FACT-diff B WT vs PACKAGE `03`/`04`/`31`/`32` (exact token count 0 on
both trees for `ACTION_INTENT` / `safety_contract` / `SAFETY_VETO` /
`CapabilityBinding` / `PrimitiveCommand` / `ObservedEffect` and all
seven [§05.8] pass names):
- B WT still 1.1-candidate; mtime `2026-09-16T02:41:04Z`; SHAs
  `532ec41f…` / `2ba742af…` / `6d42bde6…` / `a528811c…`. HEAD
  `128b09ecdb2021d1851b64e135e66b3f18fd62c5` on `branch_agent_b`.
- Quotes: [§03.1] `GEMINI / Language Adapter [§01.7]`; [§03.6]
  `MISSING / UNKNOWN / INCOMPLETE`; sole `action` is governance
  `project owner may authorize final artifact promotion/freeze`.
  [§04.5] fields `event_type`…`sequence_id` (no `command_id`).
  [§04.6] `` `reserved             16 B` `` / `` `TOTAL                128 B` ``.
  [§31.7] X0-15 `` `NO_BINDING/NO_ACTION` ``. [§32.3]
  `capability binding + safety veto/readback`.
- PACKAGE still 1.4-candidate `03`/`04` `2026-09-16T13:50:00+07:00` and
  1.3-candidate `31`/`32` `2026-09-16T14:10:00+07:00`. Same missing
  lock tokens. B WT does **not** have the lock unpublished ahead of
  PACKAGE. No HIGH `package 03 04 31 32 unpublished`. 072711 not
  rematched.

FACT-diff D WT vs PACKAGE `33` + `schema_lock.json`:
- D WT `33` SHA `33a2e9220727a137aaace2b8cc6e90a7732907f6d31255f3faeb7300abe15906`
  size 5776 / 146 lines; `pack_generation` count 0; no ManifestHeader
  offset table. `schema_lock` SHA
  `f8c5a8b0419be8ea3fe8752b27ba3b7eb18cb8e7a8d9b865999ed0029a248d52`
  omits `05`. HEAD `128b09ec…` on `branch_agent_d`.
- PACKAGE `33` SHA `f053be71a524ada1c70f6dd6ebd6dc28632aeacf3a54ca30eeda5d94e9a46668`
  size 8963 / 243 lines; prose `` `pack_generation` is u32 and is not
  `knowledge_generation` u16. ``; table still `| 12 | 4 | generation |`.
  `schema_lock` SHA
  `105ee6b23a9a46a76eba215368ac2d27c98b3620ed829678d45211d8fc97e640`
  still omits `05`. D WT does **not** have the fix unpublished ahead
  of PACKAGE. No HIGH package-unpublished mail. 072711 not rematched.

C: PACKAGE `10`/`11`/`12`/`13` still `version: "1.1-candidate"`; mtime
`2026-09-15T18:16:04Z`; sizes 5158/4759/4939/7751; SHA unchanged
(`f2276dde…` / `e3caa506…` / `4f05b623…` / `d6e62754…`). Quoted 1.1
lines still present (`ACT` = actuator; `SkillRecord` counts; WM = T1
BRAM / LTM = T2 DDR). C WT HEAD still
`f42c58fc3e8b90be458c8575c2ac8671dc8fc1c1` on `branch_agent_c` (1.3;
not package live). C ledger rows stay OPEN. No rematch C. No absorb.

01 / 02 / 05 / 20 / `READING_ORDER.md` not edited (no absorb).

### CLOSED (quoted live defect gone)

| FILE | SECTION | CLOSED BECAUSE | CLOSED_AT |
|---|---|---|---|
| R1 `04_ABI_AND_PROTOCOL.md` | [§04.6] 128-vs-132 | Live header is 128 B / `reserved` 12; `reserved=16`/132 illegal | `20260916T064243` (still closed) |
| R1 `33_IMPLEMENTATION_GUIDE.md` | [§33.2] / [§33.5] / ManifestHeader 132 note | Live [§33.2] widths via [§02.4]/[§20.9]; [§33.5] CapabilityDescriptor match; ManifestHeader 128 / reserved=12 | `20260916T065611` (still closed) |
| R1 `04_ABI_AND_PROTOCOL.md` | [§04.13] action objects off UART | Action-lane objects remain off Query/Result UART [§04.13]; reward identity uses `command_id` | `20260916T074024` (closed this pass; not a rematch of 064243) |
| R1 `10_LEARNING_AND_STRATEGY.md` | [§10.1] ACT=actuator | Live v1.4: `ACT` emits `ACTION_INTENT` into [§01.7]/[§05]; never drives an actuator | `20260916T1510` (PACKAGE land; 071529 not re-sent) |
| R1 `12_SKILL_AND_TEACHING.md` | [§12.1] SkillRecord counts | Live v1.3: `cost_stats` / `success_count` / `failure_count` are utility-only, not proof, not ASTRA status | `20260916T1510` (PACKAGE land; 071529 not re-sent) |
| R1 `13_INFORMATION_NEURONALIZATION.md` | [§13.2]/[§13.7] WM=T1 / INCOMPLETE | Live v1.3: WM/LTM are logical class; T1/T2 typical placement; `SEARCH_INCOMPLETE` | `20260916T1510` (PACKAGE land; 071529 not re-sent) |
| R1 `11_FAILURE_EXPERIENCE_MEMORY.md` | [§11.12.3] dest vs compaction | Live republish SHA `efcd0283`: separate `FEM_DEST_INTEGRITY` block; three compaction states; W9 `commit_state[1:0]` compaction-only | `20260916T081548` (C ACK A-C-14; 080341 body not re-sent) |
| R1 `33_IMPLEMENTATION_GUIDE.md` | ManifestHeader offset 12 `generation` | Live [§33.9] table is `\| 12 \| 4 \| pack_generation \|`; 128 B / reserved=12 | `20260916T1800` (D PACKAGE land; 084806 body not re-sent) |
| R1 `33_IMPLEMENTATION_GUIDE.md` | [§33.9] dest-tree unnamed | Live 17:45 tree names `mig_ui32` / `mig_ui_bram` / `mig_ui_mux` / `fem_on_mig` stand-in; not MIG_PASS / FEM_PERSIST_PASS | `20260916T2010` (D PACKAGE land; not a rematch of 084806) |
| R1 `23_HARDWARE_FACTS.md` | no generated-MIG row / D-06 only in mail | Live [§23.9] 17:45: generated MIG snapshot CANDIDATE; `arty_a7_r2_top` unbound; `arty_a7_mig_top` instantiates `mig0` CANDIDATE; not MIG_PASS | `20260916T2010` (D PACKAGE land; 105618 body not re-sent) |
| R1 `22_RTL_RISK_REGISTER.md` | [§22.1] R07 mitigation | Live 17:35: dest-complete = dest readback + matching txn/generation; FIFO-empty is a local/test hint only, not dest-completion authority | `20260916T1940` (D PACKAGE land; 100144 body not re-sent) |
| R1 `03_ASTRA_AUTHORITY.md` | no action-precheck | Live [§03.12] ACTION_INTENT + safety_contract; verdicts ≠ query `0x01–0x06`; [§03.1] Skill may originate ACTION_INTENT | `20260916T2030` (B-LAW-SYNC; 074024 body not re-sent) |
| R1 `04_ABI_AND_PROTOCOL.md` | [§04.2] 24-bit example | Live [§04.2] `SEMANTIC_ID_WIDTH = 32`; `ACTIVE_ID_RANGE` = profile; ≠ each other | `20260916T2030` (B-LAW-SYNC; 074024 body not re-sent) |
| R1 `31` / `32` | X0-15 vs §05.8 | Live [§31.12]/[§32.5] echo seven [§05.8] names; X0-15 not that set | `20260916T2030` (B-LAW-SYNC; 072711 body not re-sent) |
| R1 `23_HARDWARE_FACTS.md` | Q*/SPEAR / FE256 bind | Live 22:13 [§23.9]: r2_top route +0.375 baseline ≠ TIMING_PASS; mig_tx +0.673; FE256 OOC −75.723 DO_NOT_BIND | `20260916T2220` (D/B mail absorb; not rematch) |
| R1 `22`/`23`/`30`/`33` | FE256 R1 + common-runtime M2–M4 | Live 00:06: FE256_R1_REFERENCE_FREEZE + M2/M3/M4 CANDIDATE; no PASS stamps | `20260917T0015` (D/B mail absorb; not rematch) |
| R1 `22`/`23`/`30`/`33` | M4 shadow / MIG / PROGRAM | Live 01:04: m4_mig candidate programmed-config + UART smoke CANDIDATE; no BOARD/MIG/PROGRAM_PASS | `20260917T0110` (D/B mail absorb; not rematch) |
| R1 `22`/`23`/`30`/`33` | Pack board SEQ/ISO + reprogram | Live 01:38: SEQ 2/24 ISO 14/24 CANDIDATE; B ACCEPT_CANDIDATE only; no PACK_ABI_24_24_PASS | `20260917T0425` (D/B mail absorb; not rematch) |

### OPEN_CONTRADICTIONS (FACT quotes only)

| FILE | SECTION | LOCK VIOLATION | OWNER | LAST_MAILED |
|---|---|---|---|---|
| WT `04_ABI_AND_PROTOCOL.md` | [§04.6] / ends [§4.11] | `` `reserved             16 B` `` then `` `TOTAL                128 B` ``. No [§04.12]. Not live. | AGENT_B | `20260916T062636` (WT SHA `2ba742aff34aec70…`; not re-mailed) |
| WT `03_ASTRA_AUTHORITY.md` | [§03.1] / [§03.6] | Lag copy vs live 18:50 B-LAW-SYNC. Not live. | AGENT_B | `20260916T062636` (not re-mailed; live closed) |
| R1 `_COORDINATION/schema_lock.json` | `documents` | Keys include `00`/`01`/`02`/`03`/`04`/`10`…/`13`/`20`…/`33`/`READING_ORDER.md`. Omits `05_CAPABILITY_AND_ACTION_BINDING.md`. SHA `105ee6b23a9a46a76eba215368ac2d27c98b3620ed829678d45211d8fc97e640`. | AGENT_D | `20260916T072711` (tree rule; 062636/064243 bodies not re-sent) |

Action-path lock remains [§01.7] / [§05] / [§20.5.1]: lookup ≠ binding ≠ command;
`NO_ACTION` ≠ missing readback. B owns action-precheck encodings. Action-lane objects are off the §04 UART
[§04.13]. C owns Q* `ACT` and Skill/Teacher echo.
D owns `schema_lock` + [§33] echo. A does not write those files.

Which tree is live is the A-05 table above, not this paragraph. These
copies currently lag the 32-bit T1 directory lock and must not be used
as live NCG widths:
- `MASTER_CANON_BLUEPRINT_R0_1.md` (concatenated convenience view; still
  publishes 24-bit T1 `semantic_id` / 28-bit ptrs — **NOT LIVE**)
- `CANON_BLUEPRINT_R0_1_AUDITED_CANDIDATE/` (frozen R0.1 audit snapshot; same
  stale widths). Do not copy 24-bit identity into live [§02].
`README.md` step 6 still offers MASTER_CANON as an optional one-file view
without a lag caveat; treat [§00] here as the control, not README.

## Required reading order

See `READING_ORDER.md`.

## Cross-reference convention

Project docs use `§XX.Y` for numbered top-level sections. Governance filenames
are referenced by name. If a cross-reference points to a missing/renumbered
section, treat it as an audit defect rather than guessing silently.

## Tóm tắt tiếng Việt

Index R0.1 thêm authority precedence, audit/errata và §05 capability binding;
archive/coordination được giữ nhưng không có quyền ghi đè canon top-level.
§02 khóa bề rộng NCG T1/T2. §01.7 khóa lookup ≠ binding ≠ command.
Live R1 §04.6 khóa ManifestHeader 128 / reserved=12. Closeout 13:56: đóng hàng
§33.2/§33.5/132 do D publish. Width-gate 14:03: C WT FailureRecord 128 /
SkillRecord 256 ghi chú CANDIDATE ở §02.4/§20.9, A không khóa.
Episode-class 14:12: `EpisodeRecord` là lớp T2 bắt buộc (không Node /
Failure / SemanticEvent UART); bit/field UNKNOWN; FEM không phải episode
store. Repo `CANON_BLUEPRINT` 10–13 = 1.3; R1 package vẫn 1.1 — hàng C
OPEN. Không gửi lại 072711/071529/065611/064243/062636. Tree-rule 14:28:
HIGH `20260916T072711` tới B và D — land trên PACKAGE, không repo,
không WT 03/04 lag. Publish-gap 14:35: B WT và D WT **không** có lock
trước PACKAGE — không mail `unpublished`; không rematch 072711; C
PACKAGE vẫn 1.1. A-05 LIVE TREES: A live = worktree A-owned;
B/C/D live = R1 package unowned; repo copy và MASTER_CANON không
phải live. Ledger OPEN_CONTRADICTIONS không phải authority.
D-INTEG-01 14:55: high-zero ≠ ID width; FEM T2 DDR; `COMMITTED_CORRUPT`
là dest-integrity, không phải trạng thái compaction thứ tư.
C WT 10/11 = 1.4 unpublished; R1 vẫn 1.1; không merge.
C PACKAGE land 15:10: live `10`/`11`=1.4, `12`/`13`=1.3; đóng hàng ACT/
Skill utility/WM; dest-namespace đóng trên live [§11.12.3] republish
`efcd0283`.
D-INTEG-01 090254: BRAM 4K `pack_loader` stand-in ≠ persist; WNS OOC/integrated
không TIMING_PASS; `K_HARD_MAX=8` D-báo không khóa. D-06 091103: oscillator
100 MHz ≠ MIG `sys_clk` 166.666; pointer 0 ≠ DDR beat 0; không khóa clock. Pack/ABI-24 = 24 case, không phải luật identity 24-bit. XSim ≠ BOARD_PASS. NCG ≠ Query UART. SemanticEvent 24 byte ≠ identity 24-bit. D PACKAGE §23.9 MIG snapshot không khóa; §33.9 `pack_generation` đóng.
