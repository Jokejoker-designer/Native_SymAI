---
version: "1.7-candidate"
owner: AGENT_A
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-17T04:25:00+07:00"
---

# §02 — MEMORY STRATIFICATION

> Physical memory tiers, their roles, what belongs where, and the
> absolute rule: placement never changes epistemic class.

## 2.1 The Cardinal Rule

> **A FACT remains a FACT whether it is stored in DDR or cached in BRAM.**
> Physical tier movement changes **placement**, not **epistemic status**.

This means the following table is the correct mental model:

```text
                PHYSICAL PLACEMENT
              T0          T1          T2
            Logic        BRAM       DDR/HBM

FACT                     cache      canonical
SKILL                    hot        canonical
EPISODE                             canonical
FAILURE                  hot        canonical
POLICY WEIGHT            active     checkpoint
PROOF                    scratch    archive
CANDIDATE                hot        canonical
```

Do NOT write: "FACT = DDR", "SKILL = BRAM", "INSTINCT = LUT".

## 2.2 Tier Definitions

### T0 — Immutable Semantic Control Plane

**Physical**: LUT, distributed RAM, fixed logic.

**Contains**:
- Exact comparators
- Hash primitives
- AND / OR / NOT operators
- Type checks
- CRC / protocol logic
- Routing fabric
- Schema / ABI enforcement laws
- ASTRA state/status rules
- Safety / legality veto logic
- Bounded graph machinery
- Primitive arithmetic

**Does NOT contain**:
- Device-specific facts (e.g., "RAC_WALL → R32")
- LED mappings (e.g., "LED3 = SUCCESS")
- Teacher statements
- Learned facts, Q* preferences, episodes
- Any knowledge that could change

**Resource reality**: XC7A100T has 63,400 LUTs, but they are NOT all available for intersection engines. Each comparator costs LUT + routing + fanout + timing + power. Hardware intersection is bounded — see [§01.2].

### T1 — Hot Cognitive Working Store

**Physical**: BRAM/LUTRAM. XC7A100T provides 135 BRAM36 blocks, approximately 607.5 KiB raw block-RAM capacity before subsystem allocation.

**Contains**:
- Current QueryRecord
- Active context and role bindings
- Active goal
- Frontier (current activated working set)
- Visited set / Bloom filter
- Top-K candidate queue
- Hot directory entries (semantic node directory cache)
- Hot posting pages
- Hot edge/value records
- Proof scratch space
- Hot skills (currently executing procedures)
- Q*/SPEAR working state
- Recent FEM prototypes
- FIFO / event buffers

**Function**: Hot Cognitive Working Store only — query/bindings/frontier,
cache copies of T2 records, and currently executing skill **instances**.
T1 is physical placement, not a cognitive class.

Do **not** write: Working Memory = T1, muscle memory = BRAM, or SKILL = BRAM.
Hot skill instances in T1 are placement copies; skill epistemic class lives
on the Skill record, not on BRAM residency.

### T2 — Canonical Cognitive Memory Store

**Physical**: DDR3L (256 MB on Arty A7-100T).

**Contains**:
- Nodes, Edges, Values, Contexts, Provenance records
- Forward posting lists (node → outgoing edges)
- Reverse posting lists (node → incoming edges)
- Candidate facts (unverified)
- Episodes (temporal experience)
- Failures (typed failure records)
- Skills at every lifecycle state (CANDIDATE → LEARNED → VERIFIED → STABLE → COMPACTED → REOPENED); placement is not status
- Policy checkpoints (Q*/SPEAR learned state) — placement copies, not LTM identity
- Conflict records
- Proof artifacts

**Relation types stored** (not exhaustive):
```text
IS_A, PART_OF, USES, HAS_STATE, NAMED_AS,
BEFORE, AFTER, CORRELATES_WITH, CAUSES,
ACHIEVES, FAILED_AT, ...
```

Critical invariant: `CORRELATES_WITH != CAUSES` — always.

## 2.3 Bounded Relevance-Guided Graph Traversal

The correct name for "BRAM anchor → open only needed DDR branches":

```text
Query / Goal
     │
     ▼
T1 active anchors (BRAM cached directory entries)
     │
     ▼
exact directory lookup (ID → directory slot)
     │
     ▼
selected posting page pointer(s)
     │
     ▼
DDR fetch (only selected pages)
     │
     ▼
relation/context filter
     │
     ▼
new frontier
```

It does NOT scan all of DDR. The path is:
```text
ID → directory → posting pointer → selected adjacency
```

BRAM does not contain the entire graph. It holds the **working set** of the graph.

## 2.4 NCG Record Widths — R0.1 Architecture Lock

This section freezes **NCG physical record widths** for Arty A7-100T. Exact bit
layouts are architecture law for T0/T1/T2 placement. Wire transcription into
pack/UART ABI remains Agent B's [§04] ownership. Widths are not ontology:
`KIND != ROLE`, `ALIAS != IDENTITY`, `CANDIDATE != VERIFIED`, and
`PHYSICAL_PLACEMENT != EPISTEMIC_CLASS`.

SKILL, EPISODE, and FAILURE are **not** `NodeRecord`. T2 may store them as
separate classes/regions; bit budgets and pack layouts are owned by [§11]/[§12]
and [§04]. Do not silently overload the 256-bit Node/Edge tables.

`EpisodeRecord` is a required typed T2 class. It is not `NodeRecord`, not
`FailureRecord`, and not a `SemanticEvent` UART packet. FEM may cite
`episode_id`; FEM is not the episode store. Bit width and field list are
**not** frozen (UNKNOWN until live C/B publish a table A can gate). A does
not assign a numeric budget.

