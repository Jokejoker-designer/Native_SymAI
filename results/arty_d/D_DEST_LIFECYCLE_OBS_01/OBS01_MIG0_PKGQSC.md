# D_DEST_LIFECYCLE_OBS_01 — PACKAGE-qsc A/B ($finish; Q1–Q4; PACK_ABI still NO)

TB-only. `xvlog -d OBS01_QSC_PKG` → `QSC_USE_DEST_RDY=0` (force dest ready 1 into U32 `pack_quiescent` ports). Does **not** patch `UART_R2/u32/pack_mig_bind.sv` (still sha256 `7cee4df2…`).

```
H1_CAUSAL_CLEAR1_ACK                 = PASS_XSIM (this A/B)
PACKAGE_QSC_MIG0_TXN1_P0_P15         = PASS_XSIM (t1_seen=ffff last=P15_SETTLE_IDLE div=NONE)
PACKAGE_QSC_GOLD1                    = PASS_XSIM got=010000a5 mute=0
Q1_MIG_UI32_IDLE_AFTER_GOLD1         = YES (settle snapshot; not ever-idle)
PACKAGE_QSC_CLEAR2                   = PASS_XSIM ACK got=c1ea50a5 mute=0 dclr_busy=0
Q2_DEST_IDLE_AT_CLEAR2               = YES (BEFORE_CLEAR2 out0/idle then ACK)
GOLD2 / Q3 / Q4                      = COMPLETE this seq
PACKAGE_QSC_GOLD2                    = PASS_XSIM got=010000a5 mute=0 begin2=1
Q3_CLEAR2_RESET_BEFORE_RETIRE        = NO dclr_while_busy=0
Q4_GOLD2_SOURCE                      = NEW_COMMIT d_commit=1 d_lack=1 d_stv=1
PACKAGE_QSC_MIG0_PATH_THIS_SEQUENCE  = CLEAN (PASS_XSIM; TB-forced dest ready)
NO_STUCK_STATE_OBSERVED_ON_MIG0_THIS_SEQ = YES
LAST_EQUIVALENT_EVENT                = P15_SETTLE_IDLE
$finish                              = 4958414625 ps
U32 dest-AND seq (prior)             = FAIL_XSIM_CLEAR1_BUSY got=c1ea50b5
PACK_ABI_24_24_PASS                  = NO
MIG_PASS                             = NO
MIG0_BOARD_CAUSAL_CLASS              = STILL_OPEN
MIG0_PATH_THIS_SEQUENCE              = FAIL_XSIM_CLEAR1_BUSY  (U32 dest-AND seq; unchanged)
PACKAGE_QSC_MIG0_PATH_THIS_SEQUENCE  = CLEAN (this A/B only; not product U32)
```

No UART overlay. No dest_accept overlay. No program. No product qsc patch.

RUN parent `run_obs01_mig0_pkgqsc.bat` started 2026-09-19T09:20+07. Live `xsim`/`xsimk` still held the log at this publish.

| Artifact | SHA256 |
|---|---|
| snapshot `out/xsim_mig0_pkgqsc.log` | `63eb8e3e1145d5d668d16a989d33e7a1eaec7df566de41f0a6b1069c832455d1` (213 lines; `$finish`) |
| snapshot `out/xsim_mig0_pkgqsc_ckpt.txt` | `75cd2edd637a2a2cacff19e6e566726c71312a13993cb58864aba71c6e574a33` |
| snapshot `out/dest_ui_clk_mig0_pkgqsc.csv` | `34b68c2b22abeac30356b0229c1f0603a0222b9fb0e0c7543e1e19208a018b5b` |
| `tb_dest_lifecycle_obs_01_mig0.sv` | `db1adfceea581c39614b68fef18a6745020c0cbcb6a6033b64df3aade3a1ce5e` |
| `pack_uart_mig0_harness.sv` | `8839ccc7ad4a22c837ec59879d6db35cdc5523ab5f8664661289ba649d9aeafd` |
| `run_obs01_mig0_pkgqsc.bat` | `7ddae9b28405c7e1e244bb697ee1a1e2cdb03052199b390fe08125e4cd80a9c1` |
| U32 `pack_mig_bind.sv` | `7cee4df21b69f5eb05728473c755f3f067b6c702502f0ac97af59f19093b0fbe` (unchanged) |

## Fail/pass report (txn1)

Contrast dest = generated `mig0` + same UART CLEAR after calib:

```
USE_DEST_RDY=1 (U32 AND): CLEAR1 BUSY c1ea50b5  FIRST_DIVERGENCE=CLEAR1_ACK
USE_DEST_RDY=0 (PACKAGE): CLEAR1 ACK  c1ea50a5  qsc_ui=1 qsc_c1=1 dest_accept=1
                         BRANCH H1_CAUSAL_CLEAR1_ACK
```

Then (this snapshot, log `$display` only):

