# Isolated V-03 GOLD on unique rg_off OBS `251eafa9…` — not PACK_ABI (2026-09-20)

This watch did **not** program and did **not** run Pack24. Parent programmed `uart_r2_u33obs_rgoff_candidate.bit` then isolated first PA24-V-03.

Labtools **End of startup HIGH** on JTAG `210319BE776EA`, bit sha256 `251eafa9451cabd83089fc5cba0c6351f1955c27a70dd9a60e7e2321f4910764`. `PROGRAM.txt` STATUS=PROGRAMMED. `IR.STATUS=NA` `PROGRAM.DONE=NA`. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **PACK_ABI_24_24_PASS=NO**. Overlay **NO**. Old OBS file `71b9198f…` intact. C RTL untouched.

`PACK24_ISO_V03_FIRST_RGOFF.json` sha256 `9df1923c…`. `D_U33OBS_RGOFF_V03_GOLD.json` sha256 `9f34226e…`.

| Step | UART | TAP |
|---|---|---|
| open_drain | MUTE n=0 | — |
| CLEAR | ACK `c1ea50a5` | — |
| PA24-V-03 first | **GOLD** `010000a5` n=4 | (DUMP after) |
| v03_gold_dump | TAP1 | identity **U33OBS_GEN** CLASS_P1_OTHER p1=`3149414e` (NAI1) `gen_stat=470f0002` four-AND **flip=1** `ffffffff→00000003` epoch=2 |

V-03 R_SENTINEL on this identity is **CONTRADICTED** (old loader isolated V-03 was `0200085a`). Isolated GOLD is **PASS_BOARD CANDIDATE this hop only**, not Pack 24/24. TAP freeze-once after DUMP. A-03 MUTE, flip 0-vs-absent, R-04/G-04 query still OPEN. Pack24 on rgoff **NOT_RUN**.
