# Isolated A-03 MUTE RCA: UART `pack_begin` exact `00800001` — not PACK_ABI (2026-09-20)

This watch did **not** program, did **not** run Pack24, and did **not** edit RTL. Parent `D_U33OBS_RGOFF_A03_MUTE.json` sha256 `fc2a6a3e…`. **PACK_ABI_24_24_PASS=NO**. **PROGRAM_PASS=NO**. Overlay **NO**. C RTL untouched. B gold unmodified.

Same unique bit `251eafa9…` (PROGRAM.txt rewritten 20:01:51+07 TAP re-arm, SHA MATCH, EOS HIGH). Isolated A-03 UART **MUTE n=0**. TAP `uart1=00840001` (BEGIN length 132 = gold A-03 `RC_HEADER_LENGTH`) `load0/load1=0` **LOADER_EMPTY**. `generation_flipped` **absent** (no COMMIT four-AND). Obs DUT XSim still `LOAD_REJECT` reason 9 / `0200095a` because it bypasses UART steer.

First divergence (RTL_FACT, D-owned OBS top):

```
wire pack_begin = (f_data == 32'h00800001);
```

V-03 GOLD used `00800001` and TAP loaded NAI1. A-03/A-04 BEGIN never matches, so `steer_pack` never takes the beat into `pack_loader`. MUTE is **not** leftover dest, **not** V-03 sentinel, **not** bulk-size-only.

Steer XSim / new unique bit: **NOT_RUN / NOT_BUILT**. Do not overlay `251eafa9` / `71b9198f`.