CANDIDATE (C-owned live R1 prose; A does **not** freeze these widths into
the NCG table). Live R1 `11_FAILURE_EXPERIENCE_MEMORY.md` [§11.13]
v1.4-candidate and `12_SKILL_AND_TEACHING.md` [§12.10] v1.3-candidate
type `FailureRecord` / `SkillRecord` as their own kinds (`FAILURE`,
`SKILL`), not as `NodeRecord` / `EdgeRecord`. Quoted bit totals (FACT;
word fields sum to the stated width): `FailureRecord` **128 bits /
4 words**; `FailurePrototype` **320 bits / 10 words**; `SkillRecord`
**256 bits / 8 words**. SkillRecord 256 is a width coincidence with
Node/Edge 256, not an alias. C keeps `cost_stats` / `success_count` /
`failure_count` on SkillRecord (utility-only [§12.1]); they are not
EdgeRecord fields. C [§11.13] points EPISODE at [§01.4]/[§02] and
publishes no `EpisodeRecord` bit table — see the class lock above.
These MUST NOT alias `NodeRecord`.

### 2.4.1 Width laws

```text
SEMANTIC IDENTITY LAW (must not be weakened):
1. Canonical/cross-boundary semantic references are 32-bit fields
   [§04.2] [§33.2]. bit width = ABI/versioned representation, not ontology.
   SEMANTIC_ID_WIDTH = 32. This is identity ABI, not a profile knob.
2. ACTIVE_ID_RANGE is an implementation/profile property
   (`active_id_bits` and/or `active_id_max` on the loaded profile).
   ACTIVE_ID_RANGE != SEMANTIC_ID_WIDTH.
   A profile MAY constrain which 32-bit IDs are legal in this run
   (example: active_id_bits=24 ⇒ unused high bits must be zero).
   That example is range validation, not a 24-bit semantic-ID *type* or *law*.
   Hard-coding candidate_ref[31:24]==0 as identity is rejected.
   A 24-bit SPEAR MAC product (live [§10.7.5] Q5.19) is ranking
   arithmetic, **not** identity width and **not** `ACTIVE_ID_RANGE`.
   Live Pack/ABI-24 (`PACK_ABI_24_24_PASS`) is **24 gold integrity cases**,
   not a 24-bit identity law [§31.2]. Live [§04.5] SemanticEvent **192 bits /
   24 bytes** is a wire size, not a 24-bit identity law.
3. Keep separate:
   semantic identity  ≠  physical pointer/address  ≠  physical placement.
3a. Architecture-candidate NCG records use 32-bit T2 address *fields*.
   Internal physical pointers MAY be narrower than 32 bits only when ALL of:
   (i) they are not semantic identity;
   (ii) no information is lost (Arty 256 MiB ⇒ 28 significant address bits);
   (iii) conversion at the T1/T2/wire boundary is explicit;
   (iv) D shows implementation/resource/timing benefit.
   A narrower internal address is packing, not a new pointer ontology.
   Do not publish a 28-bit pointer *type* as identity or as §04 wire ABI.

ARCHITECTURE-CANDIDATE RECORD SIZES (owner-accepted; not final packing):
4. Standalone NCG records are sized as 128-bit *multiples* so they can be
   grouped on a wide memory interface if one exists:
   HotDirectory/Value/PostingPageHeader = 128 bits;
   Node/Edge/Context/Provenance = 256 bits.
   PostingEntry = 64 bits (packing: two entries per 128-bit group).
   `POSTING_ENTRY_WIDTH ≠ PACK_GROUP_WIDTH`: grouping is packing, not a
   128-bit PostingEntry *type* and not identity.
   These sizes are NOT a claim that MIG `app_data` *must* be 128 bits.
   D reports a generated native MIG (path `D:/FPGA/miggen`):
   `APP_DATA_WIDTH=128`, `ADDR_WIDTH=28`, `ECC=OFF` (D-06 ACK 082717).
   That is implementation evidence, **not** MIG_PASS, **not** a frozen
   architecture width, **not** a 28-bit identity or §04 pointer ABI.
   Live [§23.9] (18:50) records that snapshot (including generated `BURST_MODE`
   8-fixed). Those numbers remain CANDIDATE hardware-facts, **not** freeze.
   If a later generated MIG differs, keep these semantic field widths and
   document beat packing. Do not silently resize records.

PLACEMENT vs TRUTH:
5. T1 directory entries are placement/index records. They MUST NOT store
   epistemic status, proof, utility, or Top-K rank.
6. Verified EdgeRecord MUST NOT contain support/oppose counts, Q-values, or
   other utility/policy fields. Those belong in candidate/experience/policy
   records, not in the static typed relation [§20.1].
7. QueryRecord (256b), StructuredResult (384b), SemanticEvent (192b) stay in
   [§04]. T1 may cache them as-is; this section does not fork those layouts.

CLAIM CEILING:
8. Candidate layout != latency. != single-cycle access. != measured DDR
   efficiency. != MIG_PASS. != TIMING_PASS. != BOARD_PASS.
   != XSim banner as any of those stamps.
```

### 2.4.1b Active-range admit and profile capacity (A-ID-PROFILE-01)

`SEMANTIC_ID_WIDTH = 32`. `ACTIVE_ID_RANGE` comes from the **loaded
board/knowledge-pack profile** (`active_id_bits` and/or `active_id_max`).
D owns implementing and wiring that profile object. B owns any Manifest/ABI
field that carries it on the wire [§04]. A owns this distinction. Architecture
does **not** freeze the numeric range (including 24).

**Authoritative checker** for an ID entering the **active runtime graph**:
the **T1 directory / materialization admit** (HotDirectory fill). An ID is
not in the active graph until this check passes against the loaded profile.

**Required ingress (same profile, not a second law):** the **pack loader**
MUST refuse to install pack-sourced IDs outside `ACTIVE_ID_RANGE`. Ingress
cannot skip the profile; it is not the admit into T1.

**Defense in depth:** SPEAR, Q*, and walkers MAY re-check a `candidate_ref`
against the **same loaded profile**. That is defensive validation, **not**
semantic-identity definition. Preferred form: mask/`active_id_max` from
profile, not a baked `[31:24]==0` constant. High-zero of bits above
`ACTIVE_ID_RANGE` is a packing/range check on the 32-bit field, **not** a
new ID width. D must not shrink wire identity. A fail drops that candidate
as out-of-profile. ASTRA status mapping of that fail is owned by B
[§03]/[§04] — A does not define it. Live R1 [§10.7.3] v1.4-candidate uses
a 32-bit `candidate_ref` plus defensive `active_id_max`; that is the
allowed form.

