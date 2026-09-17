---
version: "1.7-candidate"
owner: AGENT_A
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-17T04:25:00+07:00"
---

# §01 — MASTER ARCHITECTURE

> Core dual-plane architecture of the Native Semantic Pulse Fabric (NSPF).
> This document defines the top-level information flow, authority partition,
> and the relationship between all major subsystems.

## 1.1 Design Decision

**[SUPPORTED]** Native Semantic Pulse Fabric (NSPF) is technically plausible as a **bounded cognitive substrate** in which explicit semantic units, typed relations, bindings, events and state transitions are persistent/activatable objects, while only a sparse working frontier is active at a time.

The defensible proposition is **not** "replace neural networks." The target is:

> Use exact, typed, addressable information as the persistent cognitive substrate; use event-driven sparse activation and bounded retrieval/reasoning over that substrate; reserve dense/approximate neural computation for optional perception, association or language boundaries when it provides measurable benefit.

## 1.2 End-State Architecture

```text
                HUMAN / PHYSICAL WORLD
                         │
          ┌──────────────┴──────────────┐
          │                             │
 LANGUAGE ADAPTER                SENSOR ADAPTER
          │                             │
          └──────────────┬──────────────┘
                         ▼
            QUERY / SEMANTIC EVENT BUS
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼                                 ▼
 BINARY SEMANTIC                   TEMPORAL EVENT
     PLANE                             PLANE
 ID/REL/VALUE                    EVENT/STATE/ACTION
 CTX/PROV                        TICK/DURATION/REWARD
        │                                 │
        └────────────────┬────────────────┘
                         ▼
                T1 HOT COGNITIVE WORKING STORE
        Query / Goal / Bindings / Context
             Active Frontier / Cache
                         │
                         ▼
                 EXACT DIRECTORY
                         │
                  T1 HIT │ MISS
                      ┌──┴──┐
                      ▼     ▼
                    BRAM   DDR
                           T2
                            │
                     posting pages
                            │
                            ▼
          BOUNDED RELEVANCE-GUIDED WALKER
             ┌────────┼─────────────┐
             ▼        ▼             ▼
           direct   reverse      multihop
                     │
          optional intersection
                     │
                     ▼
            candidate generation
                     │
                   SPEAR
                   Top-K
                     │
                     ▼
            value/context checks
             provenance/conflict
             causal constraints
                     │
                     ▼
                   ASTRA
                     │
      ┌──────────────┼────────────────────┐
      ▼              ▼                    ▼
   ANSWER         UNKNOWN              CONFLICT
SEARCH_INCOMPLETE / UNSUPPORTED / INTEGRITY_FAIL
                     │
                     ▼
             STRUCTURED RESULT
                     │
                     ▼
                  GEMINI
                     │
                     ▼
                   HUMAN
```

## 1.3 Binary Semantic Plane

Persistent typed records. Class and promotion live on the record
(`knowledge_state` / lifecycle), not on the plane and not on T1/T2 placement:

| Record Type | Contents |
|------------|----------|
| **Node** | Stable ID, KIND, CLASS, STATE, generation |
| **Edge** | Source ID, relation type, destination ID, context, provenance |
| **Value** | Typed payload (numeric, enum, composite) |
| **Context** | Spatial, temporal, conditional scope |
| **Provenance** | Origin (teacher, sensor, inference), revision/location, evidence ancestry |

Key invariant: meaning is separated from human-language representation. Node IDs are stable binary identifiers; human strings are aliases attached via NAMED_AS edges.

## 1.4 Temporal Event Plane

Dynamic records representing experience and change:

| Record Type | Contents |
|------------|----------|
| **Event** | Logical tick, event type, references |
| **State Transition** | Before/after state, trigger |
| **Action** | Operator, parameters, target |
| **Observation** | Sensor source, value, timestamp |
| **Reward/Penalty** | Source, magnitude, context |
| **Episode** | Ordered sequence of events/actions/effects |

