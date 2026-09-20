# Unique OBS steer `bd541f95…` Pack24 run1 B `--compare` — 28 field fails, not PACK_ABI (2026-09-20)

This watch did **not** program, did **not** run Pack24, and did **not** invoke B `--compare`. Parent compared `PACK24_RUN1_STEER_DUT.jsonl`. **PACK_ABI_24_24_PASS=NO**. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. Overlay **NO**. Old OBS `71b9198f…` and rgoff `251eafa9…` files intact. B gold/TB unmodified.

| Artifact | SHA256 |
|---|---|
| `COMPARE_PACK24_RUN1_STEER.txt` | `b63a8c6dc35f40b43ca067590e5ca539d4b03577f380536ee1901030bc17b566` |
| `D_U33OBS_STEER_PACK24_RUN1.json` | `e0a153e2b9c5d8b47b9f860122a63c6a1f0dd8b39c4cfc4696587f42da032641` |
| `PACK24_RUN1_STEER.json` | `44f2fd63f9d23a6675301a0ef590a90a79f33fcb9ef90d141a09df3c026eb4ef` |
| `PACK24_RUN1_STEER_DUT.jsonl` | `1f2867e2f70b8e5e379809f793d02a7c05b485fbbfba84887b2ad795c06e87ff` |

UART outcome/reason/ack/reject: **no FAIL lines** (24 tokens match gold TSV). `generation_flipped`: **24 FAIL** (field absent; owner four-AND; UART does not invent). query_status/query_reason: FAIL **PA24-R-04** expected 6/80; FAIL **PA24-G-04** expected 6/84. B nfail counts **fields** not cases: printed **compare -4/24**, **28 field fails**.

S-01 TAP dump-on-NAK after CLEAR was prior V-04 `S_COMMIT` four-AND (`gen_stat 470f0002` `ffffffff→0000ffff`). Omitted from DUT.jsonl (`tap_not_this_pack`). Attaching that TAP as S-01 `generation_flipped=true` is **CONTRADICTED**. Do not copy TSV flip=0 onto rejects. Do not stamp PACK_ABI.
