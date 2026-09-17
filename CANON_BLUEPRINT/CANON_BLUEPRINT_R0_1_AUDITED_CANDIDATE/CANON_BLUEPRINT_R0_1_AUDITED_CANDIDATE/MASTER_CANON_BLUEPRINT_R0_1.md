---
version: "1.0-candidate"
owner: AUDIT
status: AUDITED_CANDIDATE
category: GOVERNANCE
last_modified: "2026-09-16T09:15:00+07:00"
---

# MASTER CANON BLUEPRINT R0.1 — AUDITED CANDIDATE

> Concatenated convenience view. Individual top-level documents remain easier to review and their authority is governed by `AUTHORITY_PRECEDENCE.md`. This file is not an owner freeze.


---

## SOURCE DOCUMENT: `PROJECT_GOAL_LOCK.md`

# NATIVE AI — PROJECT GOAL LOCK

Status: FORWARD RESEARCH AUTHORITY
Scope: Developmental Native AI / Native Semantic Pulse Fabric
Historical frozen V1 evidence is not modified or inherited.

## GOAL

Native AI aims to create an FPGA/SoC-native,
evidence-governed cognitive substrate in which explicit
semantic information is represented as stable typed objects,
typed relations and temporal events rather than existing
primarily as implicit distributed knowledge inside learned weights.

Persistent semantic information and transient activation are
separate.

The system activates only a bounded sparse working set and uses
exact identity, indexed retrieval, bounded graph traversal,
role/variable binding, temporal events, learned strategy,
procedural skill and physical observation to reason and act.

Human language is an adapter, not the native cognitive substrate.

Verified facts, candidate knowledge, episodes, skills, failures,
preferences and learned policy weights are separate logical
classes.

Physical memory placement never changes those logical classes.

```
FACT != SKILL != EPISODE != FAILURE != WEIGHT
ALIAS != IDENTITY
KIND != ROLE
CANDIDATE != VERIFIED
CORRELATION != CAUSATION
UTILITY != TRUTH
CACHE_HOTNESS != PROOF
OBSERVATION != VERIFIED_FACT
PREDICTION != TRUTH
PHYSICAL_PLACEMENT != EPISTEMIC_CLASS
LOGICAL_TICK != PHYSICAL_CLOCK
TOP_K != ANSWER
SEARCH_INCOMPLETE != UNKNOWN
```

Q* selects bounded macro strategy.

SPEAR ranks legal candidates or targets.

Skill memory stores reusable verified procedures.

FEM stores typed failure experience and recovery history.

GEMINI / human-language adapters translate between human symbols
and native records but cannot create or override truth.

ASTRA remains the deterministic authority for legality,
proof validity, provenance, conflict, completeness,
epistemic status and knowledge promotion.

Teacher input, sensor observation and self-experience may create
candidate knowledge or learned procedural state, but cannot
silently create verified fact.

## Physical Implementation Stratification

### T0 — Immutable Semantic Control Plane

Fixed primitives, protocol/schema enforcement, routing,
comparison, legality, safety and ASTRA control laws.

### T1 — Hot Cognitive Working Store

Active query, bindings, context, frontier, candidate queues,
hot semantic/posting cache, proof scratch and bounded hot
procedural/learning state.

### T2 — Canonical Cognitive Memory

DDR/HBM storage for nodes, edges, values, contexts, provenance,
postings, candidate knowledge, episodes, failures, skills,
learning checkpoints and long-term state.

Movement between T2 and T1 changes only physical placement.

A verified FACT remains a FACT regardless of whether it is
currently stored in DDR or cached in BRAM.


## Physical Action Authority Path

A semantic action intent must never drive an actuator directly. Physical execution follows:

```text
ACTION_INTENT
→ ASTRA legality / safety precheck
→ capability binding
→ verified primitive executor
→ physical action
→ readback / observed effect
→ episode / evidence
```

If no compatible capability binding exists, the action is not executed. GEMINI and the
human-language adapter never drive actuators directly.

ASTRA is an authority over the encoded rules, evidence, provenance and status contract; it is
**not an omniscient truth oracle**. Its claims remain bounded by the loaded evidence, supported
query class, search completeness, integrity state and implemented verification rules.

## Runtime Reasoning Path

```
Human/Sensor Input
→ Adapter/Grounding
→ QueryRecord / Semantic Event
→ Working Memory / Active Frontier
→ Exact Directory / Posting Lookup
→ Bounded Relevance-Guided Retrieval
→ Direct / Reverse / Multi-Hop / Constraint / Intersection
  operators as appropriate
→ Candidate Generation and Ranking
→ Evidence / Value / Context / Provenance / Conflict Checks
→ ASTRA Proof and Status
→ StructuredResult
→ Optional Human-Language Rendering.
```

## Epistemic Status Codes

The system must explicitly distinguish:

```
ANSWER
UNKNOWN
CONFLICT
SEARCH_INCOMPLETE
UNSUPPORTED_QUERY
DATA_INTEGRITY_FAIL
```

and adapter-level `PARSE_ERROR`.

## Learning Path

```
Observation / Demonstration / Teacher / Physical Experience
→ Episode
→ Candidate Relation / Preference / Skill / Failure Record
→ Causal and provenance verification
→ ASTRA Promotion / Rejection / Conflict
→ Versioned generation commit.
```

## Information Neuronalization Hypothesis

Explicit semantic objects act as virtual neuron-like persistent
units, typed relations act as explicit connectivity, and sparse
event-driven activation operates only on the currently relevant
working set.

This is an engineering abstraction, not a claim that information
literally becomes a biological neuron.

The hypothesis is considered successful only if causal experiments
show transfer, grounding, compositional behavior and learning that
cannot be explained by hard-coded IDs, task-specific FSMs,
host-side reasoning or benchmark answer injection.

## Required Falsification Evidence

```
ID permutation
unseen-instance transfer
masked-slot reconstruction
causal ablation
sensor grounding
reset/restore
teacher authority attack
clock-rate invariance
event-jitter robustness
cache-on/cache-off semantic equivalence
runtime knowledge-load dependence
```

## Platform and Scaling

Arty A7-100T is the bounded experimental platform.

Larger DDR/HBM/SoC/ASIC systems may scale the same semantic ABI and
authority architecture only after profiling identifies a real
memory/throughput bottleneck.

## Claim Ceiling

No artifact may claim AGI, consciousness, universal reasoning,
zero hallucination or human-equivalent cognition without
separate evidence.

No new artifact inherits historical BOARD_PASS.

Agents may produce candidate evidence.

Only the project owner may authorize final promotion/freeze.

## Forbidden Overclaims

The following claims are explicitly prohibited in any project document:

1. "reasoning in nanoseconds" — no timing claims without measured evidence
2. "100% accuracy" — only preregistered finite benchmarks may claim 100%
3. "never lies" / "never hallucinates" — unprovable
4. "simulates biological cognition" — no basis
5. Specific large node counts (e.g., "800,000 nodes") not yet built/loaded
6. "LUT finds intersection of thousands of branches in one clock" — no resource/timing evidence
7. "R0 has perfectly frozen theory" — R0 is a research blueprint


---

## SOURCE DOCUMENT: `AUTHORITY_PRECEDENCE.md`

# AUTHORITY PRECEDENCE — AUDITED CANDIDATE

This file defines how conflicts inside this **candidate package** are resolved.
It does not rewrite frozen historical evidence and does not constitute owner
approval/freeze.

## Precedence

1. **PROJECT_GOAL_LOCK.md** — forward research North Star and invariants.
2. **Top-level R0.1 audited design docs** (`01`–`33`, including §05 capability binding).
3. **Preregistered benchmark/acceptance contracts** for the scope they test.
4. **Archived source packages** under `_ARCHIVE/` — historical/source evidence; immutable, not silently merged into current rules.
5. **Coordination metadata/tools** under `_COORDINATION/` — workflow state only, never semantic/technical authority.
6. **Local run metadata** (COM/JTAG/path/license) — evidence for one run only.

If two top-level docs conflict, stop and register an erratum rather than choosing
silently. If an external authoritative hardware source conflicts with a project
constant, correct the candidate doc and preserve the historical text in archive.

## Final authority

Agents may create candidate designs/evidence. Only the project owner may approve
promotion, final freeze or BOARD_PASS-equivalent artifact status.


---

## SOURCE DOCUMENT: `00_INDEX.md`

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

## Primary architecture

| § | File | Scope |
|---|---|---|
| 01 | `01_MASTER_ARCHITECTURE.md` | dual semantic/event planes, Working Mind, authority partition |
| 02 | `02_MEMORY_STRATIFICATION.md` | T0/T1/T2, cache/coherence/placement |
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

## Required reading order

See `READING_ORDER.md`.

## Cross-reference convention

Project docs use `§XX.Y` for numbered top-level sections. Governance filenames
are referenced by name. If a cross-reference points to a missing/renumbered
section, treat it as an audit defect rather than guessing silently.

## Tóm tắt tiếng Việt

Index R0.1 thêm authority precedence, audit/errata và §05 capability binding;
archive/coordination được giữ nhưng không có quyền ghi đè canon top-level.


---

## SOURCE DOCUMENT: `23_HARDWARE_FACTS.md`

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

## Tóm tắt tiếng Việt

Arty A7-100T dùng XC7A100T, có 135 BRAM36 (~607.5 KiB raw), 256 MB DDR3L,
bus 16-bit, khoảng 333 MHz / 667 MT/s, peak lý thuyết ~1.334 GB/s. Peak này
không phải băng thông truy vấn graph thực tế. Không khóa latency DDR bằng số ns
hay số cycle nếu chưa đo trên MIG thật. COM, JTAG serial, đường dẫn Vivado và
license chỉ là local run metadata, không phải chân lý kiến trúc.


---

## SOURCE DOCUMENT: `20_GLOSSARY_AND_LOCKED_TERMS.md`

# §20 — GLOSSARY AND LOCKED TERMS

> Canonical terminology for the audited R0.1 candidate. If a biological metaphor
> conflicts with these definitions, the technical definition wins.

## 20.1 Locked distinctions

| Left | ≠ | Right | Locked meaning |
|---|---|---|---|
| FACT | ≠ | SKILL | verified proposition ≠ executable/reusable procedure |
| FACT | ≠ | EPISODE | verified proposition ≠ temporal experience record |
| FACT | ≠ | FAILURE | verified proposition ≠ typed failure experience |
| FACT | ≠ | WEIGHT | verified proposition ≠ learned utility/policy parameter |
| ALIAS | ≠ | IDENTITY | human label ≠ stable native identity |
| KIND | ≠ | ROLE | intrinsic semantic kind ≠ contextual frame role |
| CANDIDATE | ≠ | VERIFIED | proposal/evidence candidate ≠ promoted knowledge |
| OBSERVATION | ≠ | VERIFIED_FACT | measurement/event ≠ verified proposition |
| PREDICTION | ≠ | TRUTH | model expectation ≠ observed/verified state |
| CORRELATION | ≠ | CAUSATION | association ≠ intervention-supported causal claim |
| UTILITY | ≠ | TRUTH | ranking/preference score ≠ evidence validity |
| CACHE_HOTNESS | ≠ | PROOF | access frequency ≠ evidentiary support |
| TOP_K | ≠ | ANSWER | selected candidates ≠ ASTRA-authorized result |
| SEARCH_INCOMPLETE | ≠ | UNKNOWN | bounded search exhausted ≠ complete-scope no-support result |
| PHYSICAL_PLACEMENT | ≠ | EPISTEMIC_CLASS | LUT/BRAM/DDR location ≠ FACT/SKILL/etc. |
| LOGICAL_TICK | ≠ | PHYSICAL_CLOCK | semantic ordering ≠ FPGA cycle identity |

