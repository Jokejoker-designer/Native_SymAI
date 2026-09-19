NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: CLOSE_M1_PACK24_AND_PREPARE_M2 / PACK_ABI_24_24_PASS
RUN_ID: 20260918T180425Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: U28 exclusive FAIL_BOARD r0 V-04 n=0 after Phase4 GOLD. SETTLE 2048 after debug_clear CONTRADICTED. Owner resumed GOAL (program allowed). U29 XSim leftover+four GOLD PASS_XSIM. Not PACK_ABI_24_24_PASS.
RUN_PROVENANCE: U28 bit sha256 eea43dfb627647255fecf171643de8f952191b83e400e1937ee993fb8952d84e programmed 01:03:28 +07 End of startup HIGH. Campaign after COM12_OPEN_OK. U28 RTL not patched. C/H/freeze/gold untouched.

OBSERVATION:
- FACT PASS_BOARD_OBSERVE: U28 Phase4 WARMUP ACK, CLEAR1 ACK, V04 GOLD a5000001 n=4.
- FACT FAIL_BOARD: p5 r0 CLEAR ACK then V04 n=0. CLEAR_V04_24.json / 836935.
- CONTRADICTED: Holding loader+ui32 in reset SETTLE 2048 after CLEAR helps follow-on V-04. First follow-on died; U25 without settle had two follow-on GOLD.
- FACT PASS_XSIM: U29 leftover PASS 4892095 ns. Four V-04 GOLD 9663615 ns. BEGIN gated on qsc_c1; FIFO holds BEGIN if dest not idle.
- FACT: First U28 program+campaign chain broke on PowerShell python -c sleep; JTAG still PROGRAM_OK then campaign ran separately.

HYPOTHESES:
- H-v04-during-dest-reset (INFERENCE): Host V04 during U28 settle entered CDC while loader in reset → r0 n=0.
- H-begin-only-when-qsc (HYPOTHESIS): U29 hold BEGIN until qsc_c1 avoids that class. Unproven on board until bit+program.

HOW_TRACE: U28 bit → program HIGH → PHASE4 GOLD → r0 ACK+n=0 → freeze U28 → U29 qsc gate XSim PASS → build.

EVIDENCE_MATRIX:
| claim | class | path |
| U28 Phase4 GOLD | FACT PASS_BOARD_OBSERVE | 836935 |
| U28 24/24 | FAIL_BOARD | PACK24_U28/CLEAR_V04_24.json |
| U28 SETTLE helps | CONTRADICTED | r0 n=0 vs U25 r2 |
| U29 leftover/four V-04 | FACT PASS_XSIM | PACK24_U29/U29_XSIM.md |

SUCCESS_VS_FAILURE:
- Success: U28 first GOLD; U29 XSim four GOLD.
- Failure: 24/24 not met. U28 FAIL_BOARD earlier than U25.

FIRST_DIVERGENCE: After U28 GOLD, CLEAR ACK then V-04 n=0. U25 survived two more GOLD without SETTLE.

DECISIVE_TEST: Exclusive U28 p4p5; r0 n=0. U29 XSim four GOLD with qsc-gated BEGIN.

ROOT_CAUSE_OR_UNKNOWN: SETTLE-during-V04 INFERENCE. Board dest hang after N GOLD still UNKNOWN. Do not patch U28.

REUSABLE_DECISION_PROCEDURE: Extra dest reset after ACK must not overlap host V04 into CDC. Gate new BEGIN on dest-idle, hold FIFO, do not discard BEGIN. Do not reuse U28 SETTLE.

STRUCTURAL_GUARD: Freeze U28. Ban eea43dfb… in U29 program Tcl. U29 steer_pack = pack_lock || (pack_begin && qsc_c1).

BLAST_RADIUS: u28 campaign + u29 overlay. PACKAGE bind not overwritten. No C/gold/FE256/H.

VERDICT_BY_LAYER:
- U28 BOARD Phase4 GOLD: PASS_BOARD_OBSERVE
- U28 BOARD 24/24: FAIL_BOARD
- U29 leftover/four V-04: PASS_XSIM
- PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS: NO

LESSON_TO_SHARE: NO-V04-INTO-CDC-WHILE-DEST-RESET
NEXT_DECISIVE_EXPERIMENT: U29 bit then exclusive program and 24/24. Do not patch U28.
OWNER_AND_STOP_CONDITION: AGENT_D. Goal PACK_ABI_24_24_PASS open. No self-stamp.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
