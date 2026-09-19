# U19 FAIL — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

U19_PROGRAMMED = FACT (exclusive 17:27:25 +07)
BIT_SHA256 = cecb020ff5d3c699f8892896cef650f3e3bc99d7c8888e0de352c102787b7576
DCP_SHA256 = f6e12c2acc1f9eeaa871aa489a802029f468ad0b0893da4a1a0aabb180975dd1
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH
WNS = +0.756 ns (observation)
WHS = +0.027 ns (observation)
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
GOAL_M1_COLLISION_WATCH = PASS (PROGRAM.txt frozen 17:17:39)

## FIRST_FAILING_PHASE
4 (exclusive). Phase 5 not reached.

## FIRST_FAILING_CASE
V-04 after CLEAR1 ACK (n=0, 12 s timeout)

## LAST_GOOD_EVENT
CLEAR1 ACK n=4 `a550eac1` (17:28:21 +07)

## FIRST_BAD_EVENT
V-04 n=0 NONE (17:28:34 +07)

## EXPECTED
V-04 GOLD n=4 `a5000001`

## OBSERVED
Exclusive: ACK then mute. Same-SRAM retry: CLEAR n=0 twice.
Voided 17:20 MAG `5a010002` = GOAL_M1 NAK, not this fail.

## FIRST_DIVERGENCE
U18 board: GOLD then later CLEAR UNSUP.
U19 first program 17:16: GOLD then Phase5 CLEAR n=0 (before GOAL_M1 overwrite; not collision-watched).
U19 exclusive 17:27: Phase4 V-04 n=0.
PASS_XSIM: unlocked 0 after GOLD discarded; 32/32 GOLD. That class is not this exclusive fail.

## ROOT_CAUSE_STATUS
UNKNOWN — GOLD mute after CLEAR ACK. Not MAG. Collision class closed for the MAG dump only.
Do not patch U19.

## SMALLEST_NEXT_TEST
XSim GOLD-mute after CLEAR on product overlay (TX lock vs dest hang vs BEGIN dropped by steer_pack). New identity only after that class is named. No Pack24. No M2_STARTING_POINT.

## Artifacts
- `BOARD_BASELINE_EXCLUSIVE_V04_n0.json`
- `BOARD_BASELINE_EXCLUSIVE_CLEAR1_n0_retry.json`
- `BOARD_BASELINE_CONTAMINATED_goal_m1.json` (VOID)
- `JTAG_COLLISION_GOAL_M1.md`
- `CLEAR_V04_24_FAIL_first_program.json` (17:16, not exclusive)
