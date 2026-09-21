# NATIVE AI CAUSAL ACCEPTANCE BENCHMARK R2 — MASTER VIEW
This single-file view concatenates the core package documents. The ZIP remains the canonical downloadable package.


---

# NATIVE AI CAUSAL ACCEPTANCE BENCHMARK R2

**Version:** R2.0  
**Snapshot:** 2026-09-21  
**Target:** `Jokejoker-designer/Native_SymAI` on Arty A7-100T  
**Observed repo head used for this update:** `3f0bc4cb84` (2026-09-21 01:27:31 UTC)

## 1. Why R2 exists

The older FE256 benchmark was valuable and must be preserved. It proved whether a
bounded semantic engine can return the correct `StructuredResult` over a frozen
set of 256 preregistered semantic cases.

However, project progress exposed a stronger failure mode:

> A DUT may reproduce FE256 semantics while the production Pack/DDR/runtime path
> is not causally supplying the knowledge used by the query engine.

The current project has already shown why this matters:

- the dedicated FE256 R1 reference can be functionally correct and FPGA-fit;
- a common-runtime ASTRA path has an XSim 256/256 bit-exact candidate result;
- the production Pack path and the production query path are not yet proven to
  share one committed semantic-to-physical knowledge image;
- current public status still says `PACK_ABI_24_24_PASS=NO`,
  `MIG_PASS=NO`, `ASTRA_PASS=NO`, `FE256_PASS=NO`, `BOARD_PASS=NO`,
  `FINAL_PASS=NO`;
- a repository audit explicitly identifies
  `PACK_TO_RUNTIME_KNOWLEDGE_BINDING_MISSING` /
  `SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE`.

Therefore FE256 must remain **necessary but no longer sufficient**.

## 2. New benchmark thesis

R2 asks, in order:

```text
Is the artifact identity real?
→ Did the Pack really commit to physical memory?
→ Did COMMIT publish the exact active semantic image?
→ Does the production query path actually read/use that image?
→ Does the common runtime reproduce FE256 without a benchmark-only engine?
→ Does behavior survive harmless representation changes?
→ Does behavior disappear when true causal support is removed?
→ Does learning actually alter later decision behavior?
→ Can actions be bound, executed, read back and credited safely?
→ Does the exact final artifact pass on the real board?
```

The benchmark therefore moves from **output parity** to **causal evidence**.

## 3. R2 acceptance layers

| Layer | Gate family | What it proves |
|---|---|---|
| L0 | Artifact / protocol integrity | We know exactly which source, bitstream, constraints and Pack were tested. |
| L1 | Runtime Knowledge Binding | Pack COMMIT causally publishes the knowledge image consumed by the query runtime. |
| L2 | Common-runtime semantic correctness | Production runtime, not the dedicated FE256 engine, reproduces FE256 + ASTRA semantics. |
| L3 | NSPF falsification | Correctness is not an ID/order/cache/clock/fixture artifact. |
| L4 | Developmental learning | Reward/experience causally changes future ranking/selection and survives only through the declared persistence path. |
| L5 | Capability/action grounding | Semantic intent cannot bypass physical capability, safety, execution or readback identity. |
| L6 | Human/GEMINI boundary | Human text/GEMINI can propose/render language but cannot become truth, proof, winner or actuator authority. |
| L7 | Board acceptance | The same declared artifact lineage closes timing, MIG, program, runtime, semantic and required research gates. |

## 4. Final verdicts are tiered

R2 deliberately separates claims:

```text
STATIC_FULL_EVIDENCE_CANDIDATE
NSPF_RESEARCH_CANDIDATE
DEVELOPMENTAL_LEARNING_CANDIDATE
ACTION_GROUNDED_CANDIDATE
NATIVE_AI_BOARD_CANDIDATE
OWNER_FINAL_REVIEW
```

A static Full Evidence pass does **not** imply developmental learning.
A developmental pass does **not** imply open-domain intelligence.
No automated runner may issue `BOARD_PASS` or `FINAL_PASS`.

## 5. What is retained from FE256 R1

The entire historical benchmark remains immutable:

- 256 preregistered cases:
  DIRECT 48, VALUE 32, REVERSE 32, MULTIHOP 32, CONTEXT 24,
  PROVENANCE 16, NEGATIVE 24, CONFLICT 16, IDENTITY 16, ABLATION 16.
