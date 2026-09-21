NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: WATCH-PUBLISH-FEM-PERSIST-BIT-1DB38691 / 20260921T144000Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: FACT unique FEM persist bitstream 1db38691… is BIT_OK WNS=+0.737 WHS=+0.027, parent-programmed EOS HIGH, UART CLEAR ACK and FEM opcode echo. Dest COMMIT at 0x0200010 is not 0xC0117ED0. FEM_PERSIST_PASS=NO. PROGRAM_PASS=NO. BOARD_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. PACK_ABI_24_24_PASS=NO. Watch did not program.
RUN_PROVENANCE: Parent chat 31dc87bc jsonl 6969428 @ 2026-09-21T14:38:46Z. Last GitHub 4face1a. Unique tree D:/FPGA/arty_d/UART_R2/fem_persist. Unique out build_fem_persist. Results FEM_PERSIST_OWNER_PROGRAM_20260921. Independent Get-FileHash bit=1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668 matches BIT_SHA256.txt and PROGRAM.txt. Keep ead830ae / daaca9c1 / 8bfd993d. C fem_lifecycle.v 45b9b930 unedited.
OBSERVATION: Terminal 146882 abort WNS=-2.497. Terminal 146883 abort WNS=-2.514 loops=0. Terminal 146884 BIT_OK sha=1db38691 PROGRAM=NO then parent programmed. program.log Labtools 27-3164 EOS HIGH PROGRAM_PASS=NO. UART_SMOKE.json sha256 822f8750… CLEAR ack=1 commit_magic=0 compacted=0 recov=0. PROGRAM.DONE=NA. No .bit committed.
HYPOTHESES: H1 FACT BIT_OK after UI sample of op_hold. H2 FACT silicon FEM UART plane alive. H3 FACT dest lane0 not COMMIT_MAGIC. H4 FACT FOBS key=0x70ea is not dest proof. H5 UNKNOWN why dest miss on mig0 vs XSim c0117ed0. H6 CONTRADICTED that this close is FEM_PERSIST_PASS.
HOW_TRACE: Watch hashed live bit/PROGRAM/UART_SMOKE vs D SHA256SUMS; copied unique dir; did not run program Tcl; did not stamp ladder PASS.
EVIDENCE_MATRIX:
| claim | class | evidence |
| BIT_OK WNS>=0 | FACT PASS_IMPLEMENTED | BUILD.txt STATUS=BIT_OK WNS=0.737; timing_route Design Timing Summary WNS=0.737 WHS=0.027; check_timing loops=0 |
| unique identity | FACT | bit 1db38691… not ead830ae/daaca9c1/8bfd993d |
| programmed this SHA | FACT UART_BOARD_SMOKE_CANDIDATE | program.log 27-3164 EOS HIGH; PROGRAM.txt SHA MATCH; watch did not nạp |
| UART alive | FACT | CLEAR ack=1 COM12 n=4 |
| dest COMMIT magic | FACT fail on board | DEST_READ commit_magic=0 vs XSim c0117ed0 |
| PROGRAM_PASS | NO | PROGRAM.DONE=NA |
| FEM_PERSIST_PASS | NO | dest magic missing |
SUCCESS_VS_FAILURE: Success for this publish = unique BIT_OK hashes + program log EOS HIGH + UART_SMOKE copied without .bit or PASS stamps. Failure for persist discriminator = DEST_READ != C0117ED0.
FIRST_DIVERGENCE: Timing: op_hold used across 100 MHz -> UI after loops=0. Silicon vs XSim: DEST_READ 0x0200010 lane0 after FCMP.
DECISIVE_TEST: Independent Get-FileHash of bit vs PROGRAM.txt vs BIT_SHA256.txt; UART_SMOKE commit_magic field.
ROOT_CAUSE_OR_UNKNOWN: BIT_OK: CDC hold sample (D). Dest COMMIT miss: UNKNOWN. Do not DEST_POKE COMMIT. Do not edit C RTL.
REUSABLE_DECISION_PROCEDURE: 1) Unique dir per identity. 2) Hash bit independently. 3) Keep prior identities on disk. 4) Publish logs/json not .bit. 5) FEM persist close = DEST_READ magic then FRST then magic then FREC recov=2.
STRUCTURAL_GUARD: Unique docs/audits/20260921_fem_persist_bit_1db38691/. Do not overwrite 20260921_fem_persist_xsim_restore or dest TAP dir. 96_bit aborts WNS<0. C N_RAW=4 frozen.
BLAST_RADIUS: Native_SymAI unique audit dir + reasoning copies. Live board SRAM is 1db38691; dest TAP bit file untouched.
VERDICT_BY_LAYER: PASS_XSIM prior persist TBs; PASS_IMPLEMENTED WNS=+0.737; UART_BOARD_SMOKE_CANDIDATE; DEST_COMPLETE_BOARD=NO; FEM_PERSIST_PASS=NO; PROGRAM_PASS=NO; TIMING_PASS=NO; MIG_PASS=NO; BOARD_PASS=NO.
LESSON_TO_SHARE: FEM-PERSIST-CDC-HOLD-SAMPLE-AND-DEST-MAGIC-20260921T143303Z (D-owned; copied to public tree). Watch extra: NONE.
NEXT_DECISIVE_EXPERIMENT: Classify 0x0200010 != C0117ED0 after FCMP as MEMORY|T2|ADDRESS|MIG. Do not stamp FEM_PERSIST_PASS. Do not program from this watch.
OWNER_AND_STOP_CONDITION: CURSOR_OWNER watch. Stop if asked dung theo doi, if C RTL edit, if overwrite ead830ae, or if asked to nạp. Do not self-stamp FEM_PERSIST_PASS/PROGRAM_PASS/BOARD_PASS.
HANDOFF_STATUS: COMPLETE
