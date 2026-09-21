---

# FILE: 00_README.md

# Native_SymAI Benchmark R1 — Causal Benchmark Candidate

**Date:** 2026-09-21  
**Status:** CANDIDATE — NOT AUTHORITY / NOT A PASS STAMP  
**Repository:** `Jokejoker-designer/Native_SymAI`  
**Repo snapshot inspected:** `3f0bc4cb841d80d127385a8190d579f2ffd82418`  
**Additional board evidence:** owner-provided run after that repository snapshot.

## Why R1 exists

R0.1 correctly separated Pack/ABI, FE256, causal ablation, NSPF-X0 and developmental tests, but recent silicon work exposed three benchmark weaknesses:

1. **Output parity was sometimes stronger than causal proof.** A module can return the expected result while bypassing the declared runtime memory source.
2. **Observation semantics were underspecified.** In particular, `generation_flipped=0` is not equivalent to “no COMMIT was observed.”
3. **UART multiplexing is itself a causal boundary.** Query interception can steal Pack payload words if routing is based on marker values rather than transaction ownership/state.

R1 therefore keeps the core Blueprint vision and old benchmark families, but reorganizes acceptance around **causal edges**, not only module outputs.

## R1 benchmark layers

```text
L0 — PHYSICAL / PROTOCOL
     UART mux, Pack24, commit observation, destination completion

L1 — RUNTIME MEMORY CAUSALITY
     Pack→active root→directory/posting→T2/DDR causal binding

L2 — SEMANTIC CORRECTNESS
     FE256, ASTRA adversarial/status-proof, shuffle, proof/provenance

L3 — REPRESENTATION FALSIFICATION
     ID permutation, alias replacement, causal ablation, cache parity,
     runtime knowledge dependence

L4 — DEVELOPMENTAL INTELLIGENCE
     unseen-instance transfer, 4→8→16 structural transfer,
     teacher anti-parrot, sensor grounding, reset/restore, FEM/skills
```

## Non-negotiable laws

```text
CORRECT_OUTPUT != CAUSAL_PROOF
DECLARED_SOURCE != CAUSAL_SOURCE
FALSE != ABSENT != NOT_OBSERVED != NOT_APPLICABLE
PROGRAM_PASS != BOARD_SEMANTIC_PASS
XSIM_PASS != BOARD_PASS
MODULE_PASS_SUM != SYSTEM_CAUSAL_PASS
PHYSICAL_PLACEMENT != SEMANTIC_IDENTITY
TOP_K != ANSWER
SEARCH_INCOMPLETE != UNKNOWN
```

## Governance rule

Do **not** overwrite the current R0.1 gold or authority files merely to make a DUT pass. R1 is a candidate contract. Freeze R0.1, review R1 independently, then only the project owner may promote R1 into Canon.


---

# FILE: 01_BENCHMARK_ARCHITECTURE_R1.md

# Benchmark Architecture R1

## 1. What remains unchanged from the Blueprint

The project goal remains valid:

- stable semantic identity;
- explicit typed relations/events;
- sparse bounded activation;
- T0/T1/T2 physical stratification;
- evidence/provenance/conflict governance;
- ASTRA authority over encoded legality/evidence/status;
- Q* strategy ≠ truth;
- SPEAR ranking ≠ truth;
- language adapter ≠ native cognition;
- physical placement ≠ epistemic class.

R1 does **not** redefine the Native AI thesis. It changes how that thesis is falsified.

## 2. The central R1 correction

Old-style reasoning:

```text
Pack PASS + Directory PASS + Walker PASS + ASTRA PASS
≈ system PASS
```

R1 rejects that inference.

R1 requires proof of the edges:

```text
Pack COMMIT
→ runtime active root
→ semantic lookup
→ posting
→ canonical T2/DDR record
→ retrieved evidence
→ ASTRA status/proof
```

A PASS on each block is insufficient if the output can bypass one of those edges.

## 3. Five evidence layers

### L0 — Physical / Protocol

Proves that bytes/events arrive, are owned by the correct transaction path, commit atomically, and become destination-complete.

Allowed claim: reliable protocol/storage substrate for the tested artifact.

### L1 — Runtime Memory Causality

Proves that semantic outputs depend on the active committed knowledge image and follow relocation/generation changes.

Allowed claim: runtime semantic retrieval is causally bound to active knowledge.

### L2 — Semantic Correctness

FE256 and ASTRA adversarial suites test bounded semantic/status/proof behavior after L1 is closed.

