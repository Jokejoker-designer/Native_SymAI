# Unique OBS CLEAR TAP re-arm — PASS_XSIM + SYNTH_DONE unplaced, not programmed (2026-09-20)

This watch did **not** program Arty, did **not** run Pack24, and did **not** resume parent Vivado/xelab. Unique out dir `build_u33obs_rearm/` (does not overwrite `build_u33obs` / `_steer` / `_rgoff`). **PROGRAM_PASS=NO**. **PACK_ABI_24_24_PASS=NO**. **TIMING_PASS=NO**. Overlay **NO**. Old OBS `71b9198f…`, rgoff `251eafa9…`, steer `bd541f95…` files intact. Silicon still steer `bd541f95…`. C RTL untouched.

`BUILD.txt` STATUS=**SYNTH_DONE**. TAP_CDC_CELLS=1 U2UI_CDC_CELLS=1. Post-synth unplaced WNS **-1.227** WHS **-1.631** (constraints not met at synth; expected). LUT 11951 FF 10937 BRAM tile 5 DSP 8. DCP sha256 `e53a77e5…` **not** pushed (~27 MB). New bit **NOT_BUILT**. Impl started after synth; not ROUTE_DONE.

`D_U33OBS_REARM_SYNTH.json` sha256 `8f66e4d3955d254ecef6af7c35306570730632f4134ed87c79ba2de2fe7a5eaa`. TAPDUMP XSim `u33obs_tapdump.log` sha256 `031e3d19…`: **PASS_XSIM** leftover CLASS_A + DUMP-without-NAK + GOLD four-AND + **CLEAR re-arm GOLD2 four-AND**. Not programmed.
