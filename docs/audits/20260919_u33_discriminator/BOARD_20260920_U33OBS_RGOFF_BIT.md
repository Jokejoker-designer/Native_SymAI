# U33OBS rg_off unique bit — BIT_OK hashes only, not programmed (2026-09-20)

This watch did **not** program Arty and did **not** run Pack24. **PACK_ABI_24_24_PASS=NO**. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **TIMING_PASS=NO**. Overlay **NO**. C RTL untouched. B gold unmodified. Old OBS `71b9198f…` **file intact** in `build_u33obs/`.

New out dir `build_u33obs_rgoff/` (does not overwrite `build_u33obs`). `pack_loader.sv` sha256 `bb59f068…` (`rg_off` sentinel). `bit.log` prints `uart_r2_u33obs_rgoff_BIT_OK` at 19:54:09 +07. Parent `BUILD.txt` still `STATUS=ROUTE_DONE` (bit Tcl does not rewrite it).

```
BIT_SHA256=251eafa9451cabd83089fc5cba0c6351f1955c27a70dd9a60e7e2321f4910764
DCP_SHA256=c6d75f58ffdf15d9d335bc7e34b4122e3af366ad58ca45ea98b4c6b3b22dd5c5
```

≠ old OBS `71b9198f…` ≠ U33 `ff399e0b…` ≠ TAPCDC `eb99ac69…` ≠ TAP `d448544f…` ≠ H `cf62102f…`.

Post-route signoff WNS **+0.834** WHS **+0.022** (constraints MET). LUT 10950 FF 9832 RAMB36=3 RAMB18=2 DSP=8. That is **not** `TIMING_PASS`.

Bit (~1.9 MiB) and DCP (~8 MiB) are **not** pushed. Public evidence: hashes + `BUILD.txt` + `bit.log` + `SHA256.txt`. Silicon SRAM is still old OBS until an owner-authorized program of this SHA. `97_program_uart_r2_u33obs_rgoff.tcl` is gated `OWNER_AUTHORIZED` and bans `71b9198f`; this watch did not invoke it. Isolated V-03 GOLD on this SHA is **not** evidenced.