## 20.2 Subsystems and authority

| Term | Definition |
|---|---|
| **NSPF** | Native Semantic Pulse Fabric — forward research architecture name |
| **NCG** | Native Cognitive Graph — exact typed retrieval/indexed bounded traversal substrate |
| **Q\*** | Macro strategy selector: retrieve/search/observe/act/ask/submit/stop under legal masks |
| **SPEAR** | Micro ranker for legal candidates/targets; ranking is not truth |
| **FEM** | Failure Experience Memory — DUT/runtime failure episodes/prototypes and recovery history |
| **Skill Engine** | Stores/executes parameterized procedures with lifecycle CANDIDATE→LEARNED→VERIFIED→STABLE→COMPACTED→REOPENED |
| **ASTRA** | Deterministic authority boundary under encoded rules/evidence for legality, proof validity, provenance, conflict, completeness, epistemic status and knowledge promotion |
| **GEMINI** | Human-symbol/language expression adapter; may render/explain but cannot create/override ASTRA truth/status |
| **Working Mind** | Active bounded cognitive process combining NCG, Q*, SPEAR, Skill, FEM and working state |
| **Capability Binding** | Mapping from semantic ACTION_INTENT/capability class to a verified installed hardware capability; no binding means no physical action |

ASTRA is **not an omniscient truth oracle**. It certifies only what the active
rules, evidence, provenance and declared search scope justify.

## 20.3 Physical memory tiers

| Term | Technical definition |
|---|---|
| **T0** | Immutable Semantic Control Plane — fixed logic/ROM/FF for primitives, protocol/schema, routing, legality/safety and ASTRA control laws; optional separately-certified specialization |
| **T1** | Hot Cognitive Working Store — BRAM/LUTRAM for active query/bindings/frontier, caches, proof scratch, hot skill/policy state, FIFOs |
| **T2** | Canonical Cognitive Memory — DDR/HBM bulk storage for semantic records, postings, candidates, episodes, failures, skills, checkpoints and archives |
| **Placement** | Current physical residence/copy of an object |
| **Epistemic class** | Logical class such as VERIFIED_FACT, CANDIDATE_FACT, EPISODE, SKILL, FAILURE, POLICY_WEIGHT |

Biological labels such as *instinct*, *muscle memory* and *long-term memory* are
optional explanatory metaphors only. They are not ABI types and do not determine
truth status.

## 20.4 Core records

| Term | Definition |
|---|---|
| **Node** | Typed semantic identity with stable reference, namespace/generation and metadata |
| **Edge** | Typed relation with direction, context/status/provenance references |
| **Value** | First-class typed scalar/range/enum/reference; never collapsed to sentinel node 0 |
| **Context** | Explicit applicability/condition scope |
| **Provenance** | Source/revision/location/acquisition metadata and evidence ancestry |
| **Posting list/page** | Indexed adjacency references used to avoid whole-graph scans |
| **QueryRecord** | Native binary request, currently R0.1 candidate in [§04] |
| **StructuredResult** | Native machine result including status/reason/answer/proof/provenance/context/conflict fields [§04] |
| **SemanticEvent** | Temporal/event packet carrying explicit logical ordering [§04] |
| **Knowledge Pack** | Versioned runtime-loadable binary semantic package with manifest/regions/integrity metadata |
| **ProofObject** | Machine-verifiable support path/rule/provenance object for ASTRA status decisions |
| **ModuleManifest** | Capability-module identity/version/bus/schema/fault/safety contract [§05] |

## 20.5 Result/status semantics

| Code | Meaning |
|---|---|
| `ANSWER` | Declared evidence/proof supports an answer within the active contract |
| `UNKNOWN` | Search is complete for the declared scope and no verified support is found |
| `CONFLICT` | Mutually incompatible relevant support exists and cannot be lawfully collapsed |
| `SEARCH_INCOMPLETE` | Search/proof budget ended before completeness was established |
| `UNSUPPORTED_QUERY` | Query/operator/capability is outside implemented contract |
| `DATA_INTEGRITY_FAIL` | Active data/pack/generation/integrity contract failed |
| `PARSE_ERROR` | Human-adapter parsing/resolution failed; adapter-level, not semantic UNKNOWN |

Transport faults (`CRC_ERROR`, `SEQ_GAP`, `DUPLICATE_FRAME`, overflow, stale
session/generation, unsupported ABI) are protocol statuses and must not be
silently mapped to `UNKNOWN`.

## 20.6 Relation semantics

`IS_A`, `PART_OF`, `USES`, `HAS_STATE`, `NAMED_AS`, `BEFORE`, `AFTER`,
`CORRELATES_WITH`, `CAUSES`, `ACHIEVES`, `FAILED_AT`, `CAN_DO`, `ACTS_ON`,
`CHANGES`, `OBSERVED_BY`, `COMPOSES` remain separate relation identities.

Critical laws:

```text
NAMED_AS != IS_A
CORRELATES_WITH != CAUSES
ACHIEVES != PROVES
FAILED_AT != ILLEGAL
```

## 20.7 Evidence labels

| Label | Meaning |
|---|---|
| **[SOURCE-SUPPORTED]** | Explicitly supported by a cited project/source artifact |
| **[ESTABLISHED]** | Supported by authoritative external or measured evidence |
| **[SUPPORTED]** | Strong design synthesis but not itself an implementation result |
| **[HYPOTHESIS]** | Preregisterable proposition requiring experiment |
| **[SPECULATIVE]** | Longer-range possibility with insufficient evidence |
| **[FALSIFIED]** | Rejected by current evidence/contract |
| **[NOT EVIDENCED]** | No sufficient evidence in the audited source set |

## 20.8 Hardware constants for Arty A7-100T

Canonical board/device facts are owned by [§23]. Short form:

```text
XC7A100T-CSG324-1
63,400 LUTs
126,800 FFs
240 DSP48E1
135 BRAM36 ≈ 607.5 KiB raw block RAM
256 MB DDR3L
16-bit physical DDR bus
~333 MHz memory clock / ~667 MT/s effective
~1.334 GB/s theoretical peak transfer, not measured graph throughput
```

No random-access latency or semantic-query throughput number is locked until
measured on the exact MIG/workload.

## Tóm tắt tiếng Việt

Các bất biến semantic và authority được khóa rõ: dữ liệu logic không được đồng
nhất với nơi lưu vật lý; Top-K không phải câu trả lời; prediction/observation
không tự trở thành truth; UNKNOWN chỉ hợp lệ sau khi hoàn tất phạm vi search đã
khai báo. T0/T1/T2 là tầng vật lý, không phải loại trí nhớ nhận thức.


---

## SOURCE DOCUMENT: `01_MASTER_ARCHITECTURE.md`

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
                T1 WORKING MEMORY
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

Persistent typed records representing stable knowledge:

| Record Type | Contents |
|------------|----------|
| **Node** | Stable ID, KIND, CLASS, STATE, generation |
| **Edge** | Source ID, relation type, destination ID, context, provenance |
| **Value** | Typed payload (numeric, enum, composite) |
| **Context** | Spatial, temporal, conditional scope |
| **Provenance** | Origin (teacher, sensor, inference), timestamp, confidence |

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

Semantic time uses explicit logical ticks, not physical FPGA clock. Clock frequency and jitter are implementation noise, not semantic identity.

## 1.5 Working Mind

The active cognitive process combining:

| Component | Function | Reference |
|-----------|----------|-----------|
| **NCG** (Native Cognitive Graph) | Exact retrieval via directory/posting lookup | [§02] |
| **Q*** | Macro strategy selection: retrieve, search, observe, act, ask teacher, submit, stop | [§10] |
| **SPEAR** | Ranking legal candidates or targets within chosen strategy | [§10] |
| **Skill Engine** | Executing reusable verified procedures | [§12] |
| **FEM** | Failure Experience Memory — typed failure, recovery, regression detection | [§11] |

## 1.6 Authority Partition

This partition is **locked** and must not be violated:

| Layer | Authority | Question It Answers |
|-------|-----------|-------------------|
| **Q*** | Macro strategy | "What should I do next?" |
| **SPEAR** | Candidate/target ranking | "Which candidate should I inspect first?" |
| **Skill Engine** | Procedure execution | "How do I execute this reusable procedure?" |
| **FEM** | Failure memory | "What failed before, how was it repaired?" |
| **ASTRA** | Legality, proof, status, promotion | "Is this legal? Is evidence adequate? Any conflict?" |
| **GEMINI** | Human expression | "How do I express the structured result to a human?" |

**No layer may usurp the authority of another.**

Critical rules:
- Host truth/proof authority = 0. The host may perform frozen alias/intent/unit normalization and construct QueryRecord IDs, but cannot inject answer, winner, proof, provenance, or hidden graph reasoning.
- Q* chooses macro action, not truth.
- SPEAR ranks, does not override proof legality.
- Score does not override proof legality.
- GEMINI expresses results but does not create truth and does not drive actuators directly.
- Teacher does not write weights directly.
- Candidate, episode and failure memory do not self-promote to verified fact.
- `SEARCH_INCOMPLETE != UNKNOWN`.

## 1.7 Physical Action / Capability Boundary

Semantic reasoning never drives an actuator directly. The physical action path is:

```text
Q*/Skill ACTION_INTENT
  -> ASTRA legality/safety precheck
  -> Capability Binding
  -> verified Primitive Executor
  -> physical hardware action
  -> readback / observed effect
  -> Temporal Event / Episode
```

A `CapabilityDescriptor` identifies what the installed hardware can actually do. If a semantic
action has no compatible capability binding, no physical action is issued. This boundary prevents
knowledge-pack semantics or GEMINI text from becoming direct electrical control. See [§05].

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
- 6W1H may be a compact query-operator algebra, not an English ontology.
- Logical semantic ticks carry order/time meaning; FPGA clock rate does not.
- Jitter is verification noise unless represented explicitly as data.
- Long-term knowledge is virtualized in DDR/HBM; one circuit per semantic unit is rejected.
- BRAM is a managed hot/working store, not a truth tier.
- Promotion across memory tiers changes placement, not epistemic status.
- ASTRA remains the authority for legality, proof, conflict, completeness and promotion.
- Semantic action intent must pass capability binding and verified primitive execution before any actuator command.
- Prediction/association may propose candidates but never establishes truth.

## Tóm tắt tiếng Việt

Kiến trúc NSPF gồm hai mặt phẳng: Binary Semantic Plane (tri thức tĩnh: node, edge, value, context, provenance) và Temporal Event Plane (sự kiện động: state, action, reward, episode). Working Mind kết hợp NCG + Q* + SPEAR + Skill + FEM. ASTRA là authority cuối cùng cho mọi proof/status/promotion. Ngôn ngữ tự nhiên chỉ là adapter — không phải substrate nhận thức. Mỗi layer có authority riêng, không được xâm phạm layer khác.


---

## SOURCE DOCUMENT: `02_MEMORY_STRATIFICATION.md`

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

