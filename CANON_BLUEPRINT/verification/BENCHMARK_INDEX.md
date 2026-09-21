# BENCHMARK LAYERS — FE256 R1 + CAUSAL R2

This file is an index only. It does **not** rewrite gold, §32, QueryRecord, or StructuredResult.

| Layer | Path | Role | Mutability |
|---|---|---|---|
| Live FE256 gold (B) | `CANON_BLUEPRINT/verification/fe256/` | 256-case QueryRecord/StructuredResult authority | Frozen. Do not change to rescue a DUT. |
| Live Pack/ABI-24 gold (B) | `CANON_BLUEPRINT/verification/pack_abi24/` | 24 integrity cases | Frozen. `PACK_ABI_24_24_PASS=NO` until board+compare close. |
| Historical FE256 R1 package | `CANON_BLUEPRINT/_ARCHIVE/NATIVE_AI_FULL_EVIDENCE_FE256_BENCHMARK_R1/` | Immutable R1 contract/docs/schemas | Read-only. |
| Causal acceptance R2 | `CANON_BLUEPRINT/verification/native_ai_benchmark_r2/` | New L0–L7 layer: Pack COMMIT must causally publish the knowledge image the query runtime uses | Add-only sibling. Does not replace R1 gold. |

R2 zip SHA256:

```
f1c5f998e1e5e4008d379a877cbe4fdcabfa9bb0dab0d006d633c523fd3aa4ed
```

R2 does **not** stamp `BOARD_PASS` / `FINAL_PASS` / `PACK_ABI_24_24_PASS` / `FE256_PASS` / `PROGRAM_PASS` / `TIMING_PASS` / `MIG_PASS` / `ASTRA_PASS`.
