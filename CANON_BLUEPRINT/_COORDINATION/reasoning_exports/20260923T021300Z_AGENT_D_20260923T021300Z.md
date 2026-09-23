NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: ALIAS_NEIGHBOR_VS_RESOLVED_EDGE / 20260923T021300Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: PASS_XSIM only. Two posting edges share dst 0x00020100 and differ in a fixture state byte. bounded_walk returns that dst once and last_count 2. It has no knowledge_state port. ANSWER was not emitted. proof_ref stayed 0.
RUN_PROVENANCE: New fixture and reader under arty_d/UART_R2/alias_neighbor_r1. Canon walker and directory RTL were not edited. G2 was not edited. No bitstream.
OBSERVATION: FACT — log sha256 2e84ea436dd631a55aa9cbd7917ba5e2051f0fa6a1eb3dcd7a2700b32bc42838 finish 225 ns. Walker end_id 00020100, last_count 2. Edge refs 00000020 and 00000040 came from the walker wire and the posting word in that same ROM. State bytes 11 and 22. FIXTURE_PACKING_NOT_CANON. KNOWLEDGE_STATE_ENUM_LOCKED=NO.
HYPOTHESES: A locked knowledge_state enum plus a proof_ref contract would let a later cut ask ASTRA to accept only one of these edges. That contract does not exist yet.
HOW_TRACE: Build one posting page with two entries, same neighbor, different edge words. Run the unchanged walker. Read both words with a fixture reader that has no status port.
EVIDENCE_MATRIX: Alias of end_id = FACT at PASS_XSIM. State byte meaning = NOT CANON. ANSWER = not emitted. Board = not involved.
SUCCESS_VS_FAILURE: The alias is visible. The product question is not answered.
FIRST_DIVERGENCE: last_count reports 2 while the public result is one neighbor id.
ROOT_CAUSE_OR_UNKNOWN: The hop walker follows first_neighbor and does not return the edge record.
REUSABLE_DECISION_PROCEDURE: If two records share a neighbor, do not treat end_id as the evidence. Do not assign the differing byte to VERIFIED until the enum is locked.
STRUCTURAL_GUARD: No ANSWER. No nonzero proof_ref. No G2 edit. No program. No edit of bounded_walk in this cut.
BLAST_RADIUS: The new fixture directory only. SRAM image e2d97151… unchanged. C RTL unchanged.
VERDICT_BY_LAYER: PASS_XSIM for the alias observation. ASTRA_PASS=NO. BOARD_PASS=NO. PROGRAM_PASS=NO.
LESSON_TO_SHARE: A posting count above 1 does not mean the walker exposed every edge.
NEXT_DECISIVE_EXPERIMENT: Do not emit ANSWER until knowledge_state values and the proof_ref dereference contract are locked.
OWNER_AND_STOP_CONDITION: AGENT_D. Product goal sentence 1 remains open.
HANDOFF_STATUS: COMPLETE
