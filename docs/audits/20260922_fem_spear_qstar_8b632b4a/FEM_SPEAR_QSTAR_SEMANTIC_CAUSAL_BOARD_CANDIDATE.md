# FEM_SPEAR_QSTAR_SEMANTIC_CAUSAL_BOARD_CANDIDATE

LANGUAGE=EN
FREEZE_UTC: 2026-09-22T015600Z
CONTRADICTION_FOUND: NO

```text
CLASS=FEM_SPEAR_QSTAR_SEMANTIC_CAUSAL_BOARD_CANDIDATE
STATUS=SUPPORTED
IDENTITY=8b632b4ac5317f6176cf62103b88bfcdf637b8d4dec495717db9615eea3d3ad7
BIT=D:/FPGA/arty_d/UART_R2/build_fem_spear_qstar/uart_r2_fem_spear_qstar_candidate.bit
EOS=HIGH
PROGRAM.DONE=NA
C_RTL_EDIT=NO
```

Scoped claim: with fixed descriptors, base scores, recovered FEM state, and `legal_mask=8'h03`, FEM influence changes SPEAR rank-0 and that rank-0 changes the Q* action.

```text
OFF → A → feat0=0 → action 0
ON  → B → feat0=2 → action 1
OFF → A → feat0=0 → action 0
ON  → B → feat0=2 → action 1
```

Do not rebuild `8b632b4a…` to repeat this chain.

```text
BOARD_PASS=NO
PROGRAM_PASS=NO
TIMING_PASS=NO
MIG_PASS=NO
FEM_PERSIST_PASS=NO
PACK_ABI_24_24_PASS=NO
```

Next: ASTRA at the end of the decision path. Not another SPEAR→Q* repeat. See `FEM_ACTION_THROUGH_ASTRA_SPEC.md`.
