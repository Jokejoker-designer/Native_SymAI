REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-QSTAR-ABAB-FREEZE / 20260922T004000Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Owner closed the A/B/A/B Q* mux. FEM_QSTAR_CAUSAL_ABAB_BOARD_CANDIDATE=SUPPORTED on 3ccd03f8. CONTRADICTION_FOUND=NO. Scoped claim is recovered FEM changing a bounded Q* greedy decision on silicon. Do not re-test 0,1,0,1. Next test is semantic context plus a fixed real candidate set. 3ccd03f8 cannot run it because SPEAR is idle. PASS ceilings unchanged.
RUN_PROVENANCE: Owner acceptance of CLOSURE_AUDIT_20260922T003600Z. Bit 3ccd03f8. JSON 302c7bd4. No new bitstream. No C edit. No reprogram.
OBSERVATION: Freeze file written. Next spec FEM_SPEAR_SEMANTIC_CANDIDATE_SPEC.md. Reserved tree fem_spear_semantic. SHA NOT_ASSIGNED.
HYPOTHESES: H1 FACT the mux candidate is closed by owner plus the prior audit. H2 FACT 3ccd03f8 has no live SPEAR candidate path. H3 DESIGN the next discriminator is rank-0 ref, not greedy 0/1.
HOW_TRACE: Write freeze and next spec. Update AGENTS next task. No silicon.
EVIDENCE_MATRIX:
| claim | class | evidence |
| Mux candidate supported | FACT | owner acceptance and closure audit |
| Semantic candidate test | NOT_RUN | spec only |
| PASS stamps | CONTRADICTED | ceilings remain NO |
SUCCESS_VS_FAILURE: Success is the freeze and a next test that does not repeat the mux. Failure would be another 0,1,0,1 run.
FIRST_DIVERGENCE: NONE.
DECISIVE_TEST: Not this turn.
ROOT_CAUSE_OR_UNKNOWN: N/A.
REUSABLE_DECISION_PROCEDURE: After A2 closure, stop the minimal discriminator and move the variable onto a fixed real candidate ranking.
STRUCTURAL_GUARD: Do not rebuild 3ccd03f8 for the same greedy sequence. Do not edit C. Do not put experience inside cand_desc.
BLAST_RADIUS: Roadmap label and docs. Bits on disk unchanged.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE frozen as SUPPORTED. BOARD_PASS=NO. PROGRAM_PASS=NO. FEM_PERSIST_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-QSTAR-ABAB-FROZEN-NEXT-SEMANTIC-CANDIDATE-20260922T004000Z
NEXT_DECISIVE_EXPERIMENT: Implement fem_spear_semantic with two fixed descriptors and rank-0 A/B/A/B. New SHA required before program.
OWNER_AND_STOP_CONDITION: Stop if the next build repeats the Q* greedy mux or edits C RTL.
HANDOFF_STATUS: COMPLETE
