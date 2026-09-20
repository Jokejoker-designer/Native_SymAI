NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-TICK10-U33OBS-ROUTE / 20260920T113000Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Publish parent COMPLETE U33OBS ROUTE_DONE. Timing not met. No bit. PACK_ABI=NO.
RUN_PROVENANCE: Parent jsonl 4236647 vs 4228620. GitHub was 78ca615. BUILD.txt STATUS=ROUTE_DONE.
OBSERVATION:
  FACT — post_route.dcp sha256 d3e26d3d…a32ead; BUILD TAP_CDC_XDC_AT_IMPL=YES
  FACT — WNS -1.516 TNS -6.011 7 failing setup; WHS +0.016 MET
  FACT — seven paths are 100 MHz ↔ clk_pll_i with 2.000 ns related-clock requirement
  FACT — TAP XDC only names u_cdc_tap / u_cdc_u2ui / busy_u*; failing cells are obs_ctrl, dump freeze/reason, calib, load_reject
  FACT — no .bit on disk; READY_TO_PROGRAM=NO; not programmed
  INFERENCE — TAP XDC at impl did not close obs handshake / freeze / NAK CDCs
HYPOTHESES: Parent may still write bitstream from this DCP — NOT_TESTED this tick. Programming a WNS-fail observe DUT would not earn TIMING_PASS.
HOW_TRACE: Copy BUILD.txt util_route timing extract + docs. No DCP/bit. No overlay. No program.
EVIDENCE_MATRIX: PASS_IMPLEMENTED post-route reports. TIMING_CONSTRAINTS_MET=NO. Not TIMING_PASS. Not PASS_BOARD.
SUCCESS_VS_FAILURE: Route completed; timing signoff failed. Synth unplaced WNS -1.245 did not recover at route.
FIRST_DIVERGENCE: Related-clock 2 ns window on obs_ctrl/calib/nak/freeze vs TAP-named CDC cells.
DECISIVE_TEST: Named cells in timing_route.rpt vs cells in u33obs_tap_cdc.xdc.
ROOT_CAUSE_OR_UNKNOWN: TAP XDC coverage gap for obs_ctrl/u_dump freeze-reason and MIG calib / load_reject CDCs. MAG historical still OPEN.
REUSABLE_DECISION_PROCEDURE: Unique build_u33obs. Do not overwrite U33/H/TAPCDC. Do not stamp TIMING_PASS from TAP_CDC_XDC_AT_IMPL=YES. Do not program ROUTE_DONE with WNS<0.
STRUCTURAL_GUARD: READY_TO_PROGRAM=NO. TIMING_PASS=NO. PACK_ABI=NO. No bit published.
BLAST_RADIUS: Native_SymAI docs + slim route reports. Frozen identities on disk.
VERDICT_BY_LAYER: ROUTE_DONE FAIL_TIMING_POST_ROUTE. Not TIMING_PASS / PACK_ABI / BOARD / PROGRAM.
LESSON_TO_SHARE: TAP-XDC-AT-IMPL-DOES-NOT-EXCEPT-OBS-CTRL-FREEZE-CDC-20260920T113000Z
NEXT_DECISIVE_EXPERIMENT: Wait parent bitstream COMPLETE or CDC XDC expansion. Watch continues.
OWNER_AND_STOP_CONDITION: Watch until dừng theo dõi.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