- 24 Pack/ABI integrity cases.
- exact explicit-result / no-empty / no-timeout / no-false-refusal laws.
- proof, provenance, context, identity and direction rules.
- deterministic shuffle and causal ablation.

R2 does **not** alter those gold answers. It changes where FE256 sits in the
acceptance ladder and adds causal prerequisites that prevent fixture-backed
false passes.

## 6. Immediate current blocker

The highest-value blocking question is now:

> **Can a newly committed Pack change the production runtime's semantic answer
> because the query path read the newly committed physical DDR-backed records,
> rather than because a fixture/ROM/BRAM image or host-side precomputation already
> contained the answer?**

Until that is closed, later FE256 board claims are not accepted by R2.

## 7. Package contents

- `01_TARGET_CLAIM_AND_LAWS.md`
- `02_ACCEPTANCE_LADDER_R2.md`
- `03_GATE_MATRIX.csv`
- `04_RUNTIME_KNOWLEDGE_BINDING.md`
- `05_FE256_COMMON_RUNTIME.md`
- `06_NSPF_X0_FALSIFICATION.md`
- `07_DEVELOPMENTAL_LEARNING_AND_ACTION.md`
- `08_CURRENT_STATUS_20260921.md`
- `09_MIGRATION_FROM_FE256_R1.md`
- `cases/runtime_binding_cases.jsonl`
- `cases/nspf_x0_cases.jsonl`
- `cases/developmental_cases.jsonl`
- `BENCHMARK_MANIFEST.json`
- `SHA256SUMS.txt`

This package is designed to be copied into the repository as a new benchmark
layer without rewriting the historical FE256 R1 evidence.


---

# 01 — TARGET CLAIM AND BENCHMARK LAWS

## 1. Target claim

The R2 benchmark is designed for the following bounded claim:

> A fixed FPGA artifact can load a versioned knowledge image, resolve semantic
> identifiers to physical records, perform bounded evidence-governed retrieval
> and ASTRA status/proof reasoning, optionally adapt ranking/selection through
> FPGA-owned learning from attributed experience, and expose results/actions
> through interfaces whose authority boundaries are explicit and falsifiable.

This is **not** a claim of AGI, open-domain NLU, LLM equivalence, unrestricted
autonomy, or human-like understanding.

## 2. Core laws

### R2-LAW-01 — Artifact identity
Every scored board result must identify source commit/dirty state, Vivado
version, top, XDC, IP configuration, DCP/bit hash, Pack hash, ABI/schema hash,
board/JTAG identity and run ID.

### R2-LAW-02 — No inherited pass
Historical V1/FE256/reference evidence is regression evidence only. A new product
artifact must earn its own gate.

### R2-LAW-03 — Pack COMMIT is not semantic publication by assertion
A loader ACK or `active_generation` toggle is insufficient. Publication is
proven only when the production query runtime resolves and consumes the
committed image.

### R2-LAW-04 — Semantic-to-physical causality
A semantic answer must depend on the declared physical support:
directory/posting/root/record mapping, DDR/cache reads and ASTRA evidence.
Removing or changing sole support must alter the result as preregistered.

### R2-LAW-05 — FE256 is regression, not architecture
The dedicated FE256 engine may remain frozen as a reference. Final product
acceptance requires the common runtime path.

### R2-LAW-06 — Harmless representation changes must not change semantics
ID permutation, alias changes, physical relocation, deterministic case shuffle,
legal clock/stall variation and cache on/off may change latency but not the
semantic result.

### R2-LAW-07 — Causal support removal must change behavior
If the only verified proof edge/record/context support is removed or invalidated,
the previous answer must not survive from stale cache, host injection, duplicate
fixtures or benchmark-specific logic.

### R2-LAW-08 — Utility is not truth
Q*/SPEAR ranking can change inspection order but cannot manufacture verified
truth. ASTRA retains proof/status/conflict/completeness authority.

### R2-LAW-09 — Learning requires decision authority
A changed weight/cache/FEM record is not enough. The learned state must
causally alter a later ranking/selection/action decision under a controlled
counterfactual.

### R2-LAW-10 — Proposal != execution != observed effect != credit
Only a legally bound, actually issued command with attributable readback/effect
may receive execution credit.

### R2-LAW-11 — Language has no hidden authority
GEMINI/human adapters may parse/propose/render but may not inject final answer,
proof, semantic winner, actuator command or learning winner.

