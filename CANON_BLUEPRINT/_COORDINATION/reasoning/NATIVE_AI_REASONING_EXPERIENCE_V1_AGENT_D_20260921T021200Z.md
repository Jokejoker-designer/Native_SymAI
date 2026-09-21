NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: OWNER-FREEZE-R1-PACK-ABI-P0-CLOSE / 20260921T021200Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Owner froze R1 Causal as Pack ABI authority and closed P0 Pack on R1 24/24. Historical PACK_ABI_24_24_PASS remains NO. U33OBS debug CLOSED. Next work is active-generation readback + runtime semantic→physical binding. Board not unplugged. No reprogram this turn.
RUN_PROVENANCE: Owner 2026-09-21 freeze. Unique 8fc14f25 live. C RTL unmodified. B gold.py unmodified (historical). FE256 freeze DCPs untouched.

OBSERVATION:
- FACT — python 10_pack24_r1_compare.py freeze-copy PACK24_RESUME_QUERY_R1.jsonl sha256 090b7814d0bbe6d31089e07339bfa64c93651881c429deb83d0621de56639737 → PACK_ABI24_R1_CANDIDATE 24/24 rc=0. NOTE forbids historical PACK_ABI_24_24_PASS.
- FACT — python pack_abi24_gold.py --compare freeze-copy PACK24_RESUME_QUERY_DUT.jsonl sha256 f5ead405fef0fca13f0393a1e95d8636b2dbaa1289a4dab580ae64f662b3b6c8 → 6/24 rc=1, 18 generation_flipped None vs 0.
- FACT — R1 zip 4bc37ffe958f7cea6a9f85541dde8df4945de9fa47b76d50dae4b93dd1d2cecc; master f422fff3e73ecfb8ebfc1cf2c1e655ca2df397213eecbd1c473e7c2df1426709.
- FACT — PROGRAM.txt sha256 1ab55cbdfb957d7e5b1210916d23a6f2713dece9fcad053160c60669e1745b26 bit 8fc14f25… dest_wipe=NO.
- FACT — pack_loader S_WRITE mem_wdata=page_rdata; S_COMMIT active_generation<=man_generation; reset UNSET_GEN; S_RD_WAIT compares dest to rg_first. Query exact_directory/posting_walk still $readmemh dir_a.mem/post_a.mem.
- FACT — struct_check.py PASS_IMPLEMENTED rc=0. Not READBACK_ACTIVE_GENERATION_PASS / RUNTIME_KNOWLEDGE_BINDING_8_8_PASS.
- FACT — freeze dir SHA256SUMS.txt sha256 998f19c4691bce886727d23ae074a127908c55bd071626ec93e00ec76a0404bf.

HYPOTHESES:
- H1 close P0 Pack implies PACK_ABI_24_24_PASS — REJECTED by owner and R1 comparator NOTE.
- H2 GOLD S_RD_WAIT is dest generation readback — CONTRADICTED (page first word, not pack_generation in dest).
- H3 query already bound to Pack dest — CONTRADICTED ($readmemh fixtures).

HOW_TRACE: owner freeze → copy jsonl/comparator/gold to freeze dir → re-run R1 and B compare → write GUARD/P0 close → stop U33OBS → struct_check generation flop vs dest pages vs $readmemh.

EVIDENCE_MATRIX:
- R1 24/24 PASS_R1_COMPARE (authority, not historical PASS)
- B gold 6/24 FAIL_COMPARE historical
- struct_check PASS_IMPLEMENTED
- dest_word_export NOT_RUN
- board identity PROGRAM.txt FACT

SUCCESS_VS_FAILURE: P0 Pack closed on R1 without synthesizing TSV 0 and without legacy stamp. Generation persist and T1 install remain open.

FIRST_DIVERGENCE: Pack ABI authority is now R1 omit/commit_count law, not TSV flip=0. Generation lives in flop not dest. Query lives in $readmemh not Pack dest.

DECISIVE_TEST: R1 compare rc=0 on frozen jsonl; B compare rc=1 on sibling DUT; struct_check rc=0.

ROOT_CAUSE_OR_UNKNOWN: N/A for freeze. Remaining hole for next work: DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT and generation not stored in dest (FACT).

REUSABLE_DECISION_PROCEDURE: Owner freeze of a comparator does not inherit historical PASS names. Copy evidence before switching workstreams. Do not fill TSV 0. Do not continue U33OBS debug after CLOSED.

STRUCTURAL_GUARD: GUARD.md D-PACK-ABI24-R1-AUTHORITY-FREEZE; freeze copies; gold.py untouched; struct_check.py.

BLAST_RADIUS: New freeze dir + verification_r1 docs + AGENTS.md learned facts. No RTL. No program. No overwrite of Pack24 jsonl originals.

VERDICT_BY_LAYER:
- PASS_R1_COMPARE 24/24 owner Pack ABI authority
- PACK_ABI24_R1_P0_CLOSED YES
- FAIL_COMPARE historical B gold 6/24
- PASS_IMPLEMENTED struct_check
- NOT_RUN dest hex / READBACK_ACTIVE_GENERATION_PASS / RUNTIME_KNOWLEDGE_BINDING_8_8_PASS
- Not PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS

LESSON_TO_SHARE: OWNER-FREEZE-R1-PACK-ABI-NO-LEGACY-STAMP-20260921T021200Z
NEXT_DECISIVE_EXPERIMENT: XSim GOLD then rst_n UNSET + dest page peek (generation absent). Then RKB-08 poison dir_a.mem. No Pack24. No U33OBS overlay.
OWNER_AND_STOP_CONDITION: AGENT_D. U33OBS_DEBUG=CLOSED. Stop if tempted to stamp PACK_ABI_24_24_PASS or reopen MAG hops.
HANDOFF_STATUS: COMPLETE
