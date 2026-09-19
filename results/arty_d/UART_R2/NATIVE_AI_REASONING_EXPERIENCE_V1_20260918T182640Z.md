# NATIVE_AI_REASONING_EXPERIENCE_V1_AGENT_D_20260918T182640Z

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: UART_R2_U29_FAIL_BOARD_U30_OVERLAY / 20260918T182640Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: U29 qsc_c1 BEGIN-gate FAIL_BOARD: CLEAR ACK then first V-04 n=0. pack_quiescent can stay 1 while dest is in debug_clear reset. Not PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS.
RUN_PROVENANCE:
  U29 bit D:/FPGA/arty_d/UART_R2/build_u29/uart_r2_u29_candidate.bit SHA256 c02c3343b7076a9ff2a95d88488a926130979396af5f46baa86b6164aaa0190c
  U29 DCP SHA256 7791bd5766878383ddf6172424874321e16ab93bbedd54b2463054640e8010d0
  JTAG 210319BE776EA End of startup HIGH 2026-09-19T01:21:01+07 and reprogram 01:26:07+07
  UART COM12 115200 FTDI 210319BE776EB exclusive
  U29 XSim leftover+four V-04 PASS_XSIM dest=mig_ui_bram (prior run)
  U30 overlay UART_R2/u30 (not programmed this run)
  PACKAGE pack_mig_bind / C RTL / H / freeze DCP / Pack24 gold: not overwritten
  Identity H cf62102f… not programmed
OBSERVATION:
  FACT: U29 BIT_OK LUT 10554 FF 8893 RAMB36=3 RAMB18=2 DSP 8 WNS +0.710 WHS +0.021. Not TIMING_PASS.
  FACT: First exclusive p4p5 immediately after program: all CLEAR n=0 (JTAG/COM singleton class).
  FACT: After 12s settle, WARMUP CLEAR ACK n=4 then CLEAR1/retry/reopen n=0 (BOARD_BASELINE_ACK_THEN_N0.json).
  FACT: Reprogram End of startup HIGH; 12s settle; no-warmup CLEAR1 ACK n=4 then V-04 n=0 dt=12.05s (BOARD_BASELINE.json stop V04_0).
  FACT: U25 still best board (3 GOLD then r2 n=0). U29 first V-04 failed. Regression vs U25.
  FACT: PACKAGE pack_quiescent = !loader_busy && !ui_busy && wr_outstanding==0 (no rst_loc, no !debug_clear).
HYPOTHESES:
  H1: qsc_c1=1 while rst_loc=0 so U29 steers BEGIN into CDC/loader under debug_clear/cdc_rst (S_ACK). INFERENCE.
  H2: combinational pack_begin without f_valid stalls FIFO on stale f_data. HYPOTHESIS.
  H3: first-session warmup ACK then sticky mute is COM/JTAG leftover, not U29 law. INFERENCE from prior singleton.
  H4: mig0 dest hang after CLEAR same as U22/U28. UNKNOWN until U30 board.
HOW_TRACE:
  CLEAR take from w_valid. debug_clear resets loader+ui32. rst100_pack_n <= ~cdc_rst_100 during S_CDC|S_QUIET|S_ACK.
  U29 steer_pack = pack_lock || (pack_begin && qsc_c1). f_ready=0 if pack_begin && !qsc_c1 (no f_valid).
  Host sends V04 after ACK bytes; FSM may still be S_ACK (cdc_rst=1).
EVIDENCE_MATRIX:
  U29 XSim four GOLD | PASS_XSIM | mig_ui_bram only
  U29 exclusive CLEAR then V04 n=0 | FAIL_BOARD | BOARD_BASELINE.json sha c02c3343
  U25 3 GOLD | PASS_BOARD_OBSERVE | not 24/24
  qsc during dest reset | RTL_FACT | PACKAGE pack_mig_bind.sv L70
SUCCESS_VS_FAILURE:
  Success: U25 first V-04 GOLD. Failure: U29 first V-04 n=0 after ACK.
FIRST_DIVERGENCE:
  First V-04 after a live CLEAR ACK. U25 GOLD; U29 mute 12s.
DECISIVE_TEST:
  Reprogram U29, 12s settle, no warmup: CLEAR ACK + V04. Observed n=0.
ROOT_CAUSE_OR_UNKNOWN:
  BEGIN-into-CDC-while-cdc_rst-or-dest-reset INFERENCE. Board mig0 hang UNKNOWN. U29 overlay CONTRADICTED as 24/24 fix.
REUSABLE_DECISION_PROCEDURE:
  pack_quiescent must be 0 while debug_clear or rst_loc=0. Park BEGIN only if f_valid. Do not use qsc_100 in steer (combo through CDC idle). Do not SETTLE 2048 (U28 CONTRADICTED). Freeze FAIL bits.
STRUCTURAL_GUARD:
  U30 overlay bind: pack_quiescent && rst_loc && !debug_clear. dest_accept = qsc_c1 && rst100_pack_n. Ban c02c3343 in program Tcl. Do not overwrite PACKAGE bind.
BLAST_RADIUS:
  UART_R2/u29 frozen. UART_R2/u30 overlay only. No C RTL / H / freeze DCP / Pack24 gold.
VERDICT_BY_LAYER:
  PASS_XSIM U29 leftover+four V-04 (prior). FAIL_BOARD U29 first V-04. PASS_IMPLEMENTED U29 bit (built, not a PASS stamp). Not PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS / TIMING_PASS / MIG_PASS.
LESSON_TO_SHARE: QSC-FALSE-WHILE-DEST-RESET
NEXT_DECISIVE_EXPERIMENT:
  U30 leftover+four V-04 XSim then exclusive program. Do not program until PASS_XSIM. Do not patch U29.
OWNER_AND_STOP_CONDITION:
  AGENT_D. Stop if 24/24 CLEAR-V04 GOLD n=4 then pack1/2/3 dest-complete. No self-stamp PACK_ABI_24_24_PASS.
HANDOFF_STATUS: COMPLETE
```