### R2-LAW-12 — Fail closed
Unknown, incomplete, conflict, corruption, generation mismatch, illegal action
or missing binding must remain explicit states. Silence/EMPTY is never semantic
success.

## 3. Observation vocabulary

Do not force binary truth when the hardware was not observed.

For individual predicates use:

```text
OBSERVED_TRUE
OBSERVED_FALSE
NOT_OBSERVED
NOT_APPLICABLE
```

For gate verdicts use:

```text
PASS
PASS_CANDIDATE
FAIL
BLOCKED
NOT_RUN
NOT_EVIDENCED
NOT_APPLICABLE
```

`PASS_CANDIDATE` at XSim/OOC never upgrades itself to board `PASS`.


---

# 02 — ACCEPTANCE LADDER R2

## L0 — ARTIFACT / PROTOCOL INTEGRITY

```text
L0.1 SOURCE_LINEAGE_RECORDED
L0.2 XSIM_REQUIRED_SMOKE
L0.3 POST_ROUTE_REQUIRED_PATHS_PASS
L0.4 EXACT_BITSTREAM_IDENTITY_RECORDED
L0.5 PROGRAM_CONFIGURATION_EVIDENCED
L0.6 PACK_ABI_24_24
```

L0 does not prove semantics.

## L1 — RUNTIME KNOWLEDGE BINDING

This is the new blocking layer introduced by R2.

```text
RK01 COMMIT_PUBLISHES_ACTIVE_GENERATION
RK02 COMMIT_PUBLISHES_ACTIVE_ROOT_OR_SLOT
RK03 DIRECTORY_RESOLVES_FROM_COMMITTED_IMAGE
RK04 POSTING_RESOLVES_FROM_COMMITTED_IMAGE
RK05 QUERY_TAGGED_PHYSICAL_READ_OBSERVED
RK06 READ_DATA_CAUSALLY_AFFECTS_TRAVERSAL
RK07 RELOCATION_INVARIANCE
RK08 CONTENT_MUTATION_SENSITIVITY
RK09 OLD_GENERATION_POISON_REJECT
RK10 CACHE_OFF_PARITY
RK11 FAIL_CLOSED_ON_MAPPING_OR_INTEGRITY_BREAK
RK12 REQUIRED_SENTINEL_READBACK
RK13 NO_PRODUCTION_DEPENDENCE_ON_FE256_FIXTURE_ROM
```

**Blocking rule:** no product FE256 board acceptance before L1 passes.

## L2 — COMMON-RUNTIME STATIC SEMANTICS

```text
CR01 COMMON_RUNTIME_FE256_CANONICAL_256_256
CR02 COMMON_RUNTIME_FE256_SHUFFLE
CR03 COMMON_RUNTIME_FE256_ABLATION
CR04 ASTRA_ADVERSARIAL_STATUS_PROOF
CR05 PROOF_PROVENANCE_CONTEXT_IDENTITY_ZERO_LEAK
CR06 NO_DEDICATED_FE256_ENGINE_ON_FINAL_PRODUCT_PATH
CR07 UART_E2E_32_32
```

The frozen FE256 R1 engine is used only as a reference/regression oracle.

## L3 — NSPF FALSIFICATION

```text
X0-01 ID_PERMUTATION
X0-02 ALIAS_PERMUTATION
X0-03 PHYSICAL_RELOCATION
X0-04 CASE_ORDER_SHUFFLE
X0-05 CACHE_ON_OFF_PARITY
X0-06 LOGICAL_TICK_VS_PHYSICAL_CLOCK_INVARIANCE
X0-07 DDR_STALL_JITTER_ROBUSTNESS
X0-08 MASKED_SLOT_TRANSFER
X0-09 UNSEEN_INSTANCE_ROLE_TRANSFER
X0-10 SOLE_SUPPORT_ABLATION
X0-11 CONFLICT_INJECTION
X0-12 GENERATION_SWAP_AND_STALE_REJECT
```

Passing only X0-01..07 supports representation/runtime robustness.
Transfer claims require X0-08/09.
Grounding claims require L5 physical action/effect evidence.

## L4 — DEVELOPMENTAL LEARNING

