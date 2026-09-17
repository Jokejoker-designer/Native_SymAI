---
version: "1.7-candidate"
owner: AGENT_A
status: AUDITED_CANDIDATE
category: REFERENCE
last_modified: "2026-09-17T04:25:00+07:00"
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
| EPISODE | ≠ | FAILURE | temporal experience ≠ typed failure record |
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
| K_SOFT | ≠ | K_HARD | derived inspection budget ≠ loaded profile slot capacity |
| K_HARD | ≠ | K_HARD_MAX | loaded profile Top-K capacity ≠ C compiled SPEAR slot ceiling |
| PHYSICAL_PLACEMENT | ≠ | EPISTEMIC_CLASS | LUT/BRAM/DDR location ≠ FACT/SKILL/etc. |
| SEMANTIC_IDENTITY | ≠ | PHYSICAL_POINTER | 32-bit ID ≠ T2 byte address (may pack internally) |
| NULL_T2_PTR | ≠ | SEMANTIC_ID_ZERO | address 0 as null/end ≠ identity 0 / sentinel node |
| PHYSICAL_POINTER | ≠ | PHYSICAL_PLACEMENT | address bits ≠ T0/T1/T2 residence |
| BIT_WIDTH | ≠ | ONTOLOGY | ABI/versioned representation ≠ KIND/ROLE/FACT |
| SPEAR_MAC_PRODUCT_WIDTH | ≠ | SEMANTIC_ID_WIDTH | live §10.7.5 Q5.19 24-bit ranking product ≠ 32-bit identity |
| PACK_ABI_24_24_CASES | ≠ | SEMANTIC_ID_WIDTH | 24 gold pack-integrity cases ≠ 24-bit identity law |
| SEMANTIC_EVENT_BYTES | ≠ | SEMANTIC_ID_WIDTH | live §04.5 192-bit / 24-byte event size ≠ 24-bit identity |
| POSTING_ENTRY_WIDTH | ≠ | PACK_GROUP_WIDTH | 64-bit PostingEntry ≠ 128-bit grouping / MIG beat |
| SEMANTIC_ID_WIDTH | ≠ | ACTIVE_ID_RANGE | 32-bit identity ABI ≠ loaded profile legal-ID subset |
| ACTIVE_RANGE_CHECK | ≠ | IDENTITY_LAW | profile high-bit/max check ≠ shrinking the ID type to 24 bits |
| FEM_COMPACTION_RECOVER | ≠ | FEM_DEST_INTEGRITY | C three-state compaction observables ≠ dest COMMIT/CRC class |
| WORD_ATOMIC_LOCAL_MODEL | ≠ | DDR_CRASH_SAFETY | 32-bit local T2/FEM model ≠ MIG/DDR persistence proof |
| BRAM_STANDIN | ≠ | FEM_PERSIST_STORE | r2_top 128b mig_ui_bram via mig_ui32 ≠ T2 DDR; mig_top mux onto mig0 is CANDIDATE not persist |
| MIG_BIND_SYNTH | ≠ | MIG_PASS | live §23.9 22:13: mig0 in arty_a7_mig_top CANDIDATE; r2_top still unbound ≠ calib/board MIG_PASS |
| FEM_UI_XSIM | ≠ | FEM_PERSIST_PASS | FEM_MIG_UI32_XSIM_PASS ≠ calib/board persist |
| LEARNER_UI_CLK | ≠ | TIMING_PASS | Q*/SPEAR/walk on ui_clk is implementation clocking; not freeze; not TIMING_PASS |
| OOC_WNS | ≠ | TIMING_PASS | post-synth/post-route/OOC slack (incl. fabric +0.375 / mig_tx +0.673 / bag2+ui_clk +1.032 / FE256 R0 −75.723 / FE256 R1 +0.223 / shadow +0.368 / M2–M4 OOC / M4 shadow +0.555 / M4+mig0 +0.233) ≠ owner TIMING_PASS |
| VIVADO_MET | ≠ | TIMING_PASS | constraints-reported MET ≠ owner TIMING_PASS stamp |
| LAB_HOLD_BASELINE | ≠ | TIMING_PASS | R2_TOP_ROUTE_BASELINE_WHS_0P021 / HOLD_OPTIMIZATION_STOPPED ≠ BOARD_PASS / TIMING_PASS |
| FE256_INTEGRATED_FREEZE | ≠ | PRODUCT_ARCHITECTURE | R2_FE256_R1_INTEGRATED_FREEZE / DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP = D lab freeze status ≠ permanent product path |
| FE256_REFERENCE_FREEZE | ≠ | FE256_FULL_PASS | FE256_R1_REFERENCE_FREEZE = REFERENCE_IMPLEMENTATION; FE256_DEVELOPMENT CLOSED ≠ FE256_PASS / BOARD_PASS |
| RTL_PIPELINE_DEPTH | ≠ | LOGICAL_STAGE_COUNT | IMPLEMENTATION_DEFINED RTL depth ≠ six SPEAR logical stages |
| XSIM_PASS | ≠ | BOARD_PASS | simulation match ≠ board acceptance (UART_WORD / UART_PACK / UART_FE256 / M4 UART smoke XSim included) |
| FE256_OOC | ≠ | FE256_FULL_PASS | unplaced OOC / RCA DO_NOT_BIND / HW-R1 isolated ≠ FE256_PASS / board bind |
| M2_QUERY_XSIM | ≠ | M2_PASS | M2_QUERY_POST_XSIM_PASS / isolated OOC ≠ M2_PASS / freeze bind |
| M3_WALK_XSIM | ≠ | M3_PASS | M3_QUERY_WALK_XSIM_PASS; walker incomplete ≠ ASTRA status ≠ M3_PASS |
| M4_RESULT_XSIM | ≠ | ASTRA_PASS | M4_QUERY_RESULT_XSIM_PASS / SHADOW_XSIM fail-closed hop-1 ≠ ASTRA_PASS |
| QUERY_META_PACK | ≠ | ABI_LOCK | query_meta[10] reverse / [8:5] hop_budget CANDIDATE packing of §04.3 ≠ frozen ABI |
| MIG_INSTANTIATE | ≠ | MIG_PASS | mig0 on m4_mig candidate / calib IP pin ≠ board-measured MIG_PASS |
| BITSTREAM_WRITE | ≠ | PROGRAM_PASS | write_bitstream file existence ≠ JTAG PROGRAM_PASS / BOARD_PASS |
| OWNER_PROGRAM_YES | ≠ | PROGRAM_PASS | owner auth + Labtools startup HIGH ≠ §32 PROGRAM_PASS (DONE/IR.STATUS may be NA) |
| UART_BOARD_SMOKE | ≠ | BOARD_PASS | 1-txn COM fail-closed StructuredResult ≠ UART_E2E_32_32_PASS / BOARD_PASS / ASTRA_PASS |
| PACK_ABI24_MIG_DUT_XSIM | ≠ | PACK_ABI_24_24_PASS | dest-complete via mig_ui_bram stand-in ≠ PACK_ABI_24_24_PASS / MIG_PASS |
| PACK_ABI24_BOARD_SEQ | ≠ | PACK_ABI_24_24_PASS | sequential UART board run (e.g. 2/24, first fail PA24-V-03 R_SENTINEL) ≠ PACK_ABI_24_24_PASS / BOARD_PASS |
| PACK_ABI24_BOARD_ISO | ≠ | PACK_ABI_24_24_PASS | per-case reprogram isolated board run (e.g. 14/24) ≠ PACK_ABI_24_24_PASS / BOARD_PASS |
| B_ACCEPT_CANDIDATE | ≠ | LADDER_PASS | B-NGHIEM-THU ACCEPT_CANDIDATE_ONLY ≠ any BOARD/MIG/PACK/ASTRA/FE256 PASS |
| SAME_BIT_REPROGRAM | ≠ | PROGRAM_PASS | reload identical bit sha after foreign overwrite ≠ PROGRAM_PASS / BOARD_PASS |
| BOARD_OSC | ≠ | MIG_SYS_CLK | Arty 100 MHz oscillator ≠ generated MIG sys_clk |
| NULL_T2_PTR | ≠ | DDR_BEAT_ZERO | directory/page pointer 0 ≠ MIG beat address 0 |
| FIFO_EMPTY | ≠ | DEST_COMPLETE | local FIFO drain ≠ dest readback + matching txn; live §22 R07 (17:35) agrees (hint only) |
| MIG_APP_W | ≠ | NCG_RECORD_WIDTH | generated MIG beat ≠ architecture-candidate record size |
| MIG_ADDR_WIDTH | ≠ | SEMANTIC_ID_WIDTH | MIG physical address bits ≠ identity |
| LOGICAL_TICK | ≠ | PHYSICAL_CLOCK | semantic ordering ≠ FPGA cycle identity |
| ACTION_INTENT | ≠ | PrimitiveCommand | semantic request ≠ issued actuator command |
| SKILL_STATE | ≠ | EXECUTION_PERMISSION | lifecycle CANDIDATE→REOPENED ≠ per-call action-path eligibility |
| SKILL_ENGINE | ≠ | PRIMITIVE_EXECUTOR | procedure store / ACTION_INTENT origin ≠ pin-drive after ASTRA+BOUND |
| QSTAR_PROPOSAL | ≠ | EXECUTION | Q* Top-1 / pending proposal ≠ PrimitiveCommand ran |
| EXECUTION | ≠ | CREDIT | issued+observed command ≠ learning update |
| COMMAND_ISSUED | ≠ | EFFECT_OBSERVED | accepted command ≠ attributable physical effect |
| NO_ACTION | ≠ | EFFECT_UNOBSERVED | command never issued ≠ issued without readback identity |
| HARDWARE_CAPABILITY | ≠ | QUERY_CAPABILITY | installed actuator interface ≠ ASTRA query/operator support |
| ASTRA_QUERY_STATUS | ≠ | ASTRA_ACTION_VERDICT | query `0x01–0x06` ≠ action LEGAL/DENY/VETO codes |
| ACTION_LANE_OBJECT | ≠ | QUERY_UART_RECORD | intent/binding/command/effect ≠ Query/Result/SemanticEvent [§04.13] |
| ACTION_PATH_PASS_SET | ≠ | X0_15_BINDING_FAMILY | seven §05.8 names ≠ live §31 X0-15 `Capability Binding` / `NO_BINDING/NO_ACTION` |
| NCG_RECORD | ≠ | QUERY_UART_RECORD | T1/T2 NCG types ≠ Query/Result/Event; those remain [§04] |

