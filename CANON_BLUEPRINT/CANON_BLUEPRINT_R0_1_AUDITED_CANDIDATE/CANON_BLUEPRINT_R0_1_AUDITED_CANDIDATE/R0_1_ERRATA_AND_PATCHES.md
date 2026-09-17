---
version: "1.0-candidate"
owner: AUDIT
status: AUDITED_CANDIDATE
category: GOVERNANCE
last_modified: "2026-09-16T08:45:00+07:00"
---

# R0.1 ERRATA AND PATCH SET

> Proposed corrections applied only to this candidate copy. The original
> `CANON_BLUEPRINT.rar` is preserved as source evidence.

## P0 — correctness / acceptance blockers

1. **PackHeader arithmetic/ABI** — replaced impossible 64-byte claim with a
   versioned 128-byte ManifestHeader + region descriptors; QueryRecord/Result
   now carry transaction/generation/namespace and richer status/proof fields.
2. **FE256 definition** — corrected from “256-node graph” to 256 preregistered
   cases with canonical category counts.
3. **PACK_ABI_24_24** — corrected from “24 nodes/24 edges” to 24 integrity cases.
4. **SHUFFLE_PASS** — corrected to deterministic case-order shuffle; ID/alias
   perturbation moved to NSPF-X0.
5. **UART E2E** — starts at human text and freezes host adapter; host may map IDs
   but cannot supply answer/winner/proof/provenance.
6. **UNKNOWN** — valid only when declared search scope is complete and no verified
   support exists; budget exhaustion is SEARCH_INCOMPLETE.
7. **Learning credit** — ASTRA is governance, not a reward source; only executed
   actions receive causal credit from observed outcomes.
8. **Masked Slot** — masks a frame slot while support remains; support removal is
   Causal Ablation.
9. **Hardware facts** — DDR peak corrected to ~1.334 GB/s theoretical; guessed
   fixed random latency removed; BRAM units normalized.
10. **Skill lifecycle / Sensor grounding / FEM** — candidate vs verified skill,
    observation vs fact and engineering failure vs runtime FEM separated.

## P1 — architecture clarifications

- `Logical Cognitive Class × Physical Memory Tier` is explicit.
- `TOP_K != ANSWER`, `PREDICTION != TRUTH`, `OBSERVATION != VERIFIED_FACT`,
  `LOGICAL_TICK != PHYSICAL_CLOCK` added to invariants.
- ASTRA described as deterministic authority under declared rules/evidence, not
  omniscient truth oracle.
- host mapping authority separated from host truth/proof authority.
- capability/action binding layer added as new §05.
- runtime ASTRA knowledge promotion separated from owner artifact freeze.
- `_ARCHIVE` and `_COORDINATION` authority roles defined.

## P2 — performance / scale proposals

- T1 Hot Directory is a placement record, not a semantic/epistemic record.
- atomic T2→T1 fill/generation switch and cache parity tests added.
- LRU/simple baseline remains an MVP option; TinyLFU/CMS/hot profiler is deferred
  until profiling shows cache pollution/hot-set benefit.
- no HBM/multi-walker/DFX requirement before measured bottlenecks.

## P3 — future research

- HDC/VSA proposal sidecar with exact ASTRA verification;
- larger-scale sensor grounding and concept formation;
- HBM partitioned walkers;
- offline Semantic Hardware Specialization, with DFX only after rollback/lineage
  and timing evidence;
- formal novelty/FTO study.

## Classification

- GOAL/invariants/authority boundaries: **CANON-LOCKED candidate wording**.
- Derived ABI/memory/protocol details: **CANON-DERIVED candidate** until owner approval.
- HBM/HDC/DFX/specialization: **R2/FUTURE extension**.

No patch in this file constitutes owner acceptance by itself.