**Function**: Working Memory + Hot Cache + Hot Procedural Memory.

These three are logically different but share the same physical tier:
1. **Working Memory** — transient query/binding state
2. **Hot Cache** — frequently accessed T2 records
3. **Hot Procedural Memory** — currently active skills

If you want to call this "muscle memory", reserve the metaphor for learned/verified/reusable **skills only**, not for all of BRAM.

### T2 — Canonical Cognitive Memory Store

**Physical**: DDR3L (256 MB on Arty A7-100T).

**Contains**:
- Nodes, Edges, Values, Contexts, Provenance records
- Forward posting lists (node → outgoing edges)
- Reverse posting lists (node → incoming edges)
- Candidate facts (unverified)
- Episodes (temporal experience)
- Failures (typed failure records)
- Skills (verified procedures)
- Policy checkpoints (Q*/SPEAR learned state)
- Long-term learning state
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

## 2.4 Hot Directory ABI (Candidate)

Each BRAM directory entry is a **placement/index record**, not a duplicate truth record. A 128-bit R0.1 candidate is:

| Field | Bits | Description |
|---|---:|---|
| semantic_id | 24 | Arty MVP active-range ID; full wire field remains 32-bit [§04] |
| generation | 16 | Active knowledge generation tag |
| kind | 8 | Node kind/type code |
| fwd_descriptor_ptr | 28 | Byte address/reference within 256-MB T2 space |
| rev_descriptor_ptr | 28 | Reverse-posting descriptor address/reference |
| flags | 8 | valid/pinned/dirty/prefetch metadata |
| integrity_tag | 8 | cache-entry integrity/version tag |
| namespace_tag | 8 | compact namespace/cache partition tag |
| **Total** | **128** | |

Epistemic status/proof is not inferred from cache residency. Canonical semantic state remains in the referenced record and is generation-checked.

A hypothetical directory occupying every BRAM bit would be misleading; T1 also contains working memory, FIFOs, proof scratch, postings, skills and learner state. Directory capacity must therefore be budgeted from post-synthesis allocation, not from raw-BRAM division alone.

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

A procedure MAY become hardware-accelerated ("reflex"), but this requires a full bitstream rebuild. The FPGA does not "grow new LUTs" autonomously.

## Tóm tắt tiếng Việt

Bộ nhớ chia 3 tầng vật lý: T0 (LUT — logic cố định), T1 (BRAM — working memory + cache nóng, 607.5 KiB), T2 (DDR3L — bộ nhớ chính, 256 MB). Quy tắc bất biến: di chuyển giữa T1↔T2 chỉ thay đổi vị trí vật lý, KHÔNG thay đổi trạng thái tri thức (FACT vẫn là FACT). DDR peak 1.334 GB/s nhưng random access chậm hơn nhiều — phải benchmark. BRAM cache cải thiện hiệu năng nhưng không ảnh hưởng tính đúng đắn.


---

## SOURCE DOCUMENT: `04_ABI_AND_PROTOCOL.md`

# §04 — ABI AND PROTOCOL

> Versioned binary interfaces for Native AI. This document separates semantic
> identity from transport details and preserves transaction/generation lineage.

## 4.1 Design Principles

1. FPGA-side cognition consumes **typed binary records**, not human-language text.
2. The host adapter may resolve aliases/intent into IDs and construct `QueryRecord`.
3. The host must not inject answer, winner, proof, provenance, or hidden graph reasoning.
4. Every externally committed transaction carries transaction identity and generation.
5. Transport retry must be idempotent and must not double-commit learning or pack state.
6. Protocol faults are never converted into semantic `UNKNOWN`.
7. Exact bit widths are ABI-versioned implementation choices, not ontology.

## 4.2 Semantic ID Width Policy

R0.1 uses **32-bit fields for semantic references** on the wire. The Arty MVP may
restrict the currently allocated ID range (for example to 24 significant bits),
but unused upper bits must be zero and checked.

This avoids making a 24-bit Arty implementation limit into a permanent semantic
identity law. Any future incompatible widening or reinterpretation requires an ABI
major-version change.

## 4.3 QueryRecord R0.1 — 256 bits / 32 bytes

| Field | Bits | Description |
|---|---:|---|
| magic | 16 | Query record magic |
| abi_version | 8 | ABI version |
| flags | 8 | proof/provenance/inference requirements |
| txn_id | 32 | End-to-end transaction identity |
| generation | 16 | Required active knowledge generation |
| namespace_id | 16 | Semantic namespace |
| query_meta | 16 | query-op, direction, object-valid, max-hops |
| subject_id | 32 | Subject semantic ID |
| relation_id | 16 | Relation ID |
| object_ref | 32 | Object/constraint reference; interpretation from meta |
| context_id | 32 | Context reference |
| search_budget | 16 | Explicit bounded-work budget |
| crc16 | 16 | CRC over preceding record fields |
| **Total** | **256** | **32 bytes** |

`query_meta` is an ABI field, not an English grammar field. A candidate packing is:

```text
[15:12] operation class   DIRECT / REVERSE / MULTIHOP / CONSTRAINT / ...
[11:10] direction
[9]     object_valid
[8:5]   max_hops
[4:2]   native query operator (WHAT/WHO/WHERE/WHEN/WHY/WHICH/HOW)
[1:0]   reserved
```

## 4.4 StructuredResult R0.1 — 384 bits / 48 bytes

| Field | Bits | Description |
|---|---:|---|
| magic | 16 | Result record magic |
| abi_version | 8 | ABI version |
| status | 8 | ASTRA epistemic status |
| reason_code | 8 | Machine reason, not prose |
| answer_kind | 8 | NONE / ENTITY / VALUE / RANGE / PROCEDURE / PROOF_PATH |
| completeness | 8 | COMPLETE / PARTIAL / NOT_APPLICABLE |
| flags | 8 | Result flags |
| txn_id | 32 | Exact query transaction identity |
| generation | 16 | Knowledge generation used |
| namespace_id | 16 | Semantic namespace |
| answer_ref | 32 | Primary answer reference |
| value_lo | 32 | Typed value payload low/scalar |
| value_hi | 32 | Range high/auxiliary payload |
| proof_ref | 32 | Proof object reference |
| provenance_ref | 32 | Provenance root/reference |
| context_ref | 32 | Context used/resolved |
| conflict_ref | 32 | Conflict object/reference |
| answer_count | 8 | Number of answer items in optional payload |
| payload_words | 8 | Optional payload length |
| crc16 | 16 | CRC over fixed header |
| **Total** | **384** | **48 bytes** |

Optional payload records may follow, but the fixed header always preserves the
status/proof/provenance/conflict identity needed by the GOAL.

## 4.5 SemanticEvent R0.1 — 192 bits / 24 bytes

```text
191:184 event_type
183:176 semantic_kind
175:168 role
167:160 flags
159:128 semantic_id
127:96  value_or_ref
95:64   logical_tick
63:32   context_id
31:16   source_id
15:0    sequence_id
```

Logical tick and sequence ID are meaning/order metadata. Physical FPGA cycle count is
performance/debug metadata only.

## 4.6 Knowledge Pack Manifest

The previous draft called a set of fields totaling more than 64 bytes a "64-byte
PackHeader". That arithmetic is invalid. R0.1 replaces it with a **128-byte fixed
manifest header plus a region-descriptor table**.

### 128-byte ManifestHeader candidate

```text
magic                 4 B
manifest_version      2 B
abi_version           2 B
schema_version        2 B
flags                 2 B
generation            4 B
node_count            4 B
edge_count            4 B
value_count           4 B
context_count         4 B
provenance_count      4 B
region_count          4 B
schema_sha256        32 B
content_sha256       32 B
page_size             4 B
header_length         2 B
page_crc_scheme       2 B
manifest_crc32        4 B
reserved             16 B
-------------------------
TOTAL                128 B
```

`RegionDescriptor[]` follows the header and defines typed region offset, size,
record width/count, and integrity metadata for Node/Edge/Value/Context/Provenance,
forward postings, reverse postings, proof/archive data, etc.

## 4.7 Integrity Evidence Levels

Do not claim `FPGA_SHA256_VERIFIED` unless SHA-256 is actually implemented and tested
on FPGA. Distinguish:

```text
HOST_SHA256_VERIFIED
FPGA_MANIFEST_ID_VERIFIED
FPGA_PAGE_CRC_VERIFIED
FPGA_SENTINEL_READBACK_VERIFIED
```

A host-verified SHA plus FPGA page CRC/readback is valid evidence if labeled honestly.

## 4.8 Runtime Pack Transaction

```text
HELLO/CAPABILITIES
  -> BEGIN_PACK(manifest)
  -> ABI/schema/generation precheck
  -> DATA_PAGE(seq, region, offset, payload, CRC)
  -> page ACK/NAK
  -> END_PACK
  -> write-drain complete
  -> sentinel readback
  -> integrity verification
  -> COMMIT_GENERATION
  -> atomic active-generation flip
```

`ACK_LOAD` is forbidden until all accepted writes have drained to the memory
controller completion point defined by the implementation contract.

## 4.9 UART Transport R0.1

Laboratory baseline may use 115200-8-N-1. Baud rate is a transport parameter and may
change without semantic change.

Recommended frame:

```text
[SOF16] [PROTO_VER8] [FRAME_TYPE8] [LENGTH16] [SEQ16]
[PAYLOAD N bytes]
[CRC16]
```

Length and CRC make a dedicated EOF byte unnecessary. The transport uses explicit
ACK/NAK/sequence handling and host pacing. Do not assume RTS/CTS wiring or XON/XOFF
support unless separately verified for the board path.

Timeouts are operation-specific. A transport timeout is a protocol/transport failure,
not semantic `UNKNOWN`.

## 4.10 Human-Language Boundary

Current architecture decision:

```text
Human text
 -> Host Adapter
 -> frozen/preregistered alias + intent mapping
 -> QueryRecord IDs/codes
 -> UART
 -> FPGA
 -> StructuredResult
 -> Host Renderer
 -> Human text
```

Allowed host work:
- tokenization/parsing;
- alias lookup;
- unit normalization;
- query-operator and direction resolution;
- `QueryRecord` construction;
- result rendering.

Forbidden host work:
- answer lookup;
- graph traversal to choose the winner;
- proof construction;
- provenance fabrication;
- benchmark answer injection.

## 4.11 Protocol Faults

Examples:

```text
CRC_ERROR
SEQ_GAP
DUPLICATE_FRAME
STALE_GENERATION
UNSUPPORTED_ABI
FIFO_OVERFLOW
TRANSPORT_TIMEOUT
```

These are protocol/system outcomes and must not be silently mapped to `UNKNOWN`.

## Tóm tắt tiếng Việt

ABI R0.1 bổ sung `txn_id`, `generation`, namespace, proof/provenance/conflict refs và
completeness. QueryRecord là 256 bit, StructuredResult 384 bit, SemanticEvent 192 bit.
Pack manifest được sửa thành 128 byte vì header 64 byte cũ sai phép tính. UART dùng
framing nhị phân có seq/CRC; host được phép map alias→ID nhưng không được suy luận ra
answer/proof thay FPGA.


---

## SOURCE DOCUMENT: `05_CAPABILITY_AND_ACTION_BINDING.md`