## 20.2 Subsystems and authority

| Term | Definition |
|---|---|
| **NSPF** | Native Semantic Pulse Fabric — forward research architecture name |
| **NCG** | Native Cognitive Graph — exact typed retrieval/indexed bounded traversal substrate |
| **Q\*** | Macro strategy selector: retrieve/search/observe/act/ask/submit/stop under legal masks |
| **SPEAR** | Micro ranker for legal candidates/targets; ranking is not truth |
| **SEMANTIC_ID_WIDTH** | 32-bit field width of every canonical/cross-boundary semantic reference [§02.4.1] |
| **ACTIVE_ID_RANGE** | Loaded profile property (`active_id_bits` / `active_id_max`); not identity width [§02.4.1b] |
| **K_HARD** | SPEAR/Top-K candidate-slot capacity from the same loaded profile as `ACTIVE_ID_RANGE`; D wires; C consumes; not truth; not ASTRA status [§02.4.1b] [§04.13] |
| **K_HARD_MAX** | C compiled SPEAR slot ceiling; not the profile; not frozen by A (D-reported live compiled candidate may be 8; not an architecture integer); `K_HARD > K_HARD_MAX` ⇒ fail-closed `k_invalid` [§02.4.1b] [§10.7] |
| **K_SOFT** | Inspection budget C derives from `search_budget` at SPEAR bind; not a QueryRecord field; not `K_HARD` [§04.13] |
| **MIG_APP_W** | D-reported generated native MIG `APP_DATA_WIDTH` (currently 128 at `D:/FPGA/miggen`; live [§23.9] snapshot); implementation evidence; not architecture freeze; not NCG record width; not MIG_PASS [§02.9] |
| **MIG_SYS_CLK** | D-reported generated MIG `InputClkFreq` (currently 166.666, `CLKIN_PERIOD=6000`); implementation evidence; not architecture freeze; not `LOGICAL_TICK`; board oscillator is not this net [§02.9] |
| **MIG_ADDR_WIDTH** | D-reported generated MIG address bits (currently 28); physical controller address; not `SEMANTIC_ID_WIDTH`; not §04 pointer ABI [§02.4.1] 3a |
| **SPEAR_MAC_PRODUCT** | Live C [§10.7.5] ranking arithmetic: Q1.7×Q4.12 → Q5.19 in 24 bits, then wider acc. CANDIDATE local layout; **not** identity width; A does not freeze Qm.n |
| **POSTING_ENTRY** | 64-bit T2 adjacency row [§02.4]; two may pack in one 128-bit group. Packing ≠ a 128-bit entry type [§02.9] |
| **FEM** | Failure Experience Memory — DUT/runtime failure records/prototypes and recovery history; may cite `episode_id`; FEM is not the episode store. Canonical store is T2 DDR; T1 is cache only [§02.4.1c] |
| **FEM_COMPACTION_RECOVER** | Compaction crash-safety observables: exactly one of `OLD_VALID` / `CANDIDATE_NEW` / `COMMITTED_NEW` after interruption (C [§11] table when published) |
| **FEM_DEST_INTEGRITY** | Dest-domain integrity class. `COMMITTED_CORRUPT` = COMMIT magic and dest CRC invalid; not a fourth compaction state; not a fourth `commit_state[1:0]` value; not an ASTRA status. Live [§11.12.3] dest observable is `integrity_fault` [§02.4.1c] |
| **Skill Engine** | Stores reusable procedures; may originate `ACTION_INTENT`; does not drive pins. Pin drive is the Primitive Executor after ASTRA + `BOUND` [§01.7] [§12.8] |
| **ASTRA** | Deterministic authority boundary under encoded rules/evidence for legality, proof validity, provenance, conflict, completeness, epistemic status, knowledge promotion, and action-precheck of intent+descriptor+safety_contract; ASTRA does not drive pins |
| **GEMINI** | Human-symbol/language expression adapter [§01.8]; may render/explain but cannot create/override ASTRA truth/status and cannot drive actuators |
| **Working Mind** | Active bounded cognitive process combining NCG, Q*, SPEAR, Skill, FEM and working state |
| **ACTION_INTENT** | Semantic request to act; never itself an actuator command. Origins include Q*, Skill, and `HUMAN_DEMO`; all use the same [§01.7] path [§12.4] [§12.8] |
| **ActionResolution** | Maps semantic_action_class → (capability_class, primitive_id, optional target_ref); fail ⇒ `NO_BINDING` |
| **Capability Binding** | Post-ASTRA commit mapping an intent to a verified installed hardware capability; `BOUND` is required before `PrimitiveCommand`; lookup is not this object |
| **PrimitiveCommand** | Issued executor command after `BOUND`; produces `command_id` |
| **ObservedEffect** | Attributable readback of an issued command; cites `command_id` plus episode/step |

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
**denied as identity**. They are optional prose only. Do not map working memory
→ T1/BRAM or long-term memory → T2/DDR. They are not ABI types and do not
determine truth status.

