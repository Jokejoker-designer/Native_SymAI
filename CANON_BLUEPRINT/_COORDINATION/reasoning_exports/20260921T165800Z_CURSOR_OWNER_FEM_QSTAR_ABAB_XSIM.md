REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-QSTAR-ABAB-XSIM / 20260921T165800Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Same-clock XSim of fem_qstar_infl on mig_ui_bram produced greedy 0,1,0,1 at 12445 ns. Arm A2 kept failure_total=2 and life=3 while influence off returned greedy 0. PASS_XSIM only. Bit NOT_BUILT. Board not programmed. C RTL unedited. PASS ceilings unchanged.
RUN_PROVENANCE: Owner agreed to the design then said the board is ready. This run is the XSim gate, not a program. Log sha256 a4d5576ea6212dad70719b95dece8b4e6d62bd2a9deb38c399c167e30edee944. DUT fem_qstar_infl.sv. Frozen fem_lifecycle 45b9b930 and qstar_select d4f64e65 compiled from CANON, not edited. Lease file until 2026-09-21T05:00Z is expired; no JTAG.
OBSERVATION: A feat0=0 greedy=0. B feat0=2 q_sel=2 greedy=1. A2 infl=0 feat0=0 ft still 2 life still 3 greedy=0. B2 greedy=1. explored=0 prop_valid=1 on all four. Theta survived FEM-only reset.
HYPOTHESES: H1 FACT the mux isolates FEM influence in this sim. H2 FACT 1db38691 cannot reproduce it. H3 UNKNOWN on silicon and across a clock domain. H4 CONTRADICTED any PASS stamp above PASS_XSIM.
HOW_TRACE: Wrote D wrapper and TB. xvlog/xelab/xsim Vivado 2026.1. First compile failed on default_nettype none. Rerun exit 0.
EVIDENCE_MATRIX:
| claim | class | evidence |
| greedy 0,1,0,1 | FACT | log lines ARM A B A2 B2 |
| A2 media unchanged | FACT | ft=2 life=3 on A2 line |
| Board decision | NOT_TESTED | no bitstream |
| MIG_PASS | CONTRADICTED | mig_ui_bram stand-in |
SUCCESS_VS_FAILURE: Success is the four greedy values with media held on A2. Failure would be a tie staying at 0 after recovery, or FRST clearing theta.
FIRST_DIVERGENCE: NONE this sim.
DECISIVE_TEST: tb_fem_qstar_abab.sv finish 12445 ns.
ROOT_CAUSE_OR_UNKNOWN: N/A.
REUSABLE_DECISION_PROCEDURE: Exam mode, one theta weight, mux only feature 0, FEM-only reset so theta survives, require A2 to restore greedy 0 while ft stays recovered.
STRUCTURAL_GUARD: Do not program 1db38691 for this question. Do not edit C. Do not stamp BOARD_PASS from PASS_XSIM.
BLAST_RADIUS: New tree sim only. Persist bit on disk untouched. Board SRAM untouched.
VERDICT_BY_LAYER: PASS_XSIM. PASS_BOARD=NOT_RUN. FEM_PERSIST_PASS=NO. PROGRAM_PASS=NO. BOARD_PASS=NO. MIG_PASS=NO. TIMING_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-QSTAR-ABAB-PASS-XSIM-20260921T165800Z
NEXT_DECISIVE_EXPERIMENT: A new unique bitstream with the same mux and a UART QOBS plane, then owner PROGRAM of that quoted SHA. Not a persist-repeat bit.
OWNER_AND_STOP_CONDITION: Stop if C RTL is edited or the old persist SHA is programmed as the decision DUT.
HANDOFF_STATUS: COMPLETE
