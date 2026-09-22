REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-SPEAR-SEMANTIC-CLOSURE / 20260922T011500Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Closure of 52b923a6 found no contradiction. FEM_SPEAR_SEMANTIC_CAUSAL_BOARD_CANDIDATE=SUPPORTED. Descriptors and query are localparams. Four SRNK frames match A>B, B>A, A>B, B>A with fixed bases. Next step is rank to a different final action. BOARD_PASS=NO.
RUN_PROVENANCE: UART JSON on identity 52b923a6. Bit rehashed. Prior bits 3ccd03f8 and 1db38691 still on disk. No reprogram. C RTL unedited.
OBSERVATION: SRNK arg uses only bit 0. Rank frame is emitted after rank_done. Delta 256 equals ft 2 shifted 7. No QARM and no DEST_POKE in the capture.
HYPOTHESES: H1 FACT no alternate descriptor writer. H2 FACT each rank frame matches its infl bit. H3 FACT this bit does not yet turn rank into an action. H4 CONTRADICTED BOARD_PASS.
HOW_TRACE: Read spear_fem_rank and srnk_uart. Decode SRNK words. Rehash three bit files.
EVIDENCE_MATRIX:
| claim | class | evidence |
| Rank order | FACT | four SRNK frames |
| Descriptor bytes on wire | NOT_READ | refs and bases match the localparams |
| Final action | NOT_TESTED | Q* is not fed by this rank |
SUCCESS_VS_FAILURE: Success is no contradiction on writer, invariance, and arm identity. Failure would be a second descriptor source or a rank that ignores infl.
FIRST_DIVERGENCE: NONE.
DECISIVE_TEST: This audit. No new silicon.
ROOT_CAUSE_OR_UNKNOWN: N/A.
REUSABLE_DECISION_PROCEDURE: Freeze a rank result only after the echo frame contains that arm's infl bit and the bases did not move.
STRUCTURAL_GUARD: Do not rerun 52b923a6 rank. Do not edit cand_desc or C RTL. Do not stamp BOARD_PASS.
BLAST_RADIUS: Classification and the next-task label.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE frozen SUPPORTED. BOARD_PASS=NO. PROGRAM_PASS=NO. FEM_PERSIST_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-SPEAR-SEMANTIC-RANK-FROZEN-20260922T011500Z
NEXT_DECISIVE_EXPERIMENT: New identity where rank-0 changes the action and influence-off restores it. ASTRA legality stays fixed.
OWNER_AND_STOP_CONDITION: Stop if the next design writes the expected action directly.
HANDOFF_STATUS: COMPLETE
