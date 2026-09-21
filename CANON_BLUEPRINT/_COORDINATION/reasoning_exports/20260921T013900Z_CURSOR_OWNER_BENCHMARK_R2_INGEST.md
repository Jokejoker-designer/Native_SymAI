NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: BENCHMARK-R2-INGEST / 20260921T013900Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: FACT zip f1c5f998… self-check PASS and SHA256SUMS 15/15. FACT R2 does not rewrite FE256 256 gold or Pack/ABI-24 gold. INFERENCE R2 is a suitable sibling layer because it keeps R1 immutable and adds L1 causal Pack→query binding. FACT ingest did not stamp PACK_ABI/BOARD/FE256/PROGRAM/TIMING/MIG/ASTRA/FINAL PASS.
RUN_PROVENANCE: zip D:\FPGA\NATIVE_AI_CAUSAL_ACCEPTANCE_BENCHMARK_R2_20260921.zip; MASTER af23ad6b…; validate_package.py PASS; dest Native_SymAI CANON_BLUEPRINT/verification/native_ai_benchmark_r2 plus NATIVE_AI mirror. fe256_gold.py and R1 archive files not edited.
OBSERVATION: MASTER.md is a concat of the zip docs (omits CSV body). R2 cases are 8+12+12 campaign specs, not 256 gold rows.
HYPOTHESES: H1 R2 replaces FE256 gold (REJECTED by 00_README/09_MIGRATION). H2 R2 weakens claim ceiling (REJECTED owner_stamp_rule). H3 ingest requires rewriting §32 (REJECTED; B-owned; pointer only).
HOW_TRACE: Hash zip; expand; validate_package.py; compare SHA256SUMS; read R1 00_README and §32; copy sibling layer; leave gold paths untouched.
EVIDENCE_MATRIX: self-check PASS FACT; gold files unmodified FACT; L1 blocking stated in package FACT; board PASS NOT_TESTED this ingest.
SUCCESS_VS_FAILURE: SUCCESS = sibling ingest with hashes. FAILURE would be editing fe256_gold.py or R1 archive.
FIRST_DIVERGENCE: R1 treats FE256 256/256 as primary semantic endpoint; R2 places that after proven runtime knowledge binding.
DECISIVE_TEST: git diff -- verification/fe256 verification/pack_abi24 _ARCHIVE/NATIVE_AI_FULL_EVIDENCE_FE256_BENCHMARK_R1 must be empty.
ROOT_CAUSE_OR_UNKNOWN: N/A for ingest. Project blocker remains Pack COMMIT not publishing query image (package mapping; not re-audited here).
REUSABLE_DECISION_PROCEDURE: New benchmark zip: hash, self-check, prove it does not mutate frozen gold, ingest as sibling, keep claim ceiling.
STRUCTURAL_GUARD: verification/BENCHMARK_INDEX.md; do not rewrite §32 without AGENT_B; never change fe256_gold.py to rescue DUT.
BLAST_RADIUS: verification/native_ai_benchmark_r2, BENCHMARK_INDEX, _ARCHIVE/NATIVE_AI_BENCHMARK_LAYERS.md, STATUS line. Not C RTL. Not freeze DCPs. Not unique OBS bits.
VERDICT_BY_LAYER: PACKAGE_SELF_CHECK PASS. GOLD_UNCHANGED. L1 NOT_RUN. PACK_ABI=NO. BOARD_PASS not claimed.
LESSON_TO_SHARE: BENCHMARK-SIBLING-NOT-GOLD-REPLACE-20260921T013900Z
NEXT_DECISIVE_EXPERIMENT: Owner/B decide whether to promote R2 L1 into §32 text. Do not run FE256 board on fixture-backed path.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER ingest complete. Stop without programming or weakening gold.
HANDOFF_STATUS: COMPLETE
