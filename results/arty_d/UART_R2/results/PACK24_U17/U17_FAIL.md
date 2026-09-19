# U17 FAIL_BOARD — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

U17_PROGRAMMED = FACT
BIT_SHA256 = 7be4e9df3666e7cac78d12f311b6fc73057fcca19cd0e945ea4665d43098f3a4
DCP_SHA256 = c58ba5870a3ebe9a30aed6df87e450eb733a7107967b53677054be8644d01d65
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH
COM = COM12 115200 8N1 FTDI 210319BE776EB
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
TIMING_PASS = NO
WNS = +0.521 ns (observation)
WHS = +0.018 ns (observation)

## FIRST_FAILING_PHASE
5 (second V-04 after GOLD + CLEAR ACK)

## FIRST_FAILING_CASE
Phase 5 round=0 V-04 (after CLEAR ACK n=4)

## LAST_GOOD_EVENT
CLEAR1 ACK n=4
V-04_0 GOLD n=4 010000a5
CLEAR r0 ACK n=4 a550eac1
U16 class n=0 after GOLD did not recur on this session.

## FIRST_BAD_EVENT
V-04 r0 UNSUP n=4 5a070002 (0200075a) dt=0.0766s MAG=0

## EXPECTED
V-04 GOLD n=4 010000a5

## OBSERVED
R_UNSUP 0x07. Repeatable with 0.5s gap after CLEAR ACK: GOLD then CLEAR ACK then V-04 UNSUP.

## RAW_TX
CLEAR 44524743 then PA24-V-04.mem 52 words

## RAW_RX
5a070002

## FIRST_DIVERGENCE
U16: GOLD then CLEAR n=0 (S_REQ flush).
U17: GOLD then CLEAR ACK (S_REQ flush reverted + TX CDC B ~clr_ui_req). Next V-04 UNSUP.
PASS_XSIM harness 32/32 ACK_ONLY extra=0 dest=mig_ui_bram BAUD=1M.
Idle CDC reset-order TB: no extra B word after consumed transfers.

## ROOT_CAUSE_STATUS
INFERENCE — second pack after GOLD+CLEAR is R_UNSUP (loader reject), not MAG, not n=0.
HYPOTHESIS — BEGIN dropped or first opcode != OP_BEGIN after dest-complete GOLD; not proven in 1M harness.
Do not retouch frozen U17.

## SMALLEST_NEXT_TEST
Reproduce GOLD→CLEAR ACK→V-04 UNSUP in dualclk harness at 115200 or with MIG-like dest stall. New identity. Do not patch U17 in place.
