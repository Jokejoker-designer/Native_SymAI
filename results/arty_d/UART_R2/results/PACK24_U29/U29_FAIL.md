# U29 FAIL — CLOSE_M1_PACK24_AND_PREPARE_M2

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

U29_PROGRAMMED = FACT
BIT_SHA256 = c02c3343b7076a9ff2a95d88488a926130979396af5f46baa86b6164aaa0190c
DCP_SHA256 = 7791bd5766878383ddf6172424874321e16ab93bbedd54b2463054640e8010d0
JTAG = 210319BE776EA xc7a100t_0 End of startup HIGH (01:21:01 and 01:26:07 +07)
UART = COM12 115200 FTDI 210319BE776EB
LUT=10554 FF=8893 RAMB36=3 RAMB18=2 DSP=8 WNS=+0.710 WHS=+0.021 (observation, not TIMING_PASS)
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO

Do not patch U29 RTL. Frozen identity.

## FIRST_FAILING_PHASE
Phase4 V-04 (no-warmup reprogram)

## LAST_GOOD_EVENT
CLEAR ACK `c1ea50a5` n=4 (warmup session 01:22:39; no-warmup CLEAR1 01:26:26)

## FIRST_BAD_EVENT
1. After 12s settle, WARMUP ACK then CLEAR1/retry/reopen n=0 (sticky mute that session).
2. Reprogram + 12s settle + no warmup: CLEAR1 ACK then V-04 n=0 for 12.05s.

## FIRST_DIVERGENCE
U25: first V-04 GOLD. U29: first V-04 n=0 after CLEAR ACK.
XSim leftover+four V-04 was PASS_XSIM dest=mig_ui_bram only.

## INFERENCE
`pack_quiescent` stays 1 while `debug_clear`/`rst_loc=0` (loader looks idle in reset). U29 gated BEGIN on `qsc_c1` without `f_valid` and without `rst100_pack_n`, so BEGIN can enter CDC while `cdc_rst` still asserted (S_ACK). Combinational `pack_begin && !qsc_c1` can also stall FIFO on stale `f_data`.

## SMALLEST_NEXT_TEST
U30 from U29 (do not patch U29): `pack_quiescent` includes `rst_loc && !debug_clear`; park BEGIN only if `f_valid && pack_begin && !(qsc_c1 && rst100_pack_n)`. No SETTLE 2048. XSim leftover+four V-04 before program.