## 20.4 Core records

| Term | Definition |
|---|---|
| **Node** | Typed semantic identity with stable 32-bit reference, namespace/generation and metadata; T2 `NodeRecord` = 256 bits [§02.4.3] |
| **Edge** | Typed relation with direction, context/status/provenance references; T2 `EdgeRecord` = 256 bits; no utility/Q fields [§02.4.4] |
| **Value** | First-class typed scalar/range/enum/reference; never collapsed to sentinel node 0; T2 `ValueRecord` = 128 bits [§02.4.5] |
| **Context** | Explicit applicability/condition scope; T2 `ContextRecord` = 256 bits [§02.4.6] |
| **Provenance** | Source/revision/location/acquisition metadata and evidence ancestry; T2 `ProvenanceRecord` = 256 bits [§02.4.7] |
| **Posting list/page** | Indexed adjacency references used to avoid whole-graph scans; header 128 bits + 64-bit entries [§02.4.8] |
| **HotDirectoryEntry** | T1 placement/index record only, 128 bits; 32-bit ID and 32-bit T2 pointers; not an epistemic record [§02.4.2] |
| **QueryRecord** | Native binary request, currently R0.1 candidate in [§04] |
| **StructuredResult** | Native machine result including status/reason/answer/proof/provenance/context/conflict fields [§04] |
| **SemanticEvent** | Temporal/event packet carrying explicit logical ordering [§04] |
| **EpisodeRecord** | Required typed T2 class for temporal experience [§01.4][§02.2][§02.4]; not `NodeRecord`, not `FailureRecord`, not a `SemanticEvent` UART packet. FEM may cite `episode_id`; FEM is not the episode store. Bit width and field list are not frozen (UNKNOWN until live C/B publish a table A can gate). |
| **Knowledge Pack** | Versioned runtime-loadable binary semantic package. Live R1 [§04.6] ManifestHeader = 128 B (`reserved` 12 B, CRC over `[0:112)`). `pack_generation` u32 ≠ `knowledge_generation` u16. `reserved=16` / 132 B is illegal. |
| **ProofObject** | Machine-verifiable support path/rule/provenance object for ASTRA status decisions |
| **CapabilityDescriptor** | Canonical installed-hardware identity and legal primitive set [§05.2] |
| **ModuleManifest** | Install-time names for the same `CapabilityDescriptor` (`MODULE_ID` → `capability_id`) [§05.3] |

