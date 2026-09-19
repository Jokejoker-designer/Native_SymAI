# NATIVE_AI_REASONING_EXPERIENCE_V1_AGENT_D_20260918T184540Z

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: UART_R2_U30_FAIL_BOARD / 20260918T184540Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: U30 dest-reset qsc overlay FAIL_BOARD at p5 r1 V-04 n=0 after two GOLD. UART PHY GOLD exists. AXI UART IP would not close 24/24. Not PACK_ABI_24_24_PASS.
RUN_PROVENANCE:
  bit 9f999be9e1f74623dfe5437bdf98a71ab7fb9076b5e4e89d9bb626714083335e
  dcp e3142f01a0b46195041b44a9efe244c6186c946287fdf973ca96171d08aa28cb
  JTAG 210319BE776EA End of startup HIGH 2026-09-19T01:44:56+07 COM12
  U29 frozen c02c3343… not patched. PACKAGE bind not overwritten.
OBSERVATION:
  FACT: leftover+four V-04 PASS_XSIM mig_ui_bram. Route LUT 10545 FF 8893 WNS +0.537. Not TIMING_PASS.
  FACT: nwp4p5: first CLEAR n=0; reopen ACK; Phase4 GOLD; r0 GOLD; r1 ACK then V-04 n=0.
HYPOTHESES:
  H1: UART 8N1 PHY is not the Nth-pack mute class. INFERENCE (GOLD twice).
  H2: AXI UART Lite/16550 would still need word+pack handshake; would not fix r1 n=0. INFERENCE from PG142/PG143.
HOW_TRACE:
  Same CLEAR→debug_clear→V04 path. Two dest-complete then third V04 silent after ACK.
EVIDENCE_MATRIX:
  U30 Phase4+r0 GOLD | PASS_BOARD_OBSERVE
  U30 r1 V04 n=0 | FAIL_BOARD
  PG142 AXI4-Lite 16-char FIFO | FACT (AMD PG142 2017-04-05)
SUCCESS_VS_FAILURE:
  Success: first/second V-04 GOLD. Failure: r1 after ACK.
FIRST_DIVERGENCE:
  p5 round 1 V-04 vs U25 r2. Same ACK+n=0 dest class.
DECISIVE_TEST:
  Exclusive nwp4p5 after 12s settle.
ROOT_CAUSE_OR_UNKNOWN:
  Nth dest hang UNKNOWN. UART PHY CONTRADICTED as sole 24/24 blocker.
REUSABLE_DECISION_PROCEDURE:
  Do not replace word UART with AXI UART Lite to close Pack 24/24. Keep vendor PHY optional behind same 32-bit valid/ready.
STRUCTURAL_GUARD:
  Freeze U30. Ban 9f999be9. No MicroBlaze/AXI UART pivot on Arty for M1.
BLAST_RADIUS:
  u30 overlay only. No C/H/freeze/gold.
VERDICT_BY_LAYER:
  PASS_XSIM four V-04. FAIL_BOARD r1. Not PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
LESSON_TO_SHARE: AXI-UART-NOT-PACK-24-FIX
NEXT_DECISIVE_EXPERIMENT:
  Keep word UART. Next dest-idle overlay only if owner continues GOAL. Do not patch U30.
OWNER_AND_STOP_CONDITION:
  AGENT_D. Goal PACK_ABI_24_24_PASS open. No self-stamp.
HANDOFF_STATUS: COMPLETE
```
