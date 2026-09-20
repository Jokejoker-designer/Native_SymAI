# U33OBS steer unique bit — BIT_OK hashes only, not programmed (2026-09-20)

This watch did **not** program Arty and did **not** run Pack24. **PACK_ABI_24_24_PASS=NO**. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **TIMING_PASS=NO**. Overlay **NO**. New out dir `build_u33obs_steer/` (does not overwrite `build_u33obs` / `build_u33obs_rgoff`). C RTL untouched. B gold unmodified.

`BUILD.txt` STATUS=**BIT_OK**. Bit sha256:

```
bd541f9579dfe0e2ca1b9dc4e220818fe460e293e6a7c42c08ecf8652fc9b46f
```

≠ rgoff `251eafa9…` ≠ old OBS `71b9198f…` ≠ U33 `ff399e0b…` ≠ H `cf62102f…`. DCP `29c974a1…`. `pack_begin=(f_data[7:0]==8'h01)`. A-03 steer XSim NAK9 already published (`9f09522`). Isolated A-03 NAK on this SHA is **not** evidenced.

Post-route WNS **+0.666** WHS **+0.012** (constraints MET). LUT 10942 FF 9832 RAMB36=3 RAMB18=2 DSP=8. Not `TIMING_PASS`. Bit/DCP binaries **not** pushed. Silicon still `251eafa9…`. No `97_program_*_steer.tcl` invoked.
