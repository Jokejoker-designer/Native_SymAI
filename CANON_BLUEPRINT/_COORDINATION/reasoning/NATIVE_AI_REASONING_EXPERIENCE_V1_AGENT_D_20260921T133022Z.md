NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: D-FEM-PERSIST-RESET-UART-XSIM / 20260921T133022Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Unique FEM persist tree proves dest COMMIT 0xC0117ED0 held across rst_n/FRST and recovery restores life/key/ft. PASS_XSIM only. Not FEM_PERSIST_PASS. Not silicon. C fem_lifecycle unedited.
RUN_PROVENANCE: Owner 2026-09-21 "Tiếp tục đi sang phần FEM persist / developmental memory thôi". Unique tree D:/FPGA/arty_d/UART_R2/fem_persist. Does not overwrite ead830ae / daaca9c1 / 8bfd993d. C fem_lifecycle.v sha256 45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed MATCH AGENT_C. Isolated TB sha256 ff90968a… log c260ce51… 7215 ns. UART TB sha256 54ffff13… log a25d2017… 3057395 ns. Top 825ad8cb… fem_ctrl_uart c4c1f3df… fem_ctrl_cdc 9de9333f…
OBSERVATION: Isolated XSim AFTER_CMP commit=c0117ed0 hdr=03000213 life=3 ft=2 key=70ea; AFTER_RST life=7 commit=c0117ed0 ft=0; AFTER_REC recover=2 life=3 ft=2 key=70ea. UART XSim same causal sequence via FING/FREP/FCMP/DEST_READ/FRST/FREC/FOBS. Live ead830ae COM12 CLEAR n=0 MUTE; FEM_BASE DEST_READ not observed. Current dest TAP bit still ties ing_valid/cmp/rec to 0.
HYPOTHESES: H1 FACT dest media holds COMMIT across fabric FEM reset because mig_ui_bram has no async RAM reset and FRST does not reset MIG. H2 FACT C volatile (life/ft/key) wipes on rst_n and rec_start rereads dest. H3 HYPOTHESIS COM12 mute is leave-state/USB/power, not FEM_BASE alias. H4 CONTRADICTED that FIFO-empty is persist (proxy guard still in isolated TB).
HOW_TRACE: C fem_on_mig -> fem_t2_ce dest-complete -> fem_req_ui FEM_BASE+{addr,00} -> mux B -> mig_ui_bram dest[{addr[21:20],addr[13:4]}]. A_COMMIT=4 beat 0x0200010 lane0. Rec path R_CLASS restores hdr then COMMITTED_NEW sets L_COMPACTED.
EVIDENCE_MATRIX:
| claim | class | evidence |
| dest COMMIT after compact | FACT PASS_XSIM | AFTER_CMP / DEST_READ w0=c0117ed0 |
| dest COMMIT after rst/FRST | FACT PASS_XSIM | AFTER_RST / DEST_READ after FRST still c0117ed0 |
| volatile wipe | FACT PASS_XSIM | life=7 ft=0 after rst/FRST |
| rec restores | FACT PASS_XSIM | recover=2 life=3 ft=2 key=70ea |
| silicon FEM persist | NOT_RUN | no unique bit; ead830ae stimulus tied 0; COM12 MUTE |
| FEM_PERSIST_PASS | NO | XSim != board MIG dest |
SUCCESS_VS_FAILURE: Success = dest COMMIT stable and rec restores. Failure would be COMMIT wiped by rst_n or rec OLD_VALID/integrity_fault.
FIRST_DIVERGENCE: Prior FEM_MIG_UI32_XSIM recovered without reset (live FSM reread). First divergence for developmental memory is pulse rst_n/FRST between compact and rec.
DECISIVE_TEST: Isolated rst_n then rec; UART FRST then FREC with DEST_READ COMMIT between. Both PASS_XSIM.
ROOT_CAUSE_OR_UNKNOWN: Designed: T2 canonical dest vs volatile C registers. UART mute UNKNOWN (not a FEM result).
REUSABLE_DECISION_PROCEDURE: Persist discriminator = compact -> read COMMIT -> reset FEM only -> COMMIT still magic -> rec_start -> recover_state=2 and life/key/ft match pre-reset. Do not stamp FEM_PERSIST_PASS from XSim or ACK.
STRUCTURAL_GUARD: FRST = fem_rst_n only. Do not ck_rst (MIG recalib wipes DRAM). Do not DEST_POKE COMMIT as persist. C RTL frozen N_RAW=4. Unique bit required; do not overwrite ead830ae.
BLAST_RADIUS: Unique fem_persist tree only. Not gold.py. Not C RTL. Not FE256 freeze. Not dest TAP bit.
VERDICT_BY_LAYER: PASS_XSIM isolated 7215 ns; PASS_XSIM UART 3057395 ns; PASS_BOARD=NO; FEM_PERSIST_PASS=NO; PROGRAM=NO; STOP_BEFORE_IMPL.
LESSON_TO_SHARE: FEM-PERSIST-RESET-DEST-HOLDS-20260921T133022Z
NEXT_DECISIVE_EXPERIMENT: Unique impl/bit (new SHA, new build dir). Owner PROGRAM=YES quoting that SHA. Board: FING..FCMP, DEST_READ 0x0200010 == C0117ED0, FRST (not red RESET), DEST_READ still magic, FREC restore. Do not stamp FEM_PERSIST_PASS from one hop.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop if C RTL edit, N_RAW>4, overwrite ead830ae, ck_rst/red RESET for persist, or self-stamp FEM_PERSIST_PASS/PROGRAM_PASS/BOARD_PASS/MIG_PASS.
HANDOFF_STATUS: COMPLETE
