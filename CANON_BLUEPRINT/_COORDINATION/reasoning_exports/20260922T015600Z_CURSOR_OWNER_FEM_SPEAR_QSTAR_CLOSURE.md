REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-SPEAR-QSTAR-CLOSURE / 20260922T015600Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Closure of 8b632b4a found no bypass. FEM_SPEAR_QSTAR_SEMANTIC_CAUSAL_BOARD_CANDIDATE=SUPPORTED. Q* feature comes from rank-0, not from failure_total. Actions 0,1,0,1. Do not rebuild this bit. Next is ASTRA at the end of the path. BOARD_PASS=NO.
RUN_PROVENANCE: UART JSON on 8b632b4a. Synth top fem_spear_qstar. EOS HIGH. PROGRAM.DONE=NA. C RTL unedited. No reprogram this audit.
OBSERVATION: prop_start is prop_from_rank. feat_q is 2 only when rank0 is 0xB1. legal_mask tied to 8'h03. Four frames keep base 127/0 and FEM life 3 ft 2. ON2 raw matches ON1.
HYPOTHESES: H1 FACT no direct FEM-to-Q* feature. H2 FACT each frame waits for rank then prop_done. H3 FACT ASTRA is not yet on this path. H4 CONTRADICTED BOARD_PASS.
HOW_TRACE: Read the rank-to-feature block and rq_uart. Decode OFF1 and ON2 words.
EVIDENCE_MATRIX:
| claim | class | evidence |
| Action follows rank | FACT | four UART frames |
| legal_mask internal readback | NOT_READ | UART word is the tied constant |
| ASTRA decision | NOT_TESTED | mask is a fixture |
SUCCESS_VS_FAILURE: Success is no alternate cause for the action flip. Failure would be feat_flat tied to failure_total.
FIRST_DIVERGENCE: NONE.
DECISIVE_TEST: This audit.
ROOT_CAUSE_OR_UNKNOWN: N/A.
REUSABLE_DECISION_PROCEDURE: Freeze SPEAR-to-Q* only when the feature is a function of rank-0 and the frame is after both rank_done and prop_done.
STRUCTURAL_GUARD: Do not rebuild 8b632b4a. Do not let FEM write legal_mask. Do not stamp BOARD_PASS or ASTRA_PASS.
BLAST_RADIUS: Classification and next-task label.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE frozen SUPPORTED. BOARD_PASS=NO. PROGRAM_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. FEM_PERSIST_PASS=NO. PACK_ABI_24_24_PASS=NO. ASTRA_PASS=NO.
LESSON_TO_SHARE: FEM-SPEAR-QSTAR-CHAIN-FROZEN-20260922T015600Z
NEXT_DECISIVE_EXPERIMENT: New identity where ASTRA legality stays fixed while the action still flips with FEM influence.
OWNER_AND_STOP_CONDITION: Stop if the next design writes legal_mask from FEM.
HANDOFF_STATUS: COMPLETE
