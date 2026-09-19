# D_DEST_LIFECYCLE_OBS_01 — PACKAGE-qsc A/B (CLEAR1 ACK)

TB-only. `xvlog -d OBS01_QSC_PKG` → `QSC_USE_DEST_RDY=0` (force dest ready 1 into U32 `pack_quiescent` ports). Does **not** patch `UART_R2/u32/pack_mig_bind.sv` (still sha256 `7cee4df2…`).

```
H1_CAUSAL_CLEAR1_ACK            = PASS_XSIM (this A/B)
U32 dest-AND seq (prior)        = FAIL_XSIM_CLEAR1_BUSY got=c1ea50b5
PACKAGE-qsc A/B (this seq)      = CLEAR1 ACK got=c1ea50a5
V-04 / P0–P15                   = IN_PROGRESS at publish (P0_BEGIN_ACCEPT seen; no $finish)
PACK_ABI_24_24_PASS             = NO
MIG0_BOARD_CAUSAL_CLASS         = STILL_OPEN
```

No UART overlay. No dest_accept overlay. No program. No product qsc patch.

RUN parent ~2026-09-19T02:34Z. Command `run_obs01_mig0_pkgqsc.bat`. Log still held by live `xsim` at snapshot.

| Artifact | SHA256 |
|---|---|
| snapshot `out/xsim_mig0_pkgqsc.log` | `c182aeed392e97b979690abe1c47288b8a5a4bc667a7919d30b0ffb3535a88a7` (155 lines; live file locked) |
| `tb_dest_lifecycle_obs_01_mig0.sv` | `db1adfceea581c39614b68fef18a6745020c0cbcb6a6033b64df3aade3a1ce5e` |
| `pack_uart_mig0_harness.sv` | `8839ccc7ad4a22c837ec59879d6db35cdc5523ab5f8664661289ba649d9aeafd` |
| `run_obs01_mig0_pkgqsc.bat` | `7ddae9b28405c7e1e244bb697ee1a1e2cdb03052199b390fe08125e4cd80a9c1` |
| U32 `pack_mig_bind.sv` | `7cee4df21b69f5eb05728473c755f3f067b6c702502f0ac97af59f19093b0fbe` (unchanged) |

## Fail/pass report (CLEAR1 only)

Contrast dest = generated `mig0` + same UART CLEAR after calib:

```
USE_DEST_RDY=1 (U32 AND): CLEAR1 BUSY c1ea50b5  FIRST_DIVERGENCE=CLEAR1_ACK
USE_DEST_RDY=0 (PACKAGE): CLEAR1 ACK  c1ea50a5  qsc_ui=1 qsc_c1=1 dest_accept=1
                         BRANCH H1_CAUSAL_CLEAR1_ACK
```

Then (incomplete this snapshot): `OBS01_CKPT P0_BEGIN_ACCEPT t=451550625.0 ps`.

## Claim ceiling

Not PACK_ABI_24_24_PASS / MIG_PASS / BOARD_PASS / PROGRAM_PASS.
Do not product-strip `dest_ui_*` from U32 qsc from this CLEAR1 A/B alone until owner authorizes a new overlay identity. Board exclusive U32 CLEAR1 BUSY still STILL_OPEN as cycle-causal class.
