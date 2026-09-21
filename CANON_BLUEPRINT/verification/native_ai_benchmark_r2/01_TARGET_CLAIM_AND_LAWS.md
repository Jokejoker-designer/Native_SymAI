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
