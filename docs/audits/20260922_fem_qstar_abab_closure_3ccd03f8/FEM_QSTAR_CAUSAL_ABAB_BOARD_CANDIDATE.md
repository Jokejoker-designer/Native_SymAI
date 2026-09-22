# FEM_QSTAR_CAUSAL_ABAB_BOARD_CANDIDATE

LANGUAGE=EN
FREEZE_UTC: 2026-09-22T004000Z
OWNER: accepted closure audit
CONTRADICTION_FOUND: NO

```text
CLASS=FEM_QSTAR_CAUSAL_ABAB_BOARD_CANDIDATE
STATUS=SUPPORTED
IDENTITY=3ccd03f80677607acfba6e45aab1fe05d6a8a99055224a244dbc3b7de275229d
TREE=D:/FPGA/arty_d/UART_R2/fem_qstar_causal
BIT=D:/FPGA/arty_d/UART_R2/build_fem_qstar_causal/uart_r2_fem_qstar_causal_candidate.bit
JSON=D:/FPGA/arty_d/UART_R2/results/FEM_QSTAR_CAUSAL_20260922/UART_QSTAR_ABAB.json
JSON_SHA256=302c7bd46e9262c745c3ef66fdc20d08ac378c8cae618bccb21c220c38b1c76f
CLOSURE=CLOSURE_AUDIT_20260922T003600Z.md
EOS=HIGH
PROGRAM.DONE=NA
LIVE_SRAM_HASH=NOT_READ
C_RTL_EDIT=NO
DEST_POKE=NO
WNS=+0.468
WHS=+0.010
```

## Scoped claim

Recovered FEM experience causally changes a bounded Q* greedy decision on silicon.

Evidence: greedy `0, 1, 0, 1`. Arm A2 kept `failure_total=2`, `life=3`, `compacted=1` while the D-only mux was off and greedy returned to 0. Closure audit found no contradiction on provenance, invariants, CDC/latch, or idle SPEAR.

## Closed

Do not re-test `0 → 1 → 0 → 1` on this identity. Do not rebuild `3ccd03f8…` to repeat the minimal Q* mux. Do not edit frozen C RTL.

`3ccd03f8…` keeps SPEAR idle. It cannot host a real candidate test.

## Claim ceiling

```text
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
BOARD_PASS=NO
MIG_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
```

## Next research

Semantic context and a fixed real candidate set. See `FEM_SPEAR_SEMANTIC_CANDIDATE_SPEC.md`.