```text
DL01 LEARNER_ON_DECISION_PATH
DL02 SCALAR_REWARD_NO_WINNER_INJECTION
DL03 CONTROLLED_PRE_POST_DECISION_CHANGE
DL04 FREEZE_LEARN_COUNTERFACTUAL
DL05 RESET_REMOVES_VOLATILE_EFFECT
DL06 PERSIST_RELOAD_RESTORES_EXACT_EFFECT
DL07 FEM_FAILURE_MEMORY_CAUSAL_EFFECT
DL08 SPEAR_TOPK_FIXED_BUDGET_EFFECT
DL09 QSTAR_SELECTION_CAUSAL_EFFECT
DL10 HELDOUT_SKILL_OR_INSTANCE_TRANSFER
DL11 TEACHER_FALSE_INPUT_ANTI_PARROT
DL12 NO_UNEXECUTED_CREDIT
```

A weight/state update without a later decision difference is **not** a learning pass.

## L5 — CAPABILITY / ACTION GROUNDING

The canonical seven named gates are preserved exactly:

```text
CAPABILITY_ENUM_PASS
NO_BINDING_NO_ACTION_PASS
SAFETY_VETO_PASS
COMMAND_READBACK_PASS
STALE_DESCRIPTOR_REJECT_PASS
GEMINI_NO_ACTUATOR_AUTHORITY_PASS
UNEXECUTED_NO_CREDIT_PASS
```

Add one causal grounding campaign:

```text
GROUND01 ACTION_EFFECT_IDENTITY
GROUND02 SENSOR_STATE_CAUSAL_DEPENDENCE
GROUND03 EFFECT_ABLATION_OR_MISMATCH_REJECT
```

## L6 — HUMAN / GEMINI BOUNDARY

```text
HG01 HUMAN_TEXT_ADAPTER_HASH_FROZEN
HG02 HELDOUT_PARAPHRASE_TO_SAME_QUERY_SEMANTICS
HG03 GEMINI_PROPOSAL_ONLY
HG04 GEMINI_NO_PROOF_OR_STATUS_OVERRIDE
HG05 GEMINI_NO_ACTUATOR_AUTHORITY
HG06 RENDERER_NO_SEMANTIC_AUTHORITY
HG07 TEACHER_OFF_HELDOUT_SEMANTIC_CASES
```

## L7 — BOARD ACCEPTANCE

### Static claim

```text
L0 + L1 + L2 + required board timing/MIG/program evidence
→ STATIC_FULL_EVIDENCE_BOARD_CANDIDATE
```

### Research claim

```text
STATIC_FULL_EVIDENCE_BOARD_CANDIDATE
+ required L3 campaign
→ NSPF_RESEARCH_BOARD_CANDIDATE
```

### Developmental claim

```text
NSPF_RESEARCH_BOARD_CANDIDATE
+ L4
+ required L5 action/grounding gates for the claimed capability
+ L6 authority boundary
→ NATIVE_AI_DEVELOPMENTAL_BOARD_CANDIDATE
```

Only the owner may issue the final project stamp after reviewing raw evidence.


---

# 04 — RUNTIME KNOWLEDGE BINDING

## Why this gate is mandatory

The recent audit found a decisive architecture gap: Pack writes can reach MIG/DDR
while the candidate query path can still resolve from build-time directory/posting
fixtures. A semantic benchmark can therefore appear correct without proving the
runtime knowledge image is the causal source.

R2 turns this into a first-class acceptance campaign.

## Required experiment pair

Use two physically different Packs with controlled semantic changes:

```text
Pack A:
  generation = G
  semantic fact F = value/object A
  physical placement = slot/address map A

Pack B:
  generation = G+1
  same schema/ABI
  one preregistered semantic change F -> value/object B
  physical placement deliberately relocated
```

The semantic query is the same except the required knowledge generation field is
updated according to the canonical generation contract.

### Control C0 — same semantics, relocated physical placement
Build A and A' with identical semantics but different valid physical locations.

Expected:
- same semantic result;
- different physical addresses/read trace;
- no dependence on fixture addresses.

### Intervention I1 — semantic content mutation
Build B with one sole-support fact changed.

Expected:
- targeted query changes exactly as gold specifies;
- unrelated queries remain unchanged.

### Intervention I2 — stale generation poison
Keep old slot/cache contents intentionally incompatible/stale.

Expected:
- new generation never returns the old answer;
- stale mapping is rejected or bypassed according to the contract.

### Intervention I3 — cache off
Disable/flush T1 cache without changing Pack.

