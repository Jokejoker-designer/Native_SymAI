NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-WATCH-OBS01-MIG0 / 20260919T020200Z
OWNER_AGENT: CURSOR_OWNER (side chat 94223db6 watching 31dc87bc)
CURRENT_CLAIM: Parent OBS01-MIG0 XSim is COMPLETE. Publish Native_SymAI for audit. Do not stamp PACK_ABI_24_24_PASS / MIG_PASS / BOARD_PASS. Do not overlay. Do not resume parent xelab.
RUN_PROVENANCE: Parent jsonl grew 2927251 → 2982570 (mtime 2026-09-19T02:01:21Z). Parent `$finish` 211565 ns. Live artifacts under D:/FPGA/arty_d/D_DEST_LIFECYCLE_OBS_01/. Public repo Jokejoker-designer/Native_SymAI was 42f33ba.
OBSERVATION:
  FACT — xsim_mig0.log sha256 169061f9f8b577e8e78e0dd1012798eac098b6433d623fb2a730084a2fde70ad: CLEAR1 got=c1ea50b5 mute=0; LAST_EQUIVALENT_EVENT=CALIB_DONE; FIRST_DIVERGENCE=CLEAR1_ACK.
  FACT — dest_ui_clk_mig0.csv sha256 134b59561bf07f125e3b419ac16e5170a4ce9a77682505310007b8249331b5dc; 186 data rows.
  FACT — independent csv recount this publish: qsc===app_rdy 186/186; nonidle=0; p_rdy/p_wdf_rdy nonzero=0; app_wdf_rdy!=1 =0; idle+qsc=0 =93 all with app_rdy=0; idle+qsc=0 while app_rdy=1 and app_wdf_rdy=1 =0; debug_clear=1 =0.
  FACT — TB sha256 fb36a2b88b677a0e7feebbe1a58fc484f1ae292e67d281e660842fc6e1d17a6c (CLEAR1 fail prints OBS01_QSC_VS_RDY).
  FACT — PACK_ABI_24_24_PASS=NO remains in log and STATUS.
HYPOTHESES: Parent H1 RAW_MIG_READY SEEN_THIS_SEQ copied as-is. Board causal still HYPOTHESIS. Watcher does not add a new root.
HOW_TRACE: Loop tick 3 jsonl delta → read parent OBS01_MIG0_XSIM.md + log + csv → hash match → copy sources (no xsim.dir / MIG IP) → STATUS/issues comments.
EVIDENCE_MATRIX: FACT hashes and csv identities. INFERENCE: same token class as U32 exclusive CLEAR1 BUSY. UNKNOWN: PACKAGE-qsc A/B; board cycle-causal class; SAMPLE vs DRAIN which nacked CLEAR.
SUCCESS_VS_FAILURE: Publish success is GitHub commit with hashes. Failure would be stamping PASS or overlaying.
FIRST_DIVERGENCE: Parent compile hung xvlog/xelab; successful path used -work obs. Functional divergence remains CLEAR1_ACK.
DECISIVE_TEST: This publish is not a new XSim. Next remains PACKAGE-qsc A/B (parent).
ROOT_CAUSE_OR_UNKNOWN: Watcher has no independent root. Parent mechanism PASS_XSIM_OBS01_MIG0_CLEAR1_BUSY. Board UNKNOWN.
REUSABLE_DECISION_PROCEDURE: On audit-watch ticks, publish only COMPLETE findings with hashed artifacts; omit xsim workdirs and MIG IP; never self-stamp PASS.
STRUCTURAL_GUARD: GITHUB_AUDIT_WATCH.json records jsonl bytes/mtime/sha. Do not drop dest_ui_* from dest_accept. Do not UART overlay.
BLAST_RADIUS: Native_SymAI docs + OBS01 out/ csv+log + TB + parent reasoning 015520Z. Identity H / freeze DCP / C RTL / Pack24 gold untouched.
VERDICT_BY_LAYER: PASS_IMPLEMENTED publish-of-existing-PASS_XSIM. Not PASS_BOARD. Not PACK_ABI_24_24_PASS.
LESSON_TO_SHARE: NONE (reuse RAW-MIG-READY-QSC-FOLLOWS-APP-RDY-IDLE)
NEXT_DECISIVE_EXPERIMENT: Wait for parent PACKAGE-qsc A/B; then copy that log.
OWNER_AND_STOP_CONDITION: Side chat continues 3-min watch until Anh says dừng theo dõi. Stop this turn after push+issue comments. No program.
HANDOFF_STATUS: COMPLETE
