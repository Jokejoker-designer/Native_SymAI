# FEM_SPEAR_SEMANTIC_CAUSAL_BOARD_CANDIDATE

LANGUAGE=EN
FREEZE_UTC: 2026-09-22T011500Z
CONTRADICTION_FOUND: NO

```text
CLASS=FEM_SPEAR_SEMANTIC_CAUSAL_BOARD_CANDIDATE
STATUS=SUPPORTED
IDENTITY=52b923a6a2ccfba714cd27fddb9955705844203e862747479e2f2f8895eae08a
TREE=D:/FPGA/arty_d/UART_R2/fem_spear_semantic
BIT=D:/FPGA/arty_d/UART_R2/build_fem_spear_semantic/uart_r2_fem_spear_semantic_candidate.bit
JSON=D:/FPGA/arty_d/UART_R2/results/FEM_SPEAR_SEMANTIC_20260922/UART_SPEAR_RANK.json
EOS=HIGH
PROGRAM.DONE=NA
C_RTL_EDIT=NO
```

Scoped claim: with fixed query, generation, descriptors, base scores, and recovered FEM state, toggling only FEM influence reverses semantic rank `A>B` and `B>A` twice.

Do not re-run this rank sequence on `52b923a6…`. Do not edit `cand_desc` to force the winner. Do not edit C RTL.

```text
BOARD_PASS=NO
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
MIG_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
```

Next: the rank change must pass through ASTRA/Q* into a different final action, then return when only FEM influence is removed. See `FEM_RANK_TO_ACTION_SPEC.md`.
