NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-30M-8FC14F25-PACK24-R1 / 20260921T022400Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: FACT parent COMPLETE after GitHub 3f0bc4c/00f723a: silicon PROGRAMMED 8fc14f25 EOS HIGH; iso R-04 GOLD+QUERY 03065051 (6/0x50); Pack24 B-shaped DUT 6/24; R1 jsonl 090b7814 watch-rerun PACK_ABI24_R1_CANDIDATE 24/24. FACT 99823c92 hop json kept as U33OBS_QUERY_ISO_R04.json ae394b6b. FACT PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. Watch did not nạp/impl.
RUN_PROVENANCE: PROGRAM.txt 1ab55cbd… SHA 8fc14f25; program.log 34f8d593… EOS HIGH; ISO_R04_8FC14F25 9da6c2d8…; ISO_G04 00623302… 03000051; ISO_G04_R1_ORDER 3a6e1cfd… 03065451; R1 jsonl 090b7814…; freeze SHA256SUMS 998f19c4…; P0 close fb418579… still PACK_ABI=NO. Parent jsonl 5327480 @ 02:11:56Z. GitHub before this push 00f723a (R1 ingest only).
OBSERVATION: Tick3 COMPLETE publish was interrupted by benchmark ingest. Jsonl-idle would have missed PROGRAM 8fc14f25 and Pack24/R1 jsonl. Live ISO_R04.json was overwritten 08:26; GitHub filename must stay 99823c92 hop.
HYPOTHESES: H1 R1 24/24 authorizes PACK_ABI_24_24_PASS (REJECTED by comparator NOTE + P0 close + this watch). H2 GOLD handshake is dest generation readback (CONTRADICTED: rg_first page word). H3 leftover MAG is this-pack flip (CONTRADICTED: leftover flip null CLASS_A). H4 8fc14f25 hop is 03065551 (CONTRADICTED: that token is 99823c92).
HOW_TRACE: hash unique bits/PROGRAM/CAPTURE → copy unique names → watch python 10_pack24_r1_compare.py rc=0 → do not edit gold.py → publish.
EVIDENCE_MATRIX: PROGRAM.txt FACT; EOS HIGH FACT; UART tokens FACT; R1 compare PASS_R1_COMPARE watch-rerun; B 6/24 FAIL_COMPARE historical; dest hex NOT_RUN.
SUCCESS_VS_FAILURE: SUCCESS publish COMPLETE with two query SHAs unmixed. FAILURE historical PACK_ABI / dest hex / RKB.
FIRST_DIVERGENCE: Tick2 published file≠SRAM; later parent programmed the file SHA. Filename ISO_R04 must not follow the live overwrite.
DECISIVE_TEST: Get-FileHash PROGRAM.txt vs bit SHA; decode 03065051 vs 03065551; python 10_pack24_r1_compare.py; python pack_abi24_gold.py --compare still 6/24.
ROOT_CAUSE_OR_UNKNOWN: Unique-dir -force bitstream then later program of that SHA (FACT). R1 omit vs TSV 0 is contract split (FACT).
REUSABLE_DECISION_PROCEDURE: Every 30m hash unique SHA256.txt + PROGRAM.txt + newest CAPTURE even if jsonl idle. Never overwrite a published hop json when live host reuses the filename. Never stamp PACK_ABI from R1 CANDIDATE 24/24.
STRUCTURAL_GUARD: Unique ISO_R04_8FC14F25 + PROGRAM_99823C92.txt; gold.py hash-match 2986c354; comparator NOTE; GUARD D-PACK-ABI24-R1-AUTHORITY-FREEZE.
BLAST_RADIUS: Native_SymAI results/docs hashes. Unique prior dirs/bits intact. C RTL untouched. Freeze DCPs untouched.
VERDICT_BY_LAYER:
- PASS_BOARD program CANDIDATE 8fc14f25 EOS HIGH (PROGRAM_PASS=NO)
- PASS_BOARD R-04 GOLD four-AND + QUERY 03065051
- PASS_R1_COMPARE 24/24 watch-rerun (not PACK_ABI_24_24_PASS)
- FAIL_COMPARE historical B 6/24
- NOT_RUN dest hex UART / READBACK_ACTIVE_GENERATION_PASS / RUNTIME_KNOWLEDGE_BINDING_8_8_PASS
- Not PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS / TIMING_PASS / MIG_PASS / ASTRA_PASS / FE256_PASS
LESSON_TO_SHARE: GITHUB-AUDIT-KEEP-PUBLISHED-HOP-FILENAME-20260921T022400Z
NEXT_DECISIVE_EXPERIMENT: Next 30m; parent NEXT_MAIN_D_TASK readback+RKB. Do not reopen U33OBS. Stop on dừng theo dõi.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER. Stop overlay H/U33. Stop inventing flip=0. Stop stamping PACK_ABI. Loop until dừng theo dõi.
HANDOFF_STATUS: COMPLETE