### L3 — Representation Falsification

Attempts to rule out hard-coded IDs, hidden answer tables, fixture dependence and stale caches.

### L4 — Developmental Intelligence

Tests transfer, grounding, learning, teacher boundaries, skills and failure memory.

## 4. Claim ceilings

| Highest closed layer | Maximum claim |
|---|---|
| L0 | Hardware/protocol correctness |
| L1 | Runtime knowledge causal dependence |
| L2 | Bounded semantic correctness |
| L3 | Bounded support for representation hypothesis |
| L4 | Bounded developmental/transfer candidate |

No layer implies AGI, consciousness, universal reasoning or human-equivalent cognition.


---

# FILE: 02_PACK_ABI24_R1_CONTRACT.md

# Pack ABI-24 R1 Contract

## 1. Keep the 24-case taxonomy

R1 keeps the existing case groups unchanged:

```text
VALID   V-01..V-04
SCHEMA  S-01..S-04
ABI     A-01..A-04
CONTENT C-01..C-04
CRC     R-01..R-04
GEN     G-01..G-04
```

The UART load outcome/reason expectations remain frozen unless a separate owner-authorized authority change is made.

## 2. Replace Boolean-only generation semantics

The old comparison effectively treated:

```text
reject → generation_flipped = 0
```

as if `0` were directly observed.

R1 separates **commit applicability** from **observed state transition**.

### Commit policy

Each case declares one of:

```text
MUST_COMMIT_FLIP
MUST_NOT_COMMIT
```

For the current 24 cases:

```text
MUST_COMMIT_FLIP:
  V-01 V-02 V-03 V-04 R-04 G-01

MUST_NOT_COMMIT:
  S-01..S-04
  A-01..A-04
  C-01..C-04
  R-01..R-03
  G-02 G-03 G-04
```

### Positive COMMIT proof

`MUST_COMMIT_FLIP` passes only if:

```text
capture_valid == true
overflow == false
same_capture_epoch == true
commit_event == true
generation_before is observed
generation_after is observed
generation_after != generation_before
generation_flipped == true
destination_complete == true
```

### Negative COMMIT proof

`MUST_NOT_COMMIT` does **not** pass merely because `generation_flipped` is absent.

It requires explicit negative coverage:

```text
capture_valid == true
overflow == false
observation_window_complete == true
terminal reject observed
commit_count == 0
```

`generation_flipped` must be absent/N/A for a no-COMMIT case. The benchmark must not synthesize `false` from TSV expected data.

This distinguishes:

```text
FALSE
ABSENT
NOT_OBSERVED
NOT_APPLICABLE
```

and prevents an unobserved transition from being scored as a valid negative observation.

## 3. R-04 query law

R-04 remains:

```text
load = GOLD / LOAD_OK
COMMIT = observed flip
query_status = 6
query_reason = 80 (0x50, PACK_CRC)
```

The QueryRecord must be evaluated after the R-04 committed destination state, on the same declared test lineage.

## 4. G-04 lifecycle law

G-04 must be **self-contained**. It may not depend on an earlier external G-01 case surviving an inter-case CLEAR.

Within one G-04 benchmark case:

```text
establish active generation = 2
→ attempt failed-B / PAGE_CRC
→ active generation must remain 2
→ issue stale query with q_gen = 1
→ query_status = 6
→ query_reason = 84 (0x54, STALE_GENERATION)
```

An inter-case CLEAR that destroys this state invalidates the G-04 experiment rather than proving 6/84.

## 5. Destination-complete law

A UART ACK is insufficient. For every `MUST_COMMIT_FLIP` case, destination completion must be causally observed:

```text
all writes retired
→ readback/verification addressed to the actual written destination
→ matching transaction/generation
→ only then load acceptance
```

The V-03 `region_base` vs `region_base + rg_off` bug is now a permanent regression target.

## 6. R1 Pass definition

`PACK_ABI_24_24_PASS_R1_CANDIDATE` requires, on one declared artifact lineage:

- 24/24 UART outcome/reason/token match;
- positive COMMIT proof for all six commit cases;
- explicit zero-COMMIT coverage for all 18 reject cases;
- R-04 query 6/80;
- G-04 query 6/84 under the self-contained lifecycle;
- destination-complete evidence for the six commit cases;
- no capture overflow/epoch ambiguity;
- exact bitstream/run manifest.

This candidate name does not authorize the historical `PACK_ABI_24_24_PASS` stamp.


