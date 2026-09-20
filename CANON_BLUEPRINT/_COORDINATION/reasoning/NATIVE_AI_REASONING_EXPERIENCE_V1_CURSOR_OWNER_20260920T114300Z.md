NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-TICK15-U33OBS-ROUTE-GEN / 20260920T114300Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Publish parent COMPLETE gen+XDC ROUTE_DONE. Timing not met. 18-540 at impl. No bit. PACK_ABI=NO.
RUN_PROVENANCE: Parent jsonl 4303815 vs 4301958. GitHub was 143f2ba.
OBSERVATION:
  FACT — BUILD ROUTE_DONE TAP_CDC_XDC_AT_IMPL=YES TIMING_PASS=NO
  FACT — WNS -1.507 TNS -9.850 20 setup fail; WHS +0.028 MET
  FACT — impl.log 18-540 x7; failing req still 2.000 ns
  FACT — post_route sha256 37953849…; dump-SOF d3e26d3d preserved; no .bit
  FACT — TNS worse than dump-SOF (7 fail) because epoch_ui and other gen CDC added
HYPOTHESES: Parent may still write a bit from this DCP — NOT_TESTED. Programming it would not earn TIMING_PASS.
HOW_TRACE: Copy BUILD util_route timing extract. No DCP/bit. No program. Do not edit parent XDC.
EVIDENCE_MATRIX: PASS_IMPLEMENTED post-route reports. TIMING_CONSTRAINTS_MET=NO. Not TIMING_PASS. Not PASS_BOARD.
SUCCESS_VS_FAILURE: Route completed; OBS CDC exceptions still rejected; hold MET.
FIRST_DIVERGENCE: Same 18-540 as synth; extra 17 sys_clk→ui paths (epoch TAP).
DECISIVE_TEST: impl.log 18-540 vs timing_route Requirement 2.000 ns.
ROOT_CAUSE_OR_UNKNOWN: FACT XDC -from missing. MAG historical OPEN.
REUSABLE_DECISION_PROCEDURE: Unique build_u33obs. Do not overwrite dump-SOF/U33/H. Do not stamp TIMING_PASS from TAP_CDC_XDC_AT_IMPL=YES. Do not program WNS<0.
STRUCTURAL_GUARD: READY_TO_PROGRAM=NO. TIMING_PASS=NO. PACK_ABI=NO.
BLAST_RADIUS: Native_SymAI slim route_gen reports.
VERDICT_BY_LAYER: ROUTE_DONE FAIL_TIMING_POST_ROUTE. Not TIMING_PASS / PACK_ABI / BOARD / PROGRAM.
LESSON_TO_SHARE: SET-MAX-DELAY-DATAPATH-ONLY-REQUIRES-FROM-20260920T114000Z
NEXT_DECISIVE_EXPERIMENT: Wait parent bitstream or XDC -from fix. Watch continues.
OWNER_AND_STOP_CONDITION: Watch until dừng theo dõi.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
