NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: PACK24-DATAFLOW-CLOCK-BUFFER-ROOT-AUDIT
RUN_ID: 20260919T050700Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Pack24 fails because ready/quiescent semantics treat mig0.app_rdy as dest-idle, not because clk100 vs ui_clk event loss. FACT of RTL wiring + PASS_XSIM split (U32 dest-AND CLEAR1 BUSY vs PACKAGE-qsc ACK+GOLD2). Not PACK_ABI_24_24_PASS / BOARD_PASS.
RUN_PROVENANCE:
  Live U32: D:/FPGA/arty_d/UART_R2/u32/{arty_a7_r2_top_m4_mig_candidate.sv,pack_mig_bind.sv,pack_uart_dualclk_harness.sv,pack_debug_clear.sv,pack_clear_ui.sv}
  PACKAGE bind without dest_ui AND: Native_SymAI/CANON_BLUEPRINT/rtl/native_ai/memory/pack_mig_bind.sv
  Clocks: clk_arty_mig.sv MMCM; mig_uiclk timing period 12.000 ns; WORD_CDC32_XSIM_RESULT.json a=12 ns b=10 ns
  OBS01: dest-AND FAIL_XSIM_CLEAR1_BUSY vs PACKAGE-qsc $finish GOLD2 CLEAN PASS_XSIM
  Constraint this run: NO RTL / overlay / program / UART / dest_accept / dest_ui strip
OBSERVATION:
  FACT — uart_rx_word STOP bix==3 skips emit if w_valid && !w_ready (silent drop).
  FACT — word_fifo32 DEPTH=128 LUTRAM clk100; wr_ready when used!=DEPTH and !flush.
  FACT — word_cdc32 is 1-entry toggle handshake: a_ready=(req_a==ack_a1); hold[31:0]; not Gray FIFO.
  FACT — pack_loader s_ready only IDLE/RX/REJECT/EDRAIN; PAGE_RAM_WORDS=64.
  FACT — mig_ui32 mem_cmd_ready is S_IDLE&&calib, not app_rdy; app handshake is later S_WR/S_RD.
  FACT — mig_ui_mux G_NONE zeros a_rdy/a_wdf_rdy.
  FACT — U32 top dest_ui_rdy(app_rdy) dest_ui_wdf_rdy(app_wdf_rdy) from mig0, not mux a_rdy.
  FACT — U32 pack_quiescent ANDs dest_ui_rdy && dest_ui_wdf_rdy with loader/ui/outstanding/reset.
  FACT — PACKAGE live pack_quiescent omits dest_ui_*.
  FACT — dest_accept = qsc_c1 && rst100_pack_n; qsc_100 adds CDC/TX idle terms.
  FACT — pack_debug_clear SAMPLE_N=8 !pack_quiescent -> BUSY 0xC1EA50B5.
  FACT — clk_sys166 = 100e6 * 10 / 6 = 166.667 MHz; clk_ref200 = 200 MHz; same MMCM as clk100 input.
  FACT — ui_clk period 12.000 ns (83.333 MHz) from mig_uiclk route timing; nCK_PER_CLK=4.
  FACT — UART baud is DIV CE on clk100, not a clock domain.
  FACT — PACKAGE-qsc GOLD1/GOLD2 010000a5 Q4 NEW_COMMIT $finish 4958414625 ps with dest ready forced 1.
  FACT — U32 dest-AND CLEAR1 BUSY c1ea50b5 on same generated mig0 dest class.
HYPOTHESES:
  H1 FAST/SLOW pulse miss across clk100/ui_clk is Pack24 unique root. CONTRADICTED this class.
  H2 word_cdc32 1-deep overflows UART Pack24. CONTRADICTED (FIFO 128; UART 2880 w/s).
  H3 pack_quiescent uses cycle-accept as idle. CONFIRMED PASS_XSIM split.
  H4 Board identity H is a different class than U32 XSim CLEAR1. POSSIBLE / NOT TESTED this run.
HOW_TRACE:
  hop Host->UART->FIFO->steer->CDC->loader->ui32->mux->mig0
  -> clock sources MMCM vs MIG PLL
  -> every ready meaning vs qsc AND list
  -> dest-AND BUSY vs PACKAGE-qsc ACK+CLEAN
  -> architecture options A/B/C without code
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  dest-AND CLEAR1 | BUSY c1ea50b5 | OBS01 dest-AND FAIL_XSIM | PASS_XSIM
  PACKAGE-qsc | ACK+GOLD2 CLEAN | xsim_mig0_pkgqsc.log 63eb8e3e | PASS_XSIM
  dest_ui wiring | app_rdy into qsc | u32 top L264 + bind L74-75 | PASS_IMPLEMENTED
  word_cdc32 | 1-deep handshake | word_cdc32.sv + JSON 2/2 | PASS_XSIM
  ui_clk Hz | 83.333 | mig_uiclk period 12.000 ns | PASS_IMPLEMENTED timing report
  clk100 vs ui_clk | async PLL | clk_arty_mig MMCM vs mig0 ui_clk | FACT clocks
  board Pack24 | same class as U32 CLEAR1 | identity H | NOT TESTED this run
SUCCESS_VS_FAILURE:
  Success: PACKAGE-qsc same UART/CDC/MIG dest GOLD-completes when dest_ui forced 1.
  Failure: U32 dest-AND CLEAR1 SAMPLE sees !qsc_100 because dest_ui follows app_rdy dips while loader/ui/out idle.
FIRST_DIVERGENCE:
  CLEAR1 token: dest-AND BUSY vs PACKAGE-qsc ACK. Clocks, FIFO, word_cdc32, mig0 dest unchanged.
DECISIVE_TEST:
  Force dest_ui_* = 1 in TB (OBS01_QSC_PKG) vs product AND. Already run. Do not product-strip.
ROOT_CAUSE_OR_UNKNOWN:
  ROOT (XSim CLEAR1 class): quiescence semantic (app_rdy as idle). UNKNOWN: board exclusive identity H; leftover after ACK.
REUSABLE_DECISION_PROCEDURE:
  1 Classify READY vs IDLE vs QUIESCENT vs COMPLETE vs COMMITTED on named signals.
  2 If two clocks: ask whether the failing event is a 1-cycle pulse or a held handshake/level.
  3 Split dest-AND vs dest-forced sequences; never overwrite FAIL with TB CLEAN.
STRUCTURAL_GUARD:
  Do not overlay dest_accept. Do not strip dest_ui_* without owner identity. Do not add async FIFO only because two clocks exist. word_cdc32 already exact-once.
BLAST_RADIUS:
  Audit docs + canvas + reasoning. U32/H/freeze/C RTL untouched. No program.
VERDICT_BY_LAYER:
  PASS_IMPLEMENTED: wiring and clock sources from RTL/MMCM/timing report.
  PASS_XSIM: PACKAGE-qsc CLEAN; dest-AND CLEAR1 BUSY.
  PASS_BOARD: not this run.
  PACK_ABI_24_24_PASS: NO.
LESSON_TO_SHARE: APP_RDY_IS_NOT_QUIESCENT
NEXT_DECISIVE_EXPERIMENT:
  SAMPLE-window probe dest_ui_rdy vs loader_busy vs ui_busy vs wr_outstanding vs qsc_100. Conservation counters only after ACK.
OWNER_AND_STOP_CONDITION:
  AGENT_D. Stop: no RTL/overlay/program. Do not stamp PACK_ABI from this audit.
HANDOFF_STATUS: COMPLETE
