NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: CLOSE_M1_PACK24_AND_PREPARE_M2 / UART_R2_U17 / 20260918T091000Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: U17 closed U16 CLEAR-after-GOLD n=0 on this session (ACK n=4) by reverting S_REQ flush and resetting TX CDC B from clr_ui_req. Phase 5 then failed V-04 r0 R_UNSUP 0200075a. Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.
RUN_PROVENANCE: Native_SymAI HEAD 69f9dddb0b7d5747ea0949a4737c27e9299ee37f main. U17 bit sha256 7be4e9df3666e7cac78d12f311b6fc73057fcca19cd0e945ea4665d43098f3a4 DCP c58ba5870a3ebe9a30aed6df87e450eb733a7107967b53677054be8644d01d65. PACKAGE live top unchanged 382ac125…. Pack24 gold unchanged 2986c354…. RX U11 6a9ac527… TX U14 03d05d6e…. JTAG 210319BE776EA End of startup HIGH. COM12 115200 FTDI 210319BE776EB. Vivado 2026.1 WNS +0.521 WHS +0.018 observation.

OBSERVATION:
  FACT — U16 bit e32a64e7… Phase 4 ACK+GOLD then Phase 5 r0 CLEAR n=0. MAG=0.
  FACT — U16 vs U14 delta was uart_flush at S_REQ. U14 after GOLD was 00000000||ACK.
  FACT — word_cdc32 A-reset B-live after a captured word emits b_valid with hold=0 (PASS_XSIM T1 phantom 0).
  FACT — U17 CLEAR = U8 flush/cdc_rst (no S_REQ flush). Product overlay TX CDC B rst_n = ~clr_ui_req. PACKAGE live top not overwritten.
  FACT — U17 XSim targeted pass=56 warn=1; harness 32/32 ACK_ONLY extra=0 dest=mig_ui_bram 1M; 115200 bram GOLD then CLEAR ACK then GOLD2.
  FACT — U17 programmed 7be4e9df… End of startup HIGH. U17_PROGRAMMED=FACT. PROGRAM_PASS=NO.
  FACT — Board p4p5: CLEAR ACK, V-04 GOLD, CLEAR ACK, V-04 UNSUP 5a070002. 0.5s gap after ACK still GOLD then CLEAR ACK then UNSUP.
  INFERENCE — S_REQ flush was the n=0 correlator; removing it restored ACK after GOLD on this bit.
  INFERENCE — second V-04 R_UNSUP is pack_loader reject 0x07 (END/opcode class), not MAG, not n=0.
  HYPOTHESIS — product MIG0 / fe256 / FEM mux path drops BEGIN or fails dest-complete on the second pack; bram harness does not reproduce.
  CONTRADICTED — 50ms host idle after ACK is too short for CDC-reset-during-pack: 0.5s still UNSUP.

HYPOTHESES:
  H1 S_REQ flush caused board ACK mute — SUPPORTED vs U14/U16 contrast; CLOSED_FOR_TESTED_CONTRACT on U17 session.
  H2 TX CDC A-reset B-live phantom 0 on UART — SUPPORTED in XSim; UART extra-0 not seen on U17 after GOLD CLEAR.
  H3 second pack UNSUP = RX CDC leftover 0 — NOT supported by idle-CDC reset-order XSim after consumed transfers.
  H4 second pack UNSUP = MIG dest / generation / product fe256 — OPEN.

HOW_TRACE: U16 FAIL n=0 → U17 revert S_REQ flush + TX B reset with ui_req → XSim 32/32 → product MIG0 bit → board ACK after GOLD → V-04_2 UNSUP.

EVIDENCE_MATRIX:
  PASS_XSIM targeted, CDC phantom, harness 32, harness 115200 GOLD2 bram.
  FAIL_BOARD Phase 5 r0 V-04 UNSUP. PASS_BOARD Phase 4 and CLEAR-after-GOLD ACK this session.
  No PACK24. No dest-complete UART observability.

SUCCESS_VS_FAILURE: Success = CLEAR after GOLD is exact ACK (U16 fail class). Failure = next V-04 0200075a.

FIRST_DIVERGENCE: first V-04 after GOLD+CLEAR on Arty MIG0 vs same sequence GOLD on bram XSim.

DECISIVE_TEST: 115200 dualclk bram GOLD2 PASS_XSIM; board same baud UNSUP. Next: product-top or mig0-class dest, not another S_REQ flush.

ROOT_CAUSE_OR_UNKNOWN: n=0-after-GOLD INFERENCE closed on U17 for tested contract. R_UNSUP after that UNKNOWN (MIG/product vs bram).

REUSABLE_DECISION_PROCEDURE: Contrast last identity that still ACKed. Do not keep a flush that correlates with mute. Kill CDC phantom by resetting both sides, not by holding TX flush across S_REQ. Classify UNSUP separately from n=0 and MAG.

STRUCTURAL_GUARD: uart_flush must not span S_REQ wait-for-ui_ack. TX CDC B reset from clr_ui_req, not shared RX cdc_rst at S_REQ.

BLAST_RADIUS: UART CLEAR/TX CDC only. C RTL / FE256 freeze / Pack24 gold / identity H / freeze DCPs untouched.

VERDICT_BY_LAYER:
  PASS_XSIM yes. PASS_IMPLEMENTED bit built. PASS_BOARD Phase 4 and CLEAR2 ACK only. FAIL_BOARD Phase 5 V-04. Not TIMING_PASS / PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS / MIG_PASS.

LESSON_TO_SHARE: UART-FLUSH-S_REQ-MUTES-ACK-AFTER-GOLD and UART-UNSUP-AFTER-GOLD-CLEAR-NOT-N0

NEXT_DECISIVE_EXPERIMENT: Reproduce 0200075a on product-top or MIG-like dest in XSim. New identity U18. Do not edit frozen U17.

OWNER_AND_STOP_CONDITION: AGENT_D. Stop Pack24. Stop U17 RTL edits. No M2 implementation.

HANDOFF_STATUS: COMPLETE for U17 campaign FAIL. INCOMPLETE_HANDOFF for CLOSE_M1.
