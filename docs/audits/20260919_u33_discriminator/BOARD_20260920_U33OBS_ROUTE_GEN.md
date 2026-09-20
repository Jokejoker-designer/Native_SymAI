# U33OBS gen+XDC route — ROUTE_DONE, timing not met (2026-09-20)

Not silicon. Not overlay U33/H. Not TIMING_PASS. READY_TO_PROGRAM=NO. PACK_ABI_24_24_PASS=NO. No bitstream.
dump-SOF DCP `d3e26d3d…` kept as `post_route_dumpsof.dcp`.

`BUILD.txt`:

```
STATUS=ROUTE_DONE
TAP_CDC_XDC_AT_IMPL=YES
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
READY_TO_PROGRAM=NO
```

Post-route:

```
WNS = -1.507 ns
TNS = -9.850 ns
failing setup = 20 / 26468
WHS = +0.028 ns (hold MET)
Timing constraints are not met.
```

vs dump-SOF route: WNS −1.516 / 7 fail. This identity is **worse TNS** (20 fail) because gen TAP added 100↔ui buses (`epoch_ui[*]` etc.) while OBS exceptions still did not apply.

`impl.log` **Constraints 18-540 ×7** (xdc:37–43 `set_max_delay -datapath_only` without `-from`) — same as synth. Requirement on failing paths remains **2.000 ns**.

Worst / class:

| Slack | Source → dest |
|------:|----------------|
| −1.507 | `u_obs_ctrl/ack_ui_reg_replica` → `a0_reg` |
| −1.507 | `init_calib_complete_reg_replica` → `cal0_reg` |
| −1.367 | `load_reject_reg` → `nak0_reg` |
| −0.521 | `epoch_r[13]` → `epoch_ui[13]` (17 paths `sys_clk_pin`→`clk_pll_i`) |

Util (routed): LUT 10929 FF 9802 RAMB36=3 RAMB18=2 DSP=8.

`post_route.dcp` sha256 `37953849033e1b72f61eccd2777c57695e1ffe9654510228248f9074e15329f8` (not pushed).

Do not program this checkpoint.
