# OWNER PROGRAM=YES — 2026-09-21 09:52 +07

OWNER: Anh  
HOLDER: AGENT_D  
RESOURCE: ARTY_A7_100T JTAG `210319BE776EA` UART `210319BE776EB` COM12

```text
PROGRAM          = YES (owner 09:52 +07; lease until 12:00 +07 still HELD)
PROGRAM_PASS     = NO
BOARD_PASS       = NO
PACK_ABI_24_24_PASS = NO
```

## What this grant does

Authorizes AGENT_D to program Arty **when a unique candidate bitstream exists** that is the object of the test.

## What this grant does not do

- Does not stamp PROGRAM_PASS / BOARD_PASS / MIG_PASS / TIMING_PASS / ASTRA_PASS / FE256_PASS / RUNTIME_KNOWLEDGE_BINDING_8_8_PASS / CT1_PASS.
- Does not authorize re-programming live identity `8fc14f25…` (would wipe SRAM Pack evidence; owner previously forbade redo that loses evidence).
- Does not authorize programming freeze DCPs or identity H / U33 / TAPCDC.
- Does not authorize a CT1 bitstream: **no CT1 top/bit exists**; CT1-01..05 was FAIL_XSIM until dest-lane decode fix.

Live silicon remains `uart_r2_u33obs_query_candidate.bit` sha256 `8fc14f25f2b9d936b7d412ce41b6d963991cc91137c20587e3ab5a96b5224df5`.
