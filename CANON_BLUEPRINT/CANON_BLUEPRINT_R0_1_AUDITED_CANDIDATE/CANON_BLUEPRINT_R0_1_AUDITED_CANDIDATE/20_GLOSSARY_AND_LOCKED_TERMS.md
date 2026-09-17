---
version: "1.1-candidate"
owner: AGENT_A
status: AUDITED_CANDIDATE
category: REFERENCE
last_modified: "2026-09-16T08:45:00+07:00"
---

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
