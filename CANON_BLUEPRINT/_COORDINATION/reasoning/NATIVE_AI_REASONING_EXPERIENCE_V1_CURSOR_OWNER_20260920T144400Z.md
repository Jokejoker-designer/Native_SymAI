NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-TICK75 / 20260920T144400Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: FACT parent COMPLETE restates XSim 24/24 + R-04 6/80 G-04 6/84 already in 4bb5176. FACT AGENT_D V1 20260920T144000Z and q_done-hang lesson were missing from GitHub. PACK_ABI_24_24_PASS=NO.
RUN_PROVENANCE: jsonl 4989627 mtime 2026-09-20T14:42:56Z; DUT.jsonl still 57a7b65d…; D json still 577f333d…; last GitHub 4bb5176; loop PID 24692. Watch did not xelab/Pack24/program/--compare.
OBSERVATION: Parent user-facing COMPLETE: first XSim hung on q_done; TB inline CRC finished 26165 ns. Same DUT hashes as tick74 publish.
HYPOTHESES: H1 new silicon COMPLETE (CONTRADICTED: PROGRAM=NO, same DUT SHA). H2 DUT hashes changed (CONTRADICTED).
HOW_TRACE: jsonl delta +20422; hashed DUT/D json vs 4bb5176; copied AGENT_D V1 + lesson only.
EVIDENCE_MATRIX: DUT SHA match FACT; AGENT_D V1 path FACT; PACK_ABI=NO FACT.
SUCCESS_VS_FAILURE: SUCCESS close V1 gap without re-running XSim.
FIRST_DIVERGENCE: 4bb5176 DUT/docs vs missing AGENT_D 144000Z export.
DECISIVE_TEST: Native_SymAI glob *144000Z* empty before copy.
ROOT_CAUSE_OR_UNKNOWN: Tick74 published DUT first; parent COMPLETE V1 landed after.
REUSABLE_DECISION_PROCEDURE: After parent COMPLETE, copy AGENT_D V1 named in the COMPLETE even when DUT SHA unchanged.
STRUCTURAL_GUARD: Watch never xelab/Pack24/program/--compare. PACK_ABI stays NO.
BLAST_RADIUS: Native_SymAI AGENT_D V1 + lesson. Unique bits untouched.
VERDICT_BY_LAYER: Prior PASS_XSIM. FAIL_COMPARE 18. Not PACK_ABI_24_24_PASS.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: Wait next parent COMPLETE. Do not invent reject flip=0.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER. Stop if user says dừng theo dõi.
HANDOFF_STATUS: COMPLETE
