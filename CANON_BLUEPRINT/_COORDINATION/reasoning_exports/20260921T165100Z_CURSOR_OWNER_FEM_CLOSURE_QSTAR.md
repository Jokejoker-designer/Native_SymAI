NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: WATCH-PUBLISH-FEM-CLOSURE-QSTAR-DESIGN / 20260921T165100Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: FACT JSON 6378acaf… still the legal-compact dataset; independent CRC 0x552e; no DPK in JSON; persist bit/PROGRAM.txt/UART_SMOKE unchanged. Closure freeze FEM_PERSIST_LEGAL_COMPACT_BOARD_CANDIDATE CONTRADICTION_FOUND=NO is a scoped candidate freeze, not FEM_PERSIST_PASS. Next identity fem_qstar_causal is DESIGN_LOCKED SHA NOT_ASSIGNED BUILD=NO PROGRAM=NO. Watch did not program.
RUN_PROVENANCE: Parent jsonl 7268313 @ 2026-09-21T16:48:10Z. Last GitHub 07fa414. Live CLOSURE_AUDIT sha256 c12cb954…. Freeze md 6a1cfddd…. ABAB spec 5ed00715…. Identity reservation 4959495a…. C fem 45b9b930 qstar d4f64e65 spear 11e71b50. Unique dirs 20260921_fem_persist_closure_1db38691 and 20260921_fem_qstar_causal_design. Prior unique dirs not git-overlaid.
OBSERVATION: JSON c0117ed0 count=8. dest_poke=NO. Disk bit still 1db38691. PROGRAM.txt 4c47930a. UART_SMOKE 822f8750. No build_fem_qstar_causal bit.
HYPOTHESES: H1 FACT scoped freeze docs exist. H2 FACT Q* design docs exist and SHA unknown. H3 CONTRADICTED FEM_PERSIST_PASS from freeze. H4 CONTRADICTED that 1db38691 can run FEM→Q*. H5 INFERENCE greedy 0/1/0/1 not yet simulated.
HOW_TRACE: Independent hashes vs live files; CRC via harness crc16_n; grep DPK; copy new unique dirs; did not add overlay diffs in previously published unique dirs.
EVIDENCE_MATRIX:
| claim | class | evidence |
| JSON unchanged | FACT | sha256 6378acaf… |
| CRC match | FACT | crc16_n(W0||W1)=552e |
| no DPK | FACT | 44504B31 absent |
| no new persist bit | FACT | bit hash 1db38691 |
| Q* SHA | UNKNOWN | NOT_ASSIGNED |
| FEM_PERSIST_PASS | NO | ceiling |
SUCCESS_VS_FAILURE: Success = publish closure+design without overlay or PASS stamps. Failure would be restamping persist PASS or committing a new .bit.
FIRST_DIVERGENCE: NONE vs 07fa414 JSON. Design has no silicon yet.
DECISIVE_TEST: Hash JSON/CRC/DPK/C RTL. Design next test is XSim 0/1/0/1.
ROOT_CAUSE_OR_UNKNOWN: Persist miss historically FREP omit. Decision causality NOT_TESTED.
REUSABLE_DECISION_PROCEDURE: Unique dir per freeze/design. Do not overlay UART/BIT unique dirs. Do not persist-repeat. Quote new SHA before PROGRAM.
STRUCTURAL_GUARD: Separate closure and qstar unique dirs. C_SCALE_GUARD HOLD. DEST_POKE=NO.
BLAST_RADIUS: Native_SymAI unique audit dirs + reasoning. Persist bit file untouched. C RTL untouched.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE freeze; DESIGN_LOCKED Q*; PASS_XSIM=NOT_RUN; FEM_PERSIST_PASS=NO; PROGRAM_PASS=NO; BOARD_PASS=NO; MIG_PASS=NO; TIMING_PASS=NO; PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-PERSIST-LEGAL-COMPACT-CLOSURE-NO-CONTRADICTION-20260921T162400Z ; FEM-QSTAR-ABAB-DESIGN-LOCKED-20260921T164700Z (already in lessons tree). Watch extra: NONE.
NEXT_DECISIVE_EXPERIMENT: XSim fem_qstar_causal greedy 0,1,0,1. Do not bitgen until that matches and owner asks. Do not program from this watch.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER watch. Stop if dung theo doi, C edit, DEST_POKE, overlay unique dirs, persist-repeat, or nạp. Do not self-stamp FEM_PERSIST_PASS/PROGRAM_PASS/BOARD_PASS.
HANDOFF_STATUS: COMPLETE
