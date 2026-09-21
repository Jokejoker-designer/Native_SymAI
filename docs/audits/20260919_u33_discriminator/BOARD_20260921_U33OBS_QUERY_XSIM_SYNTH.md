# Unique OBS query intercept — PASS_XSIM + SYNTH_DONE, not programmed (2026-09-21)

This watch did **not** program Arty, did **not** run impl/bitgen, and did **not** resume parent Vivado. Unique dir `build_u33obs_query/` does not overwrite `build_u33obs_rearm` / `_steer` / `_rgoff`. **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **READY_TO_PROGRAM=NO.** Overlay **NO**. Rearm SRAM `08c647ee…` file intact. C RTL untouched. B gold unmodified.

## Isolated R-04 QueryRecord on pack-only rearm (COMPLETE hop)

Same SHA `08c647ee…`. json sha256 `7add33957af871870091080c4ef120333772b48f6f3c695c43511c17e81ce30a`. Host `u33obs_iso_r04_query.py` sha256 `2387ef1066c2951a1284747c2298df8101737fb5f3cc1a548ed1e8c3a547f878`.

| Step | UART | TAP / note |
|---|---|---|
| leftover extra-BEGIN | MAG CLASS_A | this-pack flip **absent** (`U33OBS_REARM_HOPS_LEFTOVER.json` sha256 `24265863…`) |
| iso R-04 GOLD DUMP | GOLD `010000a5` | four-AND `ffffffff→0000002b` epoch 4 flip=1 |
| iso R-04 QueryRecord 8 words w0=`03014e51` | **NAK `02000f5a` RC_TRUNC 0x0F** | `uart_fe256_host.in_valid=0`; fields **not** invented |

Do **not** copy XSim/TSV R-04 `6/80` onto this hop. Parent note: QueryRecord interior `0x01` stolen as OP_BEGIN / truncated pack.

## Unique intercept TB (not silicon)

`tb_pack_obs_query.sv` sha256 `62384c33…`. `pack_obs_query.sv` sha256 `895cd23f…`. `xsim.log` sha256 `30901599…` **PACK_OBS_QUERY_XSIM_PASS** at **506 ns**:

```
R04_CRC_OK_NO_DEST  03000051
R04_DEST_PACK_CRC   03065051
G04_STALE           03065451
```

Not mig0. Not board. Token `03|qs|qr|51`. **PACK_ABI_24_24_PASS=NO.**

## SYNTH_DONE

`BUILD.txt` sha256 `d3d4600a…` STATUS=**SYNTH_DONE** TAP_CDC=1 U2UI=1. New bit **NOT_BUILT**. This watch did **not** impl. Parent impl log (if any) is **not** ROUTE_DONE / not published as timing.

Doc sibling: `BOARD_20260921_NOON_REARM_R04_QUERY_HOP.md`.