---

# FILE: 03_UART_MUX_ARBITRATION_R1.md

# UART Mux / Arbitration R1

Recent silicon work showed that QueryRecord interception can corrupt Pack behavior even when Pack and Query blocks are individually correct.

A query signature such as low word `0x4E51` must never steal payload from an active Pack transaction.

## Gate name

```text
UART_MUX_8_8_PASS
```

This is an L0 gate, not a semantic PASS.

## Eight preregistered cases

| ID | Intervention | Required behavior |
|---|---|---|
| MUX-01 | Query marker while UART owner is IDLE | Query path accepts exactly once |
| MUX-02 | Same marker appears as Pack payload while OP_BEGIN active | Pack path owns it; query sees nothing |
| MUX-03 | Marker is first data word after Pack BEGIN | Pack path owns it; no steal |
| MUX-04 | Valid Pack terminates, then Query begins | Ownership transfers once; no drop/dup |
| MUX-05 | Query terminates, then Pack begins | Ownership transfers once; no drop/dup |
| MUX-06 | CLEAR then Query | clean query ownership; no stale pack busy |
| MUX-07 | malformed query-looking word inside Pack | still Pack-owned until Pack transaction releases |
| MUX-08 | back-to-back Pack/Query under UART backpressure/busy | same logical order and exactly-once delivery |

## Required observables

```text
uart_accept_count
pack_accept_count
query_accept_count
owner_state
pack_busy / uart_busy
clear_epoch
drop_count
dup_count
```

Pass requires:

```text
drop_count = 0
dup_count = 0
misroute_count = 0
```

and each accepted word has exactly one owner.

## Permanent regressions from current project

The suite must permanently catch:

1. **Unconditional Query steal** — every UART word matching `0x4E51` is diverted.
2. **Missing Pack ownership guard** — query interception is allowed while OP_BEGIN/Pack transaction is active.


---

# FILE: 04_RUNTIME_KNOWLEDGE_BINDING_R1.md

# Runtime Knowledge Binding R1

## Gate

```text
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS
```

This is the missing causal gate between successful Pack storage and FE256 semantic acceptance.

## Why it exists

A system can pass static semantic tests while:

```text
Pack → DDR
Query → dir_a.mem / post_a.mem
```

If so, the semantic answer does not depend on the active committed Pack.

R1 therefore requires interventions on the physical source of truth.

## Eight cases

### RKB-01 — Install

Pack generation G1 at physical placement P1:

```text
A --R--> B
```

Query A must return B **and** the trace must show the lookup/dereference path reaching G1/P1.

### RKB-02 — Relocation

Relocate the same semantic graph from P1 to P2. Poison or invalidate P1.

Same QueryRecord must still return B and the observed physical dereference must use P2.

### RKB-03 — Content mutation

At the active placement change only canonical content:

```text
A --R--> B
```

to:

```text
A --R--> C
```

Keep the QueryRecord identical. Result must change B→C.

### RKB-04 — Edge dereference necessity

Keep directory/posting structure the same but invalidate/corrupt only the referenced canonical EdgeRecord.

The system must fail closed or emit the preregistered integrity/status result.

### RKB-05 — Generation switch with stale cache

Warm T1/cache on G1 (`A→B`), commit G2 (`A→C`), and query without manually clearing semantic caches.

Result must be C and stale G1 must not influence proof/result.

### RKB-06 — Cache parity

Same generation/query with cache enabled and disabled:

```text
semantic result/proof identical
```

Only performance metadata may differ.

### RKB-07 — Runtime knowledge removal

Remove the sole supporting relation from the active Pack while keeping host fixtures unchanged.

The result must change to the preregistered unsupported/unknown result.

### RKB-08 — Host/fixture independence

Disable or poison any compile-time directory/posting/expected-neighbor fixture that is not the declared runtime source.

The production query must either continue from canonical runtime memory or fail closed. It must not silently obtain the gold answer from the fixture.

## Required causal evidence

For every case record:

```text
query_id / txn_id
active_generation
semantic_id
directory source
posting source
physical pointer/root
DDR/T2 read transaction identity
retrieved record identity
ASTRA/result dependency
```

A raw “DDR read happened” is insufficient. The read must be causally necessary to the returned semantic result.

## Gate rule

FE256 board acceptance may not be promoted unless `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS` is closed first on the same declared runtime lineage.


---

# FILE: 05_FE256_AND_ASTRA_R1.md

