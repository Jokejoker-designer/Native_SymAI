NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: GOAL_AGENT_D FINAL R2 / D-PACK-SILICON-FIRST-DIVERGENCE-01
RUN_ID: 20260917T050200Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: prefix stray byte causes MAG; host cannot recover from UNSUP without RTL.
RUN_PROVENANCE:
  PROGRAM=NO. tb_h12_mag_resync.sv. xsim finish 18274295 ns
  log sha256 a8e471c7ebe14779b5fa5dc45bfb29336693024afc6b92af78e17fe701eb88f2
  uart_h12_resync.py written, not run on board. Frozen campaign host not edited.
OBSERVATION:
  FACT — stray 0x00 then full V-04 PACK → UNSUP 0200075a (not MAG).
  FACT — stray 0x00 then CLEAR → UNSUP 0200075a.
  FACT — then 3x 0x00, CLEAR ACK c1ea50a5, V-04 GOLD 010000a5.
  FACT — extra 0x00 after BEGIN word then rest of pack → MAG 0200015a.
HYPOTHESES:
  Prefix stray → UNSUP — SUPPORTED (again).
  Prefix stray → MAG — REJECTED; MAG needs extra after BEGIN.
  pad3 after UNSUP restores bix then CLEAR+PACK GOLD — SUPPORTED PASS_XSIM host-only.
  Silicon H11 MAG is extra-after-BEGIN — HYPOTHESIS.
HOW_TRACE:
  GOAL PROGRAM=NO → MAG vs UNSUP injection points → pad3 resync
EVIDENCE_MATRIX:
  DIMENSION | RESULT | LAYER
  stray then PACK | UNSUP | PASS_XSIM
  extra after BEGIN | MAG | PASS_XSIM
  pad3 resync | ACK+GOLD | PASS_XSIM
  board resync | not run | NOT_RUN
SUCCESS_VS_FAILURE:
  Success: MAG and UNSUP split; host pad3 GOLD. No Identity I.
  Failure: GOAL not complete; resync not on silicon.
FIRST_DIVERGENCE:
  extra before command word → opcode 00 UNSUP
  extra after BEGIN → R_BAD_MAGIC MAG
DECISIVE_TEST: extra_after_BEGIN. Done.
ROOT_CAUSE_OR_UNKNOWN:
  CLASS_A two injection points named. Silicon extra source UNKNOWN.
REUSABLE_DECISION_PROCEDURE:
  UNSUP vs MAG tells whether leftover is before opcode or after BEGIN.
  After UNSUP, send 3 zero bytes then CLEAR before retrying pack.
STRUCTURAL_GUARD:
  Do not edit frozen campaign host. New host only. No uart_rx_word edit without grant.
BLAST_RADIUS: TB + new host script. Synthesizable RTL untouched.
VERDICT_BY_LAYER:
  PASS_XSIM: MAG 0200015a; pad3 GOLD
  PASS_BOARD: NOT_RUN
  PACK_ABI_24_24_PASS / PROGRAM_PASS: NO
LESSON_TO_SHARE: D-H12-MAG-PAD3-RESYNC-20260917T050200Z
NEXT_DECISIVE_EXPERIMENT:
  Owner PROGRAM=YES may run uart_h12_resync.py. Else ILA bix. FEM persist blocked.
OWNER_AND_STOP_CONDITION:
  AGENT_D. GOAL_AGENT_D FINAL R2 NOT complete.
HANDOFF_STATUS: COMPLETE