# §05 — CAPABILITY AND ACTION BINDING

> Bridge between semantic intent and physical hardware. Knowledge and language do
> not directly drive pins, buses, motors, relays, or actuators.

## 5.1 Purpose

Native AI may reason about an action semantically, but execution is legal only if a
compatible installed hardware capability exists and the safety/legality contract passes.

```text
Semantic ACTION_INTENT
  -> capability-class resolution
  -> installed capability lookup
  -> version/schema compatibility
  -> ASTRA legality/safety precheck
  -> primitive executor binding
  -> physical command
  -> readback / observed effect
```

If any step fails, no actuator command is issued.

## 5.2 CapabilityDescriptor

Candidate canonical descriptor:

```text
CapabilityDescriptor {
  capability_id
  capability_class
  instance_id
  version
  interface_type
  primitive_mask
  input_schema_ref
  command_schema_ref
  status_schema_ref
  fault_schema_ref
  timing_contract_ref
  safety_contract_ref
  executor_index
  knowledge_pack_dependency_ref
  flags
  crc
}
```

The descriptor states what hardware exists and what primitive operations are legal. It
must not contain semantic winners, preferred actions, benchmark answers, or learned truth.

## 5.3 Module Manifest

A physical module may expose a manifest such as:

```text
MODULE_ID
MODULE_VERSION
CAPABILITY_CLASS
INPUT_SCHEMA
OUTPUT_SCHEMA
COMMAND_SCHEMA
FAULT_SCHEMA
TIMING_CONTRACT
SAFETY_CONTRACT
KNOWLEDGE_PACK_DEPENDENCIES
INTEGRITY_ID
```

Runtime discovery is allowed only for capabilities implemented by already-certified
generic physical interfaces. New electrical interfaces may still require new RTL and a new
bitstream lineage.

## 5.4 Action Binding

Example:

```text
semantic action: REDUCE_COMPRESSOR_FREQUENCY
        -> CAPABILITY_CLASS = COMPRESSOR_CONTROL
        -> installed instance COMPRESSOR_V1
        -> primitive SET_FREQ(parameter)
        -> safety veto check
        -> executor
        -> readback
```

If `COMPRESSOR_CONTROL` is absent or incompatible:

```text
NO_BINDING -> NO_ACTION
```

The knowledge pack cannot invent a capability that the board does not physically possess.

## 5.5 Safety Boundary

GEMINI, Human Adapter, Teacher, Q*, SPEAR and Skill memory cannot bypass the physical
safety path.

```text
GEMINI text -> actuator                    FORBIDDEN
Teacher candidate -> actuator              FORBIDDEN
SPEAR top score -> actuator                 FORBIDDEN

Q*/Skill intent
 -> ASTRA legality
 -> safety veto
 -> capability binding
 -> primitive executor                     REQUIRED
```

## 5.6 Readback and Causal Identity

An issued command is not evidence that the physical effect occurred. Every learning-capable
action lane must preserve:

```text
episode_id
step_id
capability_id / instance
primitive/action parameters
state_before
command accepted
observed_effect/readback
state_after
reward source
logical tick
generation/policy versions
```

Only executed actions with attributable observed outcomes are eligible for causal credit.

## 5.7 Plug-and-Play Scope

Long-range product goal:

```text
fixed Native AI core
+ generic verified I/O blocks
+ runtime capability descriptors
+ runtime knowledge packs
```

This may support data-driven sensor/actuator additions without resynthesis **only where the
required physical interface already exists in the bitstream**. Otherwise a new RTL artifact is
required.

## 5.8 Acceptance Tests

Minimum tests before physical-action claims:

1. `CAPABILITY_ENUM_PASS` — installed capability inventory exact.
2. `NO_BINDING_NO_ACTION_PASS` — absent capability cannot execute.
3. `SAFETY_VETO_PASS` — illegal command is blocked.
4. `COMMAND_READBACK_PASS` — command and observed effect distinguished.
5. `STALE_DESCRIPTOR_REJECT_PASS` — version/generation mismatch rejected.
6. `GEMINI_NO_ACTUATOR_AUTHORITY_PASS` — language path cannot drive executor.
7. `UNEXECUTED_NO_CREDIT_PASS` — non-executed action gets no learning update.

## Tóm tắt tiếng Việt

§05 bổ sung lớp còn thiếu giữa suy luận semantic và phần cứng thật. Native AI chỉ phát
`ACTION_INTENT`; muốn tác động thiết bị phải qua capability descriptor, ASTRA/safety,
binding tới primitive executor và readback. Knowledge Pack hoặc GEMINI không thể tự biến
một ý nghĩa thành tín hiệu điện nếu capability tương ứng không tồn tại.


---

## SOURCE DOCUMENT: `03_ASTRA_AUTHORITY.md`

# §03 — ASTRA AUTHORITY

> ASTRA is the deterministic authority boundary for legality, proof validity, provenance,
> conflict, completeness, epistemic status and knowledge promotion under the implemented
> rules/evidence contract. It is not an omniscient truth oracle. No other subsystem may
> override or bypass it.

## 3.1 ASTRA's Role

ASTRA answers one set of questions:

> Is this legal? Is the evidence adequate? Is there conflict?
> What epistemic status may be emitted? Can this candidate be promoted?

ASTRA does **not** answer:
- "What should I do next?" → Q* [§10]
- "Which candidate first?" → SPEAR [§10]
- "How do I execute this?" → Skill Engine [§12]
- "How do I say this to a human?" → GEMINI / Language Adapter [§01.7]

## 3.2 Epistemic Status Codes

ASTRA must emit exactly one of these statuses for every query resolution:

| Status | Meaning |
|--------|---------|
| `ANSWER` | Evidence supports a definite answer with proof trace |
| `UNKNOWN` | Search completed for the declared scope and found no verified support |
| `CONFLICT` | Contradictory evidence exists; cannot resolve |
| `SEARCH_INCOMPLETE` | Budget exhausted before all candidates examined |
| `UNSUPPORTED_QUERY` | Query type not supported by current system |
| `DATA_INTEGRITY_FAIL` | Knowledge pack CRC/hash mismatch or corruption |

The adapter layer may additionally emit:
| Status | Meaning |
|--------|---------|
| `PARSE_ERROR` | Input text could not be parsed into a valid QueryRecord |

**Critical distinctions**:
- `SEARCH_INCOMPLETE ≠ UNKNOWN`: If Top-K budget dropped a needed candidate, the system must say "I ran out of budget" not "I don't know."
- `CONFLICT ≠ UNKNOWN`: Having contradictory evidence is different from having no evidence.
- `ANSWER` requires a proof trace — not just a score.
- If the search budget is exhausted before required completeness is established, status is `SEARCH_INCOMPLETE`, never `UNKNOWN`.

## 3.3 Proof Objects

Every `ANSWER` status must be accompanied by a proof object containing:

```text
ProofObject:
  query_id:        reference to original QueryRecord
  answer_ref:      ID of the answer node/edge/value
  support_chain:   ordered list of edges/relations traversed
  provenance_refs: origin of each supporting piece of evidence
  context_match:   which context constraints were satisfied
  generation:      knowledge generation number at proof time
  timestamp:       logical tick of proof creation
```

## 3.4 What ASTRA Checks

For every candidate answer or promotion request, ASTRA verifies:

1. **Legality** — Does this operation comply with schema/ABI rules?
2. **Evidence** — Is the support chain present and complete?
3. **Provenance** — Where did each piece of supporting evidence come from?
4. **Conflict** — Does any existing verified knowledge contradict this?
5. **Completeness** — Has the search covered all required paths within budget?
6. **Epistemic Status** — What status code should be emitted?

## 3.5 Knowledge Promotion Rules

Knowledge promotion follows a strict pipeline:

```text
Teacher proposal / Sensor observation / Self-experience
         ↓
CANDIDATE record (with provenance attached)
         ↓
Verification against existing knowledge
         ↓
 ┌───────┼────────┐
 ↓       ↓        ↓
VERIFY  REJECT  CONFLICT
 ↓
generation commit (version increment)
 ↓
future retrieval as VERIFIED
```

**Locked rules**:
- Teacher CANNOT directly write FACT — teacher input creates CANDIDATE only
- Teacher CANNOT set weights
- Teacher CANNOT send proof
- Teacher CANNOT declare a winner
- Raw sensor input creates `OBSERVATION`/`EPISODE` evidence. A derived concept/relation may become a CANDIDATE; observation is not automatically a VERIFIED_FACT
- Self-experience creates EPISODE and CANDIDATE relations
- ASTRA may promote runtime `CANDIDATE → VERIFIED` only under the certified knowledge-promotion contract
- Project artifact promotion/freeze is a separate governance action; only the project owner may authorize final artifact promotion/freeze

## 3.6 UNKNOWN Does Not Auto-Trigger Teacher

The draft rule "UNKNOWN → ASK_TEACHER" is **incorrect**. The correct flow:

```text
MISSING / UNKNOWN / INCOMPLETE
            │
            ▼
         Working Mind
            │
      Q* chooses strategy
   ┌────────┼────────┐
   ▼        ▼        ▼
retrieve observe  ask teacher
   │        │        │
   └────────┼────────┘
            ▼
         candidate
```

`ASK_TEACHER` is only valid when:
- Teaching mode is enabled
- Policy permits asking
- Identity/pending context is valid

Teacher returns `CANDIDATE`, not `FACT`.

## 3.7 Authority Boundaries

| Component | Can Create | Cannot Create |
|-----------|-----------|---------------|
| Q* | Strategy choice | Truth, proof |
| SPEAR | Ranking score | Truth, proof, legality override |
| Teacher | CANDIDATE knowledge | FACT, weight, proof |
| Sensor | CANDIDATE concept, observation | FACT |
| FEM | Failure record, recovery | FACT promotion |
| Cache/Hotness | Placement change | Epistemic status change |
| GEMINI | Human-language rendering | Truth, knowledge |
| Predictor/HDC/association sidecar | Candidate hints/predictions | Truth, proof, legality |

**No component may override ASTRA's authority.**

## 3.8 Top-K Is Not Answer

A critical distinction that must be maintained:

```text
candidate generation
       ↓
SPEAR / relevance ranking
       ↓
Top-K candidates
       ↓
ASTRA verification
       ↓
proof + provenance + context
       ↓
ANSWER / UNKNOWN / CONFLICT / ...
```

If Top-K drops a needed candidate due to budget:
→ Emit `SEARCH_INCOMPLETE`, not `UNKNOWN`.

`Candidate Top-K ≠ ANSWER`. Scores do not substitute for proof.

## Tóm tắt tiếng Việt

ASTRA là authority cuối cùng cho mọi quyết định về tính hợp lệ, bằng chứng, provenance, xung đột và trạng thái tri thức. Mọi câu trả lời phải kèm proof trace. Hệ thống phân biệt rõ 6 trạng thái: ANSWER, UNKNOWN, CONFLICT, SEARCH_INCOMPLETE, UNSUPPORTED_QUERY, DATA_INTEGRITY_FAIL. Teacher chỉ tạo CANDIDATE, không bao giờ tạo FACT trực tiếp. Không component nào được phép vượt quyền ASTRA.


---

## SOURCE DOCUMENT: `13_INFORMATION_NEURONALIZATION.md`

# §13 — INFORMATION NEURONALIZATION

