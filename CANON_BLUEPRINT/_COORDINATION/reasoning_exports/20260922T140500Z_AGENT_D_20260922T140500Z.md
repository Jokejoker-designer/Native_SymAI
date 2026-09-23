NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: G2-EXT-PLANT-20260922T140500Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: G2_EXT_PLANT_XSIM_CANDIDATE=SUPPORTED. The proposal stays while the adder moves and the captured sample is still 1. The proposal changes only after the outside plant reads 2, while drive stays 1. The product goal is not complete. The board was not programmed.
RUN_PROVENANCE: New plant and testbench. g2_pin_r1.sv was not edited. The testbench does not assign sense_pin.
OBSERVATION: FACT: after the add, drive is 1 and sense is still 1. FACT: the sample of that sense is code 1, fem_feat stays 0, and the proposal stays 1. FACT: the next sample is code 2 with drive still 1, fem_feat becomes 1, and the proposal becomes 0. FACT: command id stays C001. FACT: the query stays ref f2a071fe status 0x04.
HYPOTHESES: The plant would update on the same edge as the adder, so the two could not be separated. The first run failed because the sampler waited an extra edge and captured 2. Sampling on the edge that first sees drive 1 captured code 1. A short from drive to sense would keep them equal after the reaction. Contradicted: drive stayed 1 while sense became 2.
HOW_TRACE: Plant module outside the DUT. Initial state 1. Add 1 one cycle after drive becomes non-zero. XSim. First log missed the split. Second log shows it. Hashed that log. Did not program. Updated the plan NEXT_CUT away from DDR.
EVIDENCE_MATRIX: Log SHA256 bb9d388d806fafaea0d019bfa37efadca56b60cc1d7a06b670cd2eefbc2e8257 finish 9865 ns. Plant SHA256 15f2ccff40a8f91bd36b688a63f7d5ad35b2cd9342147f431488c3b5f5686336. PASS_XSIM local only.
SUCCESS_VS_FAILURE: First run FAIL nfail=2 because the sample captured the already-updated plant. Second run SUPPORTED.
FIRST_DIVERGENCE: The first sampler waited a full cycle before arming sample_req, so the plant had already added.
DECISIVE_TEST: Drive 1 with captured code 1 does not move the proposal. Code 2 with drive still 1 does. The evidence ref does not move.
ROOT_CAUSE_OR_UNKNOWN: The observer copies sense_pin. The adder only updates drive_pin. The outside register is what sense_pin follows.
REUSABLE_DECISION_PROCEDURE: Sample on the edge that first exposes the new drive, before the outside plant's next update is visible to the sampler.
STRUCTURAL_GUARD: Do not assign sense_pin from drive_pin. Do not call this counter a pin. Do not edit g2_pin_r1.sv to absorb the plant. Do not open DDR for this question.
BLAST_RADIUS: g2_ext_plant_r1 and the plan STATUS and NEXT_CUT lines. No bitstream.
VERDICT_BY_LAYER: PASS_XSIM local. Not BOARD. Not a physical effect. Product goal open. FEM still does not record the real primitive.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: A package pin whose value is not this counter, on one top that can report the ref, the command id, the pin, and the next proposal without testbench strobes. Do not program this counter.
OWNER_AND_STOP_CONDITION: AGENT_D. The goal stays active.
HANDOFF_STATUS: COMPLETE
