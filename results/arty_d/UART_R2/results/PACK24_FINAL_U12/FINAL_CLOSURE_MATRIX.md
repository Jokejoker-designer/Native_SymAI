# FINAL_CLOSURE_MATRIX — UART_R2_U12_PACK24_FINAL

M1_RUNTIME_PACK_CLOSURE_CANDIDATE = FAIL

FIRST_FAILING_PHASE: 4 BASIC BOARD LIVENESS
FIRST_FAILING_CASE: CLEAR1 after fresh U12 program
LAST_GOOD_EVENT: End of startup HIGH; JTAG `210319BE776EA`; bit SHA `0f774e8745377ea75dab6ccd533fedf059a03a00612f90fbe9bddb9ce3ab5121`
FIRST_BAD_EVENT: COM12 115200 CLEAR `44524743` → n=0 (no ACK/BUSY/ERR)
EXPECTED: complete CLEAR ACK `c1ea50a5`
OBSERVED: n=0 raw empty on program1 and program2; 2s MARK retry n=0; double-open 5× CLEAR n=0
RAW_TX: `43475244` (CLEAR LE)
RAW_RX: empty
FIRST_DIVERGENCE: UART TX token never appears on U12; same-day U8 bit `2bc835fd…` (PACKAGE TX) produced one `0200075a` UNSUP then sticky mute
ROOT_CAUSE_STATUS: HYPOTHESIS — U10 `uart_tx_word` flush_hold lives in the same always_ff as `st`; Vivado inferred sequential FSM (`Synth 8-802` / `8-3354`). U11 used PACKAGE TX, same FSM infer, but no flush_hold in that process, and produced ACK+GOLD. Not MAG. Not BOARD_PASS.
SMALLEST_NEXT_TEST: U13 = U11 RX + U8 CLEAR + U10 TX with `fsm_encoding=none` and flush_hold split out of the FSM process. New identity, new hashes, new campaign. Do not retouch U12 bit.

TARGETED_XSIM = PASS_XSIM (54 pass, warn=1 U8 quiet-timeout ACK legacy)
CLEAR_V04_REPEAT = NOT_RUN (blocked by phase 4)
PACK24_RUN1 = NOT_RUN
DESTINATION_COMPLETE_CONTRACT = NOT_PROVEN (UART token missing)
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
TIMING_PASS = NO
U12_PROGRAMMED = FACT
