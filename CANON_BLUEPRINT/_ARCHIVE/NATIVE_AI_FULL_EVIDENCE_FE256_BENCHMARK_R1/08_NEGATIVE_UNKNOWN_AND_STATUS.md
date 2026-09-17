# 08 — NEGATIVE / UNKNOWN / STATUS DISCIPLINE

A major purpose of FE256 is to eliminate `EMPTY` as an epistemic state.

## Required distinctions

```text
UNKNOWN
= search completed under contract; no sufficient supported answer

SEARCH_INCOMPLETE
= search could not complete within declared bounded search contract

UNSUPPORTED_QUERY
= structured query form/relation/mode unsupported by this implementation

DATA_INTEGRITY_FAIL
= required data failed integrity checks

CONFLICT
= incompatible supported evidence remains unresolved
```

None of these may be silently mapped to `no`, empty string, or a fabricated answer.
