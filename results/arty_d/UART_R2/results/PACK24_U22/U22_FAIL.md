# U22 FAIL — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

U22_PROGRAMMED = FACT
BIT_SHA256 = ba45936f117e0d8eb6b903dc498dc66e4c36f94314bdcaa8afd366306f8a2be9
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH
PROGRAM.txt 2026-09-18 19:22:08 +07
WNS = +0.407 ns (observation)
WHS = +0.020 ns (observation)
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
GOAL_M1_COLLISION_WATCH = 17:54:48 unchanged
GOAL_M2_COLLISION_WATCH = 18:30:29 unchanged

## FIRST_FAILING_PHASE
4

## FIRST_FAILING_CASE
CLEAR1 n=0 (retry also n=0)

## LAST_GOOD_EVENT
JTAG End of startup HIGH. No UART word.

## FIRST_BAD_EVENT
CLEAR1 NONE dt=3.06s (19:22:38 +07); CLEAR1_RETRY NONE dt=3.06s

## EXPECTED
ACK a550eac1 n=4

## OBSERVED
n=0 twice. MAG=0.

Vs exclusive U21: CLEAR1 ACK then V-04 n=0.
Vs exclusive U20: CLEAR1 ACK + GOLD.

## FIRST_DIVERGENCE
U21 CLEAR1 ACK vs U22 CLEAR1 n=0.

Lock-fall FIFO flush is idle at CLEAR1 (pack_lock=0). That revert does not explain this fail.

## ROOT_CAUSE_STATUS
UNKNOWN — CLEAR1 mute. Not isolated to fifo_flush-on-lock-fall.
Do not patch U22. Do not treat as U21 V-04 class.

## SMALLEST_NEXT_TEST
Name CLEAR1 n=0 on TX.flush=0 product overlay (COM/TX/P&R) in a new identity after a decisive XSim or host probe. No Pack24.
