# BENCHMARK LAYERS

Index only. Does **not** rewrite gold, §32, QueryRecord, or StructuredResult.

| Layer | Path | Role | Mutability |
|---|---|---|---|
| Live FE256 gold (B) | `CANON_BLUEPRINT/verification/fe256/` | 256-case QueryRecord/StructuredResult authority | Frozen. Do not change to rescue a DUT. |
| Live Pack/ABI-24 gold (B) | `CANON_BLUEPRINT/verification/pack_abi24/` | 24 integrity cases (R0.1) | Frozen. `PACK_ABI_24_24_PASS=NO`. |
| Historical FE256 package | `CANON_BLUEPRINT/_ARCHIVE/NATIVE_AI_FULL_EVIDENCE_FE256_BENCHMARK_R1/` | Immutable docs/schemas | Read-only. |
| **Current causal candidate** | `CANON_BLUEPRINT/verification_r1/` | Native_SymAI Benchmark R1 Causal zip `4bc37ffe…` | CANDIDATE. Owner-selected 2026-09-21. Not Canon. |
| Prior causal snapshot | `CANON_BLUEPRINT/verification/native_ai_benchmark_r2/` | Earlier acceptance-R2 zip `f1c5f998…` | Keep; superseded as current candidate. |

R1 Causal laws: `FALSE != ABSENT != NOT_OBSERVED`; Pack COMMIT four-AND; UART mux ownership; dest-complete; FE256 only after `RUNTIME_KNOWLEDGE_BINDING_8_8`.

Does **not** stamp `BOARD_PASS` / `FINAL_PASS` / `PACK_ABI_24_24_PASS` / `FE256_PASS` / `PROGRAM_PASS` / `TIMING_PASS` / `MIG_PASS` / `ASTRA_PASS`.
