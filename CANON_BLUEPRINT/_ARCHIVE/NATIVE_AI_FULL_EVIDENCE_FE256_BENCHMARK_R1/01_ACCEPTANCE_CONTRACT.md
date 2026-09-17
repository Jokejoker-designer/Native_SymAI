# 01 — FE256 ACCEPTANCE CONTRACT

## 1. System under test

The primary SUT is:

```text
Verified Knowledge Pack
→ Loader / DDR
→ Native Semantic Query
→ Directory / Posting / Graph Retrieval
→ bounded inference
→ ASTRA proof / status
→ Structured Result
```

The primary benchmark input is a `QueryRecord`, not a human sentence.

## 2. Result contract

Every query must terminate with one explicit semantic status:

- `ANSWER`
- `UNKNOWN`
- `CONFLICT`
- `SEARCH_INCOMPLETE`
- `PARSE_ERROR` (adapter gate only)
- `UNSUPPORTED_QUERY`
- `DATA_INTEGRITY_FAIL`

`EMPTY`, silent UART, missing transaction completion or implicit timeout is never a valid semantic outcome.

## 3. PASS laws

### FE-LAW-01 — Reachability
`structured_result_returned = 256/256`.

### FE-LAW-02 — Correctness
For all preregistered answerable cases, semantic answer equality must be exact. Human wording is ignored.

### FE-LAW-03 — No false refusal
An answerable gold case may not return `UNKNOWN`, `CONFLICT`, `SEARCH_INCOMPLETE`, `UNSUPPORTED_QUERY` or an empty result.

### FE-LAW-04 — No unsupported answer
A gold UNKNOWN/negative case may not emit an answer merely because a nearby alias/model/family has one.

### FE-LAW-05 — Proof
An `ANSWER` requiring proof must have a valid proof reference resolving to the expected evidence/path class.

### FE-LAW-06 — Provenance
Verified knowledge used in a proof must trace to valid provenance. Provenance absence or corruption cannot be silently ignored.

### FE-LAW-07 — Direction
`A --R--> B` is not interchangeable with `B --R--> A`. Inverse lookup must use the declared inverse relation/direction law.

### FE-LAW-08 — Value typing
Scalar/range/unit answers use typed values. `OID=0`, string-baked literals, or alias fallbacks are forbidden as semantic substitutes.

### FE-LAW-09 — Context isolation
Evidence in context X cannot satisfy a query in incompatible context Y.

### FE-LAW-10 — Identity
Model, family, alias and human label are separate. Alias changes cannot change canonical semantic identity.

### FE-LAW-11 — Integrity
Schema/ABI/content mismatch must reject the pack or emit an explicit integrity state; never best-effort load.

### FE-LAW-12 — Causality
Preregistered edge/evidence/context ablation must cause the expected result change. A result that survives removal of its only proof support is a FAIL.

## 4. Owner stamp

The benchmark runner may report `FE256_PASS_CANDIDATE`. It may not issue `BOARD_PASS` or owner freeze stamps automatically.
