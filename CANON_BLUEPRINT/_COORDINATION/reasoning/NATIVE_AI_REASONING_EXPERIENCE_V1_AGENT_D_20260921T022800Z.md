NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: RKB08-DIR-POISON-GEN-LIFECYCLE / 20260921T022800Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Owner-ordered XSim Test 1 generation lifecycle and Test 2 RKB-08 dir_a.mem poison. Observed CLASS A. RKB-08 = FAIL_CURRENT_ARCHITECTURE. ROOT_CAUSE DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT. Stop further RKB tests. Design COMMIT→T1 next. No program. No FE256/ASTRA/Q*/SPEAR/FEM edit. PACK_ABI_24_24_PASS=NO.
RUN_PROVENANCE: Owner 2026-09-21 XSim order. Live board 8fc14f25 not reprogrammed. C RTL unmodified. B gold unmodified. U33OBS_DEBUG=CLOSED.

OBSERVATION:
- FACT — XSim $finish 6455 ns. T1_BOOT/GOLD/RST UNSET/G/UNSET all OK. Query sid 00010100 hit=1 nb=00020100 eref=00000020 dest_rd=0 at boot, after GOLD, and after reset. knowledge_after_rst_same_as_gold=1.
- FACT — Poison rom[0] sid 00010100→0. Same QueryRecord hit=0 dest_rd=0. RKB08_CLASS=A.
- FACT — TB did not $fatal on CLASS A; class was computed after observation.
- FACT — No post_a.mem poison. No RKB-01..07.

HYPOTHESES:
- H1 query uses Pack dest after GOLD — CONTRADICTED dest_rd=0.
- H2 after reset query drops previous knowledge — CONTRADICTED same hit/nb/eref.
- H3 query causally depends on dir fixture — SUPPORTED CLASS A.

HOW_TRACE: D-owned TB pack_abi24_mig_dut + query_posting_bind → V-04 GOLD → reset → hierarchical poison exact_directory.rom[0] → classify A/B/C → stop on A.

EVIDENCE_MATRIX:
- xsim.log sha256 4a7c22203c62e3107b6036aa6c33d601a24d2be43daa35a60c4e1f4ac6ddab7d PASS_XSIM
- RKB08_OBS.json sha256 18456f1649cabb98f13be02a89e5d8264c09051035a3c515a310cd16fa852c8e PASS_XSIM
- TB sha256 6f6f6b2f9c70ba5d3b78e3c0cc19e718e3a74f49c3b2ad0159695ea56299ebbb
- query_posting_bind sha256 fb8eea24… unchanged

SUCCESS_VS_FAILURE: Test 1 register lifecycle PASS_XSIM. RKB-08 architectural FAIL as owner stop. Product runtime binding unproven.

FIRST_DIVERGENCE: Pack S_COMMIT does not install/update runtime semantic directory root/entry.

DECISIVE_TEST: poison dir rom[0] sid of the QueryRecord; answer changed; dest_rd stayed 0.

ROOT_CAUSE_OR_UNKNOWN: DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT (FACT).

REUSABLE_DECISION_PROCEDURE: Observe A/B/C without encoding the predicted class as TB pass. On A stop. Next work is COMMIT→T1 design, not more TBs.

STRUCTURAL_GUARD: tb_rkb08_gen_lifecycle.sv; no FE256/C/gold edits; PROGRAM=NO.

BLAST_RADIUS: New rkb_readback XSim + design md. No product RTL. No bitstream.

VERDICT_BY_LAYER:
- PASS_XSIM Test 1 generation register
- PASS_XSIM RKB-08 CLASS A observation
- FAIL_CURRENT_ARCHITECTURE RKB-08
- Not RUNTIME_KNOWLEDGE_BINDING_8_8_PASS / PACK_ABI_24_24_PASS / BOARD_PASS / PROGRAM_PASS

LESSON_TO_SHARE: RKB08-DIR-FIXTURE-NOT-PACK-DEST-20260921T022800Z
NEXT_DECISIVE_EXPERIMENT: Implement COMMIT→writable T1 candidate. Do not run RKB-01..07 or post poison first. No silicon until XSim+audit+owner YES.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop adding RKB TBs. Stop if tempted to program or edit FE256/C/gold.
HANDOFF_STATUS: COMPLETE