**K_HARD / SPEAR profile capacity:** Top-K / candidate-slot capacity is a
**profile property** on the same loaded profile object, not a SPEAR-local
truth constant and not an ASTRA status. D owns implementing/wiring `K_HARD`
(or equivalent). C consumes it. A does not freeze the integer.

**K_HARD_MAX:** C’s compiled SPEAR slot ceiling (how many candidate slots
the SPEAR instance was built with). `K_HARD_MAX ≠ K_HARD`. A does not freeze
this integer either (including not freezing “16 lanes” or a D-reported
compiled 8). If loaded-profile
`K_HARD > K_HARD_MAX`, fail closed (`k_invalid`); do not silently clamp as
truth. Status mapping of `k_invalid` is B-owned [§03.9.2 `K_INVALID`].
Live R1 [§10.7] v1.4 states this contract.

### 2.4.1c FEM persistence and recover classes (D-INTEG-01)

Not a PASS. Not an ASTRA status table. C owns live [§11] wording. B owns
query-status mapping of dest integrity.

**Canonical FEM store:** T2 DDR via MIG. T1 BRAM is a hot cache only.
A C word-atomic 32-bit T2 port / B0–B6 local model is a **local/test model**.
It does **not** prove DDR crash safety. D-reported generated
`APP_DATA_WIDTH=128` is evidence, not a freeze [§02.4.1] claim 4 / [§02.9].
D reports the fabric top routes `pack_loader` through `mig_ui32` onto
128-bit `mig_ui_bram` in `arty_a7_r2_top` (replaced a 32-bit `t2ram`).
Live [§23.9] (22:13) still records generated `mig0` `app_*` **unbound** in
`arty_a7_r2_top`. Pack dest in that top remains `mig_ui_bram` through
`mig_ui_mux`. The same section records a separate top
`arty_a7_mig_top` that instantiates generated `mig0` and muxes pack and
FEM onto that UI on `ui_clk` (exclusive grant; pack wins;
`FEM_BASE=28'h0200000` bit 21, not slot 0/1). D mail `20260916T111118`:
on `arty_a7_mig_top` FEM moved off the CLK100MHZ local dest. That bind
is **CANDIDATE**. The `r2_top` path remains a BRAM stand-in. Neither
path is persist authority, T2 DDR crash-safety, or a second MIG width
law. Instantiation / UI mux is **not** `MIG_PASS` / `BOARD_PASS` /
`TIMING_PASS` / `FEM_PERSIST_PASS` (no calib, no bitstream).
`FEM_MIG_UI32_XSIM_PASS` and `PACK_MIG_UI32_XSIM_PASS` are not
`MIG_PASS` / `PACK_ABI_24_24_PASS` / `FEM_PERSIST_PASS`. The 12-bit
`mig_ui_bram` fold `{addr[21:20], addr[13:4]}` is packing, not identity.
Canonical FEM persist remains T2 DDR via MIG.

D reports generated `mig0` `InputClkFreq=166.666` (`CLKIN_PERIOD=6000`)
and an MMCM `clk_arty_mig` (board 100 MHz → 166.667 sys + 200 ref).
Those frequencies are generated-IP / board-clock evidence, **not**
architecture freeze, **not** `LOGICAL_TICK`, **not** TIMING_PASS.
C published Q*/SPEAR timing pipelines as CANDIDATE (not TIMING_PASS;
ports/arithmetic/vectors unchanged; per-op cycle count may grow;
`RTL_PIPELINE_DEPTH` stays `IMPLEMENTATION_DEFINED`). C-reported OOC
100 MHz post-synth WNS are estimates only. D consumed that RTL and
quotes fabric keep-hierarchy **post-synth** WNS +1.549 / TNS 0 (0 failing),
pre-place, **not** TIMING_PASS. D-06 later quotes mig_top FEM-mux synth
WNS −1.482 / TNS −50.837 (36 failing) with `clk_pll_i` WNS +4.088; CDC
handshake on UART word_cdc32 MET; still **not** TIMING_PASS. D mail
`20260916T111919`: after FEM UI mux, `arty_a7_r2_top` flatten post-synth
WNS +1.549 TNS 0; LUT 6072 FF 5107 DSP 8 BRAM 16.5 — not a freeze.
Live [§23.9]/[§30.8]/[§30.9]–[§30.23]/[§22] R21–R23 01:04:
- `arty_a7_mig_top` Q*/SPEAR/`bounded_walk` on `ui_clk` with pack+FEM
  (implementation clocking, **not** freeze, **not** TIMING_PASS).
- Pre-bag2 post-route WNS −1.160 remains old netlist; bag2+`ui_clk`
  post-route Vivado MET WNS **+1.032**.
- Fabric `arty_a7_r2_top` bag2 + `uart_tx_word`: post-synth +1.549;
  post-route Vivado MET WNS **+0.375** WHS **+0.021**. Lab DCP freeze
  name `R2_TOP_ROUTE_BASELINE_WHS_0P021` (`HOLD_OPTIMIZATION_STOPPED`)
  is a **working baseline**, **not** `TIMING_PASS` / `BOARD_PASS`.
- `UART_WORD_XSIM_PASS` / `UART_PACK_XSIM_PASS` 2/2 ≠ board.
- `mig_tx` (`mig_top`+`uart_tx`+CDC) post-route Vivado MET WNS **+0.673**;
  does not clobber `mig_uiclk` or the r2_top baseline. Not `MIG_PASS`.
- FE256 OOC R0 unplaced WNS **−75.723**, Logic Levels **144** (not “723”);
  LUT ROM / 0 BRAM; **not** on `r2_top`. D-FE256-ARCH-RCA-01 + B-CLASS:
  `DO_NOT_BIND`; BENCHMARK KEEP; no ladder promotion; not `FE256_PASS` /
  `FE256_FULL_PASS` / `TIMING_PASS`.
