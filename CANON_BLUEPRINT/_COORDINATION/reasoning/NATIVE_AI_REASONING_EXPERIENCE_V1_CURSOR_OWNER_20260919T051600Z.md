NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: GITHUB-AUDIT-WATCH-U33-BOARD-FAIL
RUN_ID: 20260919T051600Z
OWNER_AGENT: CURSOR_OWNER (publish) / AGENT_D (parent program)
CURRENT_CLAIM: U33 exclusive board is FAIL_BOARD MAG at p5 V-04 r3 after CLEAR1 ACK and four GOLDs. Not PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS.
RUN_PROVENANCE:
  Parent chat 31dc87bc; owner PROGRAM=YES 2026-09-19
  Bit uart_r2_u33_candidate.bit sha256 ff399e0b…
  Evidence D:/FPGA/arty_d/UART_R2/results/PACK24_U33/U33_FAIL.md
OBSERVATION:
  FACT — End of startup HIGH JTAG 210319BE776EA; PROGRAM.txt STATUS=PROGRAMMED PROGRAM_PASS=NO
  FACT — CLEAR1 ACK c1ea50a5 n=4 (U32 dest-AND board/XSim was CLEAR1 BUSY)
  FACT — PHASE4 and p5 r0–r2 V-04 GOLD 010000a5
  FACT — FIRST_DIVERGENCE p5 r3 MAG 0200015a n=4
  FACT — Pack24 not started
HYPOTHESES:
  H1 U33 qsc without dest_ui AND unblocks CLEAR1 on board. SUPPORTED this run.
  H2 MAG after 4 GOLD is leftover/UART/MIG class. UNKNOWN
HOW_TRACE:
  parent program U33 -> nwp4p5 COM12 -> copy FAIL evidence -> GitHub no PASS
EVIDENCE_MATRIX:
  U33 CLEAR1 ACK | board UART n=4 | FACT board
  U33 MAG p5 r3 | p5_v03.json 01962c63 | FACT board
  PACK_ABI | missing 24/24 + Pack24 dest | NO
SUCCESS_VS_FAILURE:
  Success vs U32: CLEAR1 ACK + GOLD reached.
  Failure: MAG at p5 r3; 24/24 open.
FIRST_DIVERGENCE: p5 V-04 round 3 MAG vs round 2 GOLD.
DECISIVE_TEST: already run nwp4p5; do not overlay.
ROOT_CAUSE_OR_UNKNOWN: CLEAR1 class weakened on U33 board. MAG root UNKNOWN.
REUSABLE_DECISION_PROCEDURE: Split CLEAR1 token class from later MAG. Do not stamp PACK_ABI from CLEAR1 ACK+partial GOLD.
STRUCTURAL_GUARD: Do not copy U33 bit as product identity. Identity H / freeze untouched.
BLAST_RADIUS: audit publish only.
VERDICT_BY_LAYER:
  PASS_BOARD: NO (FAIL_BOARD MAG)
  PROGRAM_PASS: NO
  PACK_ABI_24_24_PASS: NO
LESSON_TO_SHARE: U33_BOARD_CLEAR1_ACK_THEN_P5_MAG
NEXT_DECISIVE_EXPERIMENT: classify MAG 0200015a after GOLD without UART overlay.
OWNER_AND_STOP_CONDITION: Watch publish. Stop: no PASS stamp, no second identity.
HANDOFF_STATUS: COMPLETE