## 20.5 Result/status semantics

| Code | Wire [§04.12] | Meaning |
|---|---|---|
| *(illegal ASTRA status)* | `0x00` | Uninitialized-buffer detect; not a legal ASTRA `status` |
| `ANSWER` | `0x01` | Declared evidence/proof supports an answer within the active contract |
| `UNKNOWN` | `0x02` | Search is complete for the declared scope and no verified support is found |
| `CONFLICT` | `0x03` | Mutually incompatible relevant support exists and cannot be lawfully collapsed. Live R1 reason is `DISTINCT_VERIFIED_REFS` `0x30` [§03.9] [§04.12]. |
| `SEARCH_INCOMPLETE` | `0x04` | Search/proof budget ended before completeness was established |
| `UNSUPPORTED_QUERY` | `0x05` | Query/operator/**query** capability is outside implemented contract; not a hardware-capability code |
| `DATA_INTEGRITY_FAIL` | `0x06` | Active data/pack/generation/integrity contract failed |
| `PARSE_ERROR` | `0x80` | Human-adapter only; FPGA must not emit. Not semantic UNKNOWN |

Q-eval priority (first match) is owned by [§03.9]: integrity → unsupported →
`SEARCH_INCOMPLETE` → conflict → answer → unknown. Numeric encodings stay in [§04.12].
Reason-codes `TIE_OVERFLOW` `0x22`, `K_INVALID` `0x23`, `INVALID_DESCRIPTOR` `0x55`,
`COMMITTED_CORRUPT` `0x56` are **reasons**, not primary `status` [§03.9.2].
Dest-domain `COMMITTED_CORRUPT` [§02.4.1c] is the integrity class those
reason bits may report. It is not `UNKNOWN`, not `ANSWER`, and not
compaction `COMMITTED_NEW`. B owns the query-status mapping.

Transport faults (`CRC_ERROR`, `SEQ_GAP`, `DUPLICATE_FRAME`, overflow, stale
session/generation, unsupported ABI) are protocol statuses and must not be
silently mapped to `UNKNOWN`.

### 20.5.1 Actuation statuses (not §04.12 query encodings)

These are architecture statuses for [§01.7]. They are **not** ASTRA query
`0x01–0x06`. Numeric freeze is owned by [§03]/[§04] (Agent B).

| Status | Meaning |
|---|---|
| `NO_BINDING` | No compatible installed capability/primitive/instance; implies `NO_ACTION` |
| `ASTRA_DENY` | ASTRA rejected legality of intent+descriptor |
| `SAFETY_VETO` | ASTRA-admissible safety_contract fail; not a second approver |
| `STALE_DESCRIPTOR` | Version/generation/integrity mismatch; implies `NO_ACTION` |
| `NO_ACTION` | No `PrimitiveCommand` issued |
| `BOUND` | Post-ASTRA binding commit; command may be issued |
| `COMMAND_ACCEPTED` | `PrimitiveCommand` issued; not proof of effect |
| `EFFECT_UNOBSERVED` | Command issued; readback identity missing; no causal credit |
| `EFFECT_OBSERVED` | Command issued and attributable observed effect recorded |

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

**Alignment audit 2026-09-16:** the short-form constants above match [§23.1]
and [§02.5] (135 BRAM36 ≈ 607.5 KiB, 256 MB DDR3L, 16-bit bus, ~333 MHz /
~667 MT/s, ~1.334 GB/s theoretical peak). A 24-bit T1 `semantic_id` *type*
or 28-bit pointer type is **not** a hardware fact and is rejected in [§02.4.1].
A profile `ACTIVE_ID_RANGE` (which may happen to use 24 significant bits) is
not that type.

## 20.9 Architecture-candidate record widths

NCG T1/T2 sizes are owned by [§02.4]. Query/Result/Event remain [§04]
and are **not** NCG record types. They appear below only as a pointer.

| Record | Tier | Bits | Bytes |
|---|---|---:|---:|
| HotDirectoryEntry | T1 | 128 | 16 |
| NodeRecord | T2 | 256 | 32 |
| EdgeRecord | T2 | 256 | 32 |
| ValueRecord | T2 | 128 | 16 |
| ContextRecord | T2 | 256 | 32 |
| ProvenanceRecord | T2 | 256 | 32 |
| PostingPageHeader | T2 | 128 | 16 |
| PostingEntry | T2 | 64 | 8 |
| QueryRecord | wire | 256 | 32 |
| StructuredResult | wire | 384 | 48 |
| SemanticEvent | wire | 192 | 24 |

Wire records are owned by [§04]. T1/T2 NCG records are owned by [§02].
`semantic_id` / `node_id` fields are 32-bit (`SEMANTIC_ID_WIDTH`).
`ACTIVE_ID_RANGE` is not a row in this table.
These widths are **architecture candidates**. They are not latency, single-cycle
access, final physical packing, frozen MIG `app_data` width, or measured DDR
efficiency. D-reported generated `APP_DATA_WIDTH=128` does not rewrite this
table [§02.9].

`FailureRecord` / `SkillRecord` / `EpisodeRecord` are **not** rows in this
NCG table. Live R1 [§11.13] quotes `FailureRecord` 128 bits; [§12.10]
quotes `SkillRecord` 256 bits (typed `SKILL`; must not alias `NodeRecord`).
`EpisodeRecord` bit width and field list are not frozen (UNKNOWN until
C/B publish a table A can gate). Those Failure/Skill figures are C-owned
live prose; A does not freeze them here. See [§02.4].

## Tóm tắt tiếng Việt

Các bất biến semantic và authority được khóa rõ: dữ liệu logic không được đồng
nhất với nơi lưu vật lý; Top-K không phải câu trả lời; prediction/observation
không tự trở thành truth; UNKNOWN chỉ hợp lệ sau khi hoàn tất phạm vi search đã
khai báo. T0/T1/T2 là tầng vật lý, không phải loại trí nhớ nhận thức. NCG khóa
ID/pointer 32-bit (`SEMANTIC_ID_WIDTH` ≠ `ACTIVE_ID_RANGE`); `K_HARD` ≠ `K_HARD_MAX`; `MIG_APP_W` ≠ bề rộng record NCG; SPEAR Q5.19 24-bit ≠ identity; Pack/ABI-24 = 24 case gold ≠ identity; SemanticEvent 24 byte ≠ identity; XSim ≠ BOARD_PASS; NCG ≠ Query UART; directory T1 128 bit; Node/Edge 256 bit; không nhét utility
vào cạnh đã khóa. FailureRecord/SkillRecord (live C candidate 128/256) không khóa
trong bảng NCG; không alias NodeRecord. EpisodeRecord là lớp T2 bắt buộc,
không khóa bit/field; FEM không phải episode store. FEM canonical là T2 DDR;
T1 chỉ cache; `COMMITTED_CORRUPT` là dest-integrity, không phải trạng thái
compaction thứ tư. Stand-in `mig_ui_bram` ≠ persist FEM; `RTL_PIPELINE_DEPTH` ≠ sáu logical SPEAR stage; WNS OOC ≠ TIMING_PASS.
Oscillator board ≠ MIG `sys_clk`; pointer T2 0 ≠ DDR beat 0.
EPISODE ≠ FAILURE. Không map working memory→T1 hay LTM→T2.
ACTION_INTENT ≠ PrimitiveCommand; proposal ≠ execution ≠ credit;
ACTION_LANE_OBJECT ≠ QUERY_UART_RECORD;
bảy tên [§05.8] ≠ live X0-15 `Capability Binding`.
SKILL_STATE ≠ EXECUTION_PERMISSION; HUMAN_DEMO dùng cùng đường [§01.7];
NO_ACTION ≠ EFFECT_UNOBSERVED;
hardware capability ≠ query capability.
