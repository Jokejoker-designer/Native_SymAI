# U33OBS campaign leftover MAG: field absent, not false (2026-09-20)

Not silicon. Not programmed. **PACK_ABI_24_24_PASS=NO**.

Campaign step `2_leftover_mag` now expects `generation_flipped absent (no COMMIT)` instead of `=false`. Matches TAP four-AND: leftover MAG has no Pack `S_COMMIT`. `u33obs_capture.py` sha256 `f2e8a148175c88e878737bba011b329beba87ea4fb2285a67ba323bd70043637`. Plan sha256 `7453580e0cee58de2c8edbcd713152262b644b2626c9ec58d1462190f15b7181`.

Step `3_dump_mute` text still says `flip=false`; decoder selfcheck still leaves DUMP field **absent**. That string is not a silicon result.

OBS bit `71b9198f…` still **READY_TO_PROGRAM=NO**. This watch did not program.