- FE256 HW-R1 isolated (owner-auth RTL): XSim 256/256; OOC +0.568 /
  route +0.223; RAMB36=1; still not bind of old freeze; ≠ `FE256_PASS`.
- Shadow-bind candidate top INTEGRATION_CANDIDATE WNS +0.368; old freeze
  PRESERVED; new lab freeze `R2_FE256_R1_INTEGRATED_FREEZE` ≠ product
  permanent. `FE256_R1_REFERENCE_FREEZE` = REFERENCE_IMPLEMENTATION;
  FE256_DEVELOPMENT CLOSED; D M2 common-runtime resumed. Retirement law:
  common QueryRecord→directory/posting→walk→ASTRA→StructuredResult must
  hit 256/256 + legal timing before dedicated FE256 leaves final top;
  on failure repair common path — do not weaken gold / hybrid-route.
- Common-runtime CANDIDATE (no FE256 engine): M2 `query_posting_bind`
  (`query_meta[10]` reverse CANDIDATE packing of [§04.3]); M2 OOC UG901
  1R WNS +0.935; M3 walk (`incomplete` ≠ ASTRA); M4 fail-closed result
  pack (hop-1 never ANSWER/UNKNOWN). XSim banners ≠ `M2_PASS` /
  `M3_PASS` / `ASTRA_PASS`.
- M4 query-result **shadow candidate** (no dedicated FE256): route +0.555;
  UART smoke XSim ≠ board. M4+`mig0` candidate route +0.233; calib=IP ≠
  board `MIG_PASS`. Bitstream write ≠ `PROGRAM_PASS`. Owner JTAG
  `PROGRAM=YES` + startup HIGH = programmed-config CANDIDATE ≠
  `PROGRAM_PASS` / `BOARD_PASS`. UART board 1-txn fail-closed smoke ≠
  `BOARD_PASS` / `ASTRA_PASS`. `PACK_ABI24_MIG_DUT_XSIM_PASS` via
  `mig_ui_bram` ≠ `PACK_ABI_24_24_PASS` / `MIG_PASS`. Pack board SEQ/ISO
  CANDIDATE scores (2/24, 14/24) ≠ `PACK_ABI_24_24_PASS` / `BOARD_PASS`.
  Same-bit reprogram ≠ new PASS. Freeze DCPs untouched. Not on freeze
  tops without owner auth.
**CANDIDATE only** — D/B/A do not self-issue `TIMING_PASS` / `BOARD_PASS` /
`MIG_PASS` / `PROGRAM_PASS`. Snapshots are not architecture freeze.
OOC ≠ integrated ≠ routed ≠ programmed-config ≠ board acceptance.
LUT/FF/BRAM/WNS/`ui_clk` from D bags are not architecture freeze.
Live [§10.7.2] `RTL_PIPELINE_DEPTH = IMPLEMENTATION_DEFINED` and
`LATENCY = POST_ROUTE_MEASURED`. Six SPEAR logical stages are reference
semantics, not a frozen RTL depth and not a cycle-count law. Snapshots
are not `TIMING_PASS` and are not frozen. OOC ≠ integrated. C owns those
RTL modules; D does not edit them; A does not write production RTL.
Feeding the Arty 100 MHz oscillator into MIG `sys_clk_i` is a **false
path**. `pack_loader` `mem_addr` as a 28-bit byte address with 16-byte
beat align is physical packing of the generated `APP_W`, not identity.
Directory/page pointer `0` remains reserved null and is **not** DDR beat
`0`. Live [§23.9] (18:50) unbound `mig0` on `arty_a7_r2_top` remains the
BRAM-stand-in fact on that top. Live [§23.9] `arty_a7_mig_top` /
`arty_a7_r2_top_m4_mig_candidate` instantiate + Q*/SPEAR/walk on `ui_clk`
is CANDIDATE bind/clocking, **not** MIG_PASS / TIMING_PASS / BOARD_PASS.
Live [§33.9] names the stand-in modules; not persist.

**Completion authority** for a FEM dest write: dest readback plus matching
`txn_id` / generation (and outstanding-write retirement after the matching
response). FIFO-empty is **not** completion. Live [§22] R07 (17:35) now
states dest-complete = dest readback + matching txn/generation;
FIFO-empty is a local/test hint only, not dest-completion authority.
That live wording agrees with this law.

**Write atomicity:** logical FEM word is 32 bits; physical beat width is
the generated MIG `APP_DATA_WIDTH` (D-reported candidate 128; not frozen).
Beat packing of 32-bit FEM words (four words per 128-bit beat is arithmetic
of that generated width) is D’s media contract; lane placement of
W0/W1/CRCW/COMMIT within a beat is D-owned. C may keep a word-sequential
local FSM. Torn writes remain possible; reset may interrupt outstanding
writes.

Keep two namespaces. Do not collapse them:

| Namespace | Owner of table | Members | Meaning |
|---|---|---|---|
| `FEM_COMPACTION_RECOVER` | C, when live [§11] publishes the table (C WT [§11.12.3] candidate) | exactly one of `OLD_VALID` / `CANDIDATE_NEW` / `COMMITTED_NEW` after interruption | compaction crash-safety observables; behavior, not §04 ABI |
| `FEM_DEST_INTEGRITY` | A names the class; D observes; C must echo in [§11]; B maps query reason/status | `COMMITTED_CORRUPT` when dest COMMIT magic **and** dest CRC invalid | dest-domain integrity class |

`COMMITTED_CORRUPT` is **not** a fourth compaction recover state and does
not replace C’s three-state table. Index must **not** upgrade
`COMMITTED_CORRUPT` to `COMMITTED_NEW`. Do not roll-forward index or raw
retirement from a corrupt dest. Consumers must not treat dest
`COMMITTED_CORRUPT` as `UNKNOWN`, `ANSWER`, or compaction `COMMITTED_NEW`.
Live R1 [§03.9.2] already has reason `COMMITTED_CORRUPT` `0x56` (reason,
not status). A does not add a status code.