`EpisodeRecord` is a required typed T2 class [§02.2][§02.4] — not `NodeRecord`, not `FailureRecord`, and not a `SemanticEvent` UART packet — and its bit width and field list are not frozen here.

Semantic time uses explicit logical ticks, not physical FPGA clock. Clock frequency and jitter are implementation noise, not semantic identity.

## 1.5 Working Mind

The active cognitive process combining:

| Component | Function | Reference |
|-----------|----------|-----------|
| **NCG** (Native Cognitive Graph) | Exact retrieval via directory/posting lookup | [§02] |
| **Q*** | Macro strategy selection: retrieve, search, observe, act, ask teacher, submit, stop | [§10] |
| **SPEAR** | Ranking legal candidates or targets within chosen strategy | [§10] |
| **Skill Engine** | Stores reusable procedures; may originate `ACTION_INTENT`; does not drive pins | [§12] [§01.7] |
| **FEM** | Failure Experience Memory — typed failure, recovery, regression detection | [§11] |

## 1.6 Authority Partition

This partition is **locked** and must not be violated:

| Layer | Authority | Question It Answers |
|-------|-----------|-------------------|
| **Q*** | Macro strategy | "What should I do next?" |
| **SPEAR** | Candidate/target ranking | "Which candidate should I inspect first?" |
| **Skill Engine** | Procedure store / `ACTION_INTENT` origin | "Which reusable procedure should originate an ACTION_INTENT?" |
| **FEM** | Failure memory | "What failed before, how was it repaired?" |
| **ASTRA** | Legality, proof, status, promotion, action-precheck | "Is this legal? Is evidence adequate? Any conflict? May this intent+descriptor+safety bind?" |
| **GEMINI** | Human expression | "How do I express the structured result to a human?" |

**No layer may usurp the authority of another.**

Critical rules:
- Host truth/proof authority = 0. The host may perform frozen alias/intent/unit normalization and construct QueryRecord IDs, but cannot inject answer, winner, proof, provenance, or hidden graph reasoning.
- Q* chooses macro action, not truth.
- SPEAR ranks, does not override proof legality.
- Score does not override proof legality.
- GEMINI expresses results but does not create truth and does not drive actuators directly.
- Skill Engine does not drive pins (`SKILL_ENGINE ≠ PRIMITIVE_EXECUTOR`). Pin
  drive is the Primitive Executor after ASTRA + `BOUND` [§01.7].
- Teacher does not write weights directly.
- Candidate, episode and failure memory do not self-promote to verified fact.
- `SEARCH_INCOMPLETE != UNKNOWN`.

## 1.7 Physical Action / Capability Boundary

Semantic reasoning never drives an actuator directly. The physical action path is
one contract. It does **not** silently pick between GOAL_LOCK and [§05.1]: lookup
is not binding, and binding is not a command.

```text
Q*/Skill/HUMAN_DEMO ACTION_INTENT
  -> ActionResolution + installed CapabilityDescriptor lookup
     (non-actuating; no PrimitiveCommand)
  -> ASTRA legality + safety_contract precheck
  -> CapabilityBinding (BOUND | deny)
  -> PrimitiveCommand
  -> verified Primitive Executor
  -> physical hardware action
  -> ObservedEffect / readback
  -> Temporal Event / Episode
```

Every arrow is a hard stop. Skipping a stage is illegal, not an optimization.

Locked meanings:

- **Lookup / `ActionResolution`** may precede ASTRA. ASTRA must see the candidate
  descriptor and `safety_contract_ref`. Lookup is not a binding and not a command.
- **GOAL_LOCK “capability binding”** means the post-ASTRA `CapabilityBinding`
  commit (`BOUND`), not descriptor fetch.
- **ASTRA** certifies legality of the intent + resolved descriptor + safety
  contract. A failed `safety_contract` is an **ASTRA-admissible veto**. Safety is
  not a second authority that can approve what ASTRA denied. ASTRA does not drive
  pins.
