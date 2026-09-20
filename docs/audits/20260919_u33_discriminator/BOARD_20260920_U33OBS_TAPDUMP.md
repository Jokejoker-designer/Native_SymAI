# U33OBS TAP dump CDC — PASS_XSIM only (2026-09-20)

Not silicon. Not overlay U33/U33TAP. Not PACK_ABI_24_24_PASS. READY_TO_PROGRAM=NO.

Dedicated TAP CDC (`pack_obs_dump.sv`) streams after freeze:

| Cell | TAP1 | u0 | u1 | l0 | l1 |
|---|---|---|---|---|---|
| leftover MAG | `31504154` | CLEAR | BEGIN | BEGIN | BEGIN |
| DUMP-without-NAK | `31504154` | CLEAR | `44554D50` | 0 | 0 |
| GOLD V-04 | none | — | — | — | — |

Log sha256 `80746a77d96e4705d4b63c89d561d31fea06112e7683a6bad46eac2bd5ea3b58` at 6125375 ns.

Product Pack TX CDC is not the dump path. MUTE silicon still needs a board top + TAP XDC. Do not program this harness.
