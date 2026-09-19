# D_DEST_LIFECYCLE_OBS_01

OWNER AGENT_D. MODE OBSERVE_ONLY.
Not PACK_ABI_24_24_PASS / BOARD_PASS / MIG_PASS / PROGRAM_PASS.
Claim ceiling:

```
BRAM_PATH_THIS_SEQUENCE = CLEAN
MIG0_PATH_THIS_SEQUENCE = FAIL_XSIM_CLEAR1_BUSY
PACK_ABI_24_24_PASS     = NO
MIG0_BOARD_CAUSAL_CLASS = STILL_OPEN
RAW_MIG_READY_USED_AS_QUIESCENCE = SEEN_THIS_SEQ (PASS_XSIM mig0)
```

See `OBS01_MIG0_XSIM.md`. Do not treat as BOARD root cause. No qsc/UART/dest_accept overlay from this log.

`mig_ui_bram` ≠ generated `mig0`. Do not UART-overlay. Do not patch BRAM loader from this seq.
Q4 = BEGIN2 → S_COMMIT → load_ack rise → GOLD2. `lack_fell` is CLEAR reset, not a new txn.
No UART overlay. No dest_accept change. No C RTL / H / freeze DCP / Pack24 gold edits.

## Purpose

Log destination lifecycle at `ui_clk` through pack_mig_bind + mux + dest.
Answer LAST_GOOD_DEST_EVENT → FIRST_STATE_THAT_NEVER_RETURNS on:

CLEAR → V-04 → CLEAR → V-04

## Probes (ui_clk)

calib_done, p_valid, p_ready, p_data,
pack_loader.state, loader_busy, loader_wr_outstanding,
mig_ui32.st, ui_outstanding, ui_busy,
p_en, p_rdy, p_wren, p_wdf_rdy,
app_en, app_rdy, app_wdf_wren, app_wdf_rdy, app_rd_data_valid,
mux grant, pack_quiescent, debug_clear,
load_ack, load_reject, reason_code, active_generation.

Q4 extras (not UART overlay): `ack_d`, `st_valid_ui` (GOLD edge vs sticky level).

## Dest this run

BRAM path (`run_obs01.bat`): `mig_ui_bram`. Locked Q1 YES / Q2 YES / Q3 NO / Q4 NEW_COMMIT on that sequence only.

MIG0 path (`run_obs01_mig0.bat`): generated `mig0` + `ddr3_model` FAST calib. U32 qsc (USE_DEST_RDY=1). FAIL_XSIM_CLEAR1_BUSY. See `OBS01_MIG0_XSIM.md`.

PACKAGE-qsc A/B (`run_obs01_mig0_pkgqsc.bat`): same TB, `OBS01_QSC_USE_DEST_RDY=0` (force dest ready 1 into qsc only). TB-only. Does **not** patch `UART_R2/u32/pack_mig_bind.sv`. CLEAR1 ACK + txn1 GOLD1 P0–P15 + CLEAR2 ACK PASS_XSIM. GOLD2/Q4 open. No program.

## OBS01-MIG0 checkpoints (FIRST_DIVERGENCE)

After CLEAR2, BEGIN2 arm. Stop at first missing Pn. Do not guess past it.

| Pn | Must observe |
|----|----------------|
| P0 | BEGIN2 accepted after CLEAR2 |
| P1 | `mem_cmd_valid && mem_cmd_ready` write |
| P2 | write cmd MIG accept: `app_en && app_rdy` |
| P3 | write data MIG accept: `app_wdf_wren && app_wdf_rdy` |
| P4 | enter `S_RD` only after P2+P3 |
| P5 | readback cmd accepted |
| P6 | `app_rd_data_valid` |
| P7 | lane readback == `wdata_r` |
| P8 | `ui_outstanding` decreases |
| P9 | `mem_resp_valid` consumed |
| P10 | loader outstanding == 0 |
| P11 | sentinel readback OK |
| P12 | `S_COMMIT` |
| P13 | new `load_ack` rise |
| P14 | new GOLD/`st_valid_ui` rise |
| P15 | settle: loader idle + ui idle + out=0 + status drained |

CMD and WDF are counted separately (`cmd_acc` / `wdf_acc`). Flags: `partial_wr_cmd_only`, `partial_wr_wdf_only`. `debug_clear` must never occur while `cmd_acc XOR wdf_acc`.

Fail report is only:

```
LAST_EQUIVALENT_EVENT = Pn
FIRST_DIVERGENCE      = Pn+1
```

plus the listed dest/UI/loader/mux/clear snapshots. No generic “MIG lỗi”.

Q4 on MIG0 is the same BEGIN2-delta rule as BRAM (not `lack_fell`).

If MIG0 is also Q1 YES Q2 YES Q3 NO Q4 NEW_COMMIT and P0–P15 complete: `MIG0_PATH_THIS_SEQUENCE = CLEAN` still does **not** stamp PACK_ABI / MIG_PASS / BOARD. Next is repeated V-04 then Pack24, not UART overlay.