- **`NO_ACTION`** = no `PrimitiveCommand` issued. Pre-executor fails map here:
  `NO_BINDING`, `ASTRA_DENY`, `SAFETY_VETO`, `STALE_DESCRIPTOR`.
- After a `PrimitiveCommand` is issued: `COMMAND_ACCEPTED` /
  `EFFECT_UNOBSERVED` / `EFFECT_OBSERVED`. Missing readback identity ⇒
  `EFFECT_UNOBSERVED` and **no causal credit**. It does not rewrite the command
  as never issued [§05.6].
- Credit chain (live [§10.8.4] echo; architecture law):
  `proposal ≠ legal acceptance ≠ execution ≠ observed effect ≠ reward
  acceptance ≠ credit update`. A never-issued / `NO_ACTION` / unexecuted
  Top-1 gets **zero execution credit**. The action-credit lane holds **at
  most one** unresolved pending proposal; a new proposal must not silently
  overwrite it. `reward_accepted` is asserted only after identities match
  `(episode_id, step_id, command_id, generation)` [§04.13] plus
  `ObservedEffect` citing `command_id`. Duplicate credit apply is refused.
  C’s local names (`prop_refused`, `R_NO_PROPOSAL`) are C observables, not
  a second ABI. ASTRA action-precheck encodings remain B-owned.

A `CapabilityDescriptor` identifies what the installed hardware can actually do.
Canonical fields live in [§05.2]. `ModuleManifest` is the same object under
install-time names (`MODULE_ID` → `capability_id`); it is not a second hardware
identity. Knowledge-pack semantics or GEMINI text cannot become electrical
control. See [§05.8] for the seven action-path acceptance names
(`CAPABILITY_ENUM_PASS` … `UNEXECUTED_NO_CREDIT_PASS`). Those names are
the action-path set. [§31]/[§32] must echo them; live X0-15
`Capability Binding` / `NO_BINDING/NO_ACTION` is not that set.

### 1.7.1 Required logical objects (architecture)

These objects must exist as typed records. They are **not** RTL module names.

| Object | Required logical fields | Semantic-width law |
|---|---|---|
| `ACTION_INTENT` | intent_id, origin, optional skill_id + skill generation, capability_class, target_ref, param_ref, context_id, generation, flags | identity/refs = 32-bit; generation = 16-bit knowledge generation |
| `ActionResolution` | intent_id, semantic_action_class, capability_class, primitive_id, optional target_ref, result | identity/refs = 32-bit |
| `CapabilityDescriptor` | canonical list [§05.2]: capability_id, capability_class, instance_id, version, interface_type, primitive_mask, schema refs, timing/safety contract refs, executor_index, knowledge_pack_dependency_ref, flags, integrity/`crc` | identity/refs = 32-bit |
| `CapabilityBinding` | **binding_id (produced)**, intent_id, capability_id, instance_id, primitive_id, generation, result (`BOUND` / `NO_BINDING` / `ASTRA_DENY` / `SAFETY_VETO` / `STALE_DESCRIPTOR`) | identity/refs = 32-bit |
| `PrimitiveCommand` | **command_id (produced)**, binding_id, primitive_id, parameter payload/ref, generation | identity/refs = 32-bit |
| `ObservedEffect` | command_id, episode_id, step_id, accepted, readback/value_ref, state_before, state_after, logical_tick, generation | identity/refs = 32-bit; tick ≠ FPGA cycle |

Resolution laws (architecture, not RTL):

- Primitive not in `primitive_mask` ⇒ `NO_BINDING` ⇒ `NO_ACTION`.
- Multiple installed instances and missing `target_ref` ⇒ `NO_BINDING` (no silent pick).
- Production execution from Skill requires `SkillRecord.status` in the
  ASTRA-legal executable set; otherwise `ASTRA_DENY`. `SKILL_STATE ≠
  EXECUTION_PERMISSION` [§12.8]: lifecycle does not by itself authorize pins.
  Teacher demo is still an `ACTION_INTENT` with origin `HUMAN_DEMO` and must
  use this path. There is no teacher-to-actuator side channel.
