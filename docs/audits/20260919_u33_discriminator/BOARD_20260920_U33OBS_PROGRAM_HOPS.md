# U33OBS parent program + 4-step hops — not PROGRAM_PASS / not PACK_ABI (2026-09-20)

This watch did **not** program and did **not** run hops. Parent invoked `97_program_uart_r2_u33obs.tcl` with `OWNER_AUTHORIZED` then `u33obs_hops.py --run`.

Labtools **End of startup HIGH** on JTAG `210319BE776EA`, bit sha256 `71b9198f512972bae75af04e406d26c17d7940ecadd324e5b5ffecaedcbf6762`. `PROGRAM.txt` STATUS=PROGRAMMED. `IR.STATUS=NA` `PROGRAM.DONE=NA`. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **PACK_ABI_24_24_PASS=NO**. No Pack24.

Hops json sha256 `2c07f9116d6242f5b6c655a0a4bef3f8e4fe1988c98745a8cb1873d6dda67972` stop=`HOPS_DONE_NO_PACK24`:

| Step | UART | TAP |
|---|---|---|
| 0_sram_gate DUMP | 9 words TAP1 | identity **U33OBS_GEN** LOADER_EMPTY `gen_stat=47000002` flip **absent** |
| 1 dummy-open V-04 | **GOLD** `010000a5` | TAP after V-04 **MUTE n=0** |
| 2 leftover BEGIN+V-04 | **MAG** `0200015a` | TAP **MUTE n=0** leftover_flip absent |
| 3 DUMP | MUTE n=0 | no TAP1 |
| 4 V-04 | **GOLD** `010000a5` | TAP MUTE n=0 so gold four-AND **not captured** |

OBS identity on SRAM (not TAPCDC leftover). Dummy-open on this identity is GOLD, not U33 host-old MUTE. Leftover MAG still MAG. TAP DUMP after hop 0 is mute — hop TAP four-AND on silicon GOLD is **not** evidenced. Frozen H/U33/TAPCDC/FE256 DCP not overwritten.
