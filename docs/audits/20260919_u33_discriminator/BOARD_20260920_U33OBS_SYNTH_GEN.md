# U33OBS gen+XDC synth — SYNTH_DONE only (2026-09-20)

Not route. Not silicon. Not overlay U33/H. Not TIMING_PASS. READY_TO_PROGRAM=NO. PACK_ABI_24_24_PASS=NO.
dump-SOF DCP `d3e26d3d…` kept as `post_route_dumpsof.dcp` (not overwritten as product).

`build_u33obs/BUILD.txt`:

```
STATUS=SYNTH_DONE
TAP_CDC_CELLS=1
U2UI_CDC_CELLS=1
```

Post-synth unplaced: WNS **−1.243** TNS −3.673 (3 setup). WHS **−1.631** (unplaced MIG PHY hold). Intra 100 MHz setup MET (+1.607).

Three remaining setup fails still use a **2.000 ns** related-clock requirement:

| Slack | Source → dest |
|------:|----------------|
| −1.243 | `init_calib_complete_reg` → `cal0_reg` |
| −1.223 | `load_reject_reg` → `nak0_reg` |
| −1.206 | `u_obs_ctrl/ack_ui_reg` → `a0_reg` |

XDC `u33obs_tap_cdc.xdc` parsed. TAP/U2UI exceptions with `-from` applied. OBS 2FF lines 37–43 are `set_max_delay -datapath_only -to` **without `-from`**. Vivado **CRITICAL WARNING Constraints 18-540** (7×): those exceptions were **not applied**. That is why cal0/nak0/a0 still time as 2 ns related clocks at synth.

Util (synthesized): LUT 11938 FF 10901. `post_synth.dcp` sha256 `88f3310e78ed0eb2c5525f0694cff2d089eb5897da77667944f35bdfc56abbb3`.

Impl **IN_PROGRESS** at publish. Do not program this checkpoint.
