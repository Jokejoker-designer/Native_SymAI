REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-RANK-TO-QSTAR-XSIM / 20260922T013100Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: PASS_XSIM at 9525 ns. FEM influence flips SPEAR rank and that rank0 id, not the influence bit, drives Q* greedy 0,1,0,1. legal_mask stays 8'h03. Bases stay 127 and 0. FEM state stays recovered. ASTRA engine is not in this sim. 52b923a6 was not rebuilt. BOARD_PASS=NO.
RUN_PROVENANCE: Owner locked the semantic rank candidate and asked for the decision path. New tree fem_rank_action. spear_rank.v and qstar_select.v unedited. spear_fem_rank.sv reused, not edited.
OBSERVATION: OFF rank 0xA1 feat0 0 greedy 0. ON rank 0xB1 feat0 2 greedy 1 q_sel 2. Repeated. Delta 256 only on the ON arms.
HYPOTHESES: H1 FACT the action follows rank0 through Q*. H2 FACT legality did not move. H3 NOT_TESTED on silicon. H4 CONTRADICTED calling this an ASTRA result.
HOW_TRACE: xvlog xelab xsim exit 0.
EVIDENCE_MATRIX:
| claim | class | evidence |
| Action follows rank | FACT | four ARM lines |
| ASTRA engine | NOT_IN_THIS_XSIM | legal_mask is a constant |
| 52b923a6 rebuilt | CONTRADICTED | new tree only |
SUCCESS_VS_FAILURE: Success is action 0,1,0,1 with stable bases and mask. Failure would be a feat taken from fem_infl_en directly.
FIRST_DIVERGENCE: NONE.
DECISIVE_TEST: tb_rank_to_qstar.sv
ROOT_CAUSE_OR_UNKNOWN: N/A
REUSABLE_DECISION_PROCEDURE: Feed Q* from rank0 id only. Keep legal_mask constant. Do not connect fem_infl_en to the action mux.
STRUCTURAL_GUARD: Do not stamp ASTRA_PASS or BOARD_PASS. Do not rebuild 52b923a6. Do not edit C RTL.
BLAST_RADIUS: fem_rank_action sim only.
VERDICT_BY_LAYER: PASS_XSIM. ASTRA_ENGINE=NOT_IN_THIS_XSIM. BOARD_PASS=NO. PROGRAM_PASS=NO. FEM_PERSIST_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-RANK-TO-QSTAR-PASS-XSIM-20260922T013100Z
NEXT_DECISIVE_EXPERIMENT: A live ASTRA legality block, or a bitstream of this chain, only if the owner asks. Not a rank-only repeat.
OWNER_AND_STOP_CONDITION: Stop if the action is wired from fem_infl_en instead of rank0.
HANDOFF_STATUS: COMPLETE
