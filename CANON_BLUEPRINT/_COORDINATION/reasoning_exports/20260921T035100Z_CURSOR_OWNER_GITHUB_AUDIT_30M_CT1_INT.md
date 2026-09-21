NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-30M-CT1-INT-BIT-SMOKE / 20260921T035100Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: FACT jsonl idle 5603516 vs 3f5d364. FACT unique build_ct1 BIT_OK 8bfd993d WNS +0.556 PROGRAM=NO then parent PROGRAMMED EOS HIGH PROGRAM_PASS=NO. FACT integrated XSim CT1-01..05 PASS_XSIM json a3261393 finish 6047135 ns. FACT UART smoke 01..04 tokens CT1-05 NOT_RUN. FACT query PROGRAM.txt file still 8fc14f25. Watch did not nạp/impl. PACK_ABI_24_24_PASS=NO. CT1_BOARD_PASS=NO.
RUN_PROVENANCE: SHA256.txt/bit 8bfd993d; PROGRAM.txt e920490d; UART json b3a8f053; INT OBS a3261393; log 9a5fb867; BUILD STOP_BEFORE_PROGRAM then later nạp of quoted SHA. Unique vs 8fc14f25 dirs.
OBSERVATION: Jsonl-idle missed BIT_OK/PROGRAM/UART. Unique dir did not overwrite query bit file.
HYPOTHESES: H1 no COMPLETE if jsonl frozen (CONTRADICTED). H2 UART 01..04 is CT1_BOARD_PASS (REJECTED; 05 NOT_RUN + self stamp NO). H3 PROGRAM=YES isolated grant covers this bit automatically (owner later quoted 8bfd993d). H4 8fc14f25 still SRAM (CONTRADICTED CT1 PROGRAM.txt).
HOW_TRACE: hash unique SHA256.txt + bit + PROGRAM.txt + CAPTURE even though jsonl idle; grep INTEGRATED PASS_XSIM; do not copy TSV; do not nạp.
EVIDENCE_MATRIX: bit=PROGRAM.txt FACT; EOS HIGH FACT; XSim PASS_XSIM FACT; UART tokens FACT; CT1_BOARD_PASS=NO FACT.
SUCCESS_VS_FAILURE: SUCCESS publish unique CT1 identity. FAILURE ABI/board 5/5/T1 occupancy.
FIRST_DIVERGENCE: Isolated UI-BRAM 4885 ns vs integrated top 6047135 ns; then file BIT_OK vs later SRAM 8bfd993d vs leftover query PROGRAM.txt file.
DECISIVE_TEST: Get-FileHash bit vs CT1 PROGRAM.txt vs 8fc14f25 query PROGRAM.txt; decode 03000051/03010051; grep finish 6047135.
ROOT_CAUSE_OR_UNKNOWN: N/A publish. Product RKB still NOT_RUN on this smoke.
REUSABLE_DECISION_PROCEDURE: After jsonl freeze hash unique build SHA256.txt AND newest PROGRAM.txt. Unique dir must not overlay query identities. UART 4/5 with 05 NOT_RUN is not CT1_BOARD_PASS.
STRUCTURAL_GUARD: unique build_ct1; keep U33OBS_QUERY PROGRAM.txt; gold.py untouched; no .bit push; watch never programs.
BLAST_RADIUS: Native_SymAI results/ct1 + build hashes. Query unique dirs intact. C RTL untouched. Freeze DCPs untouched.
VERDICT_BY_LAYER: PASS_XSIM integrated. BIT_OK unique. PASS_BOARD program CANDIDATE 8bfd993d EOS HIGH. UART smoke CANDIDATE 01..04. Not CT1_BOARD_PASS / PROGRAM_PASS / PACK_ABI / TIMING_PASS / MIG_PASS / RKB_8_8.
LESSON_TO_SHARE: NONE
NEXT_DECISIVE_EXPERIMENT: Next 30m. Do not reopen U33OBS. Stop on dừng theo dõi.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER. No program. No invent CT1_BOARD_PASS.
HANDOFF_STATUS: COMPLETE
