NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: GOAL_AGENT_D FINAL R2 / D-PACK-SILICON-FIRST-DIVERGENCE-01
RUN_ID: 20260917T045800Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: silicon CLASS A UNSUP 0200075a cannot be produced in dualclk BRAM XSim; leftover UART bytes are harmless.
RUN_PROVENANCE:
  PROGRAM=NO. tb_h12_class_a.sv. xsim 2026.1 finish 25019055 ns
  log sha256 7f61066ac4f4d98ad006aacddb604e9d3c7bd1b6b9319556178e53260fcf26e1
  No Identity I. No C RTL edit. No JTAG.
OBSERVATION:
  FACT — control: CLEAR ACK, V-04 GOLD, n_drop=0.
  FACT — 1 extra 0x00 then CLEAR: UNSUP 0200075a, captured word 52474300, loader S_REJECT (10).
  FACT — 2 extra bytes then CLEAR: MUTE. 3 extra: MUTE.
  FACT — after rst, dest_stall flood 140 words: CLEAR ACK, PACK GOLD n_drop=0, post CLEAR 02000e5a R_STALE.
  FACT — silicon H11 i=0 PACK and i=4 CLEAR are 0200075a (UART_BOARD prior).
HYPOTHESES:
  One stray RX byte before a 4-byte command causes CLASS A UNSUP — SUPPORTED PASS_XSIM.
  Same mechanism on silicon (FTDI/JP2/host extra byte) — HYPOTHESIS (source not measured).
  extra 2–3 bytes cause CLASS B MUTE via bix leftover / CLEAR not taken — SUPPORTED PASS_XSIM.
  uart_rx_word drop on !w_ready is the silicon path — NOT evidenced (n_drop=0).
HOW_TRACE:
  GOAL PROGRAM=NO → inject extra UART bytes before CLEAR after a GOLD pack → classify token
EVIDENCE_MATRIX:
  DIMENSION | RESULT | LAYER
  extra=0 CLEAR | ACK | PASS_XSIM
  extra=1 CLEAR | UNSUP 0200075a | PASS_XSIM
  extra=2/3 CLEAR | MUTE | PASS_XSIM
  silicon H11 UNSUP | 0200075a | UART_BOARD CANDIDATE
  stray-byte source on Arty | missing | UNKNOWN
SUCCESS_VS_FAILURE:
  Success: CLASS A token reproduced. No PASS stamp. No RTL edit.
  Failure: GOAL still open; silicon source of extra byte unknown.
FIRST_DIVERGENCE:
  bix=0 exact CLEAR 44524743 → ACK vs bix leftover + CLEAR bytes → UNSUP or MUTE.
DECISIVE_TEST: extra=1 after GOLD. Done.
ROOT_CAUSE_OR_UNKNOWN:
  CLASS_A_UNSUP_ONE_STRAY_BYTE = PASS_XSIM
  SILICON_STRAY_SOURCE = UNKNOWN
REUSABLE_DECISION_PROCEDURE:
  Before ILA of pack_loader opcode, check uart_rx_word.bix. One 0x00 is enough for 0200075a.
STRUCTURAL_GUARD:
  Do not treat find_known None as mute when hex is 5a070002. Do not Identity I until owner grants bix/resync RTL.
BLAST_RADIUS: TB only. uart_rx_word synthesizable not edited.
VERDICT_BY_LAYER:
  PASS_XSIM: extra=1 UNSUP; extra=2/3 MUTE
  UART_BOARD: H11 token match is INFERENCE not proof of source
  PACK_ABI_24_24_PASS / BOARD_PASS / PROGRAM_PASS: NO
LESSON_TO_SHARE: D-H12-STRAY-BYTE-UNSUP-20260917T045800Z
NEXT_DECISIVE_EXPERIMENT:
  ILA bix/clr_take on silicon H11, or owner-authorized RX resync. FEM persist blocked. PROGRAM=NO.
OWNER_AND_STOP_CONDITION:
  AGENT_D. No Identity I. GOAL_AGENT_D FINAL R2 NOT complete.
HANDOFF_STATUS: COMPLETE
