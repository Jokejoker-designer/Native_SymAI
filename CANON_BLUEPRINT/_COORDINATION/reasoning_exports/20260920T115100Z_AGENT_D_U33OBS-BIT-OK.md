NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: U33OBS-BIT-OK-CDC-FROMTO / 20260920T115100Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Unique U33OBS bit exists with post-route constraints MET. Not programmed. PACK_ABI=NO. TIMING_PASS=NO. Owner YES required.
RUN_PROVENANCE: Exclusive PROGRAM until 2026-09-21 00:00 +07. Frozen U33 ff399e0b / TAPCDC eb99ac69 / H cf62102f / M4MIG f6a6091f untouched. dump-SOF WNS-fail DCP d3e26d3d kept.
OBSERVATION:
  FACT — post_route.dcp sha256 168359bcf460cc776c874e2f9bab43961ddbc089d8b0a3cec34605a66348d012
  FACT — uart_r2_u33obs_candidate.bit sha256 71b9198f512972bae75af04e406d26c17d7940ecadd324e5b5ffecaedcbf6762
  FACT — Design Timing Summary WNS +0.303 TNS 0 WHS +0.008 THS 0; "All user specified timing constraints are met"
  FACT — UNIQUE vs U33/TAPCDC/M4MIG
  FACT — not programmed; READY_TO_PROGRAM=NO; OWNER_YES_REQUIRED=YES
  FACT — TAPDUMP PASS_XSIM GOLD four-AND before=ffffffff after=0000ffff
  INFERENCE — CDC -from/-to closed the 2 ns related-clock OBS 2FF paths that -to-only could not
HYPOTHESES: Owner YES then dummy-open MUTE hop on this identity — NOT_TESTED
HOW_TRACE: -to-only XDC rejected → -from/-to re-impl MET → write_bitstream unique dir PROGRAM=NO. No overlay. No Pack24.
EVIDENCE_MATRIX: PASS_IMPLEMENTED BIT_OK. TIMING_CONSTRAINTS_MET post-route (not TIMING_PASS). PASS_XSIM TAPDUMP four-AND. SILICON_IDENTITY=NO. PACK_ABI=NO.
SUCCESS_VS_FAILURE: Route+bit succeeded. MUTE hop on silicon still OPEN. PACK_ABI unproven.
FIRST_DIVERGENCE: Previous WNS -1.507 was empty -from on datapath_only, not intra-clock Q* cone.
DECISIVE_TEST: timing_route Design Timing Summary 0 failing; bit SHA ≠ frozen identities.
ROOT_CAUSE_OR_UNKNOWN: XDC form (FACT). MUTE/historical MAG OPEN on product identity.
REUSABLE_DECISION_PROCEDURE: set_max_delay -datapath_only needs non-empty -from and -to. Do not program OBS without owner YES. Do not Pack24 on observe SRAM.
STRUCTURAL_GUARD: READY_TO_PROGRAM=NO. 96_bit unique dir. Ban overlay H/U33.
BLAST_RADIUS: build_u33obs bit+dcp. Frozen identities on disk. TAPCDC SRAM still current on board.
VERDICT_BY_LAYER: BIT_OK CANDIDATE. Not TIMING_PASS / PROGRAM_PASS / PACK_ABI / BOARD_PASS.
LESSON_TO_SHARE: SET-MAX-DELAY-DATAPATH-ONLY-NEEDS-FROM-AND-TO-20260920T115100Z
NEXT_DECISIVE_EXPERIMENT: Owner YES then program OBS (kill hw_server) dummy-open MUTE + GOLD DUMP four-AND. Do not Pack24. Do not overlay U33.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop until owner YES to program, or exclusive window ends. No PACK_ABI stamp.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
