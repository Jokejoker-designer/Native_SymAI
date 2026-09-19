NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-WATCH-PKGQSC-GOLD2-FINISH / 20260919T044500Z
OWNER_AGENT: CURSOR_OWNER (side chat 94223db6 watching 31dc87bc)
CURRENT_CLAIM: PACKAGE-qsc OBS01-MIG0 is COMPLETE: GOLD2 010000a5 mute=0 Q1 YES Q2 YES Q3 NO Q4 NEW_COMMIT d_commit=1 d_lack=1 d_stv=1 NO_STUCK YES LAST=P15 $finish 4958414625 ps. TB printed MIG0_PATH_THIS_SEQUENCE=CLEAN for THIS seq only. PACK_ABI_24_24_PASS=NO. Do not stamp PACK_ABI / MIG_PASS / BOARD_PASS. Do not overlay. Do not overwrite U32 dest-AND FAIL_XSIM_CLEAR1_BUSY.
RUN_PROVENANCE: Parent jsonl still 3002316. Native_SymAI f71f897 had BEGIN2 P0–P15 with GOLD2 still open; log then printed GOLD2+$finish. xsimk exited.
OBSERVATION:
  FACT — OBS01_GOLD2 mute=0 got=010000a5 begin2=1 t_commit2=4909430625.0 ps t_lack2=4909442625.0 ps.
  FACT — GOLD2_DELTA d_commit=1 d_lack=1 d_stv=1. Q4 NEW_COMMIT.
  FACT — Q1 YES Q2 YES Q3 NO dclr_while_busy=0.
  FACT — NO_STUCK ld_idle=1 ui_idle=1 out0=1 st_quiet=1.
  FACT — TB: MIG0_PATH_THIS_SEQUENCE=CLEAN PACK_ABI_24_24_PASS=NO OBS01_DONE dest=generated_mig0 not_board not_pack_abi.
  FACT — $finish 4958414625 ps. U32 pack_mig_bind 7cee4df2… unchanged.
HYPOTHESES: INFERENCE PACKAGE-qsc dest lifecycle matches BRAM Q1–Q4. HYPOTHESIS board CLEAR1 BUSY is dest-ready-in-qsc. UNKNOWN board class until exclusive U32 retest after owner overlay identity.
HOW_TRACE: Tick 57 P15 publish → GOLD2 already on live log during git push → resnapshot finished log → second commit.
EVIDENCE_MATRIX:
  GOLD2 | 010000a5 | OBS01_GOLD2 | PASS_XSIM
  Q4 | NEW_COMMIT | d_*=1 after BEGIN2 | PASS_XSIM
  CLEAN label | this seq | TB $display | PASS_XSIM PACKAGE_QSC only
  product bind | dest AND removed | 7cee4df2… | CONTRADICTED
  PACK_ABI | YES | TB PACK_ABI=NO | CONTRADICTED
SUCCESS_VS_FAILURE: Success is full CLEAR→V-04→CLEAR→V-04 on generated mig0 with TB-forced dest ready. Failure-to-promote is not product qsc, not board, not PACK_ABI.
FIRST_DIVERGENCE: U32 dest-AND vs PACKAGE-qsc still CLEAR1 ACK vs BUSY.
DECISIVE_TEST: GOLD2 vs FAIL V04_1. Next: owner overlay identity or board exclusive after authorized qsc change.
ROOT_CAUSE_OR_UNKNOWN: XSim dest path CLEAN when dest ready forced out of qsc. Board UNKNOWN.
REUSABLE_DECISION_PROCEDURE: When $finish prints GOLD2+Q4, publish immediately even if a P15-only commit just landed. Split CLEAN labels by sequence.
STRUCTURAL_GUARD: Keep product dest_ui AND until owner overlay identity. Never stamp PACK_ABI from this TB.
BLAST_RADIUS: Native_SymAI evidence. C RTL / H / freeze / U32 bind / identity H untouched.
VERDICT_BY_LAYER: PASS_XSIM PACKAGE_QSC_MIG0_PATH CLEAN Q4 NEW_COMMIT. Not PASS_BOARD. Not PACK_ABI_24_24_PASS. Not MIG_PASS.
LESSON_TO_SHARE: PACKAGE-QSC-MIG0-GOLD2-Q4-NEW-COMMIT-FINISH
NEXT_DECISIVE_EXPERIMENT: Do not product-strip dest_ui_* without owner overlay identity. Board exclusive U32 still FAIL CLEAR1.
OWNER_AND_STOP_CONDITION: Watch continues for parent chat text. This seq XSim is done. No program.
HANDOFF_STATUS: COMPLETE
