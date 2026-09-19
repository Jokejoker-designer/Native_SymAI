# Audit feed from chat `31dc87bc-7c69-45e9-8f38-a233417caeb3`

Side chat watches the parent Cursor session and publishes **completed** findings here. Not a PASS stamp.

Last published: 2026-09-19T11:44+07 from live `xsim_mig0_pkgqsc.log` (parent jsonl unchanged at 3002316).

## Parent is doing

PACKAGE-qsc XSim still running after BEGIN2 P0–P15. GOLD2 not printed. No UART overlay.

## New since GitHub `e97895b`

### 2026-09-19 08:31+07 — RAW_MIG_READY_USED_AS_QUIESCENCE

Parent reviewed Anh’s hypothesis **before overlay**.

| Layer | Verdict |
|---|---|
| `MISSING_APP_RDY_GATE` | **WEAK** — idle `mig_ui32` does not need `app_rdy`; mux `G_NONE` zeros `p_rdy` on purpose |
| U31/U32 `pack_quiescent` ANDs raw `mig0.app_rdy`/`app_wdf_rdy` | **FACT** (`pack_mig_bind.sv` + top wiring) |
| PACKAGE live qsc | **FACT** — loader+ui+outstanding only; no `dest_ui_*` |
| BRAM `app_rdy = rst_n && !stall` | **FACT** — OBS01 BRAM CLEAN cannot refute dest-ready dips |
| Board CLEAR1 BUSY / BEGIN hold caused by that AND | **HYPOTHESIS** at 08:31; XSim later **SEEN_THIS_SEQ** (board still open) |
| Root cause | **UNKNOWN** (not PACK_ABI / BOARD) |

Do not UART-overlay. Do not strip `dest_ui_*` from product qsc until PACKAGE-qsc A/B ACK.

Sources:

- `CANON_BLUEPRINT/_COORDINATION/reasoning/NATIVE_AI_REASONING_EXPERIENCE_V1_AGENT_D_20260919T013100Z.md`
- `results/arty_d/D_DEST_LIFECYCLE_OBS_01/tb_dest_lifecycle_obs_01_mig0.sv` sha256 `fb36a2b88b677a0e7feebbe1a58fc484f1ae292e67d281e660842fc6e1d17a6c`

### 2026-09-19 08:34–08:36+07 — OBS01-MIG0 compile (superseded)

Two `xvlog`/`xelab` hangs were killed (`exit 4294967295`). Compile into `-work obs` then XSim completed. See next entry.

### 2026-09-19 08:55–09:00+07 — OBS01-MIG0 XSim COMPLETE

Parent: `run_obs01_mig0.bat`. `$finish` 211565 ns. calib_done 122810625 ps. xsim elapsed ~7m25s after calib.

```
MIG0_PATH_THIS_SEQUENCE          = FAIL_XSIM_CLEAR1_BUSY
LAST_EQUIVALENT_EVENT            = CALIB_DONE
FIRST_DIVERGENCE                 = CLEAR1_ACK
got                              = c1ea50b5 (CLR_BUSY) mute=0
RAW_MIG_READY_USED_AS_QUIESCENCE = SEEN_THIS_SEQ (PASS_XSIM)
MISSING_APP_RDY_GATE             = CONTRADICTED_THIS_SEQ (qsc path)
PACK_ABI_24_24_PASS              = NO
MIG0_BOARD_CAUSAL_CLASS          = STILL_OPEN
```

P0–P15 not armed (`t1_arm` after CLEAR1 ACK). `DEBUG_CLEAR_RISE` never occurred.

Independent csv check (this publish): 186 rows. `qsc===app_rdy` 186/186. All `ld=IDLE ui=IDLE ld_out=0 ui_out=0 mux_g=0`. `p_rdy=0` and `p_wdf_rdy=0` all rows. `app_wdf_rdy=1` all rows. Idle+qsc=0: 93 rows, all `app_rdy=0`. Idle+qsc=0 while dest_rdy=1 and dest_wdf=1: **0**. `debug_clear=1`: 0.

Hashes:

| Artifact | SHA256 |
|---|---|
| `out/dest_ui_clk_mig0.csv` | `134b59561bf07f125e3b419ac16e5170a4ce9a77682505310007b8249331b5dc` |
| `out/xsim_mig0.log` | `169061f9f8b577e8e78e0dd1012798eac098b6433d623fb2a730084a2fde70ad` |
| `tb_dest_lifecycle_obs_01_mig0.sv` | `fb36a2b88b677a0e7feebbe1a58fc484f1ae292e67d281e660842fc6e1d17a6c` |
| U32 `pack_mig_bind.sv` | `7cee4df21b69f5eb05728473c755f3f067b6c702502f0ac97af59f19093b0fbe` |

No UART overlay. No dest_accept overlay. No program. Next parent test (not done): PACKAGE-qsc A/B.

```
PACK_ABI_24_24_PASS = NO
```

### 2026-09-19 09:34+07 — PACKAGE-qsc A/B CLEAR1 ACK

First `xvlog -d QSC_USE_DEST_RDY=0` split `=0` as a filename. Parent switched to `-d OBS01_QSC_PKG`.

```
USE_DEST_RDY=0  CLEAR1 ACK  c1ea50a5  qsc_ui=1 qsc_c1=1 dest_accept=1
BRANCH H1_CAUSAL_CLEAR1_ACK PACKAGE_QSC dest_rdy_not_in_qsc
P0_BEGIN_ACCEPT t=451550625.0 ps
V-04 / P1–P15 / GOLD1 = IN_PROGRESS (xsim still holds the log)
PACK_ABI_24_24_PASS = NO
```

