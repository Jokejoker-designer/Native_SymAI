# 09 — MIGRATION FROM FE256 R1

## Keep unchanged

- Historical D1–D5 evidence.
- FE256 256-case family counts and gold.
- Pack/ABI 24-case gold.
- exact result/status/proof/provenance rules.
- deterministic shuffle.
- semantic ablation.
- FE-UART-E2E-32 concept.
- no host answer/winner authority.

## Reclassify

| Old element | R2 treatment |
|---|---|
| FE256 as primary acceptance endpoint | Move to L2 static semantic regression. |
| Dedicated FE256 engine | Freeze as reference only; not final production path. |
| Pack/ABI before FE256 | Retain, but expand with L1 semantic publication/causality. |
| Simple DDR readback | Retain, but require query-tagged, causally necessary runtime reads. |
| Ablation near end | Move earlier and combine with L1/L3 causal tests. |
| Shuffle | Retain as order-invariance regression. |
| UART human chat | Retain, but authority-boundary checks move into L6. |
| Learning modules | No pass from unit presence; require L4 decision causality. |
| Sensor/action claims | Require L5 capability binding + effect readback. |

## Remove from final acceptance logic

Do not accept any of these as final proof:

- code-0 build alone;
- XSim alone for a board claim;
- PROGRAM alone for semantic correctness;
- pack loader ACK alone for active knowledge publication;
- BRAM/ROM fixture parity alone;
- common exporter agreement alone;
- a changed weight/state that never changes a later decision;
- UART text that was rendered/selected by the host;
- one positive answer without the paired causal intervention.

## Suggested repository location

```text
CANON_BLUEPRINT/verification/native_ai_benchmark_r2/
```

The existing `_ARCHIVE/NATIVE_AI_FULL_EVIDENCE_FE256_BENCHMARK_R1/` should remain
read-only and referenced by hash/path.
