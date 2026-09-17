# 03 — METRICS AND THRESHOLDS

## A. Mandatory functional metrics

Report all of these; never collapse them into one headline metric.

```text
TOTAL_CASES
EXPLICIT_RESULT_RATE
ANSWERABLE_CASES
CORRECT_ANSWER_RATE
WRONG_ANSWER_COUNT
FALSE_REFUSAL_COUNT
UNKNOWN_EXPECTED_CORRECT
CONFLICT_EXPECTED_CORRECT
SEARCH_INCOMPLETE_EXPECTED_CORRECT
EMPTY_COUNT
TIMEOUT_COUNT
TXN_MISMATCH_COUNT
PROOF_VALID_RATE
PROVENANCE_VALID_RATE
CONTEXT_LEAK_COUNT
IDENTITY_LEAK_COUNT
```

### Blocking thresholds

```text
TOTAL_CASES                    = 256
EXPLICIT_RESULT_RATE           = 100%
CORRECT_ANSWER_RATE            = 100% of answerable gold
WRONG_ANSWER_COUNT             = 0
FALSE_REFUSAL_COUNT            = 0
EMPTY_COUNT                    = 0
TIMEOUT_COUNT                  = 0
TXN_MISMATCH_COUNT             = 0
CONTEXT_LEAK_COUNT             = 0
IDENTITY_LEAK_COUNT            = 0
PROOF_VALID_RATE               = 100% where required
PROVENANCE_VALID_RATE          = 100% where required
```

This is a **finite preregistered acceptance suite**, so exact pass is appropriate. It is not a claim of universal factual correctness outside the benchmark.

## B. Loader/pack metrics

```text
VALID_PACK_LOAD
SCHEMA_MISMATCH_REJECT
ABI_MISMATCH_REJECT
CONTENT_HASH_MISMATCH_REJECT
PAGE_CRC_FAIL_DETECTED
GENERATION_ATOMICITY
READBACK_MATCH
```

All 24 loader/ABI cases must pass.

## C. Performance metrics

Always record:

```text
query_cycles_min/p50/p95/p99/max
DDR_bytes_per_query_min/p50/p95/p99/max
posting_entries_read
fact_records_materialized
frontier_high_water
candidate_high_water
proof_steps
search_depth
```

No benchmark may claim `O(1)` or `O(log N)` merely from observed timing. Report measured work and the actual index algorithm.

## D. Scale certification

Scale is reported separately from FE256 functional PASS:

- `SCALE-S`: active verified pack / small corpus
- `SCALE-M`: >=10k canonical records
- `SCALE-L`: >=100k canonical records
- `SCALE-XL`: target large corpus (e.g. 800k) only when physically materialized and board-proven

A scale label is awarded only for the corpus size actually loaded and verified on that run.

Before a scale campaign, preregister:
- query cycle budget,
- DDR bytes/query budget,
- candidate/frontier caps,
- maximum traversal depth.

Thresholds may not be edited after observing results.
