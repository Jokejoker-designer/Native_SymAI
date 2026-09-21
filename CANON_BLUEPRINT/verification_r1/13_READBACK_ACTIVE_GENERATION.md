# READBACK_ACTIVE_GENERATION — workstream start (2026-09-21)

Not `READBACK_ACTIVE_GENERATION_PASS`. Not dest-hex UART. U33OBS debug CLOSED.

## Why this is next

R1 Pack ABI is closed on UART+COMMIT four-AND+omit. GOLD `S_RD_WAIT` matches **page first word** (`rg_first`), not ManifestHeader `pack_generation` from dest.

FACT from `pack_loader.sv`:

- `S_WRITE` `mem_wdata = page_rdata` (payload pages only).
- `S_COMMIT` `active_generation <= man_generation` (flop from UART header `hw3`).
- Reset `active_generation <= UNSET_GEN` (`32'hFFFF_FFFF`).
- Dest therefore does **not** currently store generation. Power/reset loses it.

That is the first divergence between TAP four-AND generation and dest-complete generation readback.

## Gate (still open)

```text
READBACK_ACTIVE_GENERATION_PASS = NOT_RUN
PACK_DEST_COMPLETE_BOARD_PASS   = NOT_RUN
dest_word_export                = NOT_RUN
```

## First experiments (no Pack24, no U33OBS overlay)

1. Structural selfcheck (this turn): `arty_d/rkb_readback/struct_check.py`
2. XSim: after V-04 GOLD, `active_generation == 0x0000ffff`; after `rst_n=0`, `UNSET`. Dest page word 0 == `rg_first`. Dest has no generation word.
3. Board later: dest-word UART export of **page** bytes at `slot_base+rg_ddr+rg_off`, new json name, freeze hashes kept. Not TAP-freeze debug.

Do not invent dest generation. Do not reprogram unless owner YES.
