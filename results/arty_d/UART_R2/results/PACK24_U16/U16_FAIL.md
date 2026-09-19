# U16 FAIL — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

## FIRST_FAILING_PHASE
5 (repeated CLEAR after proven GOLD). Phase 4 PASS.

## FIRST_FAILING_CASE
Phase 5 round=0 CLEAR after V-04 GOLD.

## LAST_GOOD_EVENT
2026-09-18T15:30:41+07:00 COM12 115200 8N1 FTDI 210319BE776EB
CLEAR1 ACK n=4 a550eac1 (c1ea50a5)
V-04 GOLD n=4 a5000001 (010000a5)
PHASE4_OK

## FIRST_BAD_EVENT
2026-09-18T15:30:44+07:00 same COM session, no reprogram
CLEAR round=0 n=0 raw empty dt=3.0065s sub=NONE

## EXPECTED
n=4 ACK a550eac1 then V-04 GOLD. MAG=0 extra-word=0.

## OBSERVED
n=0. MAG=0 unexpected UNSUP=0. Not MAG (MAG CLOSED).

## RAW_TX
CLEAR 44524743 after GOLD complete.

## RAW_RX
empty

## FIRST_DIVERGENCE
U14 same product mux + U14 TX + U8-class cdc_rst: GOLD then CLEAR = n=8 `00000000||ACK` (ACK present).
U16 only added uart_flush at S_REQ: GOLD then CLEAR = n=0 (ACK absent).
Harness dest=mig_ui_bram BAUD=1M U16 = ACK_ONLY PASS_XSIM (did not reproduce n=0).

## ROOT_CAUSE_STATUS
INFERENCE — S_REQ uart_flush (RX+FIFO+TX level for ui_ack wait) is the only RTL delta that removed ACK from the board wire.
FACT — extra 0-word class is word_cdc32 A-reset (debug_clear / rst_ui_pack_n) while B live (rst100_pack_n=1 at S_REQ): req_a collapses to 0, B sees req!=last_b, hold=0 → b_valid 0-word.
U15 cdc_rst at S_REQ reset RX CDC A while UI B live → pack mute; not reused.
CONTRADICTED as MAG (no 0200015a).

## SMALLEST_NEXT_TEST
U17: keep MAG cdc_rst and U8 flush (no S_REQ). Reset TX CDC B from clr_ui_req so A+B overlap in reset before debug_clear. Prove harness GOLD→CLEAR ACK_ONLY and no 00000000. New identity. Do not edit frozen U16.
