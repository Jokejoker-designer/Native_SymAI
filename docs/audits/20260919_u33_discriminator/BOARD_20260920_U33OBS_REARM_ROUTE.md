# Unique OBS CLEAR TAP re-arm — ROUTE_DONE WNS −1.373, not programmed (2026-09-20)

This watch did **not** program Arty, did **not** run Pack24, and did **not** resume parent Vivado. Unique dir `build_u33obs_rearm/`. **TIMING_PASS=NO**. **PROGRAM_PASS=NO**. **PACK_ABI_24_24_PASS=NO**. Overlay **NO**. Old OBS `71b9198f…`, rgoff `251eafa9…`, steer `bd541f95…` files intact. Silicon still `bd541f95…`. New bit **NOT_BUILT**. Post-route DCP sha256 `cd51e9e4…` **not** pushed. `D_U33OBS_REARM_ROUTE.json` sha256 `2ae2a43c23f822b529f9894a6c3e377a3f077e70b5b081ad0e2dd0d3c2f1cadf`.

`BUILD.txt` STATUS=**ROUTE_DONE** TAP_CDC_XDC_AT_IMPL=YES READY_TO_PROGRAM=NO.

Post-route WNS **-1.373** (1 failing endpoint) WHS **+0.010**. Constraints **not met**. LUT 10940 FF 9836 BRAM tile 4 DSP 8.

Failing setup: `u_uiclr/debug_clear_reg/C` (clk_pll_i) → `clr100_0_reg/D` (sys_clk_pin). Do not stamp TIMING_PASS. Do not bitstream-from-failing-WNS as legal.
