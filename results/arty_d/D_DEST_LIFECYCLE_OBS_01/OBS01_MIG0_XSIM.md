# D_DEST_LIFECYCLE_OBS_01 — generated mig0 (CLEAR1 BUSY)

```
MIG0_PATH_THIS_SEQUENCE = FAIL_XSIM_CLEAR1_BUSY
BRAM_PATH_THIS_SEQUENCE = CLEAN (prior run; dest=mig_ui_bram)
PACK_ABI_24_24_PASS     = NO
MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN
RAW_MIG_READY_USED_AS_QUIESCENCE = SEEN_THIS_SEQ
MISSING_APP_RDY_GATE             = CONTRADICTED_THIS_SEQ (qsc path)
```

Dest = generated `mig0` + `ddr3_model` FAST calib. Same UART sequence as BRAM OBS01.
No UART overlay. No dest_accept overlay. No qsc product patch. No program.
RUN `20260919T015520Z`. `$finish` 211565 ns. Command `run_obs01_mig0.bat`.
xsim elapsed ~7m25s after calib at 122810625 ps.

| Artifact | SHA256 |
|---|---|
| `out/dest_ui_clk_mig0.csv` | `134b59561bf07f125e3b419ac16e5170a4ce9a77682505310007b8249331b5dc` (186 data rows) |
| `out/xsim_mig0.log` | `169061f9f8b577e8e78e0dd1012798eac098b6433d623fb2a730084a2fde70ad` |
| `UART_R2/u32/pack_mig_bind.sv` | `7cee4df21b69f5eb05728473c755f3f067b6c702502f0ac97af59f19093b0fbe` |

## Fail report

```
LAST_EQUIVALENT_EVENT = CALIB_DONE
FIRST_DIVERGENCE      = CLEAR1_ACK
got = c1ea50b5 (CLR_BUSY) mute=0
```

P0–P15 were not armed (t1_arm after CLEAR1 ACK). No generic “MIG lỗi”.
`DEBUG_CLEAR_RISE` never occurred: `pack_clear_ui` did not enter `S_CLR`.

## dest_ui_clk.csv (this seq)

Every logged row: `ld=IDLE ui=IDLE ld_out=0 ui_out=0 mux_g=0`.
`p_rdy=0` and `p_wdf_rdy=0` on all 186 rows (G_NONE).
`app_wdf_rdy=1` on all 186 rows.
`qsc == app_rdy` on all 186 rows (0 mismatches).
QSC events: 185 toggles. Dip period median **960 ns**, pulse width **24 ns** (2 ui_clk at 12 ns).
Idle + qsc=0: 93 rows, all with `app_rdy=0`. Idle + qsc=0 while dest_rdy=1 and dest_wdf=1: **0**.

ARM at 122823000 ps: `app_rdy=0 qsc=0`.
Last QSC at 211215000 ps: `app_rdy=1 qsc=1` then UART BUSY at 211565 ns.

## Candidate scoring

`RAW_MIG_READY_USED_AS_QUIESCENCE`: **SEEN_THIS_SEQ** (PASS_XSIM).
Client idle, outstanding=0, `debug_clear=0`, `mux_g=G_NONE`, `qsc_ui` follows raw `mig0.app_rdy`.
`app_wdf_rdy` did not dip this seq (still a legal term in the AND; not the toggling term here).

`MISSING_APP_RDY_GATE` / mux-`p_rdy` ownership of `mig_ui32.app_rdy`: **CONTRADICTED_THIS_SEQ** for the qsc path.
`dest_ui_rdy = d_rdy = dest_app_rdy`, not `p_rdy`. `p_rdy` stayed 0 while `qsc` still went 1 whenever `app_rdy=1`.

## Why BRAM OBS01 hid this

`mig_ui_bram`: `app_rdy = rst_n && !stall` (level-1 after reset).
U32 qsc ANDs that level. CLEAR1 ACK on BRAM. Same qsc formula + generated mig0 periodic `app_rdy` dips → CLEAR1 BUSY.

`pack_clear_ui` DRAIN_N=64 ui cycles (~768 ns) vs ~80-cycle / 960 ns dest_rdy period: a 64-cycle consecutive-qsc window is smaller than the high stretch, so CLEAR after SAMPLE is likely to NACK. `pack_debug_clear` S_SAMPLE also requires `qsc_100` (includes CDC `qsc_c1`).

## Claim ceiling

Not PACK_ABI_24_24_PASS / MIG_PASS / BOARD_PASS / PROGRAM_PASS.
Board exclusive U32 CLEAR1 BUSY is the **same token class**; not proven the same cycle-causal class on silicon.
Do not drop `dest_ui_*` from product qsc until TB A/B: same OBS01-MIG0 with PACKAGE qsc (no dest_ui AND) → CLEAR1 ACK. That A/B is not done this run.
Do not UART overlay. Do not dest_accept overlay.