Live R1 `11_FAILURE_EXPERIENCE_MEMORY.md` v1.4-candidate (SHA prefix
`efcd0283`, republished 2026-09-16T15:20+07) **splits** the namespaces in
[§11.12.3]: compaction remains exactly `OLD_VALID` / `CANDIDATE_NEW` /
`COMMITTED_NEW`; dest `COMMITTED_CORRUPT` is a separate `FEM_DEST_INTEGRITY`
block. W9 `commit_state[1:0]` stays compaction-only. Dest observable is
`integrity_fault` (not an ASTRA status). Compaction class is
`NOT_APPLICABLE` while dest-corrupt. Live C echoes B mapping `0x06` /
`0x56`; A does not rewrite B. Dest completion uses D `t2_ready` (not
FIFO-empty). This quoted 1.4 defect is **closed**.

### 2.4.2 T1 HotDirectoryEntry — 128 bits / 16 bytes

Each BRAM directory entry is a **placement/index record**, not a duplicate
truth record.

| Field | Bits | Description |
|---|---:|---|
| semantic_id | 32 | Full `SEMANTIC_ID_WIDTH` field. High-bit/range check uses loaded profile `ACTIVE_ID_RANGE`, not a 24-bit directory type |
| fwd_descriptor_ptr | 32 | Canonical T2 byte-address field; `0` = null (no object); internal storage may pack per §2.4.1.3a |
| rev_descriptor_ptr | 32 | Canonical T2 byte-address field; `0` = null (no object); internal storage may pack per §2.4.1.3a |
| generation | 16 | Active knowledge generation tag |
| kind | 8 | Intrinsic KIND; not ROLE; not FACT/SKILL/EPISODE/FAILURE; not ASTRA status |
| flags | 8 | valid / pinned / dirty / prefetch only |
| **Total** | **128** | **16 bytes; architecture-candidate size** |

Integrity of a T1 entry is generation match plus BRAM parity/ECC (implementation
choice) and a generation-checked T2 record after fill. Namespace is the active
pack/QueryRecord namespace, not a second identity packed into the directory.

Epistemic status/proof is not inferred from cache residency. Canonical
semantic state remains in the referenced T2 record and is generation-checked.

Directory capacity must be budgeted from post-synthesis T1 allocation. T1 also
contains query/binding working-state, FIFOs, proof scratch, posting-page cache,
hot skills and learner state. Do not divide 607.5 KiB by 16 bytes and call that
the graph size.

### 2.4.3 T2 NodeRecord — 256 bits / 32 bytes

Canonical identity + index pointers. ROLE is not stored here.

| Field | Bits | Description |
|---|---:|---|
| node_id | 32 | Stable semantic identity |
| generation | 16 | Knowledge generation |
| namespace_id | 16 | Semantic namespace |
| kind | 8 | Intrinsic KIND; not ROLE; not epistemic class; not ASTRA status |
| state | 8 | Discrete STATE bucket |
| flags | 16 | valid / tombstone / has_alias / has_value / … |
| class_id | 16 | CLASS; independent of KIND and ROLE |
| fwd_posting_ptr | 32 | Forward posting page byte address; `0` = null/empty (not identity 0) |
| rev_posting_ptr | 32 | Reverse posting page byte address; `0` = null/empty (not identity 0) |
| alias_ref | 32 | Reference to alias/lexicon object; not the identity |
| provenance_ref | 32 | Provenance root |
| integrity_crc16 | 16 | CRC over the preceding NodeRecord fields |
| **Total** | **256** | **32 bytes; architecture-candidate size** |

### 2.4.4 T2 EdgeRecord — 256 bits / 32 bytes

Typed relation. `knowledge_state` here is **record promotion data**, not
ASTRA query `status` (`ANSWER`/`UNKNOWN`/…) and not a function of T1/T2
placement.

| Field | Bits | Description |
|---|---:|---|
| src_id | 32 | Source node ID |
| dst_id | 32 | Destination node ID |
| context_ref | 32 | Applicability context |
| value_ref | 32 | Optional ValueRecord reference; 0 = none |
| provenance_ref | 32 | Evidence ancestry |
| valid_from_tick | 32 | Logical tick; not FPGA cycle count |
| valid_to_tick | 32 | Logical tick; 0 = open |
| relation_id | 16 | Relation identity (`IS_A`, `CAUSES`, …) |
| knowledge_state | 8 | CANDIDATE / VERIFIED / … promotion enum; not ASTRA query status; not cache hotness |
| flags | 8 | direction/tombstone/etc. |
| **Total** | **256** | **32 bytes; architecture-candidate size** |

Forbidden on this verified/static edge: `support_count`, `oppose_count`,
signed utility, Q-value, SPEAR score.

### 2.4.5 T2 ValueRecord — 128 bits / 16 bytes

Values are first-class. Never collapse a missing value to sentinel node 0.

| Field | Bits | Description |
|---|---:|---|
| value_type | 8 | scalar / range / enum / reference |
| flags | 8 | signed / empty / … |
| unit_id | 16 | Unit identity |
| lo | 32 | Scalar or range low |
| hi | 32 | Range high or unused |
| aux_ref | 32 | Auxiliary reference |
| **Total** | **128** | **16 bytes; architecture-candidate size** |

### 2.4.6 T2 ContextRecord — 256 bits / 32 bytes

| Field | Bits | Description |
|---|---:|---|
| context_id | 32 | Context identity |
| generation | 16 | Knowledge generation |
| kind | 8 | Context kind |
| flags | 8 | composable / tombstone / … |
| parent_ref | 32 | Parent/composed context; 0 = none |
| valid_from_tick | 32 | Logical tick |
| valid_to_tick | 32 | Logical tick; 0 = open |
| constraint_lo | 32 | Packed constraint payload |
| constraint_hi | 32 | Packed constraint payload |
| integrity_crc16 | 16 | CRC over preceding fields |
| reserved | 16 | Must be zero |
| **Total** | **256** | **32 bytes; architecture-candidate size** |

### 2.4.7 T2 ProvenanceRecord — 256 bits / 32 bytes