> The core research hypothesis of Native AI.
> What "neuronalizing information" means, what it does NOT mean,
> and how to falsify or support it.

## 13.1 The Hypothesis

> **Information Neuronalization:** explicit semantic objects act as virtual
> neuron-like persistent units; typed relations act as explicit connectivity
> (semantic synapses); and sparse event-driven activation operates only on
> the currently relevant working set.

This is an **engineering abstraction**, not a claim that information literally becomes a biological neuron.

## 13.2 What It Means

| Biological Analogy | NSPF Implementation |
|-------------------|---------------------|
| Neuron | Semantic Unit — virtual, persistent, addressable typed object |
| Synapse | Typed Relation — explicit, typed edge between nodes |
| Activation | Active Frontier — current sparse set of activated nodes |
| Neural pulse | Semantic Event — logical event triggering state changes |
| Working memory | Temporary activated/bound state in T1 BRAM |
| Long-term memory | Persistent graph in T2 DDR |

## 13.3 What It Does NOT Mean

- ❌ Each fact physically maps to one neuron (LUT) — rejected as scaling strategy
- ❌ The entire knowledge base fires simultaneously — only working set activates
- ❌ FPGA "grows new LUTs" — hardware specialization requires full bitstream rebuild
- ❌ Physical clock frequency carries semantic meaning — semantic time uses logical ticks
- ❌ Jitter is part of the semantic alphabet — jitter is implementation noise
- ❌ English morphology (is/am/are) is silicon ontology — language adapter normalizes
- ❌ Noun/verb/adjective get different bit widths — TYPE, ID, ROLE are independent

## 13.4 What Makes It Different from a Graph Database

The strongest engineering baseline is not only an LLM; it is also a conventional indexed graph engine. NSPF must demonstrate value from working-state activation, learning, grounding, proof/status governance or hardware behavior beyond ordinary `load → lookup → print`.

If the system only does:
```text
load graph → lookup edge → print result
```
then it is a **hardware knowledge engine**. Useful, but not Native AI.

The strong hypothesis requires demonstrating:

| Capability | Test |
|-----------|------|
| **Masked slot reconstruction** | Hide a frame slot while keeping the supporting graph intact; reconstruct a candidate from structure |
| **ID permutation invariance** | Swap all IDs, behavior unchanged |
| **Unseen-instance transfer** | Skill learned on instance A works on new instance B |
| **Structural rule transfer** | Rules from 4-bit system transfer to 8-bit system |
| **Sensor grounding** | Concept formed from sensor data before human alias |
| **Causal ablation** | Remove supporting evidence → answer changes |
| **Reset/restore** | Clear learned state → baseline returns; restore → learned behavior returns |
| **False teacher resistance** | Teacher provides wrong info → system does not blindly accept |
| **Cache invariance** | Cache on/off → same semantic results |

If these tests PASS across preregistered holdouts, information neuronalization gains empirical support beyond lookup alone.
If the claimed transfer/grounding tests repeatedly fail and success depends on exact IDs, task-specific FSMs or host-side reasoning, the strong form of the hypothesis is materially weakened; the remaining system may still be a useful hardware knowledge/reasoning engine.

## 13.5 The Contrast with Modern AI

**[ESTABLISHED]** The contrast must not be caricatured as "LLMs have no explicit memory." Modern retrieval-augmented models combine parametric models with external memory.

The correct contrast is with **weight-centric cognition**:

| Property | Weight-Centric (LLM) | Information Neuronalization (NSPF) |
|----------|----------------------|-------------------------------------|
| Knowledge storage | Large share of capability/knowledge can be parametric; many modern systems also use external memory | Verified semantic knowledge is represented explicitly; learned policy/skill weights remain separate |
| Retrieval | Attention/association and, in retrieval-augmented systems, external retrieval | Exact directory/posting retrieval on the proof-critical path |
| Provenance | Often weak for parametric recall; external retrieval can provide source metadata | Provenance is a first-class semantic record and proof dependency |
| Update | Model updates may require fine-tuning; external stores can also update incrementally | Explicit records can update incrementally; learned policies remain separately versioned |
| Uncertainty | Probabilistic/model-specific plus application controls | Explicit epistemic status contract for supported query classes |
| Compositionality | Learned/emergent and tool-augmented | Explicit role binding + bounded operators; transfer remains a hypothesis |

**[HYPOTHESIS]** NSPF is worth developing only if it beats simpler alternatives on: causal traceability, incremental update cost, deterministic provenance, transfer across IDs/instances, memory-access efficiency for sparse queries, and bounded hardware behavior.

## 13.6 Dense Neural Models Are Not Enemies

Dense neural computation may exist at the perception/language boundary:

```text
neural output ≠ truth
```

Neural models are allowed as:
- Perception adapters (image → semantic records)
- Language adapters (text → QueryRecord, StructuredResult → text)
- Association hint generators (suggest candidates for SPEAR ranking)

Neural/predictive sidecars obey `PREDICTION != TRUTH`.

Neural models are NOT allowed as:
- Hidden truth engines
- ASTRA bypass mechanisms
- Direct knowledge creators

If useful transfer requires reintroducing a large dense model into the CORE, the strong form of the hypothesis has failed.

## 13.7 "GOAL COMPLETE" Definition

The project vision is NOT proved by:
- ❌ FPGA answers one question correctly
- ❌ LED lights up
- ❌ Bitstream programs successfully

The end-state vision becomes **eligible for a strong bounded claim** only when every required link in this chain has independent causal evidence:

```text
I HAVE NATIVE PRIMITIVES
        ↓
I CAN REPRESENT INFORMATION
        ↓
I CAN LOAD AND RETRIEVE VERIFIED KNOWLEDGE
        ↓
I CAN ACTIVATE ONLY RELEVANT WORKING STATE
        ↓
I CAN REASON WITH BOUNDED EXPLICIT PATHS
        ↓
I CAN EXPRESS UNKNOWN / CONFLICT / INCOMPLETE
        ↓
I CAN OBSERVE THE PHYSICAL WORLD
        ↓
I CAN EXECUTE A REAL ACTION
        ↓
I CAN OBSERVE ITS EFFECT
        ↓
I CAN RECEIVE EXPERIENCE / REWARD
        ↓
I CAN CREATE CANDIDATES
        ↓
I CAN LEARN A REUSABLE SKILL
        ↓
I CAN TRANSFER IT TO AN UNSEEN INSTANCE
        ↓
I CAN ASK FOR TEACHING WITHOUT MAKING TEACHER TRUTH
        ↓
I CAN REMEMBER FAILURE
        ↓
I CAN REPAIR / COMPACT / REOPEN IT
        ↓
I CAN VERIFY CLAIMS THROUGH PROVENANCE / ABLATION
        ↓
I CAN EXPLAIN WHY THROUGH A MACHINE PROOF TRACE
```

## Tóm tắt tiếng Việt

"Thần kinh hóa thông tin" (Information Neuronalization) là giả thuyết trung tâm: semantic objects như neuron ảo, typed relations như synapse, sparse activation chỉ trên working set. Đây là phép ẩn dụ kỹ thuật, KHÔNG phải tuyên bố sinh học. Giả thuyết chỉ hợp lệ nếu qua được các test: ID permutation, unseen transfer, masked slot, causal ablation, sensor grounding, reset/restore, false teacher, cache invariance. Nếu không qua → hệ thống chỉ là graph database.


---

## SOURCE DOCUMENT: `10_LEARNING_AND_STRATEGY.md`

# §10 — LEARNING AND STRATEGY

> Q* macro strategy, SPEAR micro ranking, candidate generation,
> reward signals, n-step credit assignment, and the learning loop.

## 10.1 Q* — Macro Strategy Selection

Q* answers: **"What should I do next?"**

Available macro actions:

| Action | Description |
|--------|-------------|
| `RETRIEVE` | Look up known information via graph traversal |
| `SEARCH` | Broader exploration beyond immediate neighbors |
| `OBSERVE` | Sample sensor/environment state |
| `ACT` | Execute a physical action via actuator |
| `ASK_TEACHER` | Request teaching (only when policy permits) [§03.6] |
| `SUBMIT` | Emit StructuredResult to host |
| `STOP` | Cease current task |

Q* learns strategy from experience. It does NOT:
- Create or modify truth
- Override ASTRA legality
- Bypass proof requirements
- Directly set learned weights in other components

## 10.2 SPEAR — Micro Ranking

SPEAR answers: **"Which candidate or target should I inspect first?"**

Within a chosen Q* macro action, SPEAR ranks candidates:
```text
candidate_list from retrieval
       ↓
SPEAR scoring (learned relevance)
       ↓
Top-K selection (bounded by budget)
       ↓
ordered inspection queue
```

SPEAR constraints:
- Score does NOT override proof legality
- Score does NOT substitute for evidence
- If Top-K drops a needed candidate → `SEARCH_INCOMPLETE` [§03.2]
- SPEAR ranking is a utility measure, NOT a truth measure
- `UTILITY ≠ TRUTH` — always
- Any future dynamics/prediction sidecar obeys `PREDICTION ≠ TRUTH`

## 10.3 Learning Loop

The core developmental learning cycle:

```text
state_before
     ↓
Q* selects action
     ↓
action executed (physical or cognitive)
     ↓
state_after observed
     ↓
typed effect extraction from state_before/action/state_after
     ↓
reward/penalty received
     ↓
episode recorded [§11]
     ↓
 ┌───┴────────────────────┐
 ↓        ↓        ↓      ↓
FEM    Q* update  SPEAR  Skill candidate
 ↓        ↓        ↓      ↓
 └────────┴────────┴──────┘
                   ↓
        candidate relation/preference
                   ↓
              ASTRA [§03.5]
                   ↓
         verify / reject / conflict
                   ↓
           knowledge commit (if verified)
```

## 10.4 Candidate Generation

When the system encounters missing knowledge or performs inference:

```text
Frontier_A = neighbors(A)
Frontier_B = neighbors(B)
Intersection = Frontier_A ∩ Frontier_B
```

Any node Z in the intersection is a **strong candidate** for bridging A and B.

Bidirectional search can reduce branching:
```text
A → ... → Z
B ← ... → Z
```

But intersection is ONE operator, not universal reasoning. Other queries need:
- DIRECT lookup
- REVERSE lookup
- VALUE/RANGE filter
- CONTEXT filter
- MULTIHOP traversal
- PROVENANCE check
- TEMPORAL ordering

And causal reasoning specifically requires:
- Intervention (change input, observe output)
- Ablation (remove support, observe behavior change)

Not just intersection.

## 10.5 Reward Sources

| Source | Type | Learning meaning |
|--------|------|------------------|
| Physical button / explicit evaluator | Scalar reward/penalty | Human/environment evaluation |
| UART teacher signal | Scalar shaped reward | Accepted only with pending identity and teaching policy |
| Environment/readback outcome | Outcome-derived reward candidate | Depends on verified effect/readback contract |
| Benchmark harness | Test-only reward/evaluation | Must remain distinguishable from production experience |

ASTRA verification is **not a reward source**. ASTRA returns legality/proof/promotion outcomes. A separate learner may derive a bounded training signal from a verified outcome if that mapping is preregistered, but `ASTRA status != reward`.

Reward does NOT directly create FACT. Reward updates policy/preference/skill state only under the learning contract.

## 10.6 Credit Assignment

