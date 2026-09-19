# U18 FAIL — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

U18_PROGRAMMED = FACT
BIT_SHA256 = aca343792c09feaaef3ab5dcbb6326f784d7ef80ac518bff15b32513a7238949
DCP_SHA256 = afca676ad8f54c97a6d811244a684eb4258c2e551007441372851ef026e23bde
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH
COM = COM12 115200 8N1 FTDI 210319BE776EB
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
TIMING_PASS = NO
WNS = +0.498 ns (observation)
WHS = +0.014 ns (observation)

LiteX / NSL: NOT ADOPTED.

## FIRST_FAILING_PHASE
5

## FIRST_FAILING_CASE
CLEAR round=3 after Phase4 + V-04 GOLD x3 (immediate host, no gap)

## LAST_GOOD_EVENT
CLEAR r2 ACK n=4
V-04 r2 GOLD n=4 010000a5
(Also Phase4 ACK+GOLD and r0/r1 ACK+GOLD)

## FIRST_BAD_EVENT
CLEAR r3 UNSUP n=4 5a070002 (0200075a) dt=0.0782s MAG=0 n0=0

## EXPECTED
CLEAR ACK n=4 c1ea50a5 then V-04 GOLD

## OBSERVED
CLEAR token is pack_loader R_UNSUP. Command 44524743 was not taken as CLEAR
(not exact CMD at 100 MHz) and a word reached pack_loader.

## RAW_TX
44524743

## RAW_RX
5a070002

## FIRST_DIVERGENCE
U17: Phase4 GOLD then first Phase5 V-04 UNSUP (first_p=0 class in XSim).
U18 XSim: parked 0-word during ACK → U17 UNSUP, U18 GOLD first_p=BEGIN.
U18 board: parked-during-ACK class improved (3 extra GOLD) then CLEAR itself UNSUP at r3.
Host 50ms after GOLD: Phase4 OK then Phase5 CLEAR n=0 (do not keep that gap).

## ROOT_CAUSE_STATUS
INFERENCE — unlocked UART word after GOLD (0 / phase-shifted CLEAR) entered pack_loader
because CDC a_valid is not gated by pack_lock. PASS_XSIM parked-ACK. Board r3 CLEAR UNSUP
not reproduced in 32x bram harness.

## SMALLEST_NEXT_TEST
U19 overlay: discard non-BEGIN FIFO words while pack_lock=0 (CLEAR still taken on w_valid).
XSim: GOLD then inject 0 then CLEAR → U18 UNSUP, U19 ACK. New identity. Do not patch U18.