| Field | Bits | Description |
|---|---:|---|
| provenance_id | 32 | Provenance object ID |
| source_kind | 8 | teacher / sensor / inference / pack / … |
| flags | 8 | tombstone / root; MUST NOT encode proof or utility |
| generation | 16 | Knowledge generation |
| source_id | 32 | Source identity |
| revision | 32 | Source revision |
| span_lo | 32 | Location/span low |
| span_hi | 32 | Location/span high |
| parent_prov_ref | 32 | Evidence ancestry; 0 = root |
| digest_ref | 32 | Content digest / pack region reference |
| **Total** | **256** | **32 bytes; architecture-candidate size** |

### 2.4.8 T2 posting pages

`PostingPageHeader` — 128 bits / 16 bytes:

| Field | Bits | Description |
|---|---:|---|
| node_id | 32 | Owner node |
| generation | 16 | Must match NodeRecord generation |
| relation_id | 16 | 0 = mixed-relation page |
| count | 16 | Valid `PostingEntry` count in this page |
| flags | 8 | forward/reverse, last-page, … |
| reserved | 8 | Must be zero |
| next_page_ptr | 32 | Next page byte address; `0` = end/null |
| **Total** | **128** | **16 bytes; architecture-candidate size** |

`PostingEntry` — 64 bits / 8 bytes:

| Field | Bits | Description |
|---|---:|---|
| edge_ref | 32 | T2 byte address of the EdgeRecord (physical pointer; 3a-packable). Not edge identity. `neighbor_id` is the adjacent node ID. |
| neighbor_id | 32 | Adjacent node ID |
| **Total** | **64** | **8 bytes; packing group of two = 128 bits** |

Page payload length is `count` entries, padded to the pack `page_size` in
[§04.6]. Do not scan all of DDR; walk `ID → directory → posting pointer →
selected page`.

**Null T2 pointer:** physical address `0` is reserved as null/end for
directory descriptor pointers, NodeRecord posting pointers, and
`next_page_ptr`. That sentinel is **not** semantic identity `0` (Value
must not collapse to sentinel node 0 [§20.4]). An admitted ID with posting
pointer `0` is empty adjacency, not ASTRA `UNKNOWN`. Directory miss remains
distinct from pointer-null [§02.9].

D’s M2 candidate places the first live posting page at byte 16 so that `0`
stays null. **Byte 16 is not frozen** as the only legal base; live pages
must be non-zero T2 byte addresses. MIG map / base relocation remains D’s
to measure.

### 2.4.9 T1 working copies of T2 records

When a T2 object is hot-cached in BRAM, T1 holds a **bit-identical copy** of
the T2 record plus the directory metadata in §2.4.2. Cache on/off must not
change field values, `knowledge_state`, or proof [§2.7].

A hypothetical 1024-entry T1 directory is 16 KiB before RAM granularity. That
is a sizing example, not a locked graph capacity and not “the graph fits in
BRAM.”

### 2.4.10 Generation and integrity (consistency pass)

Two generation *kinds* exist. They are not silently the same field:

| Kind | Width | Where | Meaning |
|---|---:|---|---|
| `knowledge_generation` | 16 | QueryRecord, StructuredResult, HotDirectoryEntry, Node, Context, Provenance, PostingPageHeader | Active semantic generation of the graph/query |
| `pack_generation` | 32 | ManifestHeader [§04.6] | Pack/load epoch. Live R1 [§04.6] labels this **distinct** from 16-bit `knowledge_generation` (`pack_generation` u32; do not truncate to 16 bits). |

EdgeRecord and ValueRecord have **no** in-record generation field at the accepted
256/128-bit sizes. The walker MUST generation-check the owning Node and
PostingPageHeader before using an edge/value. That is a control law, not a
reason to shrink IDs.

Integrity split (architecture, not a CRC polynomial):

| Record | In-record CRC | Page/region CRC |
|---|---|---|
| NodeRecord, ContextRecord | `integrity_crc16` over preceding fields | also covered by pack page CRC when stored in T2 |
| Edge, Value, Provenance, PostingEntry | none at this candidate size | pack page CRC / region integrity [§04] |
| HotDirectoryEntry | none | BRAM parity/ECC + generation match |
| PostingPageHeader | none | `reserved` must be zero; page CRC covers header+entries |

Reserved bits:

| Record | Reserved | Rule |
|---|---|---|
| ContextRecord | 16 | must be zero |
| PostingPageHeader | 8 | must be zero |
| Arty 32-bit pointers | bits [31:28] | must be zero and checked |
| Arty 32-bit IDs | bits above loaded profile `ACTIVE_ID_RANGE` | must be zero and checked; not a 24-bit ID type |

Do not stuff utility, proof, or epistemic status into reserved bits.

## 2.5 DDR Performance Model

Arty A7-100T DDR3L specifications:

| Parameter | Value |
|-----------|-------|
| Capacity | 256 MB |
| Bus width | 16 bit |
| Memory clock | 333 MHz |
| Effective rate | 667 MT/s |
| Peak bandwidth | 1.334 GB/s ≈ 1.24 GiB/s |

**These are peak physical transfer numbers.** They do not specify user-visible random-access latency or semantic-query throughput.

Do **not** publish fixed row-hit, row-miss, or cycles-per-hop numbers until the exact generated MIG/user-interface implementation is measured. End-to-end latency depends on command/data handshakes, row/bank state, refresh, arbitration, bursts, CDC/buffering, graph indirection and proof fetches.

Required benchmarks [§31]:
```text
sequential burst throughput
random page access latency
random posting lookup
cache hit ratio
cache miss penalty
forward lookup latency
reverse lookup latency
multi-hop traversal time
```

## 2.6 Cache Strategy

BRAM cache is important for performance but not for correctness:

- **Correctness** can work with DDR-only (no cache). Results are the same.
- **Cache** improves: latency, DDR traffic, working-set locality, throughput.

Cache hypothesis for R0:
> Hot working set caching improves sparse semantic traversal.

This must be benchmarked, not assumed as design truth.

Arty MVP baseline: simple LRU/segmented LRU for ease of causal verification.

