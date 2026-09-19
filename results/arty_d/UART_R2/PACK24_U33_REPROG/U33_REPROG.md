# U33 exclusive re-plug 20260919T131144Z

PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. BOARD_PASS=NOT_EVIDENCED.
Owner: board plugged/reserved for AGENT_D. Frozen U33 bit only. No overlay. No U34.

## Program (FACT)

- Bit `D:/FPGA/arty_d/UART_R2/build_u33/uart_r2_u33_candidate.bit` sha256 `ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350`
- JTAG `210319BE776EA` device `xc7a100t_0`
- Pre-program: DONE=0 (SRAM blank after unplug)
- End of startup HIGH 2026-09-19 20:08:46 +07
- `PROGRAM.txt` sha256 `81ae5dd569cfcd3f68aaa50f42cbf2318ff9a13e4f217eaaa3f4617bc02a9505` STATUS=PROGRAMMED PROGRAM_PASS=NO
- Tcl killed hw_server after program. No hw_server left before retry campaign.

## T0 first nwp4p5 (12s settle after program)

CLEAR1 ACK `c1ea50a5` n=4 dt=0.063s then V04_0 NONE n=0 dt=12.03s.
Host TX: nwords=52 begin_n=1 w0=`00800001` w1=`3149414e`.
JSON `BOARD_BASELINE_T0_V04_N0.json` sha256 `eca5b720911d78fa8285fd66baeb8359459e2b9f2c4da3b2fdfc6f63a1449ffd`.
Class: mute after ACK, not MAG. Do not call this leftover-BEGIN.

## T1 nwp4p5 after extra 30s settle (no reprogram)

CLEAR1 ACK → Phase4 GOLD `010000a5` n=4 dt=0.093s.
p5 r0 GOLD.
p5 r1 CLEAR n=0, RETRY n=0, REOPEN, CLEAR ACK, GOLD.
p5 r2 CLEAR ACK, V04 MAG `0200015a` n=4 dt=0.077s raw `5a010002`.
Every V-04 TX log: nwords=52 begin_n=1 w0=`00800001` w1=`3149414e`.
JSON `CLEAR_V04_24.json` sha256 `4d2317ef20913f0d35be2889dfa3df00e92e77af4d368a679db0dec9a9120b6f`.
Campaign `u33_campaign.py` sha256 `e9cec162b107f8df38206bc2b99e3b7cb0de2c29290a971d4940bb4a6e783927` OUT=`PACK24_U33_REPROG` (frozen `PACK24_U33/CLEAR_V04_24.json` not overwritten).

LAST_EQUIVALENT=p5 V-04 r1 GOLD.
FIRST_DIVERGENCE=p5 V-04 r2 MAG.

Prior exclusive MAG was p5 r3 (5th V-04). This re-plug MAG is p5 r2 (Phase4 + r0 + r1 GOLD = 4 GOLD then MAG). Token identical.

## Classification

| Claim | Layer |
|---|---|
| Frozen U33 programmed after blank SRAM | FACT PASS_IMPLEMENTED End of startup HIGH |
| Host PA24-V-04 payload has exactly one BEGIN | FACT (print begin_n=1 every TX) |
| MAG `0200015a` = pack_loader R_BAD_MAGIC | FACT (same encoding) |
| Extra exact BEGIN after CLEAR IDLE is sufficient for this token | FACT PASS_XSIM leftover inject (prior) |
| Python `send_words` injected a second BEGIN | CONTRADICTED (begin_n=1) |
| FTDI/USB duplicated the 4-byte BEGIN | HYPOTHESIS |
| DUT autogenous leftover BEGIN on this silicon run | UNKNOWN (phantom CDC CONTRADICTED on BRAM) |
| 12s settle after cold-plug is enough for first GOLD | CONTRADICTED (T0 n=0; T1 GOLD after +30s) |
| PACK_ABI_24_24_PASS | NO |

No dest_accept / UART PHY / qsc / pack_loader overlay. No new identity. PROGRAM=NO until owner authorizes a capture of leftover `00800001` on the wire or a new DUT.
