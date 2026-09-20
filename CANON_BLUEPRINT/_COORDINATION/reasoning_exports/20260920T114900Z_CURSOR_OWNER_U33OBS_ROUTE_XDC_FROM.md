NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-TICK17-U33OBS-ROUTE-XDC-FROM / 20260920T114900Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Publish parent COMPLETE route with -from/-to XDC. Post-route constraints MET. Do not stamp TIMING_PASS. No bit. PACK_ABI=NO.
RUN_PROVENANCE: Parent jsonl 4322316 vs 4303815. GitHub was 9bfaac0.
OBSERVATION:
  FACT — BUILD ROUTE_DONE TIMING_PASS=NO READY_TO_PROGRAM=NO
  FACT — timing_route WNS +0.303 TNS 0 WHS +0.008; "All user specified timing constraints are met"
  FACT — impl.log 18-540 count 0; Slack VIOLATED count 0
  FACT — XDC sha256 cd8b7494… with -from and -to; DCP 168359bc…; no .bit
  FACT — dump-SOF d3e26d3d and gen_wnsfail 37953849 preserved
HYPOTHESES: Parent may write bitstream next — NOT_TESTED. Constraints MET is not TIMING_PASS ladder stamp.
HOW_TRACE: Copy BUILD util_route timing extract XDC. No DCP/bit. No program.
EVIDENCE_MATRIX: PASS_IMPLEMENTED post-route timing_summary MET. TIMING_PASS=NO. Not PASS_BOARD. Not PACK_ABI.
SUCCESS_VS_FAILURE: -from/-to closed 18-540 and 2 ns related-clock fails. Hold still MET. No bit.
FIRST_DIVERGENCE: Prior impl 18-540 / Tcl proc vs this parse-clean -from/-to.
DECISIVE_TEST: timing_route constraints met vs BUILD TIMING_PASS=NO.
ROOT_CAUSE_OR_UNKNOWN: Prior WNS was missing -from (FACT). MAG historical OPEN. MUTE silicon OPEN.
REUSABLE_DECISION_PROCEDURE: Do not stamp TIMING_PASS from one MET report. Do not program without unique bit + owner YES. Keep dump-SOF/U33/H frozen.
STRUCTURAL_GUARD: READY_TO_PROGRAM=NO. TIMING_PASS=NO. PACK_ABI=NO. Ban overlay.
BLAST_RADIUS: Native_SymAI slim route_xdcfrom reports + XDC.
VERDICT_BY_LAYER: ROUTE_DONE constraints MET. Not TIMING_PASS / PACK_ABI / BOARD / PROGRAM.
LESSON_TO_SHARE: SET-MAX-DELAY-FROM-AND-TO-MET-POST-ROUTE-NOT-TIMING-PASS-20260920T114900Z
NEXT_DECISIVE_EXPERIMENT: Wait unique bitstream COMPLETE. Watch continues.
OWNER_AND_STOP_CONDITION: Watch until dừng theo dõi.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
