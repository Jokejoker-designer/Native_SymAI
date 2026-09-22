NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: PUBLISH-SINGLE-BOARD-GOAL-CUTS-20260922T134800Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: FACT unpublished COMPLETE work since GitHub 08e20e7 is now in unique dirs. STATUS CUT16_G2_PLANT_XSIM_SUPPORTED. Watch did not program. No .bit in git. PROGRAM_PASS=NO BOARD_PASS=NO PACK_ABI_24_24_PASS=NO ASTRA_PASS=NO FEM_PERSIST_PASS=NO MIG_PASS=NO TIMING_PASS=NO.
RUN_PROVENANCE: Native_SymAI HEAD 08e20e7. Parent jsonl 9010190. Goal plan read in full. Independent SHA256 of live logs, UART JSON, C RTL, and disk bits. Unique dirs created. Existing 08e20e7 unique dirs not overlaid.
OBSERVATION: FACT C RTL hashes still 45b9b930 / d4f64e65 / 11e71b50. FACT disk bits 44546b43 and 90220cb5 match BIT_SHA256.txt and were not copied. FACT most goal-plan log SHAs match live files. FACT two live logs drifted: semantic cad86003 finish 6605 ns vs historical 1f578505 finish 6665 ns; pack-vis c435d86d finish 10085 ns vs historical 5e9a787d finish 9705 ns. FACT freeze 90220cb5 already records both pack-vis SHAs. FACT plant log f66a75fb finish 9865 ns SUPPORTED with no effect-code port.
HYPOTHESES: H1 live semantic/pack-vis logs are silent corruption (CONTRADICTED: later COMPLETE notes and FREEZE quote the new SHAs). H2 publishing into 20260922_astra_discovery would overlay SHA256SUMS (avoided; new unique dirs). H3 plant justifies a program (CONTRADICTED by self-audit: adder substitute).
HOW_TRACE: Read goal plan. Diffed origin astra_discovery vs local. Hashed claimed artifacts. Failed first verify on two logs. Located HASH_DRIFT evidence. Copied sources into unique dirs. Prepended feed. Did not nạp. Did not stamp PASS.
EVIDENCE_MATRIX: Unique dir SUMS e344c106… / 8e0e14ce… / 9efa1138…. UART action f6b50b7d. UART pack b13d43a1. Plant f66a75fb. C RTL freeze match. PASS labels stay layer-scoped. Not BOARD_PASS.
SUCCESS_VS_FAILURE: Publish proceeds only after independent hash. First script run stopped on drift. Second run VERIFY_OK with drift recorded.
FIRST_DIVERGENCE: semantic_runtime_xsim.log and pack_vis_xsim.log no longer equal the first MD SHA.
DECISIVE_TEST: Hash the live file. Keep the historical MD. Record both SHAs. Do not rewrite history.
ROOT_CAUSE_OR_UNKNOWN: Later COMPLETE reruns replaced the live log path. The historical SHA remains in append-only notes.
REUSABLE_DECISION_PROCEDURE: Before a GitHub copy, hash the live evidence. If it disagrees with the MD, find the later note or freeze that explains the new SHA. Publish the live file plus HASH_DRIFT. Do not overlay a published SHA256SUMS.
STRUCTURAL_GUARD: Unique dirs. No .bit. No global PASS. Do not edit fem_lifecycle / spear_rank / qstar_select. Do not rebuild 44546b43 or 90220cb5.
BLAST_RADIUS: New unique audit dirs, feed, V1 publish entry. Frozen identities untouched.
VERDICT_BY_LAYER: PASS_XSIM local on the listed cuts. UART_BOARD_SMOKE_CANDIDATE on 44546b43 and 90220cb5. Not PROGRAM_PASS. Not BOARD_PASS. Product goal open. NEXT_CUT remains PHYSICAL_DDR_ONLY_IF_SIM_CANNOT_ANSWER.
LESSON_TO_SHARE: LESSON_ID L-023 LIVE_LOG_SHA_DRIFT_AFTER_RERUN
NEXT_DECISIVE_EXPERIMENT: Parent owns the next goal cut. Watch does not program the plant adder. DDR stays closed while mig_ui_bram still answers.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER watch. Stop after unique-dir push and issue comment. Do not nạp.
HANDOFF_STATUS: COMPLETE
