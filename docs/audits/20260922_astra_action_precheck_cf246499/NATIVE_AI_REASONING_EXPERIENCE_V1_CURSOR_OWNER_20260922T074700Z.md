REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: ASTRA-ACTION-PRECHECK-BOARD / 20260922T074700Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: New identity cf246499 programmed EOS HIGH. UART matrix A/B/A2/C/D matches BOUND, SAFETY_VETO, BOUND, STALE_DESCRIPTOR, NO_BINDING. Proposal fixed at 1. ASTRA_ACTION_PRECHECK_BOARD_CANDIDATE=SUPPORTED. ASTRA_PASS=NO. Codes B0-B4 are packing, not a locked ABI.
RUN_PROVENANCE: XSim freeze PASS_XSIM. Bit build_astra_action_precheck sha256 cf246499c6e5c09b57fefdd89dc5d6602fc7ded5dc2426d635a0987fc2bc8dae. WNS=+5.404 WHS=+0.074. No FEM/SPEAR/Q* edit. 8b632b4a not rebuilt.
OBSERVATION: First D stimulus had the stale bit set and the DUT returned B3. Corrected flags 0x03 returned B4 and final FF. A2 restored action 01.
HYPOTHESES: H1 FACT silicon matches the five-arm matrix on the corrected stimulus. H2 FACT verdict bytes are outside 0x01-0x06. H3 CONTRADICTED ASTRA_PASS.
HOW_TRACE: Build, program EOS HIGH, UART script nfail 0 on the second run.
EVIDENCE_MATRIX:
| claim | class | evidence |
| Five-arm silicon matrix | FACT | UART_ACTION_PRECHECK.json nfail 0 |
| First D miss | FACT | stale bit set in the host word |
| ABI lock of B0-B4 | CONTRADICTED | spec says packing only |
SUCCESS_VS_FAILURE: Success is the corrected five-arm capture. The first D row was a host flag error, and the DUT followed stale-first priority.
FIRST_DIVERGENCE: Host arm D used 0b0111, which includes descriptor_stale.
DECISIVE_TEST: Second UART run flags 0x03.
ROOT_CAUSE_OR_UNKNOWN: Host bit packing, not the precheck priority.
REUSABLE_DECISION_PROCEDURE: Echo the condition word and check it before blaming the verdict.
STRUCTURAL_GUARD: Do not stamp ASTRA_PASS. Do not treat B0-B4 as ABI. Do not rebuild 8b632b4a.
BLAST_RADIUS: New SRAM identity cf246499. Prior bit files kept.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE. PASS_XSIM already frozen. ASTRA_PASS=NO. BOARD_PASS=NO. PROGRAM_PASS=NO. TIMING_PASS=NO.
LESSON_TO_SHARE: ASTRA-ACTION-PRECHECK-BOARD-CANDIDATE-20260922T074700Z
NEXT_DECISIVE_EXPERIMENT: None required to repeat this matrix. A later step can connect a real capability descriptor without collapsing verdicts into query status.
OWNER_AND_STOP_CONDITION: Stop if B0-B4 is called a locked ABI or ASTRA_PASS is stamped.
HANDOFF_STATUS: COMPLETE
