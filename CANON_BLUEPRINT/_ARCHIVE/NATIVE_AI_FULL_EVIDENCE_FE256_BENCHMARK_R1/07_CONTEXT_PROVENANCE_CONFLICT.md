# 07 — CONTEXT / PROVENANCE / CONFLICT

## Context

Context is required where the claim semantics require it; this benchmark does not force fake time/space context onto context-independent facts.

Test contrast examples conceptually:

```text
same subject + relation
context A → answer X
context B → answer Y or UNKNOWN
```

PASS requires zero cross-context leakage.

## Provenance

Every verified fact used as evidence must trace to provenance. FE256 tests provenance as a proof property, not as a decorative string.

## Conflict

A conflict test contains opposing supported claims under a compatible query scope. Expected state is `CONFLICT`, not arbitrary winner selection.

Learned scores/rankers may order evidence for search efficiency, but may not convert conflict into truth without ASTRA-authorized resolution policy.
