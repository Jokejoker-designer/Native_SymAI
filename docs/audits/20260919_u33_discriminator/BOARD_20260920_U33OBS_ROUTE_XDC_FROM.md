# U33OBS XDC `-from/-to` route — constraints MET, not TIMING_PASS (2026-09-20)

Not silicon. Not overlay U33/H. **TIMING_PASS=NO** (parent BUILD). READY_TO_PROGRAM=NO. PACK_ABI_24_24_PASS=NO. No bitstream.

`BUILD.txt` still:

```
STATUS=ROUTE_DONE
TAP_CDC_XDC_AT_IMPL=YES
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
READY_TO_PROGRAM=NO
```

Post-route `report_timing_summary` (this DCP):

```
WNS = +0.303 ns
TNS = 0
failing setup = 0 / 26465
WHS = +0.008 ns (hold MET, 0 failing)
All user specified timing constraints are met.
```

`impl.log`: **no** Constraints 18-540. XDC `u33obs_tap_cdc.xdc` sha256 `cd8b749429e75c6aa2d4615473e2edf930064219dcf02ef5bba7461eadbf2589` uses `-from` and `-to` on OBS 2FF (no Tcl `proc`).

Util (routed): LUT 10921 FF 9800 RAMB36=3 RAMB18=2 DSP=8.

`post_route.dcp` sha256 `168359bcf460cc776c874e2f9bab43961ddbc089d8b0a3cec34605a66348d012` (not pushed). Preserved: dump-SOF `d3e26d3d…`, gen WNS-fail `37953849…` as `post_route_gen_wnsfail.dcp`.

This is **PASS_IMPLEMENTED** post-route timing_summary MET. It is **not** `TIMING_PASS`, **not** a program grant, **not** Pack ABI. Do not program until unique `.bit` + owner YES.