Action credit rules:
- Action not executed/participating → receives **no causal credit**
- Credit requires exact episode/step identity plus an observed outcome/effect
- Matching expected effect may yield positive credit; mismatch/failure may yield negative or zero credit according to the preregistered reward rule
- N-step credit uses bounded returns over executed trajectories only
- Unselected SPEAR candidates receive no selected-candidate update
- Credit is a learning signal, not proof or truth

## Tóm tắt tiếng Việt

Q* chọn chiến lược macro (retrieve, search, observe, act, ask teacher, submit, stop). SPEAR xếp hạng candidate trong chiến lược đã chọn — score không thay thế proof. Vòng học: state → action → effect → reward → episode → cập nhật Q*/SPEAR/FEM/Skill → ASTRA verify → commit. Intersection là một operator, không phải toàn bộ reasoning. Reward không trực tiếp tạo FACT.


---

## SOURCE DOCUMENT: `11_FAILURE_EXPERIENCE_MEMORY.md`

# §11 — FAILURE EXPERIENCE MEMORY (FEM)

> Typed runtime failure experience, compaction, regression reopening, and repair linkage.
> FEM is part of the DUT's developmental memory. It is not the developer project issue tracker.

## 11.1 Purpose

FEM answers:

> What failed before, under what context, what repaired it, how often did it recur, and did it regress?

Locked separation:

```text
FACT != SKILL != EPISODE != FAILURE != WEIGHT
FAILURE_RECORD != NEGATIVE_FACT
SEMANTIC_CONFLICT != FAILURE by default
```

A valid `CONFLICT` result may be correct epistemic behavior; it becomes a FEM failure only
if the experiment contract says the system mishandled conflict or the conflict itself caused an
execution failure.

## 11.2 FailureRecord R0.1

```text
FailureRecord {
  failure_id
  episode_id
  step_id
  logical_tick
  domain
  stage
  capability_id
  capability_class
  capability_instance
  macro_action
  primitive_action
  candidate_id
  skill_id
  skill_version
  expected_effect
  observed_effect
  error_code
  reward_value
  reward_source
  state_signature
  action_signature
  effect_signature
  q_policy_version
  spear_policy_version
  capability_manifest_version
  knowledge_generation
  source_mode
  crc
}
```

`source_mode` distinguishes, for example:

```text
AUTONOMOUS
HUMAN_DEMO
UART_TEACHER
BOARD_TEST
BENCHMARK_HARNESS
```

Reward is evaluation metadata, not truth.

## 11.3 Typed Failure Key

Do not cluster by raw text or exact episode ID. Candidate prototype key:

```text
hash(domain,
     stage,
     capability_class,
     macro_action_class,
     primitive_class,
     effect_class,
     context_bucket)
```

The purpose is transferable failure memory while preserving enough context to avoid global
blacklisting of one isolated instance.

## 11.4 Lifecycle

```text
RAW_FAILURE
 -> repeated typed match
CLUSTERED_FAILURE
 -> corrective behavior succeeds
RESOLVED_FAILURE
 -> stable success window
COMPACTED_EXPERIENCE
 -> recurrence
REOPENED_FAILURE
```

A first failure need not immediately form a prototype.

## 11.5 FailurePrototype

```text
FailurePrototype {
  prototype_id
  prototype_key
  domain
  stage
  capability_class
  action_class
  effect_class
  first_seen_episode
  last_seen_episode
  last_failure_episode
  failure_total
  failure_recent
  success_after_repair
  regression_count
  unresolved
  compacted
  repair_skill_id
  repair_skill_version
  exemplar_refs[small_k]
  mean_recovery_steps
  mean_failure_cost
  version
  crc
}
```

Counters should saturate or widen explicitly; silent wrap is forbidden.

## 11.6 Atomic Compaction

Compaction is storage optimization, not deletion of history without evidence.

Required commit order:

```text
build prototype summary
 -> write target T2 record
 -> verify integrity/CRC
 -> mark COMMITTED
 -> update index
 -> only then retire eligible raw records
```

A power/reset interruption must not lose both the raw evidence and its replacement prototype.

## 11.7 Regression Reopen

When a compacted failure pattern reappears:

```text
new typed failure
 -> exact/prototype match
 -> REOPENED
 -> regression_count++
 -> repair skill/version re-evaluated
```

Regression must not silently mutate the original evidence record.

## 11.8 FEM Authority Boundary

FEM may provide features/signals to Q*, SPEAR, curriculum selection, and Skill Memory.

FEM may **not**:

- select final action on its own;
- override Q* or SPEAR;
- override ASTRA legality/proof/status;
- promote semantic truth;
- let a host inject winner/weight delta;
- reinterpret a hardware safety-limit state as a failure-memory truth object.

## 11.9 Engineering Failure vs DUT Failure

Vivado failures, documentation errors, CI failures, or agent mistakes belong in project evidence,
issue tracking, and the audit changelog. They do **not** automatically become runtime FEM data.
Only failures deliberately captured from the DUT/runtime experiment through the defined ingress
belong in FEM.

## 11.10 Acceptance

Minimum FEM gate:

```text
CAPTURE_CAUSAL = PASS
CLUSTER_TYPED = PASS
SEPARATION_BY_STAGE = PASS
COMPACTION_NO_DATA_LOSS = PASS
REGRESSION_REOPEN = PASS
ASTRA_AUTHORITY_PRESERVED = PASS
HOST_SEMANTIC_AUTHORITY = 0
PERSIST/RESTORE = PASS when claimed
```

## Tóm tắt tiếng Việt

FEM là bộ nhớ kinh nghiệm thất bại của chính Native AI, không phải nơi ghi lỗi phát triển
project. Failure được capture có identity, context, action/effect, version; lặp lại thì cluster,
sửa ổn định thì compact, tái phát thì reopen. FEM không phải FACT và không được vượt quyền
ASTRA/Q*/SPEAR.


---

## SOURCE DOCUMENT: `12_SKILL_AND_TEACHING.md`

# §12 — SKILL, TEACHING, AND SENSOR GROUNDING

> Procedural memory, teacher boundaries, sensor grounding, and transfer.

## 12.1 SkillRecord vs Executable Skill

A `SkillRecord` may exist before it is verified. Only a skill whose lifecycle/status permits
execution in the current mode is treated as an executable production skill.

```text
SkillRecord {
  skill_id
  version
  goal_class
  preconditions
  capability_class_mask
  parameters
  max_steps
  policy_or_sequence_ref
  termination_schema
  expected_effect_schema
  cost_stats
  success_count
  failure_count
  provenance_ref
  status
  generation
}
```

Locked distinction:

```text
CANDIDATE_SKILL != VERIFIED_SKILL
SKILL != FACT
```

## 12.2 Skill Lifecycle

```text
experience / demonstration / teaching
 -> CANDIDATE
 -> repeated/replayed learning evidence
 -> LEARNED
 -> causal/legality verification
 -> VERIFIED
 -> stable success window
 -> STABLE
 -> optional COMPACTED representation
 -> REOPENED on regression
```

One positive reward is insufficient to create a stable skill.

## 12.3 Parameterization and Transfer

Prefer capability classes and role/parameter bindings over literal instance IDs.

Bad:

```text
WRITE LED3
```

Better:

```text
SET_INDICATOR(target: DIGITAL_OUT, desired_state: ON)
```

Transfer requires training on instance A and examination on unseen instance B with the same
capability/effect contract, plus ID permutation to detect scripts.

## 12.4 Teacher Protocol

Teacher is a source of proposals, demonstrations, clarification, aliases, and scalar reward —
not a truth oracle.

Teacher may:

- demonstrate a primitive/procedure;
- provide scalar reward tied to exact pending identity;
- provide an alias or clarification;
- propose a candidate relation/fact;
- answer a question as `CANDIDATE` evidence.

Teacher may not:

- directly write `VERIFIED_FACT`;
- send winner action/candidate;
- write learner weight deltas;
- inject proof/provenance fabricated as FPGA evidence;
- override ASTRA status;
- drive an actuator directly.

## 12.5 Teacher Learning Flow

```text
knowledge gap / teaching opportunity
 -> Q* chooses ASK_TEACHER only when teaching policy permits
 -> teacher proposal/demo/reward
 -> provenance attached
 -> CANDIDATE / EPISODE / ALIAS metadata
 -> verification / conflict checks
 -> ASTRA promote / reject / conflict
 -> versioned generation commit when applicable
```

`UNKNOWN` does not automatically mean `ASK_TEACHER` [§03.6].

## 12.6 False-Teacher / Anti-Parrot Tests

Mandatory falsification patterns:

1. Teacher proposes claim contradicting verified support → must not silently become FACT.
2. Teacher proposes unsupported claim with no contradiction → remains CANDIDATE until verified.
3. Rephrase/remove teacher wording → learned procedural/semantic behavior must not depend on verbatim text.
4. Teacher may reward selected behavior, but cannot send a hidden winner or weight update.

## 12.7 Sensor Grounding

Grounding must preserve stages:

```text
RAW_SENSOR_EVENT
 -> calibrated/typed OBSERVATION
 -> bounded feature/event abstraction
 -> EPISODE / state transition
 -> candidate concept/relation
 -> repeated evidence / intervention where relevant
 -> ASTRA-governed verification status
 -> optional HUMAN_ALIAS attachment
```

A raw sensor reading is not automatically a FACT, and clustering is not automatically meaning.
Alias attachment never changes native identity by itself.

### Example hypothesis

```text
unlabeled temperature state pattern
 -> candidate internal state C_8734
 -> action/effect associations observed
 -> stability/transfer tested
 -> human later attaches aliases: "hot", "nóng", ...
```

The claim is supported only if behavior and relations survive alias replacement and, where
applicable, unseen-sensor/capability transfer.

## 12.8 Primitive / Capability / Skill Boundary

- **Primitive**: fixed executable operation implemented by the substrate.
- **Capability**: installed hardware interface declaring which primitives/effects are available [§05].
- **Skill**: learned/verified procedure combining primitives under preconditions/termination.
- **Fact**: verified semantic proposition; not executable by itself.

Execution path:

```text
Skill / Q* ACTION_INTENT
 -> ASTRA legality/safety
 -> Capability Binding [§05]
 -> Primitive Executor
 -> physical effect
 -> readback/episode
```

## Tóm tắt tiếng Việt

Skill có lifecycle riêng: candidate → learned → verified → stable → compacted/reopened. Teacher
chỉ tạo candidate/demo/reward, không tạo FACT hay proof. Sensor grounding đi từ raw event →
observation → episode → candidate concept/relation → verification; alias chỉ gắn tên. Mọi skill
muốn tác động phần cứng phải qua §05 capability binding và safety.


---

## SOURCE DOCUMENT: `21_PRIOR_ART_AND_NOVELTY.md`

# §21 — PRIOR ART AND NOVELTY

> Prior-art boundary for the research program. This document deliberately avoids
> novelty claims that have not survived a dedicated patent/literature search.

## 21.1 Established neighborhoods

No individual NSPF ingredient is new. Relevant families include:

