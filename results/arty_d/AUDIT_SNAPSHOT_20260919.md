# Audit snapshot — 2026-09-19

Published for independent audit. **Not** BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS / MIG_PASS.

GitHub issues: https://github.com/Jokejoker-designer/Native_SymAI/issues  
Status: [`docs/STATUS_20260919.md`](../../docs/STATUS_20260919.md)

## What this tree is

Current **UART_R2** overlays (U1–U32) and **D_DEST_LIFECYCLE_OBS_01** observer/TBs copied from live `D:\FPGA\arty_d\`. Frozen identity H, FE256 freeze DCPs, AGENT_C RTL, and B gold are **not** overwritten.

Xilinx MIG IP is **not** vendored. OBS01-MIG0 TB expects local `mig0_mig_sim` + `ddr3_model`.

Omitted from git (size / not source): Vivado `build_u*` DCP farms, `xsim_*` work dirs, nested `.git`.

Included bits (programmed candidates only):

| File | SHA256 |
|---|---|
| `UART_R2/build_u31/uart_r2_u31_candidate.bit` | `08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d` |
| `UART_R2/build_u32/uart_r2_u32_candidate.bit` | `0df4de2ec075bfdbe567bb661702da088a1be5322cc9112ad2ebf959d116f6ff` |

## Key source hashes (this commit)

### UART_R2 U32 (latest overlay)

| File | SHA256 |
|---|---|
| `u32/pack_uart_dualclk_harness.sv` | `d3fb0bf5654c32ada56b198cdcd6402376ff29e1650ca470f329e3ae55ee7db1` |
| `u32/pack_mig_bind.sv` | `7cee4df21b69f5eb05728473c755f3f067b6c702502f0ac97af59f19093b0fbe` |
| `u32/pack_debug_clear.sv` | `58a3961aaee067dc1a025bec02dfedc6308f716890e1719edb39fc294f512b00` |
| `u32/pack_clear_ui.sv` | `b0b1db2705102dad521d4422d7089f7b3f54c03562d2cde52f2418c81eb172aa` |
| `u32/arty_a7_r2_top_m4_mig_candidate.sv` | `66107ffe79613d5664e734e0e0d0281b06230ca0e3d28caa7c8cd41116db38d1` |

U32 overlay keeps `dest_ui_rdy` in `pack_quiescent`. Does **not** drop `dest_ui_rdy` from `dest_accept`. PACKAGE live canon RTL is a separate tree under `CANON_BLUEPRINT/`.

### UART_R2 U31 (prior)

| File | SHA256 |
|---|---|
| `u31/pack_mig_bind.sv` | `72e4b8e3c485586411e718ba597e3d262888cb59e3144b57b15dd681d603869c` |
| `u31/pack_uart_dualclk_harness.sv` | `9e67448898c27b5f671c31db450745bbddc52baeecd845594a21bc580741b76c` |

### D_DEST_LIFECYCLE_OBS_01

| File | SHA256 |
|---|---|
| `tb_dest_lifecycle_obs_01.sv` | `7430bf839edd78989cd00e9e3ae10f094100c0f6d5573141dd67dbc7f857d510` |
| `dest_lifecycle_obs.sv` | `17b5ca3cf3cb5add394e338ed4331582c600d52a134d7127fbd399639fb68b9d` |
| `out/dest_ui_clk.csv` | `6e8e93464287db5f92b78a1295a68707ce94799b18343f960f1bb9fe33343b0f` |
| `out/xsim.log` | `3dfb00161d86be905996a034eadeeaf18a83da3d8c7ff96fc959ee6ba7e992f2` |
| `pack_uart_mig0_harness.sv` | `e879df6ad405fce0151db2fe61d7981c368452926f6d317859d394182cbf8ba8` |
| `tb_dest_lifecycle_obs_01_mig0.sv` | `d84cf4ac97e1f359e76aba858fc5c80cbdf28dc047f6f228b0c561b089d7d0d9` (CLEAR2 `OBS01_QSC_VS_RDY`) |
| `dest_lifecycle_obs_mig0.sv` | `238f0830d4419932fa4ee5b9316e8790e9abcd6918097ce53dd75b6216004090` |

OBS01 **BRAM** XSim (this csv/log): Q1 YES, Q2 YES, Q3 NO, Q4 NEW_COMMIT, `BRAM_PATH_THIS_SEQUENCE=CLEAN`. Not mig0. Not board.

OBS01-MIG0 sources are present for audit of the P0–P15 lock; **MIG0 XSim result is not in this snapshot** (`MIG0_BOARD_CAUSAL_CLASS=STILL_OPEN`).

## Where to start reading

1. `UART_R2/STATUS.md` + `UART_R2/CLAIM_CEILING.txt`
2. `UART_R2/results/PACK24_U32/U32_FAIL.md` — exclusive CLEAR1 FAIL_BOARD
3. `UART_R2/results/PACK24_U31/` — leftover GOLD vs dest_accept analysis
4. `D_DEST_LIFECYCLE_OBS_01/OBS01_XSIM.md` — BRAM Q1–Q4
5. `D_DEST_LIFECYCLE_OBS_01/tb_dest_lifecycle_obs_01.sv` — Q4 BEGIN2 deltas (not `lack_fell`)
6. `CANON_BLUEPRINT/rtl/native_ai/memory/mig_ui32.sv` — `cmd_acc` / `wdf_acc`
7. `CANON_BLUEPRINT/rtl/native_ai/loader/pack_loader.sv`

## Claim ceiling (repeat)

```
PACK_ABI_24_24_PASS     = NO
BOARD_PASS              = NO
PROGRAM_PASS            = NO
MIG_PASS                = NO
MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN
```
