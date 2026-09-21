REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-QSTAR-ABAB-BOARD / 20260922T003200Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: New identity 3ccd03f8 on Arty showed QOBS greedy 0,1,0,1. A2 kept ft=2 life=3 compacted=1 while greedy returned to 0. EOS HIGH. PROGRAM.DONE=NA. WNS=+0.468 WHS=+0.010. TIMING_PASS=NO. FEM_PERSIST_PASS=NO PROGRAM_PASS=NO BOARD_PASS=NO MIG_PASS=NO PACK_ABI_24_24_PASS=NO. C RTL unedited. No DEST_POKE.
RUN_PROVENANCE: Owner agreed to build the new identity and the board was already ready. Bit D:/FPGA/arty_d/UART_R2/build_fem_qstar_causal/uart_r2_fem_qstar_causal_candidate.bit sha256 3ccd03f80677607acfba6e45aab1fe05d6a8a99055224a244dbc3b7de275229d. JSON 302c7bd46e9262c745c3ef66fdc20d08ac378c8cae618bccb21c220c38b1c76f. JTAG 210319BE776EA EOS HIGH. COM12. Disk 1db38691 not overwritten.
OBSERVATION: QTHW echo, QARM echo, QOBS frames. Virgin greedy 0. After FREC greedy 1 with feat0=2. Influence off greedy 0 with ft still 2. Influence on greedy 1 again. FOBS after FREC recov=2 life=3 key=0x70ea ft=2.
HYPOTHESES: H1 FACT the influence mux changed the greedy action on this silicon run. H2 FACT recovered FEM state remained during A2. H3 INFERENCE the ui-to-clk100 snap delivered failure_total=2, because feat0 matched ft. H4 CONTRADICTED BOARD_PASS or FEM_PERSIST_PASS from this run. H5 FACT PROGRAM.DONE was not readable.
HOW_TRACE: Synth OK, route WNS=+0.468, bitstream, program EOS HIGH, UART script exit 0.
EVIDENCE_MATRIX:
| claim | class | evidence |
| greedy 0,1,0,1 | FACT | UART JSON QOBS |
| A2 media held | FACT | ft=2 life=3 compacted=1 |
| Live SRAM hash | UNKNOWN | not read back |
| TIMING_PASS | CONTRADICTED | positive slack is not a stamp |
SUCCESS_VS_FAILURE: The four-arm discriminator matched the XSim prediction. Failure would have been A2 staying at greedy 1 or B staying at 0.
FIRST_DIVERGENCE: NONE this run.
DECISIVE_TEST: uart_fem_qstar_abab.py on identity 3ccd03f8.
ROOT_CAUSE_OR_UNKNOWN: N/A.
REUSABLE_DECISION_PROCEDURE: Build a new SHA. Do not reuse 1db38691. Gate on QOBS not opcode echo. Require A2 to keep recovered ft.
STRUCTURAL_GUARD: Ban programming 1db38691 as this DUT. No C edit. No DEST_POKE. No PASS stamp.
BLAST_RADIUS: New bit in SRAM. Persist bit file on disk unchanged. C RTL unchanged.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE. PASS_XSIM already recorded. PASS_BOARD=NOT_A_STAMP. FEM_PERSIST_PASS=NO. PROGRAM_PASS=NO. BOARD_PASS=NO. MIG_PASS=NO. TIMING_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-QSTAR-ABAB-UART-CANDIDATE-20260922T003200Z
NEXT_DECISIVE_EXPERIMENT: Not another COMMIT read. A later arm can add SPEAR only if the candidate set stays fixed. Stop if a new run breaks A2 while FOBS is still recovered.
OWNER_AND_STOP_CONDITION: Do not stamp BOARD_PASS. Do not edit C.
HANDOFF_STATUS: COMPLETE