Expected:
- same semantics;
- latency/work may change;
- physical DDR reads must become observable where expected.

### Intervention I4 — support ablation
Remove the only verified proof support.

Expected:
- previous ANSWER disappears into the preregistered explicit status;
- no stale answer survives.

## Required observables

At minimum retain:

```text
pack_hash
schema_hash
abi_hash
generation
active_slot/root
semantic_id
directory pointer
posting pointer
query txn id
query-tagged DDR command address
returned read data / integrity result
walker evidence ref
ASTRA proof/status
StructuredResult
cache hit/miss state
```

A raw MIG read count is insufficient. The read must be attributable to the query
and its returned data must be causally necessary for the downstream result.

## Hard fail conditions

Any of these blocks L1:

- query path has no connection to committed Pack state;
- `active_generation` is not consumed by the runtime;
- runtime directory/posting remains build-initialized fixture-only;
- physical relocation changes semantics;
- content mutation does not change the targeted result;
- stale old-generation answer survives;
- Pack ACK occurs before required writes are drained;
- query result can be generated without the required physical record;
- host/gold code directly writes winners/results into DUT-visible state.


---

# 05 — FE256 AS COMMON-RUNTIME REGRESSION

## 1. FE256 is retained unchanged

R2 does not replace the 256-case benchmark. It changes its role.

Old interpretation:

```text
FE256 pass ≈ major project semantic acceptance
```

R2 interpretation:

```text
FE256 pass = static semantic regression gate
             AFTER runtime knowledge binding is proven
```

## 2. Production path requirement

The final scored path is:

```text
QueryRecord
→ committed generation/root
→ exact directory/index
→ posting/value/context/provenance records
→ bounded walker/frontier
→ candidate/evidence
→ ASTRA proof/status/conflict/completeness
→ StructuredResult
```

The dedicated `fe256_query_path` may remain frozen for:

- known-good regression;
- comparator/reference behavior;
- corruption detection;
- architecture debugging.

It must not be the final product reasoning path.

## 3. Required FE256 sequence

```text
CR01 canonical 256/256
→ CR02 deterministic shuffle 256/256
→ CR03 Pack-A/Pack-B ablation
→ CR04 ASTRA adversarial/status-proof vectors
→ CR05 identity/context/provenance leak checks
→ CR06 common runtime on final product path
→ CR07 UART E2E 32/32
```

All stages must retain exact artifact lineage.

## 4. Current evidence interpretation

A common-runtime `256/256 bit-exact` XSim result is valuable and should be kept as
a candidate regression result. It does **not** satisfy R2 by itself because the
current recorded result explicitly says:

- simulation only;
- common runtime not on the product M4 top;
- no PROGRAM/TIMING/BOARD/ASTRA/FE256 pass claimed.

R2 therefore records it as:

```text
COMMON_RUNTIME_FE256_XSIM = PASS_CANDIDATE
COMMON_RUNTIME_FE256_PRODUCT_TOP = NOT_EVIDENCED
COMMON_RUNTIME_FE256_BOARD = NOT_EVIDENCED
```


---

# 06 — NSPF-X0 FALSIFICATION CAMPAIGN

The purpose of NSPF-X0 is to answer a stronger question than FE256:

> Is the observed behavior caused by the intended semantic structure, or by
> accidental IDs, fixed fixtures, order, timing, cache state or memorized cases?

## Test set

| ID | Intervention | Expected invariant / change |
|---|---|---|
| X0-01 | Permute canonical IDs consistently | Same semantics, new IDs. |
| X0-02 | Change aliases/labels only | Same canonical semantics. |
| X0-03 | Relocate records physically | Same semantics, different physical trace. |
| X0-04 | Shuffle query order | Same case results. |
| X0-05 | Cache on vs flushed/off | Same semantics; work/latency may differ. |
| X0-06 | Change physical clock / preserve logical semantics | Same logical result within legal timing. |
| X0-07 | Inject bounded DDR stalls/jitter | Same semantics or explicit timeout only if preregistered bound exceeded. |
| X0-08 | Mask one role/slot and require inference/transfer | Correct fill only if support exists; no lookup leak. |
| X0-09 | New instance with same relational role | Transfer without hard-coded instance ID. |
| X0-10 | Remove sole support edge/record | Previous answer must disappear/change. |
| X0-11 | Inject verified contradictory support | ASTRA must emit conflict law, not pick by utility. |
| X0-12 | Swap generation with stale cache retained | New generation wins; stale result rejected. |

