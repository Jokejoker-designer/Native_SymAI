NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: G2-TWO-EFFECTS-20260922T133900Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: G2_TWO_EFFECTS_XSIM_CANDIDATE=SUPPORTED. One generation-2 command id produces two effect codes. Only the code that is not the primitive changes the next proposal. The evidence stays generation 2. The product goal is not complete. The board was not programmed.
RUN_PROVENANCE: New identity. primitive_executor_r1.sv and g2_observe_r1.sv were not edited. The executor emits only on product_done, so a second sample of the same id needed a hold.
OBSERVATION: FACT: before a command, a SUCCESS row returns FB_NO_BINDING. FACT: G2 slot 1 ref f2a071fe, command C001 primitive 1. FACT: code 1 on that same id does not enter FEM and the proposal stays 1. FACT: code 4 on that same id sets fem_feat 1 and the proposal becomes 0 while command_valid, primitive, and id stay. FACT: the later query is still ref f2a071fe.
HYPOTHESES: A second product_done would keep the same command id. It would allocate C002, so the hold samples the latched id instead. A SUCCESS row before any command would be admitted. Contradicted, result was FB_NO_BINDING.
HOW_TRACE: New hold module. Same G2 policy path. Two table rows for primitive 1. XSim. Hashed the passing log. Did not program.
EVIDENCE_MATRIX: Log SHA256 af36b339d6e4ff39ab26b15225f53c6b5d32c4fa61fbe7653ffa2670598f7dcb finish 9935 ns. Top SHA256 935bf68850c495542f2e38068e776aa9585f8875a10269078d2b4050bf5a1627. Hold SHA256 45893397cd82a7bc7aa2604fefa618e13bd1c115dca96683e84f99762ad2ee67. PASS_XSIM local only.
SUCCESS_VS_FAILURE: SUPPORTED on the first run.
FIRST_DIVERGENCE: NONE.
DECISIVE_TEST: One command id, two codes, one query before and after. Proposal moves only on the code that differs from the primitive.
ROOT_CAUSE_OR_UNKNOWN: Admission compares the effect code with the primitive and with the command_valid bit. The table is not read until a command has been latched.
REUSABLE_DECISION_PROCEDURE: A second observation of one command must reuse the latched id. A new decision_done is a new command.
STRUCTURAL_GUARD: Do not edit primitive_executor_r1.sv to add a second sample. Do not call the table a sensor. Do not program this identity to replay the table.
BLAST_RADIUS: g2_two_effects_r1 and the plan STATUS line. No bitstream.
VERDICT_BY_LAYER: PASS_XSIM local. Not BOARD. Not a sensed pin. Product goal open.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: An effect that is not a testbench table and not a host-chosen UART nibble. Simulation can still change the table, so this identity does not justify a program. Do not open DDR.
OWNER_AND_STOP_CONDITION: AGENT_D. The goal stays active.
HANDOFF_STATUS: COMPLETE
