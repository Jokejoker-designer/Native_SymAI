# R2 ingest — 2026-09-21

## Verdict

**SUITABLE as an add-on layer. Not suitable as a replacement of FE256 R1 gold.**

Source:

- zip `D:\FPGA\NATIVE_AI_CAUSAL_ACCEPTANCE_BENCHMARK_R2_20260921.zip` SHA256 `f1c5f998e1e5e4008d379a877cbe4fdcabfa9bb0dab0d006d633c523fd3aa4ed`
- master view `D:\FPGA\NATIVE_AI_CAUSAL_ACCEPTANCE_BENCHMARK_R2_MASTER.md` SHA256 `af23ad6b8f03130bf19c9a84f527959ecc0f7f5a56fbb5ccdfad7901dc94755e` (concat convenience; zip remains canonical)

Self-check: `python tools/validate_package.py` → `BENCHMARK_R2_PACKAGE_SELF_CHECK = PASS`. Internal `SHA256SUMS.txt` 15/15 OK.

## Why it fits

- Keeps FE256 256-case family counts and Pack/ABI-24 gold unchanged.
- Matches current architecture lock: dedicated FE256 is reference; product path is QueryRecord → directory/posting → walker → ASTRA → StructuredResult.
- Makes `SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE` / Pack COMMIT ≠ query image a **blocking L1 gate** instead of a later story.
- Claim ceiling matches public status: no self-stamp of BOARD/FINAL/PACK_ABI/FE256/PROGRAM/TIMING/MIG/ASTRA.
- R2 jsonl files are campaign **specs** (8 binding + 12 NSPF + 12 developmental), not a second 256-case gold.

## What was not done

- Did not edit `verification/fe256/` or `verification/pack_abi24/` gold.
- Did not edit `_ARCHIVE/NATIVE_AI_FULL_EVIDENCE_FE256_BENCHMARK_R1/` files.
- Did not rewrite AGENT_B `32_ACCEPTANCE_LADDER.md`. R2 L1 is a candidate expansion of §32 `RUNTIME_DDR_LOAD_PASS` / `READBACK_PASS`; B/owner promote if they lock it into canon.
- Did not treat `03_GATE_MATRIX.csv` FAIL/PASS_CANDIDATE cells as new board stamps. They are a 2026-09-21 mapping of already-public status.
- Did not run FE256, Pack24, or board tests as part of this ingest.

## Claim ceiling after ingest

```text
PACK_ABI_24_24_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
TIMING_PASS = NO
MIG_PASS = NO
ASTRA_PASS = NO
FE256_PASS = NO
FINAL_PASS = NO
```