Contrast published U32 dest-AND seq: CLEAR1 BUSY `c1ea50b5`.

TB-only: harness forces dest ready 1 into `pack_mig_bind` dest_ui ports. Product `pack_mig_bind.sv` still `7cee4df2…` (AND dest_ui_*). No overlay. No program.

Snapshot log sha256 `c182aeed392e97b979690abe1c47288b8a5a4bc667a7919d30b0ffb3535a88a7` (155 lines). Write-up: `results/arty_d/D_DEST_LIFECYCLE_OBS_01/OBS01_MIG0_PKGQSC.md`.

### 2026-09-19 10:42+07 — PACKAGE-qsc GOLD1 + P0–P15

Live log (not parent chat text). `xsim`/`xsimk` still running. csv snapshot truncated; score from `$display`.

```
PACKAGE_QSC_MIG0_TXN1_P0_P15 = PASS_XSIM  t1_seen=ffff last=P15_SETTLE_IDLE div=NONE
PACKAGE_QSC_GOLD1            = PASS_XSIM  mute=0 got=010000a5
Q1_MIG_UI32_IDLE_AFTER_GOLD1 = YES
P0  t=451550625.0 ps
P1  t=2451602625.0 ps   (~2.00 ms sim after P0 = UART 52-word ingest)
P2+P3 same cycle 2451626625.0 ps
P15 t=2492666625.0 ps   ui/ld idle out=0 cmd_acc=0 wdf_acc=0
CLEAR2 / GOLD2 / Q3 / Q4     = IN_PROGRESS
PACK_ABI_24_24_PASS          = NO
MIG0_PATH_THIS_SEQUENCE      = FAIL_XSIM_CLEAR1_BUSY  (U32 dest-AND seq; not overwritten)
```

Wall: calib+CLEAR ~09:20–09:35; UART ingest ~09:35–10:38; GOLD1 on log by 10:40. Slow because `mig0`+`ddr3_model`+1ps+gui/wdb, not because “52 integers”.

Also on log: `OBS01_QSC0_WHILE_IDLE t=2581202625.0 ps dest_rdy=1` after BEFORE_CLEAR2. **UNKNOWN** until `OBS01_CLEAR2` prints. Not classified as CLEAR2 BUSY.

Hashes this publish:

| Artifact | SHA256 |
|---|---|
| snapshot `out/xsim_mig0_pkgqsc.log` | `564d2eb444e26599a66f8d5a93ed744a591e1850950c811204e4ecf9c698e076` (177 lines) |
| snapshot `out/xsim_mig0_pkgqsc_ckpt.txt` | `124b1f6816f52dea6e7623809d7bb12b97a657d3246ab30dc387fc3db22e4997` |
| snapshot `out/dest_ui_clk_mig0_pkgqsc.csv` | `b59272b5e160c99a48873c5b942bdc3530a41f28c6412719eafbc67d2f6ac087` (truncated) |

No UART overlay. No dest_accept overlay. No program. Product `pack_mig_bind.sv` still `7cee4df2…`.

### 2026-09-19 10:49+07 — PACKAGE-qsc CLEAR2 ACK

```
PACKAGE_QSC_CLEAR2         = PASS_XSIM  mute=0 got=c1ea50a5 dclr_busy=0 lack_fell=1
Q2_DEST_IDLE_AT_CLEAR2     = YES
OBS01_V04_2_ARM            n_commit=1 n_lack_rise=1 n_stv_rise=1
BEGIN2 P0_BEGIN_ACCEPT     t=2869094625.0 ps
GOLD2 / Q4 / P1–P15        = IN_PROGRESS
PACK_ABI_24_24_PASS        = NO
```

`lack_fell=1` is CLEAR reset of sticky `load_ack`, not BEGIN2. QSC0_WHILE_IDLE with dest_rdy=1 is **not** CLEAR2 BUSY (ACK followed).

Hashes this publish:

| Artifact | SHA256 |
|---|---|
| snapshot `out/xsim_mig0_pkgqsc.log` | `d44f4cd5dba330513fc509fbe045982e720884db6bebe057131cdfa600fa5adb` (180 lines) |
| snapshot `out/xsim_mig0_pkgqsc_ckpt.txt` | `15ce6ba4ab18b916f34bd1cbef6fa12c5db5a11dcc5b245b1a9c328a3c13b228` |

### 2026-09-19 11:44+07 — PACKAGE-qsc BEGIN2 P0–P15

```
PACKAGE_QSC_MIG0_TXN2_P0_P15 = PASS_XSIM
BEGIN2 P0  t=2869094625.0 ps
BEGIN2 P1  t=4869146625.0 ps  (~2.00 ms sim after P0 = UART 52-word ingest)
BEGIN2 P2+P3 same cycle 4869170625.0 ps
BEGIN2 P15 t=4910258625.0 ps  ui/ld idle out=0 cmd_acc=0 wdf_acc=0
GOLD2 / Q4                   = IN_PROGRESS
PACK_ABI_24_24_PASS          = NO
```

Hashes this publish:

| Artifact | SHA256 |
|---|---|
| snapshot `out/xsim_mig0_pkgqsc.log` | `aa7a038f319f74cea9aed5b58768a2be03f79f356b492fd4a4fb0eafd15e2658` (195 lines) |
| snapshot `out/xsim_mig0_pkgqsc_ckpt.txt` | `7860510a689228d7c97d2957a11545cc3e07e5dd8780dc3bb7ac232839f8ad4b` |
| snapshot `out/dest_ui_clk_mig0_pkgqsc.csv` | `4a7ace74d8f9bbc07e991b337d02fb70f57c5f6bdd240de68993b5198dec7035` |


