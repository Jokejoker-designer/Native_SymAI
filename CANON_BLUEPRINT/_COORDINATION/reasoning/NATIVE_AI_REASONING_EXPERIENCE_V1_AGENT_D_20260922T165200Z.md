NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: G2-TWO-PRIOR-20260922T165200Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: G2_TWO_PRIOR_XSIM_CANDIDATE=SUPPORTED. The same command shape ends at sense 2 or sense 4 depending on a prior latched outside the DUT. The product goal is not complete. The board was not programmed.
RUN_PROVENANCE: New plant and scheduler. g2_proto_r1.sv was not edited. NCG was not inserted. world_init is sampled only in reset.
OBSERVATION: FACT: both trials end at ref f2a071fe, command C001 primitive 1, drive 1, proposal 0, fem_feat 1. FACT: prior 1 ends at sense 2. FACT: prior 3 ends at sense 4. FACT: before the act, sense still equalled the prior while fem_feat was 0.
HYPOTHESES: One primitive would force one sense code. The two end codes differ while the command word does not. A resting value of 3 would be admitted if it were sampled under the current rule. The second trial does not sample it.
HOW_TRACE: Plant adds one when drive changes. Two resets. Direct pack feed, not UART. XSim. Hashed the log. Did not program.
EVIDENCE_MATRIX: Log SHA256 b3246a5b39d516884b85d3c0bd49ebd237eb252a996aea15b5736390ebd1b025 finish 10175 ns. Plant SHA256 d631c6be47a4597e8c6a698148786bfe13246103297cd69869b279c7b08dee7c. PASS_XSIM local only.
SUCCESS_VS_FAILURE: SUPPORTED on the first run.
FIRST_DIVERGENCE: NONE.
DECISIVE_TEST: Hold the command, the ref, and the drive. Change only the reset prior. The final sense changes.
ROOT_CAUSE_OR_UNKNOWN: Sense follows an outside register. The register's next value is its own prior plus one, not a copy of drive.
REUSABLE_DECISION_PROCEDURE: A single scripted end code does not show that the command failed to determine the observation. Two priors do.
STRUCTURAL_GUARD: Do not call prior-plus-one a pin. Do not program it. Do not sample a resting value that the admit rule would accept as an effect.
BLAST_RADIUS: g2_two_prior_r1 and the plan STATUS line. No bitstream.
VERDICT_BY_LAYER: PASS_XSIM local. Not BOARD. The law is still a counter. Product goal open.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: A package pin whose value is not prior-plus-one. This result does not justify programming.
OWNER_AND_STOP_CONDITION: AGENT_D. The goal stays active.
HANDOFF_STATUS: COMPLETE