## Anti-cheating requirements

A test is invalid if:

- gold answer is directly visible to DUT logic;
- host sends winner/answer/proof;
- intervention changes more than the preregistered causal variable;
- test and expected output share one unverified exporter that could reproduce the
  same bug on both sides;
- only latency is checked while semantic output is constant;
- the same instance/case is repeated and counted as independent transfer.

## Research claim ceiling

Passing X0 supports only the exact tested forms of invariance/transfer.
It does not establish general intelligence or open-domain abstraction.


---

# 07 — DEVELOPMENTAL LEARNING AND ACTION

## 1. Learning acceptance

The project now contains Q*, SPEAR and FEM components, but R2 does not award a
learning pass merely because those blocks synthesize, update state or pass local
vectors.

The decisive criterion is **decision causality**.

### DL01 — learner on decision path
Show the learned state is read by the exact path that selects/ranks the later
candidate/action.

### DL02 — scalar reward, no winner injection
The host/teacher may provide an allowed scalar/ordinal reward and transaction
identity. It may not provide the desired selected candidate, final answer,
gradient, delta-weight or semantic winner.

### DL03 — controlled pre/post decision change
For a preregistered context, capture the decision before learning, apply one
attributed experience/reward sequence, then repeat the same decision context.
The changed decision/rank must match the preregistered causal expectation.

### DL04 — freeze counterfactual
Repeat the same episode with `learn=0` or frozen state.
If behavior changes identically, the learning claim fails.

### DL05 — reset causality
Reset volatile learned state. The learned effect must disappear unless the
contract explicitly reloads persistence.

### DL06 — persistence/reload
Persist, reset/reprogram as specified, reload the exact generation/version and
show the learned effect returns bit-exact or within a preregistered tolerance.

### DL07 — FEM causal effect
A recorded failure prototype must alter a later legal decision/rank in the
declared context. A stored record that is never consumed is not persistence
acceptance.

### DL08 — SPEAR fixed-budget value
At the same search budget, learned ranking must improve the preregistered
needed-candidate-in-Top-K metric over the frozen heuristic/control, or the
learning advantage claim is rejected.

### DL09 — Q* selection effect
Q* learned/value state must causally alter proposed-action selection under a
controlled counterfactual while remaining subordinate to legality/safety.

### DL10 — held-out transfer
A skill/relational policy learned on one instance must work on a preregistered
unseen instance without injecting its answer/trajectory.

### DL11 — anti-parrot
Incorrect teacher language/reward identity must not become verified FACT merely
because it was presented by the teacher.

### DL12 — no unexecuted credit
Top-1 proposal, refused action, safety veto or unissued command gets zero
execution credit.

## 2. Action acceptance

Preserve the canonical action chain:

```text
ACTION_INTENT
→ ActionResolution
→ CapabilityDescriptor
→ ASTRA legality/safety precheck
→ CapabilityBinding
→ PrimitiveCommand
→ executor
→ physical effect/readback
→ attributed reward/credit
```

The seven canonical acceptance names are:

1. `CAPABILITY_ENUM_PASS`
2. `NO_BINDING_NO_ACTION_PASS`
3. `SAFETY_VETO_PASS`
4. `COMMAND_READBACK_PASS`
5. `STALE_DESCRIPTOR_REJECT_PASS`
6. `GEMINI_NO_ACTUATOR_AUTHORITY_PASS`
7. `UNEXECUTED_NO_CREDIT_PASS`

## 3. Grounding

A grounding claim additionally requires a real sensor/action/effect causal loop:

- sensor state is captured with identity/time/generation;
- action is issued through a valid binding;
- readback/effect is attributed to the command;
- altering the physical effect or sensor evidence changes later state/credit as
  preregistered;
- fabricated/mismatched readback is rejected.

This is intentionally stronger than a semantic demo.


---

# 08 — CURRENT STATUS MAPPING — 2026-09-21

**Repository snapshot used:** `Jokejoker-designer/Native_SymAI`  
**Observed HEAD:** `3f0bc4cb84`  
**Latest observed commit message:** unique query silicon was programmed/tested,
but Pack ABI remained NO.

This file is a benchmark mapping, not a new PASS stamp.

## High-level mapping

