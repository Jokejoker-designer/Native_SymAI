REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-SPEAR-SEMANTIC-XSIM / 20260922T004900Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: PASS_XSIM rank A>B, B>A, A>B, B>A at 3735 ns. Two fixed semantic descriptors. Base scores 127 and 0 on every arm. fem_delta 0 or 256 on the lower base only. FEM state held recovered. Q* and persist RTL not edited. No bitstream. BOARD_PASS=NO.
RUN_PROVENANCE: Owner allowed XSim after the invariant lock. Log sha256 52c9eff581976a97858ef3a245ba7af59de6c3f0259e6a0cb18d612191bb0126. spear_rank.v unedited. Descriptors from spear_ref packer.
OBSERVATION: inv=0 k_invalid=0. Relation match is the only semantic difference. m_fem=0 both. Influence off keeps A first. Influence on adds 256 to B and B ranks first.
HYPOTHESES: H1 FACT the order flip is the D delta, not a descriptor edit. H2 FACT base scores did not move. H3 NOT_TESTED on silicon.
HOW_TRACE: xvlog/xelab/xsim exit 0.
EVIDENCE_MATRIX:
| claim | class | evidence |
| Order flip four arms | FACT | log ARM lines |
| Descriptors invariant | FACT | fed_a/fed_b checks passed |
| BOARD_PASS | CONTRADICTED | not run |
SUCCESS_VS_FAILURE: Success is the four rank orders with stable bases. Failure would be a descriptor change or a base-score change.
FIRST_DIVERGENCE: NONE.
DECISIVE_TEST: tb_spear_fem_rank.sv
ROOT_CAUSE_OR_UNKNOWN: N/A
REUSABLE_DECISION_PROCEDURE: Keep descriptors and base scores fixed. Apply fem_delta only to the lower base when influence is on. Log id, base, delta, final, rank, FEM state.
STRUCTURAL_GUARD: Do not edit spear_rank.v. Do not put FEM into cand_desc. Do not rebuild 3ccd03f8 for this test.
BLAST_RADIUS: fem_spear_semantic sim only.
VERDICT_BY_LAYER: PASS_XSIM. PASS_BOARD=NOT_RUN. BOARD_PASS=NO. PROGRAM_PASS=NO. FEM_PERSIST_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-SPEAR-SEMANTIC-PASS-XSIM-20260922T004900Z
NEXT_DECISIVE_EXPERIMENT: A new bitstream only if the owner asks. Not a Q* mux repeat.
OWNER_AND_STOP_CONDITION: Stop if cand_desc is edited to force the winner.
HANDOFF_STATUS: COMPLETE
