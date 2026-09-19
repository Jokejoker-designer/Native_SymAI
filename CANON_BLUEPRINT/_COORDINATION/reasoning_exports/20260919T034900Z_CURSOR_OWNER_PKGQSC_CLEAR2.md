NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-WATCH-PKGQSC-CLEAR2 / 20260919T034900Z
OWNER_AGENT: CURSOR_OWNER (side chat 94223db6 watching 31dc87bc)
CURRENT_CLAIM: PACKAGE-qsc CLEAR2 is COMPLETE on log: ACK c1ea50a5 mute=0 dclr_busy=0 lack_fell=1 after GOLD1 idle. Q2 YES. V04_2_ARM printed. GOLD2 still IN_PROGRESS. Publish CLEAR2 ACK. Do not stamp PACK_ABI / MIG_PASS / BOARD_PASS. Do not overlay. Do not kill xsim. Do not overwrite MIG0_PATH_THIS_SEQUENCE=FAIL_XSIM_CLEAR1_BUSY.
RUN_PROVENANCE: Parent jsonl still 3002316. Native_SymAI was ec23d21. Live xsim holds log. Publish from $display.
OBSERVATION:
  FACT — OBS01_CLEAR2 mute=0 got=c1ea50a5 dclr_busy=0 lack_fell=1.
  FACT — OBS01_V04_2_ARM n_commit=1 n_lack_rise=1 n_stv_rise=1.
  FACT — BEFORE_CLEAR2 dest idle/out0; GOLD1 already PASS_XSIM.
  FACT — OBS01_QSC0_WHILE_IDLE dest_rdy=1 then CLEAR2 ACK — not CLEAR2 BUSY.
  FACT — no GOLD2 / Q3 / Q4 / $finish yet.
  FACT — pack_mig_bind 7cee4df2… unchanged. csv still truncated (same hash).
HYPOTHESES: INFERENCE Q2 YES this seq. HYPOTHESIS board CLEAR2 BUSY is dest-ready-in-qsc same as CLEAR1. UNKNOWN GOLD2/Q4.
HOW_TRACE: Tick 39 log gained CLEAR2+V04_2_ARM → snapshot → publish.
EVIDENCE_MATRIX:
  CLEAR2 token | ACK | OBS01_CLEAR2 | PASS_XSIM
  Q2 idle | YES | BEFORE_CLEAR2 then ACK | PASS_XSIM
  CLEAR2 BUSY after clean dest | this seq | ACK not BUSY | CONTRADICTED_THIS_SEQ (PACKAGE-qsc)
  GOLD2 | | not printed | UNKNOWN
  product bind | dest AND gone | 7cee4df2… | CONTRADICTED
SUCCESS_VS_FAILURE: Success is CLEAR2 ACK after clean GOLD1. Failure-to-promote is TB force dest ready; GOLD2 open; not board.
FIRST_DIVERGENCE: QSC0_WHILE_IDLE with dest_rdy=1 did not become CLEAR2 BUSY.
DECISIVE_TEST: OBS01_CLEAR2 ACK vs BUSY vs mute. Next GOLD2.
ROOT_CAUSE_OR_UNKNOWN: PACKAGE-qsc CLEAR2 ACK after clean txn. Board UNKNOWN.
REUSABLE_DECISION_PROCEDURE: Publish CLEAR2 token as soon as OBS01_CLEAR2 prints; do not wait GOLD2.
STRUCTURAL_GUARD: Keep product dest_ui AND. lack_fell is CLEAR reset not BEGIN2.
BLAST_RADIUS: Native_SymAI evidence. C RTL / H / freeze / U32 bind untouched.
VERDICT_BY_LAYER: PASS_XSIM PACKAGE_QSC_CLEAR2 Q2 YES. Not PACK_ABI. GOLD2 INCOMPLETE.
LESSON_TO_SHARE: PACKAGE-QSC-MIG0-CLEAR2-ACK-AFTER-GOLD1
NEXT_DECISIVE_EXPERIMENT: Wait GOLD2 / Q4 / $finish.
OWNER_AND_STOP_CONDITION: Watch continues. Stop after CLEAR2 push. No program.
HANDOFF_STATUS: COMPLETE
