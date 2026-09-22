NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: ONE-QSTAR-THEN-EXPERIENCE-20260922T124200Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: ONE_QSTAR_THEN_EXPERIENCE_XSIM_CANDIDATE=SUPPORTED for u_q only. pack_vis still contains an unconnected Q*. The product goal is not complete.
RUN_PROVENANCE: Goal continuation after CUT6. The named gap was two Q* instances. DDR stayed closed.
OBSERVATION: FACT: decision_done before a descriptor did not emit a command. FACT: generation 1 ref 025bb7b4 produced prop_done action 0 and command C001 from that proposal. FACT: effect 3 then produced a later prop_done action 1 on the same instance. FACT: the first log of this wrapper, before the record gate, was not hashed as the claim.
HYPOTHESES: A feature map that ignores the retrieved ref would still issue the same command. The gated decision and the ref-based feature were added so a missing descriptor cannot issue. The TB shows command_valid 0 before the record.
HOW_TRACE: New module. One qstar_select drives action_product_r1. FEM ingress uses that command_valid. Ran XSim after the gate. Hashed the passing log.
EVIDENCE_MATRIX: Log SHA256 0f4bc81cbf419fdb24f82536c19a2af304d7ea45b6eed66c8d2ae3d153aadf8d finish 8205 ns. Wrapper SHA256 8e1466a4ece3fdf9bb5db59fbaf8ae34e6ca99e860dc296110c86a55346953bd. PASS_XSIM local only.
SUCCESS_VS_FAILURE: SUPPORTED after the descriptor gate. An earlier unhashed run issued a command from fem_feat alone and was not kept as the claim.
FIRST_DIVERGENCE: The first feature equation did not read the retrieved ref.
ROOT_CAUSE_OR_UNKNOWN: feat_flat was only a function of fem_feat. It now is zero without a descriptor, feature 0 or 2 from the ref, and feature 1 after fem_feat.
REUSABLE_DECISION_PROCEDURE: The instance that emits the command must be the instance that later changes. Do not count a second hidden Q* as that path.
STRUCTURAL_GUARD: Do not connect pack_vis command outputs into this tail. Do not edit qstar_select.v.
BLAST_RADIUS: one_qstar_r1 and the plan STATUS line. No bitstream.
VERDICT_BY_LAYER: PASS_XSIM local. Not FEM_PERSIST_PASS. Not MIG_PASS. Not BOARD. Product goal open because the effect is still a constant and pack_vis still hides another Q*.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: Replace effect constant 3 with a readback that can fail while command_valid stays 1. Do not open DDR for that.
OWNER_AND_STOP_CONDITION: AGENT_D. Do not mark the product goal complete.
HANDOFF_STATUS: COMPLETE
