# Ingest — Native_SymAI Benchmark R1 Causal (2026-09-21)

## Verdict

**Use this package as the current causal candidate.** It does not replace FE256/Pack R0.1 gold.

Sources:

- `D:\FPGA\NATIVE_SYMAI_BENCHMARK_R1_CAUSAL_20260921.zip` SHA256 `4bc37ffe958f7cea6a9f85541dde8df4945de9fa47b76d50dae4b93dd1d2cecc`
- `D:\FPGA\NATIVE_SYMAI_BENCHMARK_R1_CAUSAL_MASTER_20260921.md` SHA256 `f422fff3e73ecfb8ebfc1cf2c1e655ca2df397213eecbd1c473e7c2df1426709`

`MANIFEST_SHA256.txt` 12/12 OK after extract.

## Why this beats the earlier R2 zip for *this* repo

Earlier `native_ai_benchmark_r2` (zip `f1c5f998…`) is a general L0–L7 causal ladder. This R1 Causal package is the one that encodes the silicon lessons already observed:

- `generation_flipped=0` is not “no COMMIT observed” (`FALSE != ABSENT != NOT_OBSERVED`)
- Query `0x4E51` steal vs Pack `uart_busy` / OP_BEGIN ownership (`UART_MUX_8_8`)
- G-04 must be self-contained (CLEAR-between ≠ 6/84)
- destination-complete ≠ UART ACK
- candidate comparator **must not synthesize** TSV `0`

## Comparator smoke (not a PASS)

Command:

```text
python 10_pack24_r1_compare.py PACK24_RUN1_QUERY_DUT.jsonl
```

Result: `PACK_ABI24_R1_CANDIDATE: FAIL (139 findings)`. Current DUT jsonl is B-compare shape (outcome/reason, int `generation_flipped=1`, omit on reject). It lacks R1 fields (`uart_token`, `capture_valid`, `commit_event`, `commit_count`, `observation_window_complete`, `destination_complete`, `g04_lifecycle`). Script also uses `is True`, so integer `1` is not accepted as True.

This FAIL is schema/coverage, not a license to invent flip=0 or to stamp `PACK_ABI_24_24_PASS`.

## Not done

- Did not edit `fe256_gold.py` or `pack_abi24_gold.py`.
- Did not rewrite §32; added `32_ACCEPTANCE_LADDER_R1_CANDIDATE.md` beside it.
- Did not program, overlay, or weaken 256 gold.