# FE256 and ASTRA R1

## 1. FE256-R0 remains frozen regression

Do not rewrite the existing 256-case gold to rescue an implementation.

FE256-R0 remains valuable as a **static semantic functional suite**.

It does not by itself prove:

- runtime DDR dependence;
- semantic→physical resolution;
- placement invariance;
- generalization;
- the Native AI research hypothesis.

## 2. New prerequisite

Before FE256 can become board semantic evidence:

```text
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS
```

must already be closed.

Otherwise 256/256 can be explained by static BRAM fixtures or baked paths.

## 3. FE256-R1 candidate deltas

Create a versioned FE256-R1 rather than editing FE256-R0 in place.

Required fixes:

### Identity cases

Alias-A/B pairs must not share the same `subject_id` on the wire when the purpose is to test identity leakage.

Include:

```text
different semantic IDs
controlled alias mapping
ID permutation intervention
same intended meaning where declared
```

### Proof references

Avoid proof references that are trivially affine in the ID allocator.

For multi-hop, `proof_ref` should resolve to real runtime proof/edge objects used by the path.

### Fixture independence

The generator that builds Pack fixtures must not be the sole independent authority for expected-neighbor/proof answers.

Gold truth and DUT storage compilation must have an independence boundary.

### Explicit causal subset

At least a preregistered subset of FE256 cases must be rerun under:

```text
Pack-A support
Pack-B support removed
content mutation
cache on/off
generation switch
```

## 4. ASTRA adversarial suite remains separate

Keep ASTRA adversarial/status-proof tests separate from FE256 histogram coverage.

They must verify distinctions such as:

```text
ANSWER
UNKNOWN
CONFLICT
SEARCH_INCOMPLETE
UNSUPPORTED_QUERY
DATA_INTEGRITY_FAIL
```

and must preserve:

```text
FALSE != UNKNOWN
UNKNOWN != SEARCH_INCOMPLETE
NOT_APPLICABLE != FALSE
NOT_OBSERVED != FALSE
```

The Pack24 generation lesson should be propagated into all future ASTRA observability schemas.


---

# FILE: 06_NSPF_X0_R1.md

# NSPF-X0 R1 — Strengthened Research Falsification

The existing X0 direction remains correct and becomes the primary research benchmark after L0–L2 are closed.

## Keep these tests

```text
X0-01 ID Permutation
X0-02 Alias Replacement
X0-03 Masked Slot
X0-04 Causal Ablation
X0-05 Clock/Spacing Invariance
X0-06 Event Jitter
X0-07 Reset/Restore
X0-08 Sensor Grounding
X0-09 False Teacher / Anti-parrot
X0-10 Cache On/Off
X0-11 Unseen Instance Transfer
X0-12 4→8→16 Structural Transfer
X0-13 Runtime Knowledge Dependence
X0-14 Stale Cache / Generation
X0-15 Capability Binding
```

## R1 strengthening

### ID permutation

Permutation must cover IDs that influence directory/posting/proof references, not only renderer labels.

Pass only if behavior is preserved modulo the declared permutation.

### Masked slot

The hidden slot cannot be reconstructed from a special-case answer table.

Control:

```text
new IDs
same structural rule
held-out composition
```

### Causal ablation

Remove only the declared causal support. Require result/proof change.

If result survives, inspect:

```text
duplicate support
stale cache
host answer injection
fixture answer
precomputed derived fact
```

### Unseen-instance transfer

Training and test instances must differ in raw IDs and physical placement.

At least one memorization baseline must be preregistered.

### 4→8→16 transfer

Mandatory controls:

```text
disable literal table shortcut
disable primitive shortcut where the claim requires structural inference
new IDs
held-out widths/compositions
same rule semantics
```

The transfer claim passes only if performance exceeds the preregistered literal/script baseline.

### Runtime knowledge dependence

This X0 test consumes the earlier L1 evidence rather than duplicating it. X0 adds research-level perturbations; L1 proves the production runtime path.

### Sensor grounding

Raw observation is not VERIFIED_FACT. Require:

```text
observation
→ candidate/episode
→ causal/effect evidence
→ promotion law
```

### False teacher

A false/rephrased teacher proposal must remain candidate/rejected/conflicted and may not silently become FACT or a proof authority.

## Research claim ceiling

Passing X0 gives bounded empirical support for the representation hypothesis. It does not prove general intelligence or biological cognition.


---

