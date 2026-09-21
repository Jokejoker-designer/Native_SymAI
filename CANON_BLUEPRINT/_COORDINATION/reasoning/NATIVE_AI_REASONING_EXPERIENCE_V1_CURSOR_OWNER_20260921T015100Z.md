NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: BENCHMARK-R1-CAUSAL-INGEST / 20260921T015100Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: FACT owner directed use of NATIVE_SYMAI_BENCHMARK_R1_CAUSAL zip 4bc37ffe and MASTER f422fff3. FACT MANIFEST 12/12. FACT package forbids overwriting fe256_gold.py / pack_abi24_gold.py / §32. FACT 10_pack24_r1_compare.py on PACK24_RUN1_QUERY_DUT.jsonl = FAIL 139 findings (schema, not invented flip=0). INFERENCE this package is the correct current candidate vs earlier causal R2 zip. PACK_ABI_24_24_PASS=NO.
RUN_PROVENANCE: zip D:\FPGA\NATIVE_SYMAI_BENCHMARK_R1_CAUSAL_20260921.zip; dest Native_SymAI CANON_BLUEPRINT/verification_r1 plus 32_ACCEPTANCE_LADDER_R1_CANDIDATE.md. Gold paths unmodified.
OBSERVATION: DUT jsonl has outcome/reason and int flip=1 / omit; R1 compare requires uart_token, four-AND fields, dest-complete, observation_window_complete, commit_count=0, G-04 lifecycle. Python `is True` rejects integer 1.
HYPOTHESES: H1 replace B gold with R1 expected json (REJECTED by package governance). H2 stamp PACK_ABI from UART 24/24 (REJECTED dest-complete NOT_RUN + compare FAIL).
HOW_TRACE: Hash zip/master; extract; MANIFEST check; read contract; run compare; copy verification_r1; keep native_ai_benchmark_r2 as prior snapshot.
EVIDENCE_MATRIX: hashes FACT; gold unmodified FACT; compare FAIL FACT; PACK_ABI=NO FACT.
SUCCESS_VS_FAILURE: SUCCESS ingest current candidate. FAILURE would be editing pack_abi24_gold.py to emit flip=0.
FIRST_DIVERGENCE: B --compare wants TSV flip=0 on reject; R1 wants explicit zero-COMMIT coverage and forbids synthesizing 0.
DECISIVE_TEST: python 10_pack24_r1_compare.py DUT.jsonl; git diff -- verification/fe256 verification/pack_abi24 empty of gold sources.
ROOT_CAUSE_OR_UNKNOWN: N/A ingest. Remaining PACK_ABI blocker is observation schema + dest-complete + B TSV 0 vs omit.
REUSABLE_DECISION_PROCEDURE: Owner-named zip supersedes prior candidate snapshot; keep both; never mutate frozen gold.
STRUCTURAL_GUARD: verification_r1 CANDIDATE; §32 original untouched; compare must not fill expected→observed.
BLAST_RADIUS: verification_r1, BENCHMARK_INDEX, 32_ACCEPTANCE_LADDER_R1_CANDIDATE.md, STATUS. Not C RTL. Not freeze DCPs.
VERDICT_BY_LAYER: PACKAGE hashes PASS. COMPARE FAIL_SCHEMA. GOLD_UNCHANGED. Not PACK_ABI / BOARD / PROGRAM / TIMING / FE256.
LESSON_TO_SHARE: R1-CAUSAL-NO-SYNTHESIZE-FLIP0-20260921T015100Z
NEXT_DECISIVE_EXPERIMENT: Emit R1-shaped DUT jsonl (tokens, four-AND, dest-complete, commit_count) without inventing 0. Do not rewrite B gold.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER ingest complete. Stop without programming or gold edits.
HANDOFF_STATUS: COMPLETE