- Live [§03.1] Skill Engine may originate `ACTION_INTENT` [§12]; that does
  **not** authorize pins. Pin drive stays the [§01.7] Primitive Executor
  after ASTRA + `BOUND`. Live [§03.12] locks action-precheck before binding.
- Expected-vs-observed compare is for **credit only**. It cannot override ASTRA
  or authorize a command.

Packing, pipeline depth, and executor micro-architecture are implementation-defined
[§02.9]. Do not encode truth, Top-K, or SPEAR score into any of these objects.
Actuation objects are **not** Query/Result UART records [§04]; B must either keep
them off the §04 wire or add distinct records. Action verdict codes must not
reuse query `0x01–0x06`.

`schema_lock.json` currently omits `05_CAPABILITY_AND_ACTION_BINDING.md`. Live
architecture of this path is [§01.7] + [§05] prose; D must add §05 to the lock.

## 1.8 Human Language Boundary

```text
Human:
"Máy lạnh này dùng gas gì?"
            ↓
HOST LANGUAGE ADAPTER
            ↓
subject_id
relation_id
query_op
context
            ↓
QueryRecord
            ↓
UART
            ↓
FPGA (reasoning)
            ↓
StructuredResult
status = ANSWER
answer_ref = R32_ID
proof_ref = ...
            ↓
HOST LANGUAGE ADAPTER
            ↓
"Máy sử dụng R32."
```

The host adapter may:
- Map "RAC_WALL" → node ID
- Map "uses refrigerant" → relation ID

The host adapter **must not**:
- Directly produce "R32" as the answer (bypassing FPGA reasoning)

This is the boundary that prevents cheating.

## 1.9 Sensor Boundary

Sensors provide the path to native meaning formation:

```text
Sensor readings: 31°, 45°, 62°, 75°
→ STATE observations
→ Experience (state_before, action, effect, state_after)
→ Candidate concept C_8734
→ Human later attaches: alias(C_8734) = "hot"
```

**[HYPOTHESIS]** If the alias changes ("nóng", "hot", "高温"), grounded internal relations should remain unchanged. This is a critical falsification test [§31], not an established property until demonstrated.

## 1.10 What Is Novel

**[ESTABLISHED]** No individual ingredient is new. Semantic networks, CAM, sparse distributed memory, VSA/HDC, production systems, external neural memory, event-driven neuromorphic routing, graph accelerators and event sensors all provide relevant precedent.

**[HYPOTHESIS]** The potentially distinctive combination is:

```text
exact typed semantic identity
+ explicit context/provenance
+ verified/candidate/episode/skill separation
+ sparse logical-event activation
+ causal proof/status authority
+ FPGA-native bounded graph/event execution
+ causal falsification by ablation/permutation/reset/clock invariance
```

Novelty must be treated as **unproven** until a dedicated patent/literature search is completed [§21].

## 1.11 Design Choices Locked in R0

- Semantic identity uses stable ID; grammatical/contextual use carried by ROLE.
- KIND, CLASS, STATE, ROLE, STATUS are independent fields.
- Human strings are aliases, not hardware identity.
- NCG T1 HotDirectoryEntry is 128 bits with 32-bit canonical IDs
  (`SEMANTIC_ID_WIDTH`) and 32-bit canonical T2 address fields [§02.4].
  A 24-bit semantic-ID *law* is rejected. `ACTIVE_ID_RANGE` is a loaded
  profile property, not identity width [§02.4.1b]. Live [§10.7.5] 24-bit
  Q5.19 SPEAR product is ranking arithmetic, not identity. Live Pack/ABI-24
  gold is 24 integrity cases, not a 24-bit ID law [§31.2]. Internal physical
  pointers may pack narrower only under [§02.4.1] 3a.