# FILE: 07_ACCEPTANCE_LADDER_R1.md

# Acceptance Ladder R1

R1 separates transport correctness, causal runtime memory, semantic correctness and research falsification.

## Static / Board causal ladder

```text
AUDIT_COMPLETE
→ R1_CONTRACT_FROZEN
→ XSIM_SMOKE_PASS
→ POST_ROUTE_CANDIDATE
→ PROGRAM_IDENTITY_RECORDED
→ UART_MUX_8_8_PASS
→ PACK24_UART_24_24_BOARD
→ PACK24_COMMIT_OBSERVATION_PASS
→ PACK_DEST_COMPLETE_BOARD_PASS
→ PACK_ABI24_R1_CANDIDATE
→ RUNTIME_KNOWLEDGE_BINDING_8_8_PASS
→ READBACK_ACTIVE_GENERATION_PASS
→ FE256_R0_REGRESSION_256_256
→ ASTRA_ADVERSARIAL_PASS
→ FE256_R1_256_256_PASS
→ SHUFFLE_PASS
→ CAUSAL_ABLATION_PASS
→ UART_E2E_32_32_PASS
→ FULL_EVIDENCE_R1_BOARD_CANDIDATE
→ OWNER_REVIEW
```

## Meaning of new gates

### `PROGRAM_IDENTITY_RECORDED`

Only records:

```text
bitstream SHA
device/JTAG identity
startup state
route/timing report
```

It is not `PROGRAM_PASS` unless the existing authority definition is explicitly satisfied.

### `PACK24_UART_24_24_BOARD`

All 24 Pack load-side UART outcome/reason tokens match on silicon.

This is useful but **not** full Pack ABI.

### `PACK24_COMMIT_OBSERVATION_PASS`

All six commit cases have positive four-AND COMMIT evidence.

All 18 reject cases have explicit complete negative coverage with `commit_count=0`.

### `PACK_DEST_COMPLETE_BOARD_PASS`

The accepted Pack cases are proven destination-complete, not merely UART-ACK complete.

### `PACK_ABI24_R1_CANDIDATE`

Requires all Pack24 R1 fields including R-04 6/80 and self-contained G-04 6/84.

### `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`

Proves semantic output depends causally on active committed knowledge and follows relocation/generation.

This gate did not exist explicitly enough in R0.1 and is now mandatory before FE256 board semantic promotion.

## Separate research ladders

### NSPF R1 research candidate

Requires the relevant strengthened X0 tests after L0–L2.

### Developmental candidate

Additionally requires:

```text
executed-action credit
reset/restore learning causality
FEM lifecycle
skill lifecycle
unseen-instance transfer
teacher anti-parrot
sensor/action/effect grounding
capability binding + safety veto/readback
fact/candidate/episode/skill/weight separation
checkpoint integrity
```

## No inherited stamps

No R1 candidate run automatically inherits:

```text
PACK_ABI_24_24_PASS
BOARD_PASS
PROGRAM_PASS
TIMING_PASS
MIG_PASS
FE256_PASS
ASTRA_PASS
FEM_PERSIST_PASS
FINAL_PASS
```

Those remain governed by existing authority until the owner explicitly promotes a revised contract.


---

# FILE: 08_CURRENT_STATUS_20260921.md

# Current Project Status Mapped to R1 — 2026-09-21

This file is a status snapshot, not a PASS stamp.

## Provenance split

### Repository-verifiable snapshot

Latest repo commit inspected while preparing this package:

```text
3f0bc4cb841d80d127385a8190d579f2ffd82418
```

That commit records the `99823c92…` query-silicon work and an `8fc14f25…` file state that had not yet been published as programmed.

### Owner-provided later board evidence

The owner reports a later local run on identity:

```text
8fc14f25…
End of startup HIGH
WNS +0.275
```

This is treated here as `OWNER_PROVIDED_BOARD_EVIDENCE`, not yet as repository-verifiable final authority.

Do not convert this into `TIMING_PASS` or `PROGRAM_PASS`.

## Current silicon behavior reported by owner

### R-04

```text
Pack load: GOLD 010000a5
four-AND: ffffffff → 0000002b
QueryRecord: 03065051
query_status = 6
query_reason = 80 (0x50)
```

This matches the R-04 semantic gold pair.

### G-04 in the latest `--run2` output

```text
Pack reject: 0200055a
QueryRecord: 03065451
query_status = 6
query_reason = 84 (0x54)
```

