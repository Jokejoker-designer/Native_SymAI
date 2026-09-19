NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-WATCH-PKGQSC-BEGIN2-P0P15 / 20260919T044400Z
OWNER_AGENT: CURSOR_OWNER (side chat 94223db6 watching 31dc87bc)
CURRENT_CLAIM: PACKAGE-qsc BEGIN2 dest path is COMPLETE on log through P15 (t=4910258625.0 ps idle). GOLD2 UART still IN_PROGRESS. Publish P0–P15 txn2. Do not stamp PACK_ABI / MIG_PASS / BOARD_PASS. Do not overlay. Do not kill xsim. Do not overwrite MIG0_PATH_THIS_SEQUENCE=FAIL_XSIM_CLEAR1_BUSY.
RUN_PROVENANCE: Parent jsonl still 3002316. Native_SymAI was cc6c47e. Live xsim holds log. Publish from $display.
OBSERVATION:
  FACT — BEGIN2 P0 at 2869094625.0 ps then P1 at 4869146625.0 ps (~2.00 ms UART ingest).
  FACT — P2+P3 same cycle; P4 cmd_acc=1 wdf_acc=1; P6/P7 matching readback; P15 idle out=0.
  FACT — no OBS01_GOLD2 / Q4 / $finish yet.
  FACT — pack_mig_bind 7cee4df2… unchanged.
HYPOTHESES: INFERENCE txn2 dest handshake matches txn1. UNKNOWN GOLD2 token and Q4 NEW_COMMIT vs replay until GOLD2 $display.
HOW_TRACE: Tick 57 log P1–P9 → wait 25s → P10–P15 → snapshot → publish.
EVIDENCE_MATRIX:
  BEGIN2 P0-P15 | all printed | log | PASS_XSIM
  GOLD2 | 010000a5 | not printed | UNKNOWN
  product bind | dest AND gone | 7cee4df2… | CONTRADICTED
SUCCESS_VS_FAILURE: Success is BEGIN2 P0–P15 without missing Pn. Failure-to-promote is TB force dest ready; GOLD2 open; not board.
FIRST_DIVERGENCE: None on dest Pn this txn; wall cost again UART+ddr3_model.
DECISIVE_TEST: P15_SETTLE_IDLE vs missing Pn. Next GOLD2.
ROOT_CAUSE_OR_UNKNOWN: Dest txn2 reachable on PACKAGE-qsc. GOLD2/board UNKNOWN.
REUSABLE_DECISION_PROCEDURE: Publish BEGIN2 P0–P15 when P15 prints even if GOLD2 UART still pending.
STRUCTURAL_GUARD: Keep product dest_ui AND. Score Pn from $display not csv.
BLAST_RADIUS: Native_SymAI evidence. C RTL / H / freeze / U32 bind untouched.
VERDICT_BY_LAYER: PASS_XSIM PACKAGE_QSC_MIG0_TXN2_P0_P15. Not PACK_ABI. GOLD2 INCOMPLETE.
LESSON_TO_SHARE: PACKAGE-QSC-MIG0-BEGIN2-P0-P15
NEXT_DECISIVE_EXPERIMENT: Wait OBS01_GOLD2 / Q4 / $finish.
OWNER_AND_STOP_CONDITION: Watch continues. Stop after BEGIN2 P0–P15 push. No program.
HANDOFF_STATUS: COMPLETE
