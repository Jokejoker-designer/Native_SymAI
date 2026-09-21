NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-30M-CT1-PASS-XSIM / 20260921T032000Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: FACT parent COMPLETE vs a4d46f6: isolated CT1-01..05 PASS_XSIM json 372ea910 log 3d076365 finish 4885 ns. FACT first FAIL json 5f875a49 kept. FACT PROGRAM.txt still 8fc14f25 PROGRAM_PASS=NO. FACT owner PROGRAM=YES 09:52 is grant not nạp. Watch did not xelab/program. PACK_ABI_24_24_PASS=NO.
RUN_PROVENANCE: jsonl 5603516 @ 03:06:26Z. GitHub a4d46f6. AGENT_D V1 025900Z. dest_root_cache bc2b7cd2. Grant e0f3aca3. RKB-08 json 18456f16 unchanged.
OBSERVATION: Live CT1_OBS overwritten from FAIL 01/03-only to PASS all-1. Unique-name siblings required. No hw program.
HYPOTHESES: H1 PROGRAM=YES means PROGRAM_PASS (REJECTED). H2 PASS_XSIM is board CT1 (REJECTED; UI-BRAM). H3 8fc14f25 contains dest_root_cache (CONTRADICTED; no CT1 bit).
HOW_TRACE: hash live vs GitHub FAIL → grep PASS_XSIM in log → copy unique PASS names → do not nạp.
EVIDENCE_MATRIX: PASS_XSIM isolated FACT; FAIL first DUT FACT; SRAM 8fc14f25 FACT; grant FACT; bitstream NOT_RUN.
SUCCESS_VS_FAILURE: SUCCESS publish PASS without destroying FAIL. FAILURE would be overwrite 5f875a49 or stamp PROGRAM_PASS.
FIRST_DIVERGENCE: SID in dest beat lane1 vs lane0 CRC.
DECISIVE_TEST: Get-FileHash CT1_OBS FAIL vs PASS; Select-String PASS_XSIM.
ROOT_CAUSE_OR_UNKNOWN: Isolated DUT lane decode (FACT). Product silicon still missing directory install (FACT RKB-08).
REUSABLE_DECISION_PROCEDURE: Owner PROGRAM=YES is not a bit. Keep first FAIL json when live host reuses CT1_OBS.json. Isolated UI-BRAM ≠ board.
STRUCTURAL_GUARD: unique PASS/FAIL filenames; grant file PROGRAM_PASS=NO; no program of 8fc14f25.
BLAST_RADIUS: Native_SymAI verification_r1/ct1 + results hashes. No C RTL. No SRAM.
VERDICT_BY_LAYER: PASS_XSIM isolated CT1-01..05. NOT_RUN bitstream/board. NO PROGRAM_PASS / BOARD_PASS / PACK_ABI / RKB_8_8 / CT1_BOARD_PASS.
LESSON_TO_SHARE: OWNER-PROGRAM-YES-IS-NOT-A-BIT-20260921T025900Z
NEXT_DECISIVE_EXPERIMENT: Next 30m. Unique CT1 bit only after audit. Stop on dừng theo dõi.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER. No xelab. No program. No invent PROGRAM_PASS.
HANDOFF_STATUS: COMPLETE
