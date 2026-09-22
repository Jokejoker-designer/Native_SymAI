REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: FEM-QSTAR-ABAB-CLOSURE / 20260922T003600Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Independent check of identity 3ccd03f8 A/B/A/B found no contradiction on provenance, mux-only change, A2 discriminator, QOBS latch timing, or idle SPEAR. BOARD_PASS=NO. PROGRAM.DONE=NA. Live SRAM hash not read. C RTL unedited.
RUN_PROVENANCE: UART JSON 302c7bd4…. Bit rehashed this turn to 3ccd03f8…. Persist disk bit still 1db38691…. Synth Tcl reads fem_qstar_causal top. No reprogram this audit.
OBSERVATION: One QTHW before A. No FRST or QTHW from QARM_B through QOBS_B2. A2 raw words greedy 0 q_sel 0 feat0 0 ft 2 life 3 compacted 1. B2 returns q_sel 2. QARM echo is issued in the same step that latches Q* greedy and q_sel.
HYPOTHESES: H1 FACT A2 mux-off with recovered ft. H2 FACT theta was not reloaded between arms. H3 INFERENCE theta contents stayed at the single QTHW write because B2 q_sel is 2. H4 CONTRADICTED a stale QOBS copy of the previous arm. H5 UNKNOWN live SRAM hash.
HOW_TRACE: Rehash bit. Decode QOBS words. Read qstar ties and qstar_dec_uart S_WAIT. Count JSON steps.
EVIDENCE_MATRIX:
| claim | class | evidence |
| Bit is the causal tree | FACT | hash and synth path |
| A2 recovered and greedy 0 | FACT | raw QOBS words |
| SPEAR idle | FACT | tied ports in causal top |
| BOARD_PASS | CONTRADICTED | ceiling |
SUCCESS_VS_FAILURE: Success is no contradiction on the five checks. A contradiction would be a second QTHW, an FRST before A2, or q_sel stuck across arms.
FIRST_DIVERGENCE: NONE versus the JSON and the causal RTL.
DECISIVE_TEST: This file and RTL read. No new silicon.
ROOT_CAUSE_OR_UNKNOWN: N/A.
REUSABLE_DECISION_PROCEDURE: Require QARM echo before QOBS. Require q_sel to change with the arm. Require B2 without a second theta write before calling A2 a mux effect.
STRUCTURAL_GUARD: Do not stamp BOARD_PASS. Do not treat PROGRAM.DONE=NA as PROGRAM_PASS. Do not edit C.
BLAST_RADIUS: Classification only. SRAM and bit files untouched.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE stands. BOARD_PASS=NO. PROGRAM_PASS=NO. FEM_PERSIST_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. PACK_ABI_24_24_PASS=NO.
LESSON_TO_SHARE: FEM-QSTAR-ABAB-CLOSURE-NO-CONTRADICTION-20260922T003600Z
NEXT_DECISIVE_EXPERIMENT: None required for these five checks unless a new capture contradicts them.
OWNER_AND_STOP_CONDITION: Stop if a later note rewrites this JSON or restamps BOARD_PASS.
HANDOFF_STATUS: COMPLETE
