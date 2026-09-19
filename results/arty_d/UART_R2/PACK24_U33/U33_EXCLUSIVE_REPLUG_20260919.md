# U33 exclusive after replug — 2026-09-19 20:08–20:11 +07

PACK_ABI_24_24_PASS = NO. PROGRAM_PASS = NO. BOARD_PASS = NO. No overlay.

Parent reserved Arty; SRAM lost on unplug. Side chat did not JTAG. Evidence = parent terminals + `build_u33/PROGRAM.txt` mtime 20:08:46.

## Program (FACT)

```
bit     D:/FPGA/arty_d/UART_R2/build_u33/uart_r2_u33_candidate.bit
sha256  ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350
JTAG    210319BE776EA  xc7a100t_0
Labtools End of startup HIGH
uart_r2_u33_PROGRAM_OK  20:08:46 +07
PROGRAM_PASS = NO
```

Device was `DONE=0` before this program (unprogrammed after power loss). Frozen U33 identity, not H.

## Campaign A — immediate nwp4p5 after program

Terminal `547668` `reprogram_nwp4p5.py` exit 1, 68 s.

```
CLEAR1 ACK n=4  a550eac1
TX_V04_0 nwords=52 begin_n=1 w0=00800001 w1=3149414e
V04 NONE n=0
```

Immediate post-program first V-04 mute. Not MAG this hop.

## Campaign B — extra 30 s settle then nwp4p5 (no second program)

Terminal `547669` `u33_campaign.py settle` + sleep 30 + `nwp4p5` exit 1, 53 s.

```
CLEAR1 ACK n=4  a550eac1
V04 GOLD n=4  a5000001   PHASE4_OK
CLEAR 0 ACK / V04 0 GOLD n=4
CLEAR 1 NONE n=0 ; RETRY NONE ; REOPEN ACK
V04 1 GOLD n=4
CLEAR 2 ACK / V04 2 OTHER_0200015a n=4 raw 5a010002
```

MAG `0200015a` = load_reject `R_BAD_MAGIC` packing (same token as prior U33 p5 r3). Three GOLD then MAG, with a CLEAR n=0 in the middle. Not 24/24. Leftover BEGIN / host still UNKNOWN.

## Closed / not closed

| Claim | Verdict |
|---|---|
| Replugged SRAM empty until this program | FACT (DONE=0 then HIGH) |
| Immediate V-04 GOLD | CONTRADICTED this hop (NONE n=0) |
| Extra settle makes Pack 24/24 | CONTRADICTED (MAG at V04 2) |
| MAG gone after dest=mig0 five GOLD XSim | CONTRADICTED on board |
| PACK_ABI_24_24_PASS | NO |

## Artifacts

| File | SHA256 |
|---|---|
| `term_547668_reprogram_nwp4p5.txt` | `e380fb47f4c43955ad978da80dc417b54525ac65c0402afde6bae1e6d10a79e3` |
| `term_547669_settle30_nwp4p5.txt` | `98403b2a83b2241144f1b1032fcf86b327fd78bda6363138f16e36e300a1bbd2` |
| `PROGRAM_20260919T130846.txt` | `81ae5dd569cfcd3f68aaa50f42cbf2318ff9a13e4f217eaaa3f4617bc02a9505` |
