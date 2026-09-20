# Unique OBS steer `bd541f95…` isolated V-01 GOLD then TAP DUMP before CLEAR (2026-09-20)

This watch did **not** program Arty and did **not** run Pack24. Parent isolated PA24-V-01 then DUMP TAP immediately (LOAD_OK before CLEAR). Same SRAM `bd541f95…`. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **PACK_ABI_24_24_PASS=NO**. Overlay **NO**. Old OBS `71b9198f…` and rgoff `251eafa9…` files intact.

`PACK24_ISO_STEER_PA24-V-01.json` sha256 `64a8e6f2e983702e6e010fe5ed0bb7b7c0e9ea2ee88f0d9e7a9118d326c8f7d8`. `D_U33OBS_STEER_ISO_V01.json` sha256 `d6143a546d41c997d9c7c689747637cbc70654c5c3a6f44fbe7cdc7d9d700983`.

| Step | UART | TAP |
|---|---|---|
| CLEAR | ACK `c1ea50a5` | — |
| PA24-V-01 | **GOLD** `010000a5` n=4 | `tap=null` (UART does not invent `generation_flipped`) |
| DUMP before CLEAR | TAP1 9 words | four-AND **flip=1** `ffffffff→00000001` `gen_stat=470f0002` commit=1 same_epoch=1 capture_valid=1 U33OBS_GEN |

This hop is **PASS_BOARD CANDIDATE**: TAP four-AND observed on **this pack** LOAD_OK without a later NAK dump. Pack24 campaign still omitted the field (TAP freeze-once). Not Pack 24/24. Query R-04/G-04 still OPEN. Do not copy TSV flip=0 onto UART GOLD.
