# U33OBS isolated leftover / GOLD DUMP / V-04×4 — not PACK_ABI (2026-09-20)

This watch did **not** program and did **not** run hops. Parent isolated modes after SRAM OBS.

**Leftover** (`U33OBS_HOPS_LEFTOVER.json` sha256 `6b50e87f…`) MAG `0200015a` + TAP 9-word **U33OBS_GEN** `CLASS_A_p1_BEGIN` `gen_stat=47000002` `generation_flipped` **absent**.

**GOLD DUMP** (`U33OBS_HOPS_GOLD.json` sha256 `3ecaae59…`) UART GOLD `010000a5` + TAP `gen_stat=470f0002` before=`ffffffff` after=`0000ffff` four-AND **flip=1** identity U33OBS_GEN. hop `CLASS_P1_OTHER p1=3149414e`. DUT row `source=BOARD_U33OBS_GOLD_DUMP_NOT_PACK24`. **PACK_ABI_24_24_PASS=NO**.

**V-04×4** (`U33OBS_HOPS_V04x4.json` sha256 `dfd3b2fe…`) 4/4 GOLD, mag=0 mute=0. Not 24 ABI cases. **PACK_ABI_24_24_PASS=NO**.

Combined first hops still TAP MUTE after hop0. Isolated GOLD DUMP captured four-AND. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**.
