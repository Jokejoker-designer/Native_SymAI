NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: INDEP-AUDIT-FEM-PERSIST-1DB38691 / 20260921T153500Z
OWNER_AGENT: INDEPENDENT_AUDIT
CURRENT_CLAIM: Silicon 1db38691 FCMP ran with life_state=CLUSTERED and cmp_result=NOT_RESOLVED because the board smoke omitted FREP x3. C_COMMIT was not entered. Missing C0117ED0 is the expected COMMIT slot, not proof of MIG/T2/address failure. FEM_PERSIST_PASS=NO. PROGRAM_PASS=NO. BOARD_PASS=NO. MIG_PASS=NO. TIMING_PASS=NO. PACK_ABI_24_24_PASS=NO.
RUN_PROVENANCE: Owner independent audit of commit b9072521c7f1f8e6cd110f642c6c51ffbb93b11a and identity 1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668. Evidence dir Native_SymAI/docs/audits/20260921_fem_persist_bit_1db38691/. UART_SMOKE.json sha256 822f8750d1471c2f24ff7c9291d77d6ca8572f7a5ce88f399ff278ea366cd367. C fem_lifecycle.v sha256 45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed unedited. Did not program. Did not DEST_POKE. Did not edit C RTL.
OBSERVATION: uart_smoke_fem_persist.py sends FING 5,6,4,4 then FCMP with no FREP. XSim tb_fem_persist_int.sv sends FREP 0x0111 x3 and requires life==RESOLVED before FCMP. FOBS_AFTER_CMP s0=0000091f => txn=15 cmp_result=1 n_raw=2 life=1 compacted=0. s1=02020002 => ft=2 fr=2 sar=0. DEST_READ 0x0200010 lanes fffffff7 ff7fffff 000070ea 00010000. Lane2 matches hdr2_word key at A_HDR2 in the same 128-bit beat as A_COMMIT. FREC recov=0 restores CLUSTERED. D 20260921T143303Z and watch T144000Z labeled dest miss UNKNOWN MIG/T2/ADDRESS.
HYPOTHESES: H1 FACT compact guard is (not RESOLVED)->1 (sar<3)->2 (fr!=0)->3 else 0. H2 FACT silicon at FCMP failed clause 1. H3 FACT C_B0 only if guard==0. H4 CONTRADICTED that FCMP echo means compact wrote COMMIT. H5 CONTRADICTED that missing magic first-cause is MIG. H6 STRONG_INFERENCE ingress T2 write+DEST_READ mapping worked (HDR2). H7 NOT_TESTED whether FREP x3 on this bit reaches RESOLVED then COMMIT.
HOW_TRACE: FING arg[1:0]=domain arg[4:2]=ctx; domain 1/2 rejected; two DUT domain0 store RAW then CLUSTERED at CLUSTER_THRESHOLD=2; no rep_valid; cmp_start stores guard=1 and jumps C_DONE; fem_req_ui addr=FEM_BASE+{t2_addr,00}; DEST_READ dumps 128b beat lanes.
EVIDENCE_MATRIX:
| claim | class | evidence |
| FREP on this UART run | CONTRADICTED | UART_SMOKE.json steps; uart_smoke_fem_persist.py |
| preconditions at FCMP | CONTRADICTED | life=1 sar=0 fr=2 vs L_RESOLVED N_STABLE=3 fr==0 |
| cmp_result=1 | FACT | lifecycle comment + guard assignment |
| C_COMMIT this run | CONTRADICTED | guard reject path |
| 0x0200010 is A_COMMIT | FACT | fem_req_ui + A_COMMIT=4 |
| lane2 70ea is A_HDR2 | STRONG_INFERENCE | hdr2 packing + lane map |
| missing magic => MIG fail | CONTRADICTED | compact never armed |
| FEM_PERSIST_PASS | NO | discriminator not executed |
SUCCESS_VS_FAILURE: Success for this audit = first divergence at stimulus (FREP) not media. Failure would have been life==RESOLVED sar>=3 fr==0 and still no magic.
FIRST_DIVERGENCE: TEST HARNESS. After second DUT FING, XSim FREPs; silicon FCMPs.
DECISIVE_TEST: Same bitstream, issue FREP x3, FOBS gate life==2, then FCMP, DEST_READ 0x0200010.
ROOT_CAUSE_OR_UNKNOWN: Known for this dataset: guard NOT_RESOLVED. Compact/COMMIT on mig0 remains NOT_TESTED.
REUSABLE_DECISION_PROCEDURE: 1) Diff board opcode list vs XSim. 2) Decode FOBS life/sar/fr/cmp_result before media. 3) Remember C_DONE pulses cmp_done on reject. 4) Map DEST_READ lanes to T2 addrs in the same beat. 5) Only then classify T2/MIG.
STRUCTURAL_GUARD: Persist harness must not FCMP until FOBS shows RESOLVED. No DEST_POKE COMMIT. No C edit. No FEM_PERSIST_PASS without magic then FRST then magic then recov=2.
BLAST_RADIUS: Causal classification and smoke script. Unique bit 1db38691 and C RTL unchanged. Prior D/watch UNKNOWN dest-miss is superseded for this run, not deleted.
VERDICT_BY_LAYER: PASS_XSIM persist TB still prior-layer only; UART_BOARD_SMOKE_CANDIDATE opcode+FOBS; compact/COMMIT on board NOT_TESTED; FEM_PERSIST_PASS=NO; PROGRAM_PASS=NO; MIG_PASS=NO; TIMING_PASS=NO; BOARD_PASS=NO; PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-PERSIST-FCMP-WITHOUT-FREP-NOT-MIG-20260921T153500Z
NEXT_DECISIVE_EXPERIMENT: On 1db38691, FING 5/6/4/4, FREP 0x0111 x3, FOBS life==2 sar>=3 fr==0, FCMP, DEST_READ 0x0200010. No new bit unless identity lost. No DEST_POKE. No red RESET. No C RTL.
OWNER_AND_STOP_CONDITION: Independent audit. Stop if C fem_lifecycle edit, DEST_POKE COMMIT, new PASS stamp, or red RESET used as persist.
HANDOFF_STATUS: COMPLETE
