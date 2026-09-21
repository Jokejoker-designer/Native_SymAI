# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: D-RKB08-CURRENT-ARCH-FIXTURE
RUN_ID: 20260921T060110Z
OWNER_AGENT: AGENT_D
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES
MAILBOX: NOT_SENT (owner relays)
PROGRAM: NO

CURRENT_CLAIM:
RKB-08 current-architecture fixture independence on dest-backed
Directory→Posting→EdgeRecord (`pack_edge_dut`): 08A poisoned TB fixture still C;
08B dest EdgeRecord poison does not recover C from intact fixture; 08C restore
returns C; 08D DUT sources have no `$readmemh dir_a.mem/post_a.mem`. Isolated
PASS_XSIM. Historical `8fc14f25` CLASS A unchanged. Not 8/8. Not board.

RUN_PROVENANCE:
- Command: `D:\FPGA\arty_d\rkb_readback\run_rkb08_arch_xsim.bat` exit 0
- `$finish` 7375 ns `RKB-08 ARCH PASS_XSIM A=1 B=1 C=1`
- RKB-08D python precheck PASS hits=[]
- RKB08_ARCH_OBS.json sha256 `65fb25bae8993d456a1d31e648a047332c814cb18d493d635cca0e75f4fdb817`
- RKB08D_SRC.json sha256 `170260ec8bd64c943c0d8985276bddca88112107a1e7fbec371562efc67a1c12`
- rkb08_arch_xsim.log sha256 `373745b2679adb833d5b95913676ea8cfa64b974034bc8f0d245b4f1a56293a2`
- tb_rkb08_arch.sv sha256 `945423305b0b9ec9f8ec6505a60be1d13822a207c7260bb6e998b2d89d32e5b2`
- xvlog list: no posting_walk / exact_directory / query_posting_bind
- PROGRAM=NO. gold.py not edited. No Pack24. No mailbox. Board unplugged.

OBSERVATION:
FACT: 08A TB fixture_nb=`deadbeef`, DUT hit C `00030100` dest_rd=5 gen=`000000c1`.
FACT: 08B TB fixture_nb=`00030100`, dest edge zero, posting dest still C, DUT hit=0 nb=0 dest_rd=4.
FACT: 08C dest edge restored, DUT hit C dest_rd=5 gen=`000000c1`.
FACT: 08D scanned DUT SV files: no `$readmemh("dir_a.mem"` / `post_a.mem`, no posting_walk instance.
FACT: Historical `tb_rkb08_gen_lifecycle.sv` + `query_posting_bind` CLASS A on `8fc14f25` was not re-run and is not overwritten.

HYPOTHESES:
H1: Query still uses dir_a.mem/post_a.mem. REJECTED — 08B intact C fixture, dest edge poison, miss dest_rd=4.
H2: Poisoned fixture would change dest C. REJECTED — 08A fixture DEADBEEF, DUT still C dest_rd=5.
H3: Restoring dest is unnecessary because fixture would answer. REJECTED — 08B miss then 08C C only after dest restore.
H4: Comment "Not posting_walk" means the module is instantiated. REJECTED — 08D instance scan empty; xvlog compiled dest_posting_edge_walk only.

HOW_TRACE:
Pack A2B then A2C → dest SLOT1 C. TB $readmemh poison into unused arrays → query C.
TB $readmemh intact C arrays; zero dest[1029..1030]; posting dest[1028] still C; query miss.
Restore dest edges; query C. Python scan DUT SV for $readmemh fixtures.

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| RKB-08A/B/C dest-backed fixture independence | PASS_XSIM | RKB08_ARCH_OBS 7375 ns A=B=C=1 |
| RKB-08D no static answer source on DUT | FACT | RKB08D_SRC hits=[] |
| 8fc14f25 CLASS A | UNCHANGED | RKB08_FAIL_CURRENT_ARCHITECTURE.md |
| UART / 8/8 | NOT_RUN | no stamp |
| PACK_ABI_24_24_PASS | NO | owner KEEP |

SUCCESS_VS_FAILURE:
Success: C with poisoned unused fixture; miss with dest edge poison while fixture holds C; C after dest restore; DUT has no $readmemh fixtures.
Failure would be 08B returning C from fixture, 08A following DEADBEEF, or xvlog of posting_walk.

FIRST_DIVERGENCE:
Old architecture: query hit with dest_rd=0 from dir_a.mem (CLASS A). This DUT: dest_rd=5 on C, dest_rd=4 on dest-edge miss.

DECISIVE_TEST:
`run_rkb08_arch_xsim.bat`. 08A C dest_rd>=4 fixture=DEADBEEF. 08B miss dest_rd>=3 fixture=C posting still C. 08C C. 08D hits=[].

ROOT_CAUSE_OR_UNKNOWN:
Current isolated DUT answer SoT is dest EdgeRecord.dst_id. Static $readmemh directory is not on this DUT. CT1 silicon bit is still SID→fwd, not this walk. Board fixture independence UNKNOWN.

REUSABLE_DECISION_PROCEDURE:
1. Do not inherit fixture-independence PASS from "fixture file not compiled".
2. 08A: fixture would give the wrong neighbor; dest still C.
3. 08B: fixture would give C; dest edge poison must miss.
4. 08C: restore dest only; C returns.
5. 08D: scan DUT sources and xvlog list for $readmemh dir_a/post_a and posting_walk.
6. Keep historical CLASS A as a different identity/DUT.

STRUCTURAL_GUARD:
TB ANDs 08A C+DEADBEEF, 08B miss+fixture C+posting C+edge 0, 08C C. Python 08D hits=[].
Do not stamp RUNTIME_KNOWLEDGE_BINDING_8_8_PASS.

BLAST_RADIUS:
New tb_rkb08_arch / emit_rkb08_fixtures / rkb08_check_dut / run_rkb08_arch_xsim.bat.
Does not edit posting_walk, exact_directory, gold.py, C RTL, FE256, historical RKB08_FAIL doc body, bitstream.

VERDICT_BY_LAYER:
PASS_XSIM isolated pack_edge_dut 08A/B/C + 08D source scan.
NOT_RUN UART / 8/8 / CT1_BOARD_PASS.
NO PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS.

LESSON_TO_SHARE: RKB08-DEST-EDGE-NOT-FIXTURE-FALLBACK-20260921T060110Z

NEXT_DECISIVE_EXPERIMENT:
Do not stamp 8/8. CT1 bit is not this DUT. Owner decides whether to bind this walk into a new identity.
PROGRAM=NO. Board stays unplugged.

OWNER_AND_STOP_CONDITION:
Owner unplugged board. No mailbox. D does not UART/program. Stop after RKB-08A-D evidence.
Do not self-stamp 8/8. Do not rewrite 8fc14f25 CLASS A.
