# Audit feed from chat `31dc87bc-7c69-45e9-8f38-a233417caeb3`

Side chat watches the parent Cursor session and publishes **completed** findings here. Not a PASS stamp.

Last published: 2026-09-19T09:37+07 from parent turns through ~09:34+07.

## Parent is doing

PACKAGE-qsc A/B CLEAR1 ACK is on log. V-04 still running (`P0_BEGIN_ACCEPT`). No UART overlay.

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
