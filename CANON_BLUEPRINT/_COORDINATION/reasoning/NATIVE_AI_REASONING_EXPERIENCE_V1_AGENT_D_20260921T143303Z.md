NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: D-FEM-PERSIST-UNIQUE-BIT-BOARD / 20260921T143303Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Unique FEM persist bitstream 1db38691… is programmed on Arty A7-100T. BIT_OK WNS=+0.737 WHS=+0.027. UART CLEAR ACK and FEM opcode echo. Dest COMMIT at 0x0200010 is not 0xC0117ED0. FEM_PERSIST_PASS=NO. PROGRAM_PASS=NO. BOARD_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. PACK_ABI_24_24_PASS=NO.
RUN_PROVENANCE: Owner 2026-09-21 "Ok board sẵn rồi nên có thể bitstream luôn cho tôi nhé". Unique tree D:/FPGA/arty_d/UART_R2/fem_persist. Unique out D:/FPGA/arty_d/UART_R2/build_fem_persist. Ban ead830ae / daaca9c1 / 8bfd993d. C fem_lifecycle.v unedited. Bit sha256 1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668. JTAG Digilent 210319BE776EA. UART COM12. PROGRAM.txt + UART_SMOKE.json under results/FEM_PERSIST_OWNER_PROGRAM_20260921/.
OBSERVATION: First unique route WNS=-2.497 with 3 combo loops. Steal fix -> loops=0 still WNS=-2.514 sys_clk_pin->clk_pll_i u_fcdc/op_hold_reg->FSM_sequential_ust_reg requirement 2.000 ns. Intra 100 MHz UART steal->fifo used WNS=-0.285. After op_u/arg_u sample + fifo_push FF + XDC datapath_only: WNS=+0.737 WHS=+0.027 loops=0 BIT_OK. Program EOS HIGH Labtools 27-3164. CLEAR n=4 ack c1ea50a5. FOBS_PRE life=7. FING x4 + FCMP echo. DEST_READ 0x0200010 beat fffffff7 ff7fffff 000070ea 00010000 commit_magic=0. FOBS_AFTER_CMP compacted=0 life=1 n_raw=2 cmp_result=1 key=70ea. FRST FOBS life=7 key=0. FREC FOBS recov=0 life=1 key=70ea. XSim dest COMMIT was c0117ed0 and recover=2.
HYPOTHESES: H1 FACT loops=0 after steal fix; remaining -2.514 was CDC hold used in UI FSM. H2 FACT sampling op_hold into op_u plus max_delay closed BIT_OK. H3 FACT silicon FEM UART plane is alive (CLEAR/FOBS/FING/FCMP/FRST/FREC). H4 FACT dest lane0 at 0x0200010 is not COMMIT_MAGIC after FCMP. H5 HYPOTHESIS compact did not dest-complete on real mig0 (compacted=0, recov=0). H6 UNKNOWN whether address fold, T2, calib window, or FEM_BASE mapping caused the miss. H7 CONTRADICTED that FOBS key=70ea proves dest COMMIT.
HOW_TRACE: clk100 fem_ctrl_uart steal FING/FCMP -> fem_ctrl_cdc req_tog 2FF -> sample op_u/arg_u -> UI pulses into frozen C fem_on_mig/fem_lifecycle -> fem_req_ui FEM_BASE. DEST_READ dest_diag_ui 0x0200010 four beats. FRST holds fem_rst_n only.
EVIDENCE_MATRIX:
| claim | class | evidence |
| BIT_OK WNS>=0 | FACT PASS_IMPLEMENTED | BUILD.txt STATUS=BIT_OK WNS=0.737 WHS=0.027; check_timing loops=0 |
| unique identity | FACT | bit sha256 1db38691… not ead830ae/daaca9c1/8bfd993d |
| programmed this SHA | FACT UART_BOARD_SMOKE_CANDIDATE | program.log 27-3164 EOS HIGH; PROGRAM.txt SHA MATCH |
| UART alive | FACT | CLEAR ack=1 COM12 |
| FEM opcodes wired | FACT | FOBS/FING/FCMP/FRST/FREC echo |
| dest COMMIT magic | FACT fail on board | DEST_READ commit_magic=0 vs XSim c0117ed0 |
| recover_state=2 | FACT fail on board | FOBS_AFTER_FREC recov=0 |
| FEM_PERSIST_PASS | NO | dest magic missing |
| PROGRAM_PASS | NO | PROGRAM.DONE=NA; D does not self-stamp |
SUCCESS_VS_FAILURE: Success for bitstream = unique BIT_OK + quoted SHA programmed + EOS HIGH + no overwrite of dest TAP. Failure for persist discriminator = DEST_READ != C0117ED0 or recov!=2.
FIRST_DIVERGENCE: Timing: op_hold combinational use in UI FSM (not loops). Silicon vs XSim: DEST_READ 0x0200010 lane0 after FCMP.
DECISIVE_TEST: BIT abort WNS<0 then CDC sample rebuild; DEST_READ 0x0200010 == C0117ED0 after FCMP.
ROOT_CAUSE_OR_UNKNOWN: BIT_OK: CDC hold sample. Dest COMMIT miss: UNKNOWN (mig0 vs mig_ui_bram). Do not DEST_POKE COMMIT. Do not edit C RTL.
REUSABLE_DECISION_PROCEDURE: 1) check_timing loops. 2) If loops=0 and WNS~-2.5 on 100->UI, look at handshake data into dest-clock FSM. 3) Sample holds in dest clock + datapath_only. 4) Board persist = DEST_READ magic, FEM-only FRST, magic still, FREC recov=2. FOBS key is not dest proof.
STRUCTURAL_GUARD: Unique build_fem_persist. 96_bit aborts WNS<0. 97_program bans ead830ae/daaca9c1/8bfd993d. FRST != red RESET. No DEST_POKE COMMIT. C N_RAW=4 frozen.
BLAST_RADIUS: fem_persist tree, build_fem_persist, results/FEM_PERSIST_OWNER_PROGRAM_20260921. Live board now 1db38691 not ead830ae. dest TAP bit file on disk untouched.
VERDICT_BY_LAYER: PASS_XSIM prior isolated/UART persist; PASS_IMPLEMENTED WNS=+0.737; UART_BOARD_SMOKE_CANDIDATE; DEST_COMPLETE_BOARD=NO; FEM_PERSIST_PASS=NO; PROGRAM_PASS=NO; TIMING_PASS=NO; MIG_PASS=NO; BOARD_PASS=NO.
LESSON_TO_SHARE: FEM-PERSIST-CDC-HOLD-SAMPLE-AND-DEST-MAGIC-20260921T143303Z
NEXT_DECISIVE_EXPERIMENT: Classify why 0x0200010 is not C0117ED0 on mig0 after FCMP (MEMORY|T2|ADDRESS|MIG) without C RTL edit and without DEST_POKE. Optional wait longer after FCMP before DEST_READ. Do not stamp FEM_PERSIST_PASS.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop if C RTL edit, N_RAW>4, overwrite ead830ae, red RESET, or self-stamp FEM_PERSIST_PASS/PROGRAM_PASS/BOARD_PASS/MIG_PASS/TIMING_PASS.
HANDOFF_STATUS: COMPLETE
