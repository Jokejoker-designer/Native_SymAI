# 10 — SCALE / PERFORMANCE / STRESS

FE256 functional correctness and corpus-scale certification are separate stamps.

## Stress dimensions

- distractor node count,
- posting list length,
- relation fan-out,
- reverse index occupancy,
- 2-hop/3-hop branching,
- value-table size,
- provenance-table size,
- repeated query transaction load.

## Required telemetry

For each query record:

```text
cycles
DDR bytes
posting reads
fact materializations
candidate count
frontier high-water
search depth
proof steps
status
```

## Liveness stress

Run the full FE256 order and a deterministic shuffled order. Then run a long repeated stream. A single malformed/long/unsupported transaction must not permanently backpressure or deadlock later queries.

Recommended liveness campaign:
- 10,000 sequential structured transactions,
- zero permanent stall,
- zero txn-id loss/reorder unless protocol explicitly permits it.

## Scale claims

Never infer an `800k` board claim from a logical namespace or procedural responder. The actual materialized pack size and DDR evidence must be recorded.