- semantic networks / knowledge graphs / production systems;
- associative memory, CAM/BCAM and content-addressed lookup;
- Kanerva sparse distributed memory;
- VSA/HDC and Semantic Pointer Architecture/Nengo;
- ACT-R and Soar working/declarative/procedural memory;
- NTM/DNC and memory-augmented neural systems;
- SNN/event-driven neuromorphic systems (TrueNorth, Loihi, SpiNNaker);
- graph accelerators and FPGA/HBM graph-processing engines;
- event-based sensors and temporal event processing;
- cache admission/hot-set profiling and reconfigurable computing;
- complementary-learning/consolidation models in cognitive science.

These works establish precedent for explicit memory, sparse activation,
working-vs-long-term stores, event routing, associative retrieval, graph
traversal and specialization. Therefore **none of those concepts alone can be
claimed as Native AI novelty**.

## 21.2 What is genuinely being tested

The stronger Native AI hypothesis is the combination of:

```text
explicit typed semantic objects
+ typed relations and variable/role binding
+ explicit context/provenance/status
+ verified/candidate/episode/skill/failure/weight separation
+ sparse logical-event activation
+ indexed bounded retrieval and proof construction
+ ASTRA legality/proof/conflict/completeness boundary
+ physical action/effect grounding through verified capabilities
+ causal falsification (ablation/permutation/reset/restore)
+ FPGA-native execution with memory-placement stratification
```

This is **[HYPOTHESIS]**, not a novelty verdict.

## 21.3 Fair comparison boundaries

| Family | What it already provides | What NSPF must still demonstrate |
|---|---|---|
| Indexed KG/graph engine | exact IDs, adjacency/indexes, bounded traversal, provenance extensions | learning/grounding/skill transfer/authority and hardware benefit beyond a well-engineered graph baseline |
| ACT-R / Soar | working/declarative/procedural memory, goals/rules | silicon-native implementation and the claimed semantic/event/causal properties |
| VSA/HDC/SPA | distributed binding, similarity and compositional proposals | exact proof/provenance path if used; HDC must remain proposal sidecar unless separately certified |
| NTM/DNC | learned controllers over external memory | whether explicit typed memory + deterministic authority is advantageous for the target workload |
| SNN/neuromorphic | sparse event routing/local state/online learning | explicit semantic identity and proof/status authority, not merely event-driven operation |
| Graph accelerators | memory-specialized frontier traversal, HBM parallelism | semantic correctness, typed context/provenance and bounded proof semantics |
| LLM/RAG | learned language/representation and external retrieval | do not caricature these systems; compare bounded tasks on update cost, traceability, grounding, compute and language capability |

## 21.4 Novelty boundary

The following are **not sufficient novelty claims**:

```text
three memory tiers
"brain-like" memory names
using BRAM as cache
using DDR for a knowledge graph
spreading activation
Top-K ranking
partial reconfiguration
CAM on FPGA
```

Potentially distinctive contributions, if experimentally demonstrated and
novelty-searched, may lie in the **joint contract**: exact semantic objects +
event plane + epistemic separation + ASTRA authority + causal tests + hardware
placement/specialization while preserving truth/provenance across tiers.

## 21.5 Patent/FTO status

`NOVELTY = NOT ESTABLISHED`

A real patent/FTO analysis must examine claim language, priority dates,
continuations/families and jurisdictions. A keyword search that fails to find an
identical phrase does not establish novelty or freedom to operate.

## 21.6 Claim discipline

Allowed today:

> NSPF is a research architecture that recombines established mechanisms under
> a stricter semantic/authority/falsification contract.

Not allowed today:

> NSPF is the first/new/unique cognitive architecture of its kind.

## Tóm tắt tiếng Việt

Không có thành phần đơn lẻ nào đủ để claim mới. Điểm cần nghiên cứu là tổ hợp
exact semantic objects + event plane + authority/provenance + causal tests +
FPGA execution. Tính mới và FTO hiện vẫn `NOT ESTABLISHED`.


---

## SOURCE DOCUMENT: `31_VERIFICATION_AND_CAUSAL_TESTS.md`

# §31 — VERIFICATION AND CAUSAL TESTS

> Verification is layered. Correct answers alone do not establish representation,
> causal dependence, learning or silicon correctness.

## 31.1 Test families

| Family | What it establishes |
|---|---|
| Unit / reference | codecs, indexes, operators, status rules |
| XSim integration | RTL subsystem behavior, not silicon |
| Pack/ABI integrity | fail-closed loader/schema/content/generation behavior |
| FE256 | static semantic correctness across 256 preregistered **cases** |
| Shuffle | order invariance of the FE256 case campaign |
| Causal ablation | runtime answer dependence on declared evidence |
| FE-UART-E2E-32 | human text→host adapter→wire→FPGA→result→render parity |
| NSPF-X0 | strong research falsification: representation/transfer/grounding/learning |
| Board | physical execution for the exact artifact/run manifest |

`XSIM_PASS != BOARD_PASS`, and `PROGRAM_PASS` proves configuration only.

## 31.2 Pack/ABI integrity campaign — 24 cases

`PACK_ABI_24_24_PASS` means all 24 preregistered integrity cases pass:

```text
4 valid pack/readback              -> LOAD_OK
4 schema-hash mismatch             -> LOAD_REJECT
4 ABI mismatch                     -> LOAD_REJECT
4 content-hash mismatch            -> LOAD_REJECT
4 page/record CRC corruption       -> reject or DATA_INTEGRITY_FAIL
4 generation / A-B atomicity       -> no partial/stale activation
```

It does **not** mean 24 nodes + 24 edges.

## 31.3 FE256 static semantic benchmark

FE256 contains **256 cases**. Canonical composition:

| Class | Cases |
|---|---:|
| DIRECT | 48 |
| VALUE | 32 |
| REVERSE | 32 |
| MULTIHOP | 32 |
| CONTEXT | 24 |
| PROVENANCE | 16 |
| NEGATIVE | 24 |
| CONFLICT | 16 |
| IDENTITY | 16 |
| ABLATION | 16 |
| **TOTAL** | **256** |

Required core acceptance:

```text
256/256 explicit StructuredResult
wrong answer = 0
false refusal = 0
EMPTY = 0
timeout = 0
txn mismatch = 0
context leak = 0
identity leak = 0
proof/provenance valid = 100% where required
```

`255/256 = FAIL_PARTIAL` for the finite preregistered suite.

The benchmark graph/pack may contain any compliant number of semantic records;
**256 is the number of cases, not a node-count requirement**.

### Status correctness

- `UNKNOWN`: complete declared search scope, no verified support.
- `SEARCH_INCOMPLETE`: completeness not established because a budget/resource limit ended search.
- `CONFLICT`: conflicting relevant support is the expected result for conflict cases, not a campaign failure by itself.
- protocol/integrity faults never become UNKNOWN.

## 31.4 FE256 shuffle

The shuffle gate replays the **same preregistered cases in a deterministic
shuffled order** and requires the same semantic outcomes. It targets hidden
order/state dependence.

ID permutation and alias replacement are separate NSPF-X0 falsification tests;
they are not redefined as FE256 `SHUFFLE_PASS`.

## 31.5 Causal Pack-A / Pack-B ablation

Preregister a support claim, e.g. Pack A contains the only supporting edge and
Pack B removes exactly that support while preserving all other intended state.
The same canonical QueryRecord must change from the Pack-A supported result to
`UNKNOWN` (or another preregistered correctly supported status) under Pack B.

If the old answer survives with no alternate support, investigate:

```text
host answer injection
hard-coded/ROM answer
stale T1 cache
duplicate edge/derived fact
wrong generation switch
hidden state
```

## 31.6 Human UART E2E — 32 cases

The final human-facing E2E path is:

```text
human text
→ frozen/preregistered host adapter
→ QueryRecord
→ UART/frame
→ FPGA semantic/proof path
→ StructuredResult
→ UART/frame
→ host renderer
→ human text
```

Freeze/log host adapter source/hash/version. The adapter may resolve aliases,
query intent, direction and units to native IDs. It may not select the answer,
generate ASTRA proof/provenance, traverse a hidden answer graph or encode gold
answers in flags/IDs.

Required: 32/32 semantic parity and zero frame/CRC/timeout/txn/status distortion.

## 31.7 NSPF-X0 falsification suite

| ID | Test | Correct intervention | Pass condition / interpretation |
|---|---|---|---|
| X0-01 | ID Permutation | consistently remap raw semantic IDs | meaning/behavior preserved modulo remapped IDs |
| X0-02 | Alias Replacement | rename/multilingual aliases only | native semantics unchanged |
| X0-03 | Masked Slot | hide a frame slot/role while keeping supporting knowledge present | bounded resolver reconstructs/queries the slot from structure/evidence or returns lawful status; no answer table |
| X0-04 | Causal Ablation | remove declared support / intervention variable | dependent answer/behavior changes; alternate support handled explicitly |
| X0-05 | Clock-Rate / Spacing Invariance | legal physical clock/clock-enable spacing, same logical events | semantic result/proof invariant modulo timing metadata |
| X0-06 | Event Jitter Robustness | seeded delay/stall within preregistered envelope | no drop/dup/deadlock; same semantics when logical order unchanged |
| X0-07 | Reset/Restore | W0→train W1→reset→restore | baseline returns after reset; learned behavior returns after restore |
| X0-08 | Sensor Grounding | observe/action/effect before alias; attach/rename alias later | internal relation survives alias change and has causal/effect evidence |
| X0-09 | False Teacher / Anti-parrot | teacher proposes false/rephrased information | proposal remains candidate/rejected/conflicted; no direct FACT/weight/proof authority |
| X0-10 | Cache On/Off | same active generation/query with T1 semantic cache enabled/disabled | same semantic result/proof; only performance differs |
| X0-11 | Unseen Instance Transfer | train skill on instance A, test equivalent unseen B | transfer follows capability/class/effect, not hard-coded ID |
| X0-12 | 4→8→16 Structural Transfer | train bounded transition/procedure at 4-bit, disable primitive shortcut, test wider holdouts | transfer exceeds literal-table/script baseline |
| X0-13 | Runtime Knowledge Dependence | valid loaded pack vs absent/replaced support | result depends causally on active pack/generation |
| X0-14 | Stale Cache / Generation | switch generation while cached entries exist | stale generation cannot influence new result |
| X0-15 | Capability Binding | remove/mismatch required hardware capability | `NO_BINDING/NO_ACTION`; no unsafe actuation |

Passing this suite supplies **bounded empirical support** for the hypothesis; it
does not prove general intelligence or universal cognition.

## 31.8 Learning/teacher/sensor evidence

For any learned-state claim require, as applicable:

```text
W0/S0/K0 → behavior A
train/experience → W1/S1/K1 → behavior B
reset → A returns
restore → B returns
```

Teacher statements are source evidence/candidates, not FACT. Sensor readings are
observations, not automatically verified propositions. A predicted effect does
not substitute for readback.

## 31.9 Verification anti-patterns

Forbidden evidence shortcuts include:

- changing gold/threshold/case selection to rescue a candidate;
- counting renderer text as semantic proof;
- converting timeout/overflow into UNKNOWN;
- host injecting winner/proof/answer;
- materializing special derived facts solely to evade required reasoning;
- using program/startup HIGH as semantic board evidence;
- calling a benchmark PASS after only targeted regression without a fresh full run.

## Tóm tắt tiếng Việt

FE256 = 256 case, Pack/ABI = 24 integrity case. SHUFFLE là đổi thứ tự case,
không phải ID permutation. Masked Slot che slot nhưng giữ support; ablation mới
là test bỏ support. UART E2E bắt đầu từ text người dùng và đóng băng host adapter.


