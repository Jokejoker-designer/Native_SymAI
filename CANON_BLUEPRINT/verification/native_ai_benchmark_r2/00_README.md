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
