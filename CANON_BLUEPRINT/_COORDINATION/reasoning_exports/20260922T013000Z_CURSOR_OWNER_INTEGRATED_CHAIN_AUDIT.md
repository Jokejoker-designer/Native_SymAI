REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: INTEGRATED-CHAIN-AUDIT / 20260922T013000Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Independent wiring audit of the behavioral chain. INTEGRATED_CAUSAL_XSIM_CANDIDATE=SUPPORTED. CONTRADICTION_FOUND=NO. Not a board build.
RUN_PROVENANCE: chain_xsim.log sha256 e112783e8c350633bb8111e13462e894746bc55091cdf6fb895eac52e59ed0ea. Finish 18555 ns. C RTL not edited. No force, no UART, no bitstream.
OBSERVATION: failure_total drives spear_fem_rank.fem_ft. Delta uses infl_r and ft_r only. rank0_id selects feat 0 or 2. q_proposed is the precheck input. final_w is the precheck output. OFF2 matched OFF1. VETO kept proposal 1 and final FF. PRE with influence on and ft 0 stayed dB 0 action 0.
HYPOTHESES: H1 FACT no TB driver for the seven downstream values. H2 FACT life_r and comp_r are latched and unread, so they are not an alternate delta path. H3 CONTRADICTED arm-id, sticky latch, and influence-alone delta.
HOW_TRACE: Read DUT ports, delta expression, feature assignment, precheck port map, TB arm task, and the five epoch lines.
EVIDENCE_MATRIX:
| claim | class | evidence |
| downstream injection | NOT_FOUND | TB assigns only infl, safety, run_start, and FEM stimulus |
| influence alone causes dB 256 | CONTRADICTED | PRE infl=1 ft=0 dB=0 |
| sticky rank | CONTRADICTED | OFF2 returned to OFF1 after ON1 |
| ASTRA gates final | FACT | VETO proposal 1 verdict B2 final FF |
SUCCESS_VS_FAILURE: No alternate explanation displaced the three live edges.
FIRST_DIVERGENCE: NONE
DECISIVE_TEST: PRE versus ON1, OFF2 versus OFF1, VETO versus ON1.
ROOT_CAUSE_OR_UNKNOWN: N/A
REUSABLE_DECISION_PROCEDURE: Treat a snapshot copy of the same net as non-independent. Use the consumer output, here final_w, as the gate evidence.
STRUCTURAL_GUARD: Do not build a bitstream from this audit. Synthetic substitutes stay labeled.
BLAST_RADIUS: Audit only. No RTL edit.
VERDICT_BY_LAYER: PASS_XSIM connectivity candidate remains the ceiling.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: None inside this audit. Board only if the owner requests a new identity.
OWNER_AND_STOP_CONDITION: Stop on any global PASS stamp.
HANDOFF_STATUS: COMPLETE
