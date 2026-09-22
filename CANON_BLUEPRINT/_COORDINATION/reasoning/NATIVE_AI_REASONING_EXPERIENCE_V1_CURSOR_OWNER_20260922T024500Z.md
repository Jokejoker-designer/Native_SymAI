REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: ACTION-PRODUCT-R1-AUDIT / 20260922T024500Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Independent audit of the productization cut only. ACTION_PRODUCTIZATION_XSIM_CANDIDATE=SUPPORTED. CONTRADICTION_FOUND=NO. RECOMMEND_BOARD_BUILD=NO. 435bdc88 not re-audited and not rebuilt.
RUN_PROVENANCE: Log sha256 74688ff679bb4dda1eca6a6c9305d34cf54d9bc3e5951c8271d80490531e815b finish 18605 ns. No UART. No force. No bitstream.
OBSERVATION: intent_primitive is assigned from q_proposed_live. Lookup hit is CRC match and MASK[primitive]. capability_id is the one installed id 0xC1 on hit. command_valid is set only when verdict is BOUND and hit. VETO clears command_id. Primitive 2 uses the same lookup function and a second precheck instance and returns B4.
HYPOTHESES: H1 REJECTED arm-id selects C1 or the command. H2 REJECTED veto leaks C003. H3 FACT command ids C001-C004 are a counter under prefix C000, not the proposal sequence 0,0,1,0.
HOW_TRACE: Read action_product_r1.sv, the TB drivers, and the five epoch lines. Did not reopen the frozen FEM-SPEAR-Q* chain.
EVIDENCE_MATRIX:
| claim | class | evidence |
| intent source | FACT | intent_primitive <= proposed_action; proposed_action is q_proposed_live |
| lookup | FACT | lookup_ok = crc match and MASK[prim] |
| command gate | FACT | command_valid only in BOUND and hit branch |
| probe | FACT | lookup_ok(3'd2) into second astra_action_precheck_v1 |
SUCCESS_VS_FAILURE: No alternate driver found for the new cut.
FIRST_DIVERGENCE: NONE
DECISIVE_TEST: ON1 command primitive 1 versus VETO command_id 0 with the same proposal 1.
ROOT_CAUSE_OR_UNKNOWN: N/A
REUSABLE_DECISION_PROCEDURE: Treat a one-entry id as a lookup only when hit/miss is a function of the live primitive. A probe must call that same function.
STRUCTURAL_GUARD: Do not build a board bit from this audit. Fixed query, theta, legal_mask, and SPEAR descriptors stay synthetic.
BLAST_RADIUS: Audit verdict only.
VERDICT_BY_LAYER: PASS_XSIM candidate remains the ceiling.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: None inside this audit.
OWNER_AND_STOP_CONDITION: Stop. No global PASS. No bitstream.
HANDOFF_STATUS: COMPLETE
