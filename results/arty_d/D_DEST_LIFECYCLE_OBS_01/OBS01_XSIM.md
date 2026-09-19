# D_DEST_LIFECYCLE_OBS_01 — tightened Q4 / no-stuck (BRAM)

```
BRAM_PATH_THIS_SEQUENCE = CLEAN
PACK_ABI_24_24_PASS     = NO
MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN
```

Dest = `mig_ui_bram` ≠ generated `mig0` ≠ board. No UART overlay. No loader patch. No program.
RUN `20260919T010544Z`. `$finish` 4835343750 ps. Command `run_obs01.bat`.

| Artifact | SHA256 |
|---|---|
| `tb_dest_lifecycle_obs_01.sv` | `7430bf839edd78989cd00e9e3ae10f094100c0f6d5573141dd67dbc7f857d510` |
| `dest_lifecycle_obs.sv` | `17b5ca3cf3cb5add394e338ed4331582c600d52a134d7127fbd399639fb68b9d` |
| `out/dest_ui_clk.csv` | `6e8e93464287db5f92b78a1295a68707ce94799b18343f960f1bb9fe33343b0f` (216 lines) |
| `out/xsim.log` | `3dfb00161d86be905996a034eadeeaf18a83da3d8c7ff96fc959ee6ba7e992f2` |

## Scoring (this run)

Q4 does **not** use `lack_fell`. CLEAR2 `debug_clear` resets `pack_loader`, so `load_ack` fall is client reset. NEW_COMMIT requires:

BEGIN2 accepted → later `S_COMMIT` → `load_ack` rise after that COMMIT → GOLD2 after that commit.

Deltas are vs BEGIN2 snapshot, not cumulative totals.

`NO_STUCK_STATE_OBSERVED_ON_BRAM_THIS_SEQ` only after GOLD2 settle: loader idle, `mig_ui32` idle, `ui_outstanding==0`, `st_valid_ui==0 && st_valid_100==0`.

## Four questions PASS_XSIM BRAM

| # | Answer | Snapshot |
|---|---|---|
| Q1 | **YES** | After GOLD1 + 64 ui_clk: `ui_st=IDLE ui_busy=0` (not ever-idle) |
| Q2 | **YES** | CLEAR2 boundary: `ui_out=0` |
| Q3 | **NO** | `DEBUG_CLEAR_RISE` dest already IDLE/out0. `lack_fell=1` is sticky `load_ack` drop, not a live txn |
| Q4 | **NEW_COMMIT** | `P_BEGIN` 2746394000 ps (`00800001`). `d_commit=1 d_lack=1 d_stv=1` vs BEGIN2 counts c=l=s=1. `t_commit2=4786519000` then `t_lack2=4786531000` then GOLD2 UART. `lack_fell` printed only as CLEAR-reset diagnostic |

V04_2_ARM before BEGIN2: `n_commit=1 n_lack_rise=1 n_stv_rise=1` (transaction 1 only).

## Stuck check

`NO_STUCK_STATE_OBSERVED_ON_BRAM_THIS_SEQ ld_idle=1 ui_idle=1 out0=1 st_quiet=1`

This does **not** mean FIRST_STATE_THAT_NEVER_RETURNS is closed on silicon.

## What this eliminates / does not

Eliminated for **this BRAM sequence**: loader/BRAM dest not returning IDLE; CLEAR2 chopping a live `mig_ui32` txn; GOLD2 being sticky-`load_ack` replay without BEGIN2/COMMIT2.

Not proven: board path, generated `mig0`, U32 exclusive CLEAR1 BUSY/n=0.

## Next (no U33, no BRAM loader patch)

Same OBS01 probes on generated `mig0`:

`app_en app_rdy app_wdf_wren app_wdf_rdy app_rd_data_valid`
`mig_ui32.st ui_outstanding loader.state loader wr_outstanding`
`mux grant debug_clear pack_quiescent load_ack`

Decisive: BRAM `WRITE→READBACK→IDLE→CLEAR2→BEGIN2→COMMIT2` vs first mig0 divergence.
