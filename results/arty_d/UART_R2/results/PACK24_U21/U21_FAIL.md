# U21 FAIL — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

U21_PROGRAMMED = FACT
BIT_SHA256 = 09736afe958400d4a7bf6e41b81cb0247f119f8678780aef585cccf0ba4f1ff9
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH
PROGRAM.txt 2026-09-18 18:57:37 +07
WNS = +0.609 ns (observation)
WHS = +0.012 ns (observation)
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
GOAL_M1_COLLISION_WATCH = 17:54:48 unchanged
GOAL_M2_COLLISION_WATCH = 18:30:29 unchanged (SRAM last-writer was GOAL_M2 before this JTAG)

## FIRST_FAILING_PHASE
4

## FIRST_FAILING_CASE
V-04 after CLEAR1 ACK (n=0, 12.04 s)

## LAST_GOOD_EVENT
CLEAR1 ACK a550eac1 (18:58:06 +07)

## FIRST_BAD_EVENT
V-04 n=0 NONE

## EXPECTED
GOLD a5000001

## OBSERVED
Phase4 ACK then mute. MAG=0.

Vs exclusive U20: ACK+GOLD then Phase5 CLEAR n=0.
Vs exclusive U19: ACK then V-04 n=0 (this U21 class).

## FIRST_DIVERGENCE
U20 exclusive: V-04 GOLD.
U21 exclusive: V-04 n=0.
New U21 RTL: TX.flush=0, clr_ack_ready=mux_ready, FIFO flush on pack_lock fall.

## ROOT_CAUSE_STATUS
INFERENCE — pack_lock-fall FIFO flush can wipe V-04 after BEGIN sets lock, if GOLD-handshake/phantom st_valid_100 drops lock mid-pack.
UNKNOWN until U22 reverts only that delta.
Do not patch U21.

## SMALLEST_NEXT_TEST
U22: fifo_flush = uart_flush only. Keep TX.flush=0. Exclusive program. No Pack24.