```
P0_BEGIN_ACCEPT          t=451550625.0 ps
P1_MEM_CMD_WRITE_HS      t=2451602625.0 ps  ld_st=3
P2_APP_EN_RDY_WR         t=2451626625.0 ps  (same cycle as P3)
P3_APP_WDF_HS_WR         t=2451626625.0 ps
P4_ENTER_S_RD_AFTER_P2P3 t=2451638625.0 ps  cmd_acc=1 wdf_acc=1
P5_RD_CMD_ACCEPT         t=2452010625.0 ps
P6_APP_RD_DATA_VALID     t=2452310625.0 ps
P7_LANE_MATCH_WDATA_R    t=2452310625.0 ps
P8_UI_OUTSTANDING_DEC    t=2452334625.0 ps  ui_out=0
P9_MEM_RESP_CONSUME      t=2452706625.0 ps
P10_LOADER_OUT_ZERO      t=2491562625.0 ps
P11_SENTINEL_OK          t=2491862625.0 ps
P12_S_COMMIT             t=2491874625.0 ps
P13_LOAD_ACK_RISE        t=2491886625.0 ps
P14_STATUS_VALID_RISE    t=2491898625.0 ps
P15_SETTLE_IDLE          t=2492666625.0 ps  ui_st=0 ui_out=0 ld_st=0 ld_out=0 cmd_acc=0 wdf_acc=0
OBS01_GOLD1              mute=0 got=010000a5 t1_seen=ffff last=P15_SETTLE_IDLE div=NONE
OBS01_AFTER_GOLD1_SETTLE q1_ui_idle=1 ui_st=0 ui_out=0 ld_st=0
OBS01_BEFORE_CLEAR2      q2_out0=1 ui_st=0 ui_out=0 ld_out=0 ld_busy=0 ui_busy=0
OBS01_QSC_VS_RDY         dest_rdy=1 dest_wdf=1 p_rdy=0 p_wdf=0 mux_g=0 qsc_ui=1 qsc_c1=1 dest_accept=1
OBS01_QSC0_IDLE_COUNTS   n=0 rdy0=0 rdy1=0
OBS01_QSC0_WHILE_IDLE    t=2581202625.0 ps dest_rdy=1 dest_wdf=1 p_rdy=0 mux_g=0 qsc_c1=1 dest_accept=1
OBS01_CLEAR2             mute=0 got=c1ea50a5 dclr_busy=0 lack_fell=1
OBS01_V04_2_ARM          n_commit=1 n_lack_rise=1 n_stv_rise=1 (lack_fell is CLEAR reset, not BEGIN2)
OBS01_CKPT P0_BEGIN_ACCEPT t=2869094625.0 ps  (BEGIN2)
OBS01_CKPT P1_MEM_CMD_WRITE_HS t=4869146625.0 ps
OBS01_CKPT P2+P3 same cycle 4869170625.0 ps
OBS01_CKPT P4 cmd_acc=1 wdf_acc=1
OBS01_CKPT P5–P9 readback consume
OBS01_CKPT P10–P15_SETTLE_IDLE t=4910258625.0 ps ui/ld idle out=0
```

FACT: generated `mig0` on this PACKAGE-qsc sequence completed CLEAR→V-04→CLEAR→V-04 dest lifecycle with Q1 YES Q2 YES Q3 NO Q4 NEW_COMMIT. `lack_fell=1` is CLEAR reset of sticky `load_ack`, not a new txn.

```
OBS01_GOLD2 mute=0 got=010000a5 begin2=1 t_begin2=2869094625.0 ps t_commit2=4909430625.0 ps t_lack2=4909442625.0 ps
OBS01_GOLD2_DELTA d_commit=1 d_lack=1 d_stv=1
Q1_MIG_UI32_IDLE_AFTER_GOLD1 YES
Q2_UI_OUTSTANDING_ZERO_BEFORE_CLEAR2 YES
Q3_CLEAR2_RESET_BEFORE_RETIRE NO dclr_while_busy=0
Q4_GOLD2_SOURCE NEW_COMMIT begin2=1 commit2=1 lack2_after_commit=1 d_commit=1 d_lack=1 d_stv=1
NO_STUCK_STATE_OBSERVED_ON_MIG0_THIS_SEQ ld_idle=1 ui_idle=1 out0=1 st_quiet=1
LAST_EQUIVALENT_EVENT = P15_SETTLE_IDLE
MIG0_PATH_THIS_SEQUENCE = CLEAN   (TB label for THIS PACKAGE-qsc seq)
PACK_ABI_24_24_PASS = NO
OBS01_DONE dest=generated_mig0 not_board not_pack_abi
$finish 4958414625 ps
```

FACT: `OBS01_QSC0_WHILE_IDLE` with `dest_rdy=1` occurred before CLEAR2 ACK. It is **not** CLEAR2 BUSY.

UNKNOWN: board exclusive U32 CLEAR1 BUSY cycle-causal class; whether owner will authorize a new overlay identity to change product qsc.

## Claim ceiling

Not PACK_ABI_24_24_PASS / MIG_PASS / BOARD_PASS / PROGRAM_PASS.
TB-forced dest ready ≠ product `pack_mig_bind` dest-AND.
Do not product-strip `dest_ui_*` from U32 qsc until owner authorizes a new overlay identity.
`MIG0_PATH_THIS_SEQUENCE=FAIL_XSIM_CLEAR1_BUSY` remains the **U32 dest-AND** sequence label.
`PACKAGE_QSC_MIG0_PATH_THIS_SEQUENCE=CLEAN` is this A/B only.
