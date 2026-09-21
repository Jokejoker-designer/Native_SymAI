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
