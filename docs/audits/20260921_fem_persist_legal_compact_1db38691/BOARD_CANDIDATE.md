# FEM persist legal-compact silicon run — 1db38691

LANGUAGE=EN  
RUN_ID: 20260921T160900Z  
IDENTITY (PROGRAM.txt + unique persist UART plane, no bitstream readback):  
`1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668`

```text
NEW_BITSTREAM=NO
REPROGRAM_THIS_RUN=NO
DEST_POKE=NO
RED_RESET=NO
C_RTL_EDIT=NO
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
BOARD_PASS=NO
MIG_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
```

JSON `D:/FPGA/arty_d/UART_R2/results/FEM_PERSIST_LEGAL_COMPACT_20260921/UART_LEGAL_COMPACT.json`  
sha256 `6378acafe72067f208ba2aae1d324a27bce3f5953cb21188f7275b3d8f34f13f`

All FOBS gates passed. DEST_READ beats matched compacted HDR/W0/W1/CRCW and COMMIT/INDEX/HDR2. Beats were bit-identical across FEM-only FRST. FREC `recover_state=2` restored COMPACTED. CRC16 over `{p_w0,p_w1}` from frozen C algorithm = `552e`; observed lane3 `a5a5552e`.

This is a **narrow board-candidate** for legal compact + T2 COMMIT persist across FEM-only reset on identity 1db38691. It is **not** FEM_PERSIST_PASS / MIG_PASS / BOARD_PASS. Closure audit requested.

Lane3 of beat `0x0200010` remains `00010000` (no A_* at word 7). Not used as a fail.
