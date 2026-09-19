# U14 board trial 2026-09-18

U14_PROGRAMMED = FACT
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
TIMING_PASS = NO

BIT_SHA256 = 3597886d91c1fc3f6af6c154f240fd02c587168c41f1033ff55f6827029d102b
JTAG = 210319BE776EA
DEVICE = xc7a100t_0
End of startup = HIGH
COM = COM12 115200 8N1 FTDI 210319BE776EB
dtr/rts = False

## Phase 3
Fresh program exact U14 bit. Not leftover-dirty SRAM baseline.

## Phase 4
First OPEN after 15s settle + 0.3s drain:
CLEAR1 n=0 empty 3.052s

Second OPEN, physical MARK wait 2s, drain junk_n=0:
CLEAR ACK c1ea50a5
CLEAR2 ACK c1ea50a5

Third OPEN, MARK 2s:
CLEAR ACK then V-04 GOLD 010000a5 (n=4 a5000001)
PHASE4_LIVENESS = OK on this host contract (MARK 2s after COM open)
Not a first-open-after-program pass.

## Phase 5 FIRST_DIVERGENCE
round=0 CLEAR after GOLD
EXPECTED: n=4 ACK a550eac1
OBSERVED: n=8 raw 00000000a550eac1 word=00000000 then ACK in same capture
MAG=0 unexpected UNSUP=0 n=0=0
STOP. No Pack24. No RTL patch in this identity.

Leftover probe: 0.5s after GOLD extra=0, then CLEAR still 00000000+ACK.
Zeros are not delayed GOLD leftover. They are emitted with the next CLEAR.

## FIRST_FAILING_PHASE
5 (repeat CLEAR after proven GOLD)

## LAST_GOOD_EVENT
V-04 GOLD n=4 010000a5

## FIRST_BAD_EVENT
next CLEAR n=8 00000000||ACK

## ROOT_CAUSE_STATUS
U12/U13 total mute: handshake ready-during-flush_hold. U14 board can ACK/GOLD, so that class is closed on this bit for the MARK-2s contract.
Remaining: extra 32-bit zero word before ACK after a pack GOLD. UNKNOWN, not patched here.
COM-open first CLEAR still flaky (n=0 vs ACK).

## SMALLEST_NEXT_TEST
Capture whether mux sends st_data_100=0 during CLEAR after GOLD (CDC release vs ACK order). New identity if RTL change. Do not retouch U14 in place.
