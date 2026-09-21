# Unique OBS query identity — programmed SHA vs later file overwrite, iso R-04 UART QUERY not PACK_ABI (2026-09-21)

This watch did **not** program Arty and did **not** resume parent Vivado. Same unique dir `build_u33obs_query/` (does not overwrite rearm/steer/rgoff **dirs**). Parent **did** overwrite the **filename** in that dir after the hop. **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **TIMING_PASS=NO.** Overlay **NO**. C RTL untouched. B gold unmodified. Bit binaries not pushed.

Parent jsonl still 5069225 @ 07:43Z; disk COMPLETE after that.

## Two SHAs — do not mix

| Role | SHA256 | When | On Arty now? |
|---|---|---|---|
| **PROGRAMMED silicon** (this hop) | `99823c92122ac1e3bb16ddbc3885610a84b51cbb2e16416e94ccced91ac81099` | BIT_OK ~08:08, PROGRAM.txt 08:08:59 | **Yes until parent nạp again.** PROGRAM_PASS=NO |
| **Current file** (dir reuse) | `8fc14f25f2b9d936b7d412ce41b6d963991cc91137c20587e3ab5a96b5224df5` | `write_bitstream` 08:24 BIT_OK `PROGRAM=NO` | **No.** File ≠ SRAM. READY_TO_PROGRAM=NO |

≠ rearm `08c647ee…` ≠ steer `bd541f95…` ≠ rgoff `251eafa9…` ≠ OBS `71b9198f…` ≠ U33 `ff399e0b…` ≠ H `cf62102f…`.

First route: `WNS=0.365` `WHS=0.008`. Second route: `WNS=0.275` `WHS=0.008`. **TIMING_PASS=NO** both.

## PROGRAMMED (parent) — silicon `99823c92…`

`results/U33OBS_QUERY_OWNER_PROGRAM/PROGRAM.txt` sha256 `b42ac7abb68857b51fc1ccb63541d4319c860e790a2e7d90a16bee06bf3a098e`. STATUS=PROGRAMMED SHA MATCH JTAG `210319BE776EA`. **PROGRAM_PASS=NO.** This watch did not nạp.

## Isolated R-04 hop on **programmed** SHA `99823c92…` (08:09+07)

json sha256 `ae394b6b12d38440f3079739af17faa58874e159fb473e68c8a6f24e562bcf7a`.

| Step | UART | Class |
|---|---|---|
| leftover extra-BEGIN | n=0 | **MUTE_n0** (not MAG this hop) |
| CLEAR | `c1ea50a5` | CLEAR_ACK |
| iso R-04 (pack send) | `03065551` | **QUERY** `03\|qs=6\|qr=0x55\|51` — not GOLD `010000a5` |
| DUMP TAP | TAP1 | `commit_event=0` flip **absent** |
| QueryRecord 8 words w0=`03014e51` | `03000051` | **QUERY** `qs=0 qr=0`; `query_fields_invented=false`; `rc_trunc=false` |

Do **not** copy TSV R-04 `6/80` (would be qr=`0x80`). Board qr=`0x55` then `0x00`. Dest-complete **NOT_RUN**. **PACK_ABI_24_24_PASS=NO.**

This hop is **not** evidence for file SHA `8fc14f25…`.

## File overwrite 08:24+07 — BIT_OK `8fc14f25…` not programmed

`SHA256.txt` + bit file + `bit.log` line `uart_r2_u33obs_query_BIT_OK sha=8fc14f25… PROGRAM=NO`. `BUILD.txt` STATUS=BIT_OK WNS=0.275 READY_TO_PROGRAM=NO. Watch did **not** impl/bitgen/program.
