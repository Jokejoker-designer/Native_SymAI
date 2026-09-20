NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-TICK14-U33OBS-SYNTH-GEN / 20260920T114000Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Publish parent COMPLETE gen+XDC SYNTH_DONE. OBS 2FF XDC not applied (18-540). Impl IN_PROGRESS. PACK_ABI=NO.
RUN_PROVENANCE: Parent jsonl 4301958 vs 4298582. GitHub was 8151cc2.
OBSERVATION:
  FACT — BUILD SYNTH_DONE TAP_CDC_CELLS=1 U2UI_CDC_CELLS=1
  FACT — unplaced WNS -1.243 (3 setup) WHS -1.631; LUT 11938 FF 10901
  FACT — three 2.000 ns paths: cal0, nak0, a0
  FACT — synth.log Constraints 18-540 x7 on xdc:37-43 set_max_delay -datapath_only without -from
  FACT — dump-SOF DCP d3e26d3d preserved; no bit; impl started (empty impl.log at 18:39:48)
HYPOTHESES: Same 18-540 at impl unless parent adds -from — NOT_TESTED this tick.
HOW_TRACE: Copy BUILD util timing extract docs. No DCP. No program. Do not edit parent XDC.
EVIDENCE_MATRIX: PASS_IMPLEMENTED synth reports. TIMING_CONSTRAINTS_MET=NO. Not TIMING_PASS. Not PASS_BOARD.
SUCCESS_VS_FAILURE: Synth completed; OBS CDC exceptions rejected; TAP-named CDC cells still 1.
FIRST_DIVERGENCE: XDC -to-only vs Vivado requiring -from for -datapath_only.
DECISIVE_TEST: synth.log 18-540 vs timing.rpt Requirement 2.000 ns on cal0/nak0/a0.
ROOT_CAUSE_OR_UNKNOWN: FACT XDC syntax rejected. MAG historical OPEN.
REUSABLE_DECISION_PROCEDURE: Unique build_u33obs. Do not overwrite dump-SOF/U33/H. Do not stamp TIMING_PASS from unplaced WNS. Do not fix parent XDC from this watch.
STRUCTURAL_GUARD: READY_TO_PROGRAM=NO. TIMING_PASS=NO. PACK_ABI=NO.
BLAST_RADIUS: Native_SymAI slim synth_gen reports.
VERDICT_BY_LAYER: SYNTH_DONE. Impl IN_PROGRESS. Not TIMING_PASS / PACK_ABI / BOARD / PROGRAM.
LESSON_TO_SHARE: SET-MAX-DELAY-DATAPATH-ONLY-REQUIRES-FROM-20260920T114000Z
NEXT_DECISIVE_EXPERIMENT: Wait parent impl COMPLETE or XDC fix.
OWNER_AND_STOP_CONDITION: Watch until dừng theo dõi.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