- Architecture-candidate NCG sizes (not final packing, not MIG freeze)
  [§02.4] [§20.9]: HotDirectory / Value / PostingPageHeader = 128;
  Node / Edge / Context / Provenance = 256; PostingEntry = 64 (two may
  pack in one 128-bit group). QueryRecord 256 / StructuredResult 384 /
  SemanticEvent 192 remain [§04] (`NCG_RECORD ≠ QUERY_UART_RECORD`).
  SemanticEvent’s 24-byte size is not a 24-bit identity law.
- FEM canonical persistence is T2 DDR; T1 is cache; a word-atomic local
  model is not DDR crash safety. Dest `COMMITTED_CORRUPT` is dest-integrity,
  not a fourth compaction recover state [§02.4.1c]. FIFO-empty is not FEM
  dest completion (`FIFO_EMPTY ≠ DEST_COMPLETE`); live [§22] R07 (17:35)
  agrees (FIFO-empty is a local/test hint only).
  D-reported generated
  MIG `APP_DATA_WIDTH=128` / `ADDR_WIDTH=28` is implementation evidence,
  not architecture freeze, not 28-bit identity [§02.9]. Live [§23.9] is
  that snapshot (including generated burst 8-fixed); not freeze. A pack_loader
  `mig_ui_bram` via `mig_ui32` is not FEM persist authority (live [§23.9]
  22:13 still unbound `mig0` on `arty_a7_r2_top`; `arty_a7_mig_top`
  instantiates `mig0` and muxes pack+FEM on `ui_clk` CANDIDATE; Q*/SPEAR/
  `bounded_walk` on that top also on `ui_clk` — implementation clocking,
  not freeze; FEM off CLK100MHZ local dest on that top only). Instantiation /
  UI mux / learner clock move is not
  `MIG_PASS` / `FEM_PERSIST_PASS` / `TIMING_PASS`. Board
  oscillator ≠ generated MIG `sys_clk`; T2 null pointer `0` ≠ DDR beat `0`.
  XSim banners are not `BOARD_PASS` / `MIG_PASS` / `FEM_PERSIST_PASS` /
  `TIMING_PASS` [§20.1] [§22] R20. Live [§10.7.2]
  `RTL_PIPELINE_DEPTH = IMPLEMENTATION_DEFINED`; six SPEAR logical stages
  are not a frozen RTL depth. C published Q*/SPEAR pipelines as CANDIDATE
  (not TIMING_PASS). D fabric bag2+`uart_tx` post-route WNS +0.375 WHS
  +0.021   (lab baseline `R2_TOP_ROUTE_BASELINE_WHS_0P021`, not TIMING_PASS),
  `mig_tx` +0.673, bag2+`ui_clk` +1.032, FE256 OOC R0 −75.723 / 144 levels
  `DO_NOT_BIND`, FE256 HW-R1 isolated +0.568/+0.223, shadow-bind candidate
  +0.368 (new lab freeze `R2_FE256_R1_INTEGRATED_FREEZE` ≠ product permanent;
  `FE256_R1_REFERENCE_FREEZE` = REFERENCE_IMPLEMENTATION; FE256_DEVELOPMENT
  CLOSED), M2/M3/M4 common-runtime OOC +0.935/+1.899/+1.203, M4 shadow
  candidate +0.555, M4+`mig0` candidate +0.233, and prior
  +1.549 / −1.482 / −1.160 snapshots are not
  `TIMING_PASS`; −10.174 / −1.490 are superseded where noted.
  Instantiating `mig0` ≠ `MIG_PASS`. Integrated ≠ C OOC.
  `UART_WORD_XSIM_PASS` / `UART_PACK_XSIM_PASS` / `UART_FE256_XSIM_SMOKE`
  / UART board hop-1 smoke ≠ `BOARD_PASS`.
  Owner `PROGRAM=YES` JTAG config + startup HIGH ≠ `PROGRAM_PASS` /
  `BOARD_PASS`. Bitstream write ≠ `PROGRAM_PASS`.
  FE256 OOC / HW-R1 / shadow-bind / reference freeze ≠ `FE256_FULL_PASS` /
  `FE256_PASS`. M2/M3/M4 QueryRecord XSim banners ≠ `M2_PASS` / `M3_PASS` /
  `ASTRA_PASS`.   `PACK_ABI24_MIG_DUT_XSIM_PASS` ≠ `PACK_ABI_24_24_PASS`.
  Pack board SEQ 2/24 / ISO 14/24 CANDIDATE ≠ `PACK_ABI_24_24_PASS` /
  `BOARD_PASS`. Reprogram of same bit ≠ `PROGRAM_PASS`.
  Dedicated FE256 on integrated freeze top is D roadmap status
  only; retirement requires common-runtime 256/256 + legal timing.
