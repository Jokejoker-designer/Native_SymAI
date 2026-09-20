# Pack ABI-24 observe DUT XSim — honest four-AND, not PACK_ABI (2026-09-20)

Not silicon. Not programmed. **PACK_ABI_24_24_PASS=NO**. dest = `mig_ui_bram` (not `mig0`, not board). B TB unmodified.

XSim `tb_pack_abi24_obs_dut` finish **23885 ns** banner `PACK_ABI24_OBS_DUT_XSIM_LOAD 24/24 dest-complete observe (simulation only; not PACK_ABI_24_24_PASS)`.

`DUT.jsonl` sha256 `035636d3a00036125fb4c87056d3977f0566600356b395dabcf186fa2c633e1a`. `generation_flipped` only if Pack `S_COMMIT` four-AND. 17 reject rows omit the field. B `--compare` prints **2/24 match, 22 fail** (field-fail count). Cases that fully match compared fields: V-01..V-04 and G-01. R-04/G-04 still query-blocked. Do not invent reject `flip=0`.

Also: campaign leftover MAG string now **absent (no COMMIT)** (`u33obs_capture.py` sha256 `f2e8a148…`). DUMP plan text still says `flip=false` while decoder DUMP field is absent.

OBS bit `71b9198f…` **READY_TO_PROGRAM=NO**. This watch did not program.
