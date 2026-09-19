# U20 FAIL — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

U20_PROGRAMMED = FACT
BIT_SHA256 = 1c3f954f93caac75d5ff63089261ea45790d0879fcf15aaf668c2ffcdc539ff9
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH
PROGRAM.txt 2026-09-18 18:23:41 +07
WNS = +0.506 ns (observation)
WHS = +0.008 ns (observation)
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
GOAL_M1_COLLISION_WATCH = PROGRAM.txt unchanged 17:54:48 during p4p5

## FIRST_FAILING_PHASE
5

## FIRST_FAILING_CASE
CLEAR round=0 after Phase4 GOLD (n=0)

## LAST_GOOD_EVENT
CLEAR1 ACK; V-04 GOLD (Phase4) 18:24:21 +07

## FIRST_BAD_EVENT
CLEAR r0 n=0 NONE dt=3.05s

## EXPECTED
CLEAR ACK n=4

## OBSERVED
Phase4 GOLD `a5000001`. Next CLEAR mute. MAG=0 UNSUP=0.

Vs exclusive U19: Phase4 V-04 n=0. U20 closed that first-fail class on this run.

## FIRST_DIVERGENCE
U19 exclusive: V-04 after ACK n=0.
U20: V-04 GOLD then Phase5 CLEAR n=0 (same class as U19 17:16 / U16).

## ROOT_CAUSE_STATUS
UNKNOWN — CLEAR-after-GOLD mute. DROP-flush one-cycle did not close it.
Do not patch U20.

## SMALLEST_NEXT_TEST
Name GOLD-then-CLEAR n=0 (TX lock vs hold vs dest). New identity after that. No Pack24. No M2_STARTING_POINT.