Post-baseline candidates, enabled only after profiling:
- TinyLFU / Count-Min Sketch admission
- cost-aware or context-aware admission
- subgraph-aware prefetch
- pinned entries for active query nodes

Admission and eviction are separate decisions. Any probabilistic profiler affects placement only and cannot affect ASTRA truth/status.

## 2.7 Cache Coherence and Atomic Promotion

Runtime T2→T1 promotion uses shadow fill and exact generation checks:

```text
DDR canonical object/page
 -> fill inactive/shadow cache slot
 -> verify generation + integrity
 -> atomic directory visibility update
 -> active cache entry
```

On generation change, stale entries are invalidated or generation-mismatched. Cache on/off must produce semantically equivalent results; only latency/traffic may change.

## 2.8 Runtime Consolidation vs Offline Specialization

Two distinct processes — do not conflate:

### Runtime Consolidation (Caching)

```text
T2 DDR → hot object → T1 BRAM
```

This is **caching**. No new truth. No status change. Pure placement optimization.

### Offline Hardware Specialization

After extensive evidence that a pattern is stable:

```text
stable operator / skill / motif
       ↓
profiling
       ↓
benefit analysis
       ↓
causal verification
       ↓
host compiler
       ↓
RTL candidate
       ↓
Vivado synthesis → P&R → timing → regression
       ↓
new bitstream (NEW ARTIFACT, NEW HASH, NEW BITSTREAM)
```

A stable operator MAY receive offline hardware specialization. That requires a
full bitstream rebuild. The FPGA does not grow new LUTs autonomously. Do not
write INSTINCT = LUT or reflex = T0.

## 2.9 Implementation contract for Agent D

Status: **architecture candidate**. This is not RTL_PASS, TIMING_PASS, MIG_PASS,
or BOARD_PASS.

### D must implement (logical)

- 32-bit semantic identity (`SEMANTIC_ID_WIDTH`) and 32-bit T2 byte addresses
  on NCG records [§02.4.1].
- Load `ACTIVE_ID_RANGE` (`active_id_bits` / `active_id_max`) and `K_HARD`
  from the board/knowledge-pack profile. Do not bake 24 as identity.
  Do not treat C `K_HARD_MAX` as the profile value.
- Pack-loader **ingress** check of pack IDs against that profile.
- T1 directory / materialization **authoritative admit** of IDs into the
  active runtime graph against the same profile [§02.4.1b].
- Pointer high-bit zero checks on Arty (physical addresses, §2.4.1.3a / bits
  [31:28]); do not conflate with ID `[31:24]`.
- Exact directory lookup: `ID → directory → posting pointer → selected page`.
  Directory miss is not an ASTRA query status [§03]. Posting pointer `0` is
  null/empty adjacency, not identity 0 and not `UNKNOWN`.
- Generation check before using a cached or fetched record [§02.4.10].
- Cache on/off semantic equivalence [§02.7].
- EdgeRecord without utility/Q/support counts; field `knowledge_state` is not
  ASTRA query status.
- `PostingEntry.edge_ref` is a T2 EdgeRecord byte address, not packed identity.
- ACTION_INTENT path in [§01.7] if the milestone includes actuation; otherwise
  leave the path wired as `NO_BINDING → NO_ACTION`.
- FEM canonical persistence on T2 DDR via MIG; T1 is cache only [§02.4.1c].
- Dest completion by readback + matching `txn_id`/generation, not FIFO-empty.
- Dest `COMMITTED_CORRUPT` (COMMIT magic and CRC fail): do not upgrade to
  `COMMITTED_NEW`; do not roll-forward index/retire.

### Architecture-candidate widths (do not treat as measured physics)

| Record | Bits | Bytes |
|---|---:|---:|
| HotDirectoryEntry | 128 | 16 |
| Node / Edge / Context / Provenance | 256 | 32 |
| ValueRecord | 128 | 16 |
| PostingPageHeader | 128 | 16 |
| PostingEntry | 64 | 8 |

### Implementation-defined (D may choose, then record in the run manifest)

- Generated MIG `app_data` width: D-reported native MIG
  `APP_DATA_WIDTH=128`, `ADDR_WIDTH=28`, `ECC=OFF` (`D:/FPGA/miggen`).
  Record in the run manifest / live [§23.9]. **Not** MIG_PASS. **Not** frozen ABI.
  Generated `BURST_MODE` 8-fixed is the same class of snapshot, not NCG.
- How candidate-sized records / 32-bit FEM words are packed onto that
  interface (media contract; not NCG resize).
- Endianness/byte-lane mapping, jointly versioned with [§04].
- BRAM banking, ECC vs parity, pipeline depth, outstanding requests.
- Numeric `page_size` (the field lives in [§04.6]; the number is not locked here).
- Clock domains, FIFO depths, native MIG `app_*` vs AXI wrapper [§33.7].
- CRC16 polynomial for in-record NCG CRC (not automatically the [§04.12]
  Query/Result CRC16-CCITT-FALSE).

### D may fold / pack / pipeline

- Time-multiplex walkers, hash directory, cascade BRAM ports.
- Pack two `PostingEntry` values in one 128-bit group.
- Pack *internal* T2 addresses narrower than 32 bits if §2.4.1.3a holds.
- Register-slice, outstanding-request queues, posting prefetch.
- LRU/set-associative T1 as the R0 baseline [§02.6].

### D must NOT change without escalation to A (and B if the wire ABI moves)

- Shrink canonical/cross-boundary semantic IDs to a 24-bit *type* or *law*,
  or hard-code `candidate_ref[31:24]==0` as identity rather than profile range.
- Publish a 28-bit pointer *type* as identity or as §04 wire ABI.
- Pack internal addresses narrower without the four §2.4.1.3a conditions.
- Put utility/proof/Top-K into HotDirectoryEntry or verified EdgeRecord.
- Dual-use `PostingEntry.edge_ref` as both byte address and packed identity.
- Infer FACT/VERIFIED from T1 residency.
- Freeze generated MIG `APP_DATA_WIDTH` / `ADDR_WIDTH` / `ECC` /
  `BURST_MODE` / `InputClkFreq` / `ui_clk` as architecture ABI or as MIG_PASS.
