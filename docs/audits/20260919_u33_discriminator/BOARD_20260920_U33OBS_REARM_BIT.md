# Unique OBS CLEAR TAP re-arm — BIT_OK hashes only (2026-09-20)

This watch did **not** program Arty and did **not** run Pack24. Unique dir `build_u33obs_rearm/` (does not overwrite `build_u33obs` / `build_u33obs_rgoff` / `build_u33obs_steer`). **PACK_ABI_24_24_PASS=NO**. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **TIMING_PASS=NO**. Overlay **NO**. C RTL untouched. B gold unmodified.

`BUILD.txt` STATUS=**BIT_OK** READY_TO_PROGRAM=NO. Bit sha256:

```
08c647ee850cb513f503448ea91c1461551450a145151f0fe02fb296f8137728
```

≠ steer `bd541f95…` ≠ rgoff `251eafa9…` ≠ old OBS `71b9198f…` ≠ U33 `ff399e0b…` ≠ H `cf62102f…`. Live files of those prior bits remain intact.

Second unique impl (after published fail DCP `cd51e9e4…` WNS −1.373) produced post-route DCP sha256 `16566cd8…`. Design Timing Summary WNS **+0.766** WHS **+0.008**, 0 failing endpoints, constraints **MET**. LUT 10938 FF 9836 RAMB36=3 RAMB18=2 DSP=8. Not `TIMING_PASS`. Bit/DCP binaries **not** pushed.

`96_bit_uart_r2_u33obs_rearm.tcl` refuses overwrite of old OBS / steer / rgoff paths. This watch did **not** run bitgen; parent did.
