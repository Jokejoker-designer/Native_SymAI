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
| U33 five_v04 XSim **generated mig0** | PASS_XSIM five GOLD `$finish` 12207195 ns. V04_4 GOLD p0=BEGIN p1=MAGIC. **Not** board MAG. |

`xsim_u33f.log` sha256 `c4011529721270fe063043ae640911b7017d4b4ffdb4613924832fa8e3efc5d0`  
`xsim_u33m.log` sha256 `0778d0a9b939a498982758707d67cdca1e83db06610ccd27c4859b4514406256`

Board MAG is **not** “5th V-04 on BRAM dest” and **not** “5th V-04 on generated mig0”.

## Leftover inject (M4) 20260919T111705Z — PASS_XSIM BRAM

See `U33_LEFTOVER_MAG_XSIM.md`. Extra exact BEGIN after CLEAR IDLE is **sufficient** for `0200015a` (p0=BEGIN p1=BEGIN p2=MAGIC). Unlocked GOLD leftover is not. n=0-retry and zero-settle are not MAG on BRAM 1M. ACK-overlap BEGIN is mute n_p=0, not the board n=4 NAK. Source of leftover BEGIN on silicon **UNKNOWN**. No overlay. PROGRAM=NO.

mig0 5× **PASS_XSIM five GOLD** 20260919T125801Z (V04_4 GOLD p0=BEGIN p1=MAGIC). dest=mig0 5th MAG **CONTRADICTED**. Do not patch `pack_loader`. No UART/dest_accept overlay. No new identity until leftover BEGIN is observed without TB injection (UART/host 115200).

Phantom CDC after CLEAR (20260919T114421Z): **no** leftover BEGIN without inject. `a_idle=b_idle=1 hold=0 n_ph=0` then 5th GOLD. Leftover `00010001` GOLD. See `U33_PHANTOM_CDC_XSIM.md`.

115200 nosettle five GOLD + r2-retry GOLD (20260919T130222Z). First-byte MARK gap = mute not MAG. See `U33_BAUD115200_XSIM.md`. Board MAG still leftover exact BEGIN / FTDI host UNKNOWN.

Exclusive after replug 2026-09-19T20:08+07: program HIGH `ff399e0b…` PROGRAM_PASS=NO. Immediate V-04 NONE. Settle+30s: 3 GOLD then V04_2 MAG `0200015a`. See `U33_EXCLUSIVE_REPLUG_20260919.md`.

## Re-plug exclusive 20260919T131144Z — FAIL_BOARD MAG r2, host begin_n=1

See `D:/FPGA/arty_d/UART_R2/results/PACK24_U33_REPROG/U33_REPROG.md`. Frozen U33 reprogrammed after blank SRAM. T0 12s first V-04 n=0 (not MAG). T1 +30s: 4 GOLD then p5 r2 MAG `0200015a`. Every host TX begin_n=1. Python dup CONTRADICTED. Extra BEGIN source still UNKNOWN. No overlay. Not PACK_ABI_24_24_PASS.