- Publish MIG `ADDR_WIDTH=28` as semantic identity or as §04 pointer ABI.
- Resize architecture-candidate *semantic field* widths to match MIG.
- Map transport/protocol faults or directory miss to semantic `UNKNOWN`.
- Claim fixed DDR latency, single-cycle graph access, or DDR efficiency.
- Treat a word-atomic local FEM T2 model as proof of DDR crash safety.
- Treat FIFO-empty as FEM dest completion (live [§22] R07 17:35 already
  treats FIFO-empty as a local/test hint only).
- Upgrade dest `COMMITTED_CORRUPT` to compaction `COMMITTED_NEW`.
- Treat C `K_HARD_MAX` as the loaded-profile `K_HARD`, or silently clamp
  profile `K_HARD` into the SPEAR array.
- Freeze `K_HARD_MAX` as an architecture integer (including a compiled 8).
- Treat a pack_loader BRAM stand-in (`mig_ui_bram` via `mig_ui32`, or an
  older 4K-word `mem_*` stub) as FEM persist authority or as T2 DDR.
- Treat OOC or integrated post-synth WNS as TIMING_PASS.
- Freeze `RTL_PIPELINE_DEPTH` or a SPEAR/Q* cycle count as architecture
  (live [§10.7.2] is `IMPLEMENTATION_DEFINED` / post-route measured).
- Quote D fabric keep-hierarchy / r2_top flatten WNS +1.549, mig_top
  FEM-mux synth WNS −1.482, post-route WNS −1.160 (pre-`ui_clk` / pre-bag2),
  bag2+`ui_clk` post-synth setup WNS +1.277 / post-route WNS +1.032
  (Vivado MET, not `TIMING_PASS`), fabric bag2+`uart_tx` post-synth +1.549 /
  post-route +0.375 WHS +0.021, `mig_tx` post-route +0.673, FE256 OOC
  unplaced WNS −75.723 (144 levels), C OOC +1.703/+1.898, or superseded
  −10.174 / −1.490 as `TIMING_PASS`.
  Moving Q*/SPEAR/`bounded_walk` onto `ui_clk` is implementation clocking,
  not a freeze and not TIMING_PASS. Pre-place ≠ routed. Instantiating
  `mig0` ≠ `MIG_PASS`. Snapshots may move. Do not freeze D LUT/FF/BRAM/`ui_clk`.
- Promote `UART_WORD_XSIM_PASS` / `UART_PACK_XSIM_PASS` (loopback / pack
  ACK-NAK) to `BOARD_PASS` / UART board proof.
- Promote lab DCP name `R2_TOP_ROUTE_BASELINE_WHS_0P021` /
  `HOLD_OPTIMIZATION_STOPPED` to owner `TIMING_PASS` / `BOARD_PASS`.
- Bind FE256 OOC onto `r2_top`, or stamp `FE256_PASS` / `FE256_FULL_PASS`,
  from unplaced WNS −75.723 / RCA analysis alone.
- Treat `FEM_MIG_UI32_XSIM_PASS` or muxing FEM onto the pack UI as
  `FEM_PERSIST_PASS` / `MIG_PASS`.
- Promote an XSim banner (`*_XSIM_PASS`) to `BOARD_PASS`, `MIG_PASS`,
  `FEM_PERSIST_PASS`, or `TIMING_PASS`.
- Freeze generated MIG `InputClkFreq` / MMCM multiply as architecture ABI.
- Feed the board oscillator into MIG `sys_clk_i` (false path vs generated
  `InputClkFreq`).
- Treat DDR beat address `0` as the T2 directory/page null pointer.
- Treat T2 address `0` as semantic identity `0`, or freeze first posting
  page at byte 16 as wire ABI.

## Tóm tắt tiếng Việt

Bộ nhớ chia 3 tầng vật lý: T0 (LUT/FF), T1 (BRAM/LUTRAM, ~607.5 KiB raw), T2 (DDR3L 256 MB). Tầng vật lý không phải loại tri thức; T1 không phải working memory. NCG giữ identity 32-bit (`SEMANTIC_ID_WIDTH`); `ACTIVE_ID_RANGE` là profile, không phải luật 24-bit. High-zero là packing/range, không phải bề rộng ID mới. Admit T1 directory là checker có thẩm quyền; pack loader là ingress; SPEAR được phép check phòng thủ. T1 directory 128 bit; T2 Node/Edge/Context/Provenance 256 bit; Value 128 bit; posting header 128 bit + entry 64 bit. `edge_ref` là địa chỉ T2, không phải identity. Pointer T2 `0` là null/end, không phải identity 0. Edge dùng `knowledge_state`, không phải ASTRA status. SKILL/EPISODE/FAILURE không phải NodeRecord. `EpisodeRecord` là lớp T2 bắt buộc, không phải FailureRecord / SemanticEvent UART; FEM có thể cite `episode_id` nhưng không phải episode store; bit/field chưa khóa. FEM canonical nằm T2 DDR; T1 chỉ cache; mô hình word-atomic ≠ an toàn crash DDR. Stand-in `mig_ui_bram` qua `mig_ui32` không phải persist FEM (không phải `mig0`). D báo MIG native `APP_DATA_WIDTH=128` / `ADDR_WIDTH=28` — bằng chứng IP, không khóa kiến trúc, không phải identity 28-bit. `K_HARD_MAX` (kể cả số 8 D báo) không khóa. WNS OOC/integrated không phải TIMING_PASS. Oscillator 100 MHz ≠ MIG `sys_clk`; pointer T2 `0` ≠ DDR beat 0. `COMMITTED_CORRUPT` là dest-integrity, không phải trạng thái compaction thứ tư. Live R1 C-owned candidate: FailureRecord 128 / SkillRecord 256 (A không khóa; không alias Node). Hợp đồng triển khai cho D ở [§02.9]. Skill candidate cũng nằm T2. Không nhét utility vào EdgeRecord. DDR peak 1.334 GB/s không phải throughput graph.
