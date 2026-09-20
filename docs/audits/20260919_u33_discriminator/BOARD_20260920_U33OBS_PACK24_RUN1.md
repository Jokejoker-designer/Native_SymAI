# U33OBS Pack24 run1 on OBS SRAM — not PACK_ABI (2026-09-20)

This watch did **not** run Pack24. Parent `u33obs_pack24.py` `PACK24_RUN1_DONE`. Identity `71b9198f…`. **PACK_ABI_24_24_PASS=NO**. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. `fresh=false`.

`PACK24_RUN1.json` sha256 `f8379872…`. `PACK24_RUN1_DUT.jsonl` sha256 `560eb157…`. DUT rows omit `generation_flipped` (no TAP four-AND in these UART responses).

LOAD_OK UART GOLD: V-01, V-02, V-04, R-04, G-01. V-03 `0200085a` LOAD_REJECT reason 8. A-02 MAG `0200015a`. A-03/A-04 **MUTE n=0** (`UART_NOT_EXACT4`). Other cases NAK with ABI reasons. `compare_ready=false` throughout mapped rows.

Do not stamp Pack 24/24 from 5 GOLD tokens. MUTE vs MAG still OPEN.