The benchmark must keep the G-04 lifecycle self-contained; a CLEAR-separated approximation is not equivalent.

## Two UART mux bugs already exposed

1. Query interception stole any UART word matching `0x4E51`, consuming QueryRecord/Pack data incorrectly.
2. Arbitration required Pack transaction ownership guarding (`uart_busy` / active OP_BEGIN) before allowing Query steal.

These are now permanent `UART_MUX_8_8_PASS` regressions.

## Pack24 current interpretation

The supplied run shows:

- V-01..V-04: GOLD + positive flip observation;
- R-04: GOLD + query 6/80;
- G-01: GOLD + positive flip observation;
- G-04: reject reason 5 + query 6/84;
- reject cases: `flip=None`, not fabricated zero.

The remaining old comparator disagreement is:

```text
18 reject rows:
old TSV expects generation_flipped = 0
owner observation contract emits absent/N/A
```

R1 does **not** resolve this by filling expected→observed.

Instead it requires explicit complete negative COMMIT evidence.

## Gates still open

```text
PACK_ABI_24_24_PASS          = NO
PACK_DEST_COMPLETE_BOARD     = NOT_RUN
RUNTIME_KNOWLEDGE_BINDING    = NOT_RUN
BOARD_PASS                   = NO
PROGRAM_PASS                 = NO
TIMING_PASS                  = NO
MIG_PASS                     = NO
ASTRA_PASS                   = NO
FE256_PASS                   = NO
FEM_PERSIST_PASS             = NO
FINAL_PASS                   = NO
```

## Immediate R1 priorities

```text
P0-A  Freeze generation observation semantics:
      MUST_COMMIT_FLIP vs MUST_NOT_COMMIT

P0-B  Prove explicit zero-COMMIT coverage for 18 reject cases

P0-C  Run destination-complete board evidence

P0-D  Re-run UART mux 8/8 regressions on the query-capable identity

P0-E  Only then close Pack ABI R1 candidate

P1    Implement and run RUNTIME_KNOWLEDGE_BINDING_8_8

P2    Resume FE256/ASTRA board semantic acceptance
```


---

# FILE: 11_MIGRATION_FROM_R0_1.md

# Migration Plan — R0.1 → R1

## Do not mutate historical evidence

Keep these as frozen historical/reference artifacts:

```text
CANON_BLUEPRINT/31_VERIFICATION_AND_CAUSAL_TESTS.md
CANON_BLUEPRINT/32_ACCEPTANCE_LADDER.md
verification/pack_abi24/pack_abi24_gold.py
verification/fe256/fe256_gold.py
```

Do not rewrite them merely because the current DUT disagrees with a field.

## Recommended side-by-side repo layout

```text
CANON_BLUEPRINT/verification_r1/
  README.md
  pack_abi24_r1/
    pack24_r1_expected.json
    pack24_r1_compare.py
    PACK_ABI24_R1_CONTRACT.md
  uart_mux_r1/
    UART_MUX_ARBITRATION_R1.md
  runtime_binding_r1/
    RUNTIME_KNOWLEDGE_BINDING_R1.md
  fe256_r1/
    FE256_AND_ASTRA_R1.md
  nspf_x0_r1/
    NSPF_X0_R1.md

CANON_BLUEPRINT/31_VERIFICATION_AND_CAUSAL_TESTS_R1_CANDIDATE.md
CANON_BLUEPRINT/32_ACCEPTANCE_LADDER_R1_CANDIDATE.md
```

## Promotion sequence

```text
1. Owner reviews R1 semantics.
2. Agent B independently audits comparator/gold independence.
3. Agent D binds observations without importing expected values.
4. Agent C audits causal false-pass paths.
5. Run R1 as candidate beside R0.1.
6. Resolve disagreements by authority decision, not DUT convenience.
7. Only owner promotes R1 to Canon.
```

## Required “no rescue” rule

A benchmark change is valid only if it is justified by a clearer semantic/causal contract and applied consistently to future DUTs.

Invalid reason:

```text
"current DUT would pass if we changed this field"
```

Valid reason:

```text
"the old Boolean field conflated no-COMMIT with an observed false transition;
R1 now requires explicit negative COMMIT coverage"
```

## Current recommended first implementation

Implement only these three R1 additions first:

```text
UART_MUX_8_8_PASS
PACK24 negative COMMIT coverage
PACK_DEST_COMPLETE_BOARD_PASS
```

Then close Pack R1 before opening the full runtime-binding work.
