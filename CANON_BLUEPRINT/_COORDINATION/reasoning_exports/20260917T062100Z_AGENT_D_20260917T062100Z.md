NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: GOAL_AGENT_D FINAL R2 / H19_BOARD
RUN_ID: 20260917T062100Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: First A-01 after identity H program is UNSUP even when Python writes exactly 132 bytes. Under test: Python-join extra byte vs FTDI/PHY/FPGA. Not PACK_ABI_24_24_PASS.
RUN_PROVENANCE:
  bit sha256 cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9
  program 2026-09-17T13:20:58+07 End of startup HIGH JTAG 210319BE776EA PROGRAM_PASS=NO
  script uart_h19_board_probe.py (frozen uart_pack24_clear_board.py not edited)
  jsonl sha256 3aa5d56e950b89b6bed64ec221bbe2090d00e56e684891e710a0d17a34f99650
  H19 XSim log sha256 7ffd4627e216796fdba7a9f0f7ba5147e5be2e440d277576a4e8012c0f4834d6
OBSERVATION:
  FACT — pre-program CLEAR rx_n=0 NO_BYTE (leave-state mute).
  FACT — reprogram identity H SHA MATCH End of startup HIGH.
  FACT — i=0 CLEAR tx=4 ACK a550eac1; PACK tx=132/132 exact=true UNSUP 5a070002.
  FACT — i=1 and i=2 ACK then NAK_R02 5a020002 exact 132.
  FACT — in_waiting 0 before/after CLEAR. Pack rx_n=4 (one word).
  FACT — read_raw idle 0.15s after ACK before A-01.
  UNKNOWN — whether FPGA RX first byte after ACK is 0x00 (needs ILA).
HYPOTHESES:
  H-py (REJECTED): pyserial join added a byte. tx_n==132.
  H-overlap (REJECTED this script): host sent A-01 during ACK UART. 0.15s idle.
  H-first (SUPPORTED): first pack after program is UNSUP; later A-01 NAK like XSim.
  H-ftdi (HYPOTHESIS): FTDI/PHY inserts 0x00 on first bulk TX after ACK.
  H-fpga (HYPOTHESIS): FPGA RX/mig0/query path corrupts first opcode without an extra UART byte.
HOW_TRACE:
  mute probe -> reprogram existing H bit -> exact-length A-01 isolate -> compare H19 XSim
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  Mute leave | n=0 | pre-program probe | PASS_BOARD contact
  Program | H cf62102f | PROGRAM.txt / vivado_prog.log | PROGRAMMED CANDIDATE not PROGRAM_PASS
  Exact TX | 132/132 | jsonl | PASS_BOARD
  i0 token | 0200075a | jsonl | PASS_BOARD
  i1-2 token | 0200025a | jsonl | PASS_BOARD
  Extra source | 0x00 on RX | ILA missing | UNKNOWN
SUCCESS_VS_FAILURE:
  Success: closed Python extra-byte; reproduced isolate i0 UNSUP / later NAK.
  Failure: GOAL open; ILA not in this bit (Labtools: no supported soft debug core); CLASS B not this arm.
FIRST_DIVERGENCE:
  Board i=0 PACK UNSUP vs i=1 PACK NAK with identical exact 132 B A-01 after ACK.
DECISIVE_TEST:
  This isolate. Next ILA bix/first RX byte on first pack after program.
ROOT_CAUSE_OR_UNKNOWN:
  Python extra REJECTED. First-after-program UNSUP SUPPORTED. SOURCE of phase error UNKNOWN.
REUSABLE_DECISION_PROCEDURE:
  Log tx_n vs 4*nwords before blaming host join. First-after-program is a distinct case from later NAK.
STRUCTURAL_GUARD:
  GUARD_ID G-H19-POST-ACK-PAD still. Do not stamp Pack PASS from i1 NAK.
BLAST_RADIUS:
  Probe script + jsonl + reprogram H. Frozen host / gold / C RTL / freeze DCP untouched. No Identity I.
VERDICT_BY_LAYER:
  PASS_XSIM: H19 extra-byte mechanism.
  PASS_BOARD: isolate sequence only; not BOARD_PASS.
  PROGRAM_PASS: NO.
LESSON_TO_SHARE: D-H19-BOARD-EXACT-TX-20260917T062100Z
NEXT_DECISIVE_EXPERIMENT:
  ILA on uart_rx_word bix/w_data first word after ACK on first pack after program. Same H top has no debug core today.
OWNER_AND_STOP_CONDITION:
  Stop Pack PASS. Owner ILA on debug top required to name RX byte. Do not build Identity I.
HANDOFF_STATUS: COMPLETE for H19 board arm; GOAL_AGENT_D INCOMPLETE
