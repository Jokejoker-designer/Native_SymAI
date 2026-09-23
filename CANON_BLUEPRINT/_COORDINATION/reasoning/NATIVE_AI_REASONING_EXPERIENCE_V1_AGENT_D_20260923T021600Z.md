NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: PROOF_REF_CONTRACT_CANDIDATE / 20260923T021600Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: A candidate checker accepts a proof_ref only when it names a support body bound to txn_id and generation, and rejects a proof_ref that is an edge address. ANSWER_ALLOWED stays NO because knowledge_state has no locked numeric enum.
RUN_PROVENANCE: Host checker arty_d/UART_R2/proof_ref_contract_r1/proof_ref_contract_r1.py. No RTL. No Canon edit. No pack edit. No program.
OBSERVATION: FACT — eight cases printed, including SHAPE_OK_PROOF_BODY with ANSWER_ALLOWED=NO. FACT — §2.4.4 writes knowledge_state as CANDIDATE / VERIFIED / … and gives no opcode.
HYPOTHESES: NONE. The checker is not a proposal to number VERIFIED.
HOW_TRACE: Encode the architecture rule as refusals. Run them. Leave answer authority closed.
EVIDENCE_MATRIX: Shape refusals = PASS_CHECK on the host. Canon layout = still unlocked. Enum = UNKNOWN. Board = not used.
SUCCESS_VS_FAILURE: The alias between proof_ref and an edge address is now a failing check. The product answer is still absent.
FIRST_DIVERGENCE: A filled proof shape is not permission to emit status 0x01.
ROOT_CAUSE_OR_UNKNOWN: Epistemic state has names and no numeric encoding, so a byte cannot yet be treated as VERIFIED.
REUSABLE_DECISION_PROCEDURE: Separate reference shape from epistemic permission. A body can be well-formed and still not be an answer.
STRUCTURAL_GUARD: Do not copy this candidate into Canon. Do not assign 0x11 or 0x22 to VERIFIED. Do not program.
BLAST_RADIUS: One new Python checker and the goal-plan note. Image e2d97151… unchanged.
VERDICT_BY_LAYER: PASS_CHECK for the candidate shape. ASTRA_PASS=NO. BOARD_PASS=NO. PROGRAM_PASS=NO.
LESSON_TO_SHARE: proof_ref shape and ANSWER permission are different gates.
NEXT_DECISIVE_EXPERIMENT: A locked knowledge_state enum from the Canon owner. Until then, do not emit ANSWER.
OWNER_AND_STOP_CONDITION: AGENT_D. Sentence 1 of the product goal remains open.
HANDOFF_STATUS: COMPLETE
