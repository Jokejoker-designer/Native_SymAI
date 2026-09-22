REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-SPEAR-QSTAR-BOARD / 20260922T015300Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: New identity 8b632b4a programmed EOS HIGH. UART action 0,1,0,1 follows rank A,B,A,B. Bases fixed. legal_mask 3. FEM not wired into Q*. BOARD_PASS=NO. Prior identities kept on disk.
RUN_PROVENANCE: XSim freeze PASS_XSIM on fem_rank_action log. Bit build_fem_spear_qstar sha256 8b632b4ac5317f6176cf62103b88bfcdf637b8d4dec495717db9615eea3d3ad7. JSON 7cc2f947e0077f7cce0438eff789d0bec48dcfa6763f0c260005a54b4bd7599e. WNS=+0.369. C RTL unedited.
OBSERVATION: OFF rank 0xA1 feat0 0 greedy 0. ON rank 0xB1 feat0 2 greedy 1. Repeated. ft stayed 2.
HYPOTHESES: H1 FACT the silicon action followed rank-0. H2 FACT legality mask did not change. H3 CONTRADICTED BOARD_PASS.
HOW_TRACE: Build, program EOS HIGH, UART script exit 0.
EVIDENCE_MATRIX:
| claim | class | evidence |
| action 0,1,0,1 | FACT | UART print and JSON |
| direct FEM to Q* | CONTRADICTED | feat_q comes from rank0 compare |
| ASTRA | NOT_IN_THIS_TEST | mask is a constant |
SUCCESS_VS_FAILURE: Success is the four-arm action sequence with fixed bases. Failure would be action stuck while rank flips.
FIRST_DIVERGENCE: NONE this run.
DECISIVE_TEST: uart_fem_spear_qstar.py
ROOT_CAUSE_OR_UNKNOWN: N/A
REUSABLE_DECISION_PROCEDURE: Drive Q* from rank-0 code only. Keep legal_mask constant. Log rank, feat, and action in one frame.
STRUCTURAL_GUARD: Do not overwrite 52b923a6, 3ccd03f8, or 1db38691. Do not stamp BOARD_PASS. Do not edit C RTL.
BLAST_RADIUS: SRAM now 8b632b4a. Prior bit files kept.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE. PASS_XSIM already frozen. BOARD_PASS=NO. PROGRAM_PASS=NO. FEM_PERSIST_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-SPEAR-QSTAR-UART-CANDIDATE-20260922T015300Z
NEXT_DECISIVE_EXPERIMENT: None until an owner asks to route this action through a live ASTRA legality path.
OWNER_AND_STOP_CONDITION: Stop if a later note treats this mask as an ASTRA result.
HANDOFF_STATUS: COMPLETE
