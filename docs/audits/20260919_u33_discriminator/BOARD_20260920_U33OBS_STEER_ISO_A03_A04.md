# Unique OBS steer `bd541f95…` programmed — isolated A-03 NAK9 / A-04 NAK15 (2026-09-20)

This watch did **not** program Arty and did **not** run Pack24. Parent used `97_program_uart_r2_u33obs_steer.tcl` then `--iso-steer` PA24-A-03 then PA24-A-04.

Labtools **End of startup HIGH** on JTAG `210319BE776EA`, bit sha256 `bd541f9579dfe0e2ca1b9dc4e220818fe460e293e6a7c42c08ecf8652fc9b46f`. `PROGRAM.txt` STATUS=PROGRAMMED SHA MATCH. `IR.STATUS=NA` `PROGRAM.DONE=NA`. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **PACK_ABI_24_24_PASS=NO**. **TIMING_PASS=NO**. Overlay **NO**. Old OBS file `71b9198f…` and rgoff `251eafa9…` intact. C RTL untouched. B gold unmodified.

`pack_begin=(f_data[7:0]==8'h01)`. Silicon is now this unique steer SHA (not rgoff).

| Artifact | SHA256 |
|---|---|
| `PROGRAM.txt` | `bb28cb7fe6e5d5a3133cb30120cedeaf59ef275be81932fd2ded61e95fb21a43` |
| `program.log` | `aa1e0157aa3cda939c0c06cbbcd28dfaee6f45a0919338b77b1147aa8a67c76c` |
| `PACK24_ISO_STEER_PA24-A-03.json` | `d396cb6142970f8f05fd50e118fe6e90504c70e2ab38053faf040b334476cc42` |
| `PACK24_ISO_STEER_PA24-A-04.json` | `ce2ba8b60f7c1f9275a698051fb19a0b559ad4c50782f0feac28243a93b43491` |
| `D_U33OBS_STEER_A03_A04.json` | `caeee0027cfc3c58bcb331a5b591c2853dc45b5877b19b6adea37eecbb12bdcc` |
| `97_program_uart_r2_u33obs_steer.tcl` | `d161c27430abd6692866166c8cb81fe976bd201f3652ee36f95c1b016da465d4` |

| Step | UART | TAP |
|---|---|---|
| A-03 CLEAR | ACK `c1ea50a5` | — |
| PA24-A-03 | **`0200095a`** (LOAD_REJECT reason 9) n=40 / 10 words | TAP1 **U33OBS_GEN** `uart1=00840001` `load0=00840001` `load1=3149414e` (NAI1) `gen_stat=47000002` commit=0 **generation_flipped absent** (four-AND) CLASS_P0_NOT_BEGIN p0=`00840001` |
| A-04 CLEAR | ACK `c1ea50a5` | — |
| PA24-A-04 | **`02000f5a`** (LOAD_REJECT reason 15) n=4 | (DUMP after) |
| A-04 DUMP | **MUTE n=0** | **NO_TAP1** freeze-once after A-03 NAK DUMP |

A-03 UART MUTE on rgoff `251eafa9…` is **CONTRADICTED_THIS_IDENTITY**. Isolated A-03/A-04 UART hops are **PASS_BOARD CANDIDATE this hop only**, not Pack 24/24. Flip 0-vs-absent, leftover MAG, R-04/G-04 query, Pack24 on steer **NOT_RUN**. Bit/DCP binaries **not** pushed.
