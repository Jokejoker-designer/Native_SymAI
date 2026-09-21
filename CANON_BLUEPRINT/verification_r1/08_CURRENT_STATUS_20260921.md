# Current Project Status Mapped to R1 — 2026-09-21

This file is a status snapshot, not a PASS stamp.

**Owner freeze 2026-09-21:** Pack ABI authority is this R1 Causal package. P0 Pack closed on R1 24/24. Historical `PACK_ABI_24_24_PASS=NO`. U33OBS debug CLOSED. See `12_OWNER_FREEZE_PACK_ABI_R1_AUTHORITY.md`. Do not treat the P0 list below as still-open Pack debug.

## Provenance split

### Repository-verifiable snapshot

Latest repo commit inspected while preparing this package:

```text
3f0bc4cb841d80d127385a8190d579f2ffd82418
```

That commit records the `99823c92…` query-silicon work and an `8fc14f25…` file state that had not yet been published as programmed.

### Watch-hashed later board evidence (2026-09-21T022400Z)

Independently hashed (not owner recap):

```text
PROGRAM.txt sha256 1ab55cbdfb957d7e5b1210916d23a6f2713dece9fcad053160c60669e1745b26
SHA256        8fc14f25f2b9d936b7d412ce41b6d963991cc91137c20587e3ab5a96b5224df5
Labtools      End of startup HIGH
WNS           +0.275 (not TIMING_PASS)
ISO R-04      U33OBS_QUERY_ISO_R04_8FC14F25.json 9da6c2d8… GOLD + 03065051
R1 jsonl      PACK24_RESUME_QUERY_R1.jsonl 090b7814… watch-rerun 24/24 CANDIDATE
B --compare   still 6/24 on sibling DUT f5ead405…
```

Repository-verifiable **hashes**. Still **not** `TIMING_PASS` / `PROGRAM_PASS` / `PACK_ABI_24_24_PASS` / `BOARD_PASS`.

GitHub keeps the `99823c92…` hop as `U33OBS_QUERY_ISO_R04.json` `ae394b6b…`. Do not mix SHAs.

## Current silicon behavior reported by owner

### R-04

```text
Pack load: GOLD 010000a5
four-AND: ffffffff → 0000002b
QueryRecord: 03065051
query_status = 6
query_reason = 80 (0x50)
```

This matches the R-04 semantic gold pair.

### G-04 in the latest `--run2` output

```text
Pack reject: 0200055a
QueryRecord: 03065451
query_status = 6
query_reason = 84 (0x54)
```

The benchmark must keep the G-04 lifecycle self-contained; a CLEAR-separated approximation is not equivalent.

## Two UART mux bugs already exposed

1. Query interception stole any UART word matching `0x4E51`, consuming QueryRecord/Pack data incorrectly.
2. Arbitration required Pack transaction ownership guarding (`uart_busy` / active OP_BEGIN) before allowing Query steal.

These are now permanent `UART_MUX_8_8_PASS` regressions.

## Pack24 current interpretation

The supplied run shows:

- V-01..V-04: GOLD + positive flip observation;
- R-04: GOLD + query 6/80;
- G-01: GOLD + positive flip observation;
- G-04: reject reason 5 + query 6/84;
- reject cases: `flip=None`, not fabricated zero.

The remaining old comparator disagreement is:

```text
18 reject rows:
old TSV expects generation_flipped = 0
owner observation contract emits absent/N/A
```

R1 does **not** resolve this by filling expected→observed.

Instead it requires explicit complete negative COMMIT evidence.

## Gates still open

```text
PACK_ABI_24_24_PASS          = NO
PACK_DEST_COMPLETE_BOARD     = NOT_RUN
RUNTIME_KNOWLEDGE_BINDING    = NOT_RUN
BOARD_PASS                   = NO
PROGRAM_PASS                 = NO
TIMING_PASS                  = NO
MIG_PASS                     = NO
ASTRA_PASS                   = NO
FE256_PASS                   = NO
FEM_PERSIST_PASS             = NO
FINAL_PASS                   = NO
```

## Immediate R1 priorities

```text
P0-A  Freeze generation observation semantics:
      MUST_COMMIT_FLIP vs MUST_NOT_COMMIT

P0-B  Prove explicit zero-COMMIT coverage for 18 reject cases

P0-C  Run destination-complete board evidence

P0-D  Re-run UART mux 8/8 regressions on the query-capable identity

P0-E  Only then close Pack ABI R1 candidate

P1    Implement and run RUNTIME_KNOWLEDGE_BINDING_8_8

P2    Resume FE256/ASTRA board semantic acceptance
```
