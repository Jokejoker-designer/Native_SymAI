# U33OBS route — ROUTE_DONE, timing not met (2026-09-20)

Not silicon. Not overlay U33/H/U33TAP/TAPCDC. Not TIMING_PASS. READY_TO_PROGRAM=NO. PACK_ABI_24_24_PASS=NO. No bitstream on disk.

`build_u33obs/BUILD.txt`:

```
STATUS=ROUTE_DONE
TAP_CDC_XDC_AT_IMPL=YES
CLASS=uart_r2_u33obs_CANDIDATE
PROGRAM_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
READY_TO_PROGRAM=NO
```

Post-route `report_timing_summary`:

```
WNS = -1.516 ns
TNS = -6.011 ns
failing setup endpoints = 7 / 25630
WHS = +0.016 ns (hold MET, 0 failing)
WPWS = +0.187 ns
Timing constraints are not met.
```

Util (routed): LUT 10751 FF 9507 RAMB36=3 RAMB18=2 DSP=8.

`post_route.dcp` sha256 `d3e26d3d662e0d5efcd1b24092326977dcc1109fbe7010d2700bd40e67a32ead` (not pushed; 8.3 MiB). Unique dir `build_u33obs`. Frozen U33 `ff399e0b…` / H `cf62102f…` / TAP `d448544f…` / TAPCDC `eb99ac69…` / freeze DCPs not overwritten.

TAP XDC `u33obs_tap_cdc.xdc` was applied at impl. It only excepts `u_dump/u_cdc_tap`, `u_dump/u_cdc_u2ui`, and `busy_u*`. The seven failing paths are **other** 100 MHz ↔ `clk_pll_i` (ui, 12 ns) related-clock setups with a **2.000 ns** requirement:

| Slack | Source | Destination |
|------:|--------|-------------|
| -1.516 | `u_obs_ctrl/ack_ui_reg_replica` (ui) | `u_obs_ctrl/a0_reg` (100) |
| -1.509 | `init_calib_complete_reg_replica` (ui) | `cal0_reg` (100) |
| -1.491 | `u_ld/u_ld/load_reject_reg` (ui) | `nak0_reg` (100) |
| -0.547 | `u_obs_ctrl/freeze_r_reg` (100) | `u_dump/freeze_ui0_reg` (ui) |
| -0.508 | `u_obs_ctrl/arm_hold_reg` (100) | `u_obs_ctrl/u0_reg` (ui) |
| -0.231 | `u_obs_ctrl/reason_r_reg[1]` (100) | `u_dump/dump_w_reg[5][17]` (ui) |
| -0.209 | `u_obs_ctrl/reason_r_reg[0]` (100) | `u_dump/dump_w_reg[5][16]` (ui) |

Intra-clock `sys_clk_pin` setup is MET (WNS +0.436, `u_q` DSP path). TAP handshake CDC cells covered by XDC are not in this failing list.

Do not program this checkpoint. Bitstream not generated. Parent was hashing DCP after route; this publish is route only.