| R2 item | Current classification | Evidence interpretation |
|---|---|---|
| Frozen FE256 R1 reference | PASS_CANDIDATE / reference only | XSim 256/256 and legal routed reference evidence exist; not final product path. |
| Common-runtime FE256 XSim | PASS_CANDIDATE | Recorded 256/256 bit-exact simulation; result explicitly says not FE256/ASTRA/BOARD/TIMING pass. |
| Common-runtime on product top | NOT_EVIDENCED | Recorded common-runtime result says it was not on the M4 product top. |
| Pack ABI 24/24 board | FAIL / OPEN | Public status remains `PACK_ABI_24_24_PASS=NO`. |
| Runtime DDR load/readback publication | NOT_EVIDENCED / BLOCKING | Loader can write/check storage, but semantic publication to query runtime is not proven. |
| Semantic→physical runtime binding | FAIL / BLOCKING | Audit identifies Pack→runtime binding missing/incomplete for inspected U33 path. |
| Final MIG pass | NOT_EVIDENCED | `MIG_PASS=NO`. |
| Final timing pass | NOT_EVIDENCED | Individual candidates meet timing, but final project `TIMING_PASS=NO`. |
| Program pass | NOT_EVIDENCED | Bits were programmed, but project `PROGRAM_PASS=NO`; artifact/semantic closure is not satisfied. |
| ASTRA final pass | NOT_EVIDENCED | `ASTRA_PASS=NO`. |
| FE256 final/product pass | NOT_EVIDENCED | `FE256_PASS=NO`. |
| Q*/SPEAR/FEM RTL presence | OBSERVED_TRUE | Blocks/reference/tests exist. Presence is not decision-authority evidence. |
| Learning decision authority | NOT_EVIDENCED | R2 DL01–DL04 remain required. |
| FEM persistence final | NOT_EVIDENCED | `FEM_PERSIST_PASS=NO`. |
| Board pass | NOT_EVIDENCED | `BOARD_PASS=NO`. |
| Final pass | NOT_EVIDENCED | `FINAL_PASS=NO`. |

## What changed versus the old benchmark

The project has progressed beyond asking whether FE256 semantics can be
implemented efficiently. The more important open question is now whether the
**production memory/runtime topology is causally correct**.

Therefore the immediate priority under R2 is:

```text
L1 Runtime Knowledge Binding
→ L2 common-runtime FE256 on product path
→ L3 falsification
→ only then stronger developmental/grounding claims
```

Do not spend effort making the dedicated FE256 reference prettier. It has already
served its architectural purpose.


---

# 09 — MIGRATION FROM FE256 R1

## Keep unchanged

- Historical D1–D5 evidence.
- FE256 256-case family counts and gold.
- Pack/ABI 24-case gold.
- exact result/status/proof/provenance rules.
- deterministic shuffle.
- semantic ablation.
- FE-UART-E2E-32 concept.
- no host answer/winner authority.

## Reclassify

| Old element | R2 treatment |
|---|---|
| FE256 as primary acceptance endpoint | Move to L2 static semantic regression. |
| Dedicated FE256 engine | Freeze as reference only; not final production path. |
| Pack/ABI before FE256 | Retain, but expand with L1 semantic publication/causality. |
| Simple DDR readback | Retain, but require query-tagged, causally necessary runtime reads. |
| Ablation near end | Move earlier and combine with L1/L3 causal tests. |
| Shuffle | Retain as order-invariance regression. |
| UART human chat | Retain, but authority-boundary checks move into L6. |
| Learning modules | No pass from unit presence; require L4 decision causality. |
| Sensor/action claims | Require L5 capability binding + effect readback. |

## Remove from final acceptance logic

Do not accept any of these as final proof:

- code-0 build alone;
- XSim alone for a board claim;
- PROGRAM alone for semantic correctness;
- pack loader ACK alone for active knowledge publication;
- BRAM/ROM fixture parity alone;
- common exporter agreement alone;
- a changed weight/state that never changes a later decision;
- UART text that was rendered/selected by the host;
- one positive answer without the paired causal intervention.

## Suggested repository location

```text
CANON_BLUEPRINT/verification/native_ai_benchmark_r2/
```

The existing `_ARCHIVE/NATIVE_AI_FULL_EVIDENCE_FE256_BENCHMARK_R1/` should remain
read-only and referenced by hash/path.