---

## SOURCE DOCUMENT: `32_ACCEPTANCE_LADDER.md`

# §32 — ACCEPTANCE LADDERS

> Static Full Evidence acceptance, NSPF research falsification and Developmental
> learning acceptance are deliberately separate. No pass is inherited from
> frozen historical V1 into a new artifact.

## 32.1 Full Evidence board-candidate ladder

```text
AUDIT_COMPLETE
→ XSIM_SMOKE_PASS
→ POST_ROUTE_PASS
→ PROGRAM_PASS
→ PACK_ABI_24_24_PASS
→ RUNTIME_DDR_LOAD_PASS
→ READBACK_PASS
→ FE256_256_256_PASS
→ SHUFFLE_PASS
→ ABLATION_PASS
→ UART_E2E_32_32_PASS
→ FULL_EVIDENCE_BOARD_PASS_CANDIDATE
→ OWNER REVIEW
```

### AUDIT_COMPLETE

- source lineage/dirty state and authority files recorded;
- GOAL/invariants/ABI/status semantics audited;
- forbidden overclaims and stale hardware constants removed;
- benchmark contracts frozen before execution.

### XSIM_SMOKE_PASS

- required RTL compiles and preregistered smoke vectors pass;
- simulation evidence only.

### POST_ROUTE_PASS

- implementation completes;
- timing gate meets the preregistered target (e.g. WNS ≥ 0, TNS = 0, hold clean);
- critical DRC/unconstrained semantic paths resolved;
- resource reports archived.

### PROGRAM_PASS

- exact bitstream hash recorded;
- target JTAG/device identity recorded;
- configuration succeeds/startup is valid.

`PROGRAM_PASS` **only proves configuration**, not semantic behavior.

### PACK_ABI_24_24_PASS

All 24 integrity cases in [§31.2] pass: valid/readback, schema mismatch, ABI
mismatch, content mismatch, corruption and generation/A-B atomicity.

### RUNTIME_DDR_LOAD_PASS

- production loader receives the frozen valid pack;
- no load ACK before FIFO/write responses are drained;
- manifest/generation/integrity level is recorded honestly;
- active generation switches atomically.

### READBACK_PASS

Read back preregistered sentinel pages/records from at least:

```text
NODE / EDGE / VALUE / POSTING / CONTEXT / PROVENANCE
```

and verify exact active-generation contents/integrity. The gate does not require
reading every record in a large pack unless its contract explicitly says so.

### FE256_256_256_PASS

- exactly 256 preregistered FE256 **cases** execute;
- 256/256 semantic results/status/proof requirements match gold;
- all zero-error conditions in [§31.3] hold.

### SHUFFLE_PASS

- replay the same FE256 cases in preregistered deterministic shuffled order;
- semantic outcomes remain identical to canonical order;
- no hidden order/state dependence.

### ABLATION_PASS

- preregistered Pack-A/Pack-B support intervention passes [§31.5];
- no stale cache, host injection or hidden duplicate support explains the result.

### UART_E2E_32_32_PASS

- 32 human-text cases execute through the frozen host adapter and production UART path;
- 32/32 semantic parity;
- zero parse deadlock, frame/CRC/txn mismatch, timeout and status distortion;
- host adapter source/hash/version is part of evidence.

### FULL_EVIDENCE_BOARD_PASS_CANDIDATE

- every preceding static Full Evidence gate passes on the same declared artifact lineage;
- all expected CONFLICT/UNKNOWN/etc. cases match gold;
- no unresolved protocol/integrity failure exists;
- raw board evidence and hashes are sealed.

This candidate does **not** imply NSPF developmental learning/grounding/transfer
passes, and is not owner `BOARD_PASS`.

### OWNER REVIEW

Only the project owner may promote/reject/request more evidence and authorize a
final artifact freeze/stamp.

## 32.2 Separate NSPF research-candidate gate

`NSPF_R0_RESEARCH_CANDIDATE` is separate from Full Evidence. It requires the
preregistered NSPF-X0 campaign relevant to the research claim, including at
minimum ID/alias perturbation, masked slot, causal ablation, logical-time
robustness, cache parity and knowledge-load dependence. Transfer/grounding tests
are required before those stronger claims may be made.

## 32.3 Separate Developmental R2 candidate

`DEVELOPMENTAL_R2_CANDIDATE` additionally requires evidence for:

```text
executed-action credit
reset/restore learning causality
FEM lifecycle/regression
parameterized skill lifecycle + unseen-instance transfer
teacher false-input/anti-parrot boundary
sensor/action/effect grounding
capability binding + safety veto/readback
fact/candidate/episode/skill/weight separation
checkpoint generation/version integrity
```

No lower-level static pass automatically satisfies these.

## 32.4 Claim ceilings

```text
XSIM_*                         -> simulation claim only
PROGRAM_PASS                   -> configuration claim only
FULL_EVIDENCE_BOARD_PASS_CANDIDATE -> static semantic board candidate only
NSPF_R0_RESEARCH_CANDIDATE     -> bounded research-hypothesis support only
DEVELOPMENTAL_R2_CANDIDATE     -> bounded developmental candidate only
OWNER REVIEW                   -> owner decision, never agent self-certification
```

Historical V1 evidence remains frozen/read-only and is never overwritten or
inherited by these new candidates.

## Tóm tắt tiếng Việt

R0.1 tách ba loại acceptance: Full Evidence tĩnh, NSPF falsification, và
Developmental learning. Pack/ABI 24/24 là 24 integrity case; FE256 là 256 case;
UART E2E đi từ human text. Chỉ owner được cấp final stamp.


---

## SOURCE DOCUMENT: `22_RTL_RISK_REGISTER.md`

# §22 — RTL / IMPLEMENTATION RISK REGISTER

> Risks are tracked as engineering evidence. Project/tool failures are not
> automatically runtime FEM records.

## 22.1 Risk register

| ID | Class | Risk | Severity | Mitigation / gate |
|---|---|---|---|---|
| R01 | Timing | Semantic path/MIG integration misses timing | HIGH | parameterized clocks, OOC early, pipeline/shared arithmetic; do not lock 50 MHz as architecture |
| R02 | Resource | BRAM working/cache state exceeds 135 BRAM36 | HIGH | per-block budget, OOC utilization, spill canonical state to T2 |
| R03 | Resource | comparator/router/proof logic consumes excessive LUT/routing | HIGH | bounded lanes, time-multiplex, hash/posting structures, post-route evidence |
| R04 | Memory | irregular DDR access dominates traversal | HIGH | measure exact workload; indexed postings; cache/admission only where evidence shows benefit |
| R05 | Coherence | stale T1 entry survives T2 generation switch | CRITICAL | generation tags, shadow fill, atomic activate/invalidate, cache-on/off parity test |
| R06 | Protocol | drop/duplicate/retry double-commits records/events | CRITICAL | sequence/session/txn identity, CRC, idempotent commit, assertions |
| R07 | Loader | ACK emitted before DDR write drain/commit | CRITICAL | outstanding write counter, FIFO empty + response completion before ACK |
| R08 | Status | UNKNOWN emitted when search is incomplete | CRITICAL | completeness tracking, exhaustive status vectors, ASTRA assertions |
| R09 | Proof | proof/provenance refs point outside active generation | CRITICAL | generation-bound proof validation and readback |
| R10 | Host authority | host adapter performs hidden answer/reasoning | CRITICAL | freeze adapter hash; log QueryRecord; Pack-A/B ablation; host code audit |
| R11 | Capability | semantic action reaches wrong/unverified physical actuator | CRITICAL | capability manifest/binding, ASTRA legality/safety, no-binding→no-action [§05] |
| R12 | Learning | unexecuted candidate receives credit | CRITICAL | executed-action-only credit + episode/step identity |
| R13 | Teacher | teacher proposal becomes FACT/weight/proof directly | CRITICAL | candidate-only teacher contract; false-teacher/anti-parrot tests |
| R14 | Meaning | ID/alias/clock/cache placement accidentally carries semantics | CRITICAL | ID permutation, alias replacement, clock invariance, cache parity |
| R15 | Benchmark | case-specific hardcoding / derived shortcut produces false PASS | CRITICAL | shuffled order, holdouts, Pack-A/B ablation, code review, immutable gold |
| R16 | Scaling | hub/posting explosion silently truncates search | HIGH | paged adjacency, explicit budget/completeness, SEARCH_INCOMPLETE |
| R17 | Integrity | Pack/ABI/schema/content/generation mismatch is partially accepted | CRITICAL | 24 Pack/ABI integrity gates, fail-closed loader |
| R18 | CDC | unconstrained/unsafe clock-domain path causes intermittent corruption | CRITICAL | CDC handshakes/FIFOs, constraints, assertions/report review |
| R19 | Toolchain | environment/version/path drift invalidates reproducibility | MEDIUM | run manifest + exact tool/source/bit/pack hashes; local paths not canon |
| R20 | Evidence | XSim/programming result is promoted to board semantic PASS | CRITICAL | acceptance ladder and owner-only final stamp [§32] |

## 22.2 Risk response protocol

When a project/RTL risk materializes:

1. Freeze the failing run and raw evidence.
2. Record it in project issue/evidence logs and the immutable failure campaign.
3. Classify the **first causal divergence** before editing.
4. Apply the smallest justified patch.
5. Rerun targeted lower gate, then fresh full campaign after a functional change.
6. Escalate architecture after repeated failure of the same causal class.

Only DUT/runtime experience intentionally captured by the Native AI data model
belongs in **FEM**. Vivado failures, stale documentation, agent mistakes and
build-environment issues remain engineering/project evidence unless a separate
research experiment explicitly models them as DUT experience.

## 22.3 Stop conditions

Stop and request architecture review if any of the following persists:

- semantic correctness depends on cache state, physical IDs or clock spacing;
- host reasoning is required to obtain the benchmark answer;
- T1/T2 generation coherence cannot be proven;
- proof/status must be weakened to achieve acceptable outputs;
- the only repair is modifying gold/threshold/case selection;
- three repair attempts in the same causal class fail without new evidence.

## Tóm tắt tiếng Việt

Risk register R0.1 tách lỗi engineering khỏi FEM runtime, bổ sung stale-cache,
host cheating, capability binding, authority/benchmark overfit, CDC và evidence
promotion. Không khóa 50 MHz như chân lý kiến trúc.


---

## SOURCE DOCUMENT: `30_MILESTONE_ROADMAP.md`

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

## Tóm tắt tiếng Việt

Roadmap R0.1 sửa M1 thành runtime load vào DDR + write-drain/readback; FE256 là
256 case, không phải 256 node; UART E2E bắt đầu từ text người dùng; bốn artifact
chỉ là bộ control tối thiểu, raw evidence vẫn bắt buộc khi cần.


---

## SOURCE DOCUMENT: `33_IMPLEMENTATION_GUIDE.md`

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
→ installed ModuleManifest match
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

## Tóm tắt tiếng Việt

Implementation guide R0.1 phân biệt luật kiến trúc với lựa chọn MVP. Wire dùng
32-bit semantic ref; 24-bit/50 MHz/LRU không còn là chân lý canon. Physical action
bắt buộc qua capability binding + ASTRA/safety + effect readback.
