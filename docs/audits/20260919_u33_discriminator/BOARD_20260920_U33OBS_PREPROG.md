# U33OBS pre-program — decoder PASS_SELFCHECK, Tcl gated, not programmed (2026-09-20)

Not silicon. Not overlay. **PROGRAM_PASS=NO**. **READY_TO_PROGRAM=NO**. **OWNER_YES_REQUIRED=YES**. PACK_ABI_24_24_PASS=NO.

BIT_OK `71b9198f…` already published. This tick adds:

1. `u33obs_capture.py` sha256 `6587bf62ed3dd998c37ac2be1bbc194a59f1321df4618af759e3d86f53048112` — TAP four-AND decoder. **PASS_SELFCHECK** (re-run this watch): GOLD `commit=1 same_epoch=1 capture_valid=1 before=ffffffff after=0000ffff`; leftover CLASS_A flip=false; DUMP empty flip=false; 6-word TAPCDC is `NOT_U33OBS_GEN`.
2. `97_program_uart_r2_u33obs.tcl` sha256 `ae7e82b5…` — aborts unless tclarg `OWNER_AUTHORIZED`; bans H/U33/TAPCDC/TAP/M4MIG SHA; unique `build_u33obs` bit only.
3. `run_program_u33obs.bat` sha256 `411c9941…` — exit 4 if first arg is not `OWNER_AUTHORIZED`.

This watch **did not** invoke the bat or open JTAG. Do not Pack24 on TAPCDC SRAM. Campaign plan is a script, not a board result.
