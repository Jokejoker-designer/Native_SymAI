# Isolated PA24-A-03 on rg_off OBS — UART MUTE, TAP LOADER_EMPTY (2026-09-20)

This watch did **not** program and did **not** run Pack24. Same SRAM identity `251eafa9…` as isolated V-03 GOLD (no new `PROGRAM.txt` after 19:56+07). **PACK_ABI_24_24_PASS=NO**. **PROGRAM_PASS=NO**. Overlay **NO**.

`PACK24_ISO_RGOFF_PA24-A-03.json` sha256 `4a795670…`.

| Step | UART | TAP |
|---|---|---|
| CLEAR | ACK `c1ea50a5` | — |
| PA24-A-03 | **MUTE n=0** | (DUMP after) |
| PA24-A-03_dump | TAP1 9 words | identity **U33OBS_GEN** class **LOADER_EMPTY** `gen_stat=47000002` `uart1=00840001` load0=load1=`0` commit=0 same=0 cap=0 **flip absent** epoch=2 |

A-03 MUTE remains **OPEN** (UART n=0). TAP is not mute-n=0 on this DUMP: it shows empty loader, not CLASS_A leftover MAG. `generation_flipped` omitted (no COMMIT four-AND). Isolated V-03 GOLD on this bit does **not** close Pack 24/24.
