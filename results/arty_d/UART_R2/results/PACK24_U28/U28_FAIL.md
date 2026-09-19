# U28 FAIL — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

U28_PROGRAMMED = FACT
BIT_SHA256 = eea43dfb627647255fecf171643de8f952191b83e400e1937ee993fb8952d84e
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH 01:03:28 +07
WNS = +0.515 ns (observation)
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO

Do not patch U28 RTL. Frozen identity.

## FIRST_FAILING_PHASE
5 round 0 V-04

## LAST_GOOD_EVENT
Phase4 V-04 GOLD a5000001 n=4 (WARMUP ACK, CLEAR1 ACK)

## FIRST_BAD_EVENT
p5 r0 CLEAR ACK then V-04 n=0 NONE (~12 s)

## FIRST_DIVERGENCE
U25: 3 GOLD then r2 n=0.
U26: 2 GOLD then r1 n=0.
U28 SETTLE 2048 after debug_clear: 1 GOLD then r0 V-04 n=0 after ACK.
Host V04 is sent while loader+ui32 still in settle reset; CDC can take BEGIN with dest in reset.

## SMALLEST_NEXT_TEST
U29 from U25 (no settle): new BEGIN only if `qsc_100`. Keep debug_clear of loader+ui32. Do not patch U28.