- `K_HARD` is loaded-profile Top-K capacity; `K_HARD_MAX` is C’s compiled
  SPEAR slot ceiling. They are not the same integer [§02.4.1b].
- T2 byte address `0` is a null/end pointer sentinel, not semantic identity
  `0`. First posting-page base is not frozen at byte 16 [§02.4.8].
- 6W1H may be a compact query-operator algebra, not an English ontology.
- Logical semantic ticks carry order/time meaning; FPGA clock rate does not.
- Jitter is verification noise unless represented explicitly as data.
- Canonical bulk placement is virtualized in DDR/HBM; one circuit per semantic unit is rejected. Duration/stability of knowledge is epistemic, not a DDR identity.
- BRAM is a managed hot/working store, not a truth tier.
- Promotion across memory tiers changes placement, not epistemic status.
- ASTRA remains the authority for legality, proof, conflict, completeness,
  promotion, and action-precheck of intent+descriptor+safety.
- Skill Engine does not drive pins (`SKILL_ENGINE ≠ PRIMITIVE_EXECUTOR`).
- Semantic action intent must pass non-actuating lookup, ASTRA legality/safety
  precheck, `CapabilityBinding`, and verified primitive execution before any
  actuator command. `NO_ACTION` ≠ missing readback.
- Prediction/association may propose candidates but never establishes truth.

## Tóm tắt tiếng Việt

Kiến trúc NSPF gồm hai mặt phẳng: Binary Semantic Plane và Temporal Event Plane. `EpisodeRecord` là lớp T2 bắt buộc, không phải NodeRecord / FailureRecord / gói SemanticEvent UART; bit và field không khóa ở đây. Working Mind kết hợp NCG + Q* + SPEAR + Skill + FEM. T1 là Hot Cognitive Working Store, không phải tên khác của working memory. FEM canonical nằm T2 DDR; T1 chỉ cache. Skill Engine không drive pins (`SKILL_ENGINE ≠ PRIMITIVE_EXECUTOR`). ACTION_INTENT đi lookup (không lệnh) → ASTRA/safety → CapabilityBinding → PrimitiveCommand → executor → ObservedEffect [§01.7]. `NO_ACTION` chỉ khi chưa phát lệnh. Proposal ≠ execution ≠ credit; tối đa một pending. Bảy tên [§05.8] là bộ acceptance action-path; [§31]/[§32] không được thay bằng thang không tên. FIFO-empty không phải dest-complete. ASTRA là authority cuối cùng. NCG identity 32-bit (`SEMANTIC_ID_WIDTH` ≠ profile `ACTIVE_ID_RANGE`); `K_HARD` ≠ `K_HARD_MAX`; D báo MIG `APP_DATA_WIDTH=128` là bằng chứng IP, không khóa; pointer T2 `0` là null, không phải identity; bề rộng record là candidate tại [§02.4], hợp đồng D tại [§02.9].
