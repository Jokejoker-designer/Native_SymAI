# Unique OBS query identity `8fc14f25…` PROGRAMMED — iso R-04 GOLD then QUERY `03065051` (2026-09-21)

This watch did **not** program Arty and did **not** resume parent Vivado. Unique dir `build_u33obs_query/` (does not overwrite rearm/steer/rgoff **dirs**). Parent **did** program the later same-dir bitstream. **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **TIMING_PASS=NO.** Overlay **NO**. C RTL untouched. B gold unmodified. Bit binaries not pushed.

GitHub keeps the 08:09 hop on silicon `99823c92…` as `U33OBS_QUERY_ISO_R04.json` sha256 `ae394b6b…`. This file is **not** that hop.

## Two SHAs — do not mix

| Role | SHA256 | When | On Arty now? |
|---|---|---|---|
| First query hop (keep) | `99823c92122ac1e3bb16ddbc3885610a84b51cbb2e16416e94ccced91ac81099` | PROGRAM.txt 08:08; hop UART `03065551`/`03000051` | **No.** Superseded SRAM. Evidence: `PROGRAM_99823C92.txt` + `U33OBS_QUERY_ISO_R04.json` |
| **PROGRAMMED silicon** (this hop) | `8fc14f25f2b9d936b7d412ce41b6d963991cc91137c20587e3ab5a96b5224df5` | Parent nạp after 08:24 file BIT_OK; PROGRAM.txt now this SHA | **Yes until parent nạp again.** PROGRAM_PASS=NO |

≠ rearm `08c647ee…` ≠ steer `bd541f95…` ≠ rgoff `251eafa9…` ≠ OBS `71b9198f…` ≠ U33 `ff399e0b…` ≠ H `cf62102f…`.

Route WNS **+0.275** WHS **+0.008**. **TIMING_PASS=NO.**

## PROGRAMMED (parent) — silicon `8fc14f25…`

`results/U33OBS_QUERY_OWNER_PROGRAM/PROGRAM.txt` sha256 `1ab55cbdfb957d7e5b1210916d23a6f2713dece9fcad053160c60669e1745b26`. STATUS=PROGRAMMED SHA MATCH JTAG `210319BE776EA`. Labtools **End of startup HIGH** in `program.log` sha256 `34f8d593b32c226813924a00408195fa504fb1f7e4955e864eabe074bb5f204a`. Line `uart_r2_u33obs_query_PROGRAM_OK … PROGRAM_PASS=NO`. **PROGRAM_PASS=NO.** This watch did not nạp.

Kept sibling: `PROGRAM_99823C92.txt` sha256 `b42ac7abb68857b51fc1ccb63541d4319c860e790a2e7d90a16bee06bf3a098e`.

## Isolated R-04 hop on **programmed** SHA `8fc14f25…` (08:26+07)

json `U33OBS_QUERY_ISO_R04_8FC14F25.json` sha256 `9da6c2d87d398e9b551f16be5466aecf2f04c28162c0223b69d5121c66b5d8a3`.

| Step | UART | Class |
|---|---|---|
| leftover extra-BEGIN | n=0 | **MUTE_n0** (not MAG this hop) |
| CLEAR | `c1ea50a5` | CLEAR_ACK |
| iso R-04 (pack send) | `010000a5` | **GOLD** |
| DUMP TAP | TAP1 | four-AND `ffffffff→0000002b` epoch 2 `generation_flipped=1` |
| QueryRecord 8 words w0=`03014e51` | `03065051` | **QUERY** `03\|qs=6\|qr=0x50\|51`; parsed 6/80; `query_fields_invented=false`; `rc_trunc=false` |

Do **not** invent this token onto the `99823c92…` hop (that hop was `03065551` then `03000051`). Dest hex UART **NOT_RUN**. **PACK_ABI_24_24_PASS=NO.**

## Isolated G-04 CLEAR-between (not TSV 6/84)

json `U33OBS_QUERY_ISO_G04.json` sha256 `00623302edb03847dfaaa4556f036d73cd8d14117cd07db5795b85ee67c614a7`. NAK `0200055a` then QUERY `03000051` (qs=0 qr=0). Not TSV `6/84`.

## Isolated G-04 R1 order (fail_B then query)

json `U33OBS_QUERY_ISO_G04_R1_ORDER.json` sha256 `3a6e1cfdc025620508dbe15b11d24e84fc1a1db69c05799f42573e6a12736366`. QUERY `03065451` parsed 6/84. `query_fields_invented=false`. **PACK_ABI_24_24_PASS=NO.**

## Leftover MAG vs this-pack COMMIT

`U33OBS_QUERY_HOPS_LEFTOVER.json` sha256 `40b8528eb92fc4bf6be8f12784f580e3acfb38b1621bc89f849ffea729e6223f`. MAG CLASS_A `p1=BEGIN`; leftover `generation_flipped` **null** (not this-pack four-AND). Do not treat leftover MAG as directory/T1.

Watch did **not** impl/bitgen/program. Freeze DCPs untouched.
