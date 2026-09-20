# U33OBS core — PASS_XSIM only (2026-09-20)

Not silicon. Not overlay U33. Not PACK_ABI_24_24_PASS. Not READY_TO_PROGRAM.

## Core

`pack_obs_lane.sv` 112-bit TraceEntry, depth 256, no wrap overwrite, CLEAR does not wipe.  
`pack_obs_gen.sv` owner four-AND `generation_flipped`.  
`pack_obs_ctrl.sv` epoch arm/freeze handshake (compiled; not the leftover TB).

`tb_pack_obs_core`: `PASS_XSIM pack_obs_core CLEAR-survive overflow gen-4AND` at 296 ns.  
Log `xsim_u33obs_core.log`.

## Leftover MAG on contract loader lane

Frozen U32 harness + U33 `pack_mig_bind` + `pack_obs_lane` on `p_fire`.  
`STATUS mute=0 got=0200015a p0=00800001 p1=00800001 n_ev=33 ov=0`  
`PASS_XSIM leftover pack_obs_lane CLASS_A` first_divergent=p1.  
Matches TAPCDC silicon CLASS_A and hop_log starter, now on frozen 112-bit ABI.

## Still missing for U33OBS identity

Nine contract lanes on a board top, DUMP `44554D50` freeze without NAK, dedicated TAP dump CDC, arm-before-CLEAR, COMMIT peek for gen on GOLD path, MUTE dummy-open XSim. Query UART still tied off.

Do not program this core alone.
