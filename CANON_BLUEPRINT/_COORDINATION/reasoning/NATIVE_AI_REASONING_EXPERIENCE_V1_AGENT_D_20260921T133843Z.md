NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: D-FEM-PERSIST-COM12-RESTORE-OBSERVE / 20260921T133843Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: COM12 mute was not dest TAP failure. USB unplug left xc7a100t DONE=0. Restore of quoted identity ead830ae EOS HIGH; UART CLEAR ACK; FEM_BASE has no COMMIT magic.
RUN_PROVENANCE: Owner: COM12 is the board again after mouse mixup. JTAG 776EA Labtools 27-1435 DONE=0 then program ead830ae… EOS HIGH Labtools 27-3164. UART COM12 776EB CLEAR c1ea50a5 WALK_TAP gen=ffffffff DEST_READ FEM_HDR/COMMIT/0x50 DRAM garbage. Unique fem_persist synth started build_fem_persist. C fem_lifecycle 45b9b930… unedited.
OBSERVATION: Pre-restore UART n=0. JTAG FACT not programmed. Post-restore UART alive. FEM_COMMIT beat fffffff7 ff7fffff 00040000 00010000 != c0117ed0. PACK_E0 different garbage. Alias FEM vs pack = 0.
HYPOTHESES: H1 FACT SRAM bitstream and DDR contents lost on USB power. H2 FACT dest TAP still cannot ingress FEM (stimulus tied 0). H3 INFERENCE mouse-on-COM12 was earlier mute cause; DONE=0 is the mute cause after cable swap.
HOW_TRACE: USB yank -> DONE=0 -> UART mute. Restore same SHA -> EOS HIGH -> CLEAR/DRD1 work. FEM_BASE not written by lifecycle.
EVIDENCE_MATRIX:
| claim | class | evidence |
| DONE=0 before restore | FACT | Labtools 27-1435 |
| restore identity | FACT | SHA MATCH ead830ae EOS HIGH |
| UART live | FACT PASS_BOARD_UART | CLEAR ACK c1ea50a5 |
| no FEM COMMIT | FACT PASS_BOARD_UART | DEST_READ 0x0200010 != c0117ed0 |
| FEM_PERSIST_PASS | NO | stimulus tied 0; DRAM garbage is not persist |
SUCCESS_VS_FAILURE: Success = UART answers after restore. Failure would be DONE=1 still mute or COMMIT present without ingress.
FIRST_DIVERGENCE: Treating COM12 n=0 as dest TAP UART bug. First contrary fact is DONE=0.
DECISIVE_TEST: JTAG PROGRAM.DONE then restore quoted SHA then CLEAR.
ROOT_CAUSE_OR_UNKNOWN: Configuration lost on USB unplug. Not FEM media alias.
REUSABLE_DECISION_PROCEDURE: If UART n=0 after cable swap, JTAG DONE first. Reprogram only a previously quoted SHA. Do not red-RESET to recover UART when DONE=0.
STRUCTURAL_GUARD: Unique persist bit in build_fem_persist. Do not overwrite ead830ae file. Do not stamp FEM_PERSIST_PASS from DRAM garbage or ACK.
BLAST_RADIUS: Board SRAM/DDR contents. Frozen dest TAP bit file untouched. C RTL untouched.
VERDICT_BY_LAYER: PASS_BOARD_UART liveness on restored ead830ae. FEM persist silicon NOT_RUN. PROGRAM_PASS=NO. STOP unique bit before program until new SHA quoted.
LESSON_TO_SHARE: UART-MUTE-CHECK-JTAG-DONE-20260921T133843Z
NEXT_DECISIVE_EXPERIMENT: Finish unique fem_persist bit; owner PROGRAM=YES quoting NEW SHA; FING/FCMP DEST_READ COMMIT then FRST not ck_rst.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop if overwrite ead830ae file, C RTL edit, or FEM_PERSIST_PASS self-stamp.
HANDOFF_STATUS: COMPLETE
