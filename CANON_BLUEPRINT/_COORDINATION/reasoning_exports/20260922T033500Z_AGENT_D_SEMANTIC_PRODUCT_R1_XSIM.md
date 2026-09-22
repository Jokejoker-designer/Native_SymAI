REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: SEMANTIC-PRODUCT-R1-XSIM / 20260922T033500Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: SEMANTIC_PRODUCTIZATION_XSIM_CANDIDATE=SUPPORTED. QueryRecord subject and active_generation change the fetched SPEAR descriptor through directory and posting. No bitstream. 44546b43 and 435bdc88 untouched.
RUN_PROVENANCE: semantic_runtime_xsim.log sha256 1f578505325fd2cd1faf667888a8fb44fe7894d87e2e1ccb6e15b3a06467c42b. Finish 6665 ns. exact_directory and posting_walk were not edited. desc address is edge_ref[7:4].
OBSERVATION: Q_A edge 0x20 desc A1 rank A1 command C001. Q_B edge 0x60 desc B1 rank B1 command C002. GEN_MISS same subject as Q_A, active generation 2, directory generation 1, edge still 0x20, fetch refused, no command. Q_A2 returns to A1 and issues C003.
HYPOTHESES: H1 REJECTED a query-id mux, because the generation miss keeps the posting edge and drops the descriptor. H2 FACT the descriptor word is mem[edge_ref index].
HOW_TRACE: Real dir_a.mem and post_a.mem. Descriptor image only at the posting edge indexes 2 and 6.
EVIDENCE_MATRIX:
| claim | class | evidence |
| query changes edge and descriptor | FACT | Q_A 0x20/A1 vs Q_B 0x60/B1 |
| generation gates the fetch | FACT | GEN_MISS gmatch=0 fetch=0 |
| sticky rank | CONTRADICTED | Q_A2 returns to A1 |
| board | NOT_TESTED | BITSTREAM=NOT_BUILT |
SUCCESS_VS_FAILURE: Four arms matched. nfail 0.
FIRST_DIVERGENCE: NONE
DECISIVE_TEST: Same subject, active_generation 2, posting edge present, descriptor not fetched.
ROOT_CAUSE_OR_UNKNOWN: N/A
REUSABLE_DECISION_PROCEDURE: A retrieval claim needs a generation miss that still shows the posting address and refuses the descriptor.
STRUCTURAL_GUARD: No board SHA before an independent audit. Theta, legal_mask, and the rank map stay substitutes. Do not stamp global PASS.
BLAST_RADIUS: New XSim only.
VERDICT_BY_LAYER: PASS_XSIM candidate for this batch. Global PASS stamps remain NO.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: Independent audit of this log. No bitstream before that.
OWNER_AND_STOP_CONDITION: Stop before a new SHA.
HANDOFF_STATUS: COMPLETE
