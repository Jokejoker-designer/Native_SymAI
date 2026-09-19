# U26 FAIL — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

U26_PROGRAMMED = FACT
BIT_SHA256 = 8f5471a7d2da35dacfec42ede3e1b9a9b19e7f90e3e23a4ba42c94b267df3375
post_route.dcp = c0fc74713faf18b3ced72ce84e3340805fba36fc7227d6d5842f8084b9d67b29
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH 00:42:25 +07
WNS = +0.530 ns (observation)
WHS = +0.008 ns (observation)
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO

Do not patch U26 RTL. Frozen identity.

## FIRST_FAILING_PHASE
5 round 1 V-04

## LAST_GOOD_EVENT
p5 r0 V-04 GOLD a5000001 n=4

## FIRST_BAD_EVENT
p5 r1 V-04 n=0 NONE (12.04 s) after CLEAR n=0 then RETRY ACK

## FIRST_DIVERGENCE
U25: p4 GOLD + r0 GOLD + r1 GOLD then r2 n=0.
U26: p4 GOLD + r0 GOLD then r1 V-04 n=0.
U26 `debug_clear` resets `pack_loader` only (mig_ui32 live) did not beat U25. H-ui32-reset-vs-mig0 CONTRADICTED as the 24/24 fix.

## COM
First campaign after program: COM12 Access Denied — GOAL_M1 `probe_pack24_ack4.py` PID 48496. Killed. Retry exclusive GOLD then this FAIL.

## SMALLEST_NEXT_TEST
U27 from frozen U25 UART + PACKAGE bind. Soft CLEAR: ACK when quiescent without `debug_clear`.
