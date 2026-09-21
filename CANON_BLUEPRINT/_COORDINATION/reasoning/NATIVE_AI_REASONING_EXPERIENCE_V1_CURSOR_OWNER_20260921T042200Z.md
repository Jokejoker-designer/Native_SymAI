NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-30M-CT1-RKB-PACK24 / 20260921T042200Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Tick 8. Jsonl grew to 5852278. Same SRAM 8bfd993d (PROGRAM.txt e920490d). COMPLETE: RKB UART TAP/no-CLEAR CANDIDATE; leftover MAG CLASS_A; V04 GOLD n=4; Pack24 RUN1 6 GOLD/17 NAK/1 MAG; watch gold.py 2/24. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. CT1_BOARD_PASS=NO. RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.
RUN_PROVENANCE: Watch hashed unique SHA256.txt + PROGRAM.txt + UART/RKB/Pack24 json even though PROGRAM.txt unchanged. Parent 31dc87bc. Unique vs 8fc14f25 files. gold.py 2986c354 unmodified.
OBSERVATION:
FACT — jsonl 5603516→5852278 @ 04:15:52Z.
FACT — PROGRAM.txt still 8bfd993d EOS HIGH from 10:50; no new nạp.
FACT — RKB TAP 3e7abe6d / no-CLEAR 43ce2b97 / D_RKB c0f7e919; 01/03/07 UART CANDIDATE; 02/04/05/06 NOT_RUN.
FACT — leftover MAG CLASS_A leftover_tap_not_this_pack; V04x4 GOLD n=4 mag=0 mute=0.
FACT — PACK24_CT1_RUN1 stop PACK24_RUN1_DONE 6 GOLD 17 NAK 1 MAG A-02.
FACT — watch --compare PACK24_CT1_RUN1_DUT.jsonl 150b716f → 2/24 rc=1 (18 omit-vs-0 plus R-04/G-04 query fields).
FACT — live D_PACK_ABI_GAP.json 70bcd8e3 GOAL_A R1 24/24 CLOSED ≠ historical PASS; GOAL_B freeze 6/24; RUN1 2/24 DONE_NOT_RESCUE.
FACT — query PROGRAM.txt file still 1ab55cbd / 8fc14f25. Watch did not nạp.
INFERENCE — Pack24 on CT1 cannot close historical PACK_ABI name under omit law.
HYPOTHESES: H1 Pack24 6 GOLD = PACK_ABI_24_24_PASS (REJECTED). H2 gold.py 6/24 on freeze DUT applies to this RUN1 jsonl (CONTRADICTED; this file is 2/24).
HOW_TRACE: hash unique build+PROGRAM+new UART json; copy unique; run gold.py --compare; do not invent flip=0; do not overlay 8fc14f25; do not push .bit.
EVIDENCE_MATRIX: PROGRAM.txt FACT; RKB json FACT; leftover/V04 FACT; Pack24 json+DUT FACT; gold.py 2/24 FACT; 8/8 NOT_RUN FACT.
SUCCESS_VS_FAILURE: SUCCESS=publish unique CT1 post-smoke hops. FAILURE=stamp PACK_ABI/PROGRAM_PASS/CT1_BOARD_PASS/RKB 8/8.
FIRST_DIVERGENCE: D_PACK_ABI_GAP 11:10 said pack24 NOT_RUN; disk PACK24_CT1_RUN1 11:14 DONE. Watch publishes the later COMPLETE file. gold.py this DUT 2/24 vs freeze DUT 6/24.
DECISIVE_TEST: Get-FileHash PROGRAM.txt vs 8bfd993d; python pack_abi24_gold.py --compare PACK24_CT1_RUN1_DUT.jsonl.
ROOT_CAUSE_OR_UNKNOWN: Omit-vs-0 still blocks historical PASS name. Dest dump UNKNOWN. RKB-02 still XSim next.
REUSABLE_DECISION_PROCEDURE: After smoke, hash newest UART json in unique PROGRAM dir. Re-run gold.py on THIS jsonl; do not reuse freeze 6/24. MAG n=40 with tap_not_this_pack is leftover, not this-pack COMMIT.
STRUCTURAL_GUARD: unique CT1 outdir; no .bit push; gold.py untouched; keep 8fc14f25 PROGRAM.txt; watch never programs.
BLAST_RADIUS: Native_SymAI results/CT1_OWNER_PROGRAM_20260921 new json only. Query unique dirs intact. C RTL / freeze DCP untouched.
VERDICT_BY_LAYER: UART CANDIDATE RKB 01/03/07. V04 GOLD n=4. Pack24 RUN1 DONE 6/17/1. FAIL_COMPARE 2/24. NO PACK_ABI / PROGRAM_PASS / CT1_BOARD_PASS / RKB_8_8.
LESSON_TO_SHARE: GOLD-PY-COMPARE-THIS-JSONL-NOT-FREEZE-DUT-20260921T042200Z
NEXT_DECISIVE_EXPERIMENT: Next 30m. RKB-02 is XSim. Stop on dừng theo dõi.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER. No program. No invent PACK_ABI_24_24_PASS.
HANDOFF_STATUS: COMPLETE
