# U33OBS DUT map — TAP four-AND → compare fields, not Pack24 (2026-09-20)

Not silicon. Not programmed. **PACK_ABI_24_24_PASS=NO**. READY_TO_PROGRAM=NO.

`generation_flipped=true` only from Pack-owner `S_COMMIT` four-AND:

`commit_event==1` AND `generation_after!=generation_before` AND `same_capture_epoch` AND `capture_valid==1`

Idle DUMP/CLEAR/epoch snapshot delta keeps the field **absent**. UART GOLD/MAG must not invent it. Valid COMMIT with `after==before` may be `false`; otherwise absent → `compare_ready=false`.

`u33obs_capture.py` sha256 `a33e82a2247012c8d89871c488653c29979946eb02b6c568624c6e9d6cc8bd9a`. Mapper `observe_from_tap_gen` sha256 `c95d562647c27b6262ee708ab5547cb2e742f9786cfa261cbe8b2b941d866874`.

This-watch `--selfcheck`: **PASS_SELFCHECK TAP four-AND decoder + DUT map**. GOLD flip=1; leftover/DUMP field absent (`None`); idle `0x47060002` must stay absent.

Synthetic DUT row `U33OBS_DUT_SHAPE_V04.jsonl` sha256 `63962fd6…` source=`SYNTHETIC_TAPDUMP_XSIM_NOT_SILICON` V-04 `generation_flipped=1`. Parent: `pack_abi24_gold.py --compare` **1/24 match, 23 missing** — contract shape only, **not** silicon, **not** PACK_ABI.

OBS bit `71b9198f…` still waits owner YES. This watch did not program.
