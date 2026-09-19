# U33 MAG class — 0200015a is pack_loader R_BAD_MAGIC, not GOLD scramble

PACK_ABI_24_24_PASS = NO. PROGRAM_PASS = NO. U33 frozen FAIL_BOARD.

## Token (FACT)

UART status packing in `u33/arty_a7_r2_top_m4_mig_candidate.sv`:

- GOLD = `{8'h01, 8'h00, reason, 8'hA5}` → reason 0 → `010000a5`
- NAK  = `{8'h02, 8'h00, reason, 8'h5A}` → reason `R_BAD_MAGIC=8'h01` → `0200015a`

Board p5 V-04 r3 n=4 `5a010002` / word `0200015a` is **load_reject R_BAD_MAGIC**.
`pack_loader` sets that iff after OP_BEGIN, `hw0 != 32'h3149414E` (MAGIC_NAI1).

This is the same encoding as historical GOAL_M1 BEGIN-NAK bytes. Post-campaign no COM12 holder. Collision **WEAKENED**, not closed during the 50s window.

## Board vs BRAM XSim

| Cell | Result |
|---|---|
| U32 exclusive CLEAR1 | BUSY `c1ea50b5` |
| U33 exclusive CLEAR1 | ACK `c1ea50a5` |
| U33 Phase4 + p5 r0–r2 | GOLD `010000a5` (4 GOLD) |
| U33 p5 r3 = **5th V-04** | MAG `0200015a` |
| U33 two_v04 XSim (4 GOLD, BRAM dest) | PASS_XSIM `9666815 ns` |
| U33 five_v04 XSim (5th = board MAG cell, BRAM dest) | PASS_XSIM five GOLD `12083475 ns` p0=`00800001` p1=`3149414e` rsn=00 |

`xsim_u33f.log` sha256 `c4011529721270fe063043ae640911b7017d4b4ffdb4613924832fa8e3efc5d0`

Board MAG is **not** “5th V-04 on BRAM dest”. Next cell: generated mig0 + U33 qsc, same 5× CLEAR-V-04 (not run this log). Do not patch `pack_loader`. No UART/dest_accept overlay. No new identity until that mig0 cell.
