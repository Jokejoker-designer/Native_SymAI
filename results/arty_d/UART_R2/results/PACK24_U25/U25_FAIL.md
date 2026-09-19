# U25 FAIL — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

U25_PROGRAMMED = FACT
BIT_SHA256 = 6c41ed1838c08af6595e5ad39ce807d4434ad659b288b2be9e7353e3213d8902
post_route.dcp = 254826761b87bab4b4921994b55ed59e0a78dfafb49d6244abadb7a51f4ae221
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH
PROGRAM.txt 2026-09-19 00:24 +07
WNS = +0.390 ns (observation)
WHS = +0.008 ns (observation)
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
MIG_PASS = NO
TIMING_PASS = NO

Do not patch U25 RTL. Frozen identity.

## FIRST_FAILING_PHASE
5 round 2 V-04

## FIRST_FAILING_CASE
V-04 after CLEAR ACK n=4 (V04 n=0, 12.00 s)

## LAST_GOOD_EVENT
p5 r1 V-04 GOLD a5000001 n=4 (00:24:12 +07)

## FIRST_BAD_EVENT
p5 r2 V-04 n=0 NONE

## EXPECTED
GOLD a5000001 n=4

## OBSERVED
Phase4 GOLD. p5 r0 CLEAR n=0 then RETRY ACK then GOLD. p5 r1 ACK+GOLD. p5 r2 ACK then V-04 n=0.
UNSUP=0 MAG=0. Not leftover `0200075a`.

## FIRST_DIVERGENCE
U24 exclusive: p4 GOLD then p5 r0 GOLD then r1 V-04 n=0.
U25 exclusive: p4 GOLD + p5 r0 GOLD + p5 r1 GOLD then r2 V-04 n=0.
U21 GOLD-kill CONTRADICTED (U25 first GOLD lived).
U20 leftover UNSUP CONTRADICTED (fail is n=0 after ACK).

## ROOT_CAUSE_STATUS
INFERENCE — dest/pack complete hang after N dest-completes + debug_clear of loader+ui32 while mig0 is live.
FACT — `pack_clear_ui` ACKed so `pack_quiescent` was 1; debug_clear does not reset generated mig0.
UNKNOWN — whether 1s host wait after ACK/GOLD changes r2; whether splitting ui32 reset from debug_clear restores dest.

## SMALLEST_NEXT_TEST
1. Host-only WAIT_AFTER_ACK/GOLD=1.0 on frozen U25 SRAM (no RTL patch).
2. If still n=0: U26 overlay, `debug_clear` resets `pack_loader` only, not `mig_ui32`.
