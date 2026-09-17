# H_OBS identity lock — H_OBS ≠ H

This folder is a **named observe identity**. It is not identity H.

## Forbidden inferences

| Allowed | Forbidden |
|---|---|
| Report `first_pack_word`, `bix_*`, `sh0..3`, `drop_seen` **on the H_OBS bit** | Copy that class onto identity H (`cf62102f…`) |
| Say “H_OBS reproduced H19 / H20 / OTHER **on this P&R**” | Say “identity H is H19” or “H is H20” or “H is explained” |
| Keep H20 as a **classifier** of pack-accepted word + drop | Treat H20 as a silicon root-cause or a fix |
| Program / UART **H_OBS** only | Overwrite identity H bit/DCP, freeze DCPs, AGENT_C RTL, pad, resync, product guards |

## Identity table

| Name | SHA256 prefix | What it is |
|---|---|---|
| **H** | `cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9` | VALIDATION_CLEAR product candidate. Internals not on the wire. Untouched. |
| **H-ILA-A** | `b037b355a7098c99b9a995554756122e09569230d3b8d02698c255e6a64f8cef` | Different P&R; dump latched CLEAR. Not H. Refused by H_OBS program. |
| **H_OBS** | this folder’s `BUILD.txt` / `PROGRAM.txt` SHA, **must not** equal H or H-ILA-A | UART-dump observe reproducer. BASIC-license path. |

`H_OBS_EQUALS_H = NO`  
`EXPLAINS_IDENTITY_H = NO`  
`CLASSIFIER_APPLIES_TO = H_OBS_ONLY`  
`H20_ROLE = CLASSIFIER_ONLY_NOT_SILICON_SOLUTION`

SRAM after `42_program_h_obs.tcl` holds **H_OBS**, not H. That does not convert H_OBS into H. The identity-H **file** stays at `D:/FPGA/arty_d/m4_mig_clear/`. This Tcl **must not** write that `PROGRAM.txt`.

## What H_OBS is for

Create a reproducer with **internal** observe:

- first **pack-accepted** word after CLEAR (`fifo_wr_valid && fifo_wr_ready`, never the CLEAR word `44524743`)
- `bix` at arm / first post-CLEAR byte / first pack accept
- first 4 UART shift bytes after arm
- `drop_seen` at 4th STOP while `w_valid && !w_ready`

Dump magic on the wire: LE `OBS1` = `32'h3153424F`. Auto-dump after pack status if `cap_fresh`.

## What H_OBS is not

- Not a proof about identity H
- Not `PROGRAM_PASS` / `BOARD_PASS` / `PACK_ABI_24_24_PASS` / `TIMING_PASS` / `MIG_PASS`
- Not a product UART protocol
- Not a reason to add pad, resync, or a new guard on H

If a later owner wants H itself classified, that needs a **new** named capture on that exact bit, not a reverse copy from here.
