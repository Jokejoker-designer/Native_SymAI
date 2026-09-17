NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: GOAL_AGENT_D FINAL R2 / H19_ACK_PAD
RUN_ID: 20260917T061500Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Silicon A-01 isolate first PACK UNSUP can be produced on the BRAM UART harness by one extra 0x00 after CLEAR ACK. Under test: that mechanism vs baud-gap / hold-overlap / word-TB PASS. Not a claim that FTDI is proven on board.
RUN_PROVENANCE:
  TB tb_h19_ack_pad_a01.sv
  bat D:/FPGA/arty_d/first_divergence_01/run_xsim_h19_ack_pad_a01.bat
  log sha256 7ffd4627e216796fdba7a9f0f7ba5147e5be2e440d277576a4e8012c0f4834d6
  JSON D:/FPGA/arty_d/first_divergence_01/H19_ACK_PAD_A01_XSIM.json
  PA24-A-01.mem first word 00800001
  B compare log sha256 21dae23d6ddd8ae59f1260b792fb0c2d95b0c9f01870289fdd9291f10a94afc1 24/24 at 15805 ns
  identity H bit cf62102f… unchanged. PRODUCT_RTL_CHANGED=NO GOLD_CHANGED=NO PROGRAM=NO
OBSERVATION:
  FACT — H19 CLEAR ACK c1ea50a5 bix=0 t=956615 ns.
  FACT — extra 0x00 sets bix=1 t=1043415 ns.
  FACT — A-01 then PACK 0200075a first_p=80000100 n_p=33 reason=07 bix=1 finish 12570465 ns banner H19_ACK_PAD_XSIM_UNSUP.
  FACT — H16 without extra byte is NAK_R02 first_p=BEGIN.
  FACT — H16 hold-overlap S_ACK still NAK first_p=BEGIN n_drop=0.
  FACT — B tb_pack_abi24_xsim_compare 24/24 word-stream; not UART; not board.
  UNKNOWN — whether silicon actually inserts that 0x00 (FTDI/host/PHY).
HYPOTHESES:
  H-H19a (SUPPORTED PASS_XSIM): 00 + BEGIN LE 01 00 80 00 → first word 80000100 opcode 0 → R_UNSUP. Matches isolate token.
  H-H19b (HYPOTHESIS): silicon A-01 isolate is this byte, not mig0 opcode corruption.
  H-H19c (NOT_ADDRESSED): CLASS B sticky mute after A-01.
HOW_TRACE:
  GOAL continue
  -> skip another clean 115200 NAK replay
  -> inject extra byte AFTER ACK (FTDI leftover arm listed as NEXT)
  -> xvlog/xelab/xsim UG900 three-step
  -> record hashes; no PASS stamps
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  Token | 0200075a | xsim.log banner | PASS_XSIM
  Shift | first_p 80000100 | xsim.log | PASS_XSIM
  Contrast | no extra → NAK BEGIN | H16 | PASS_XSIM
  Silicon source | extra byte present | not measured | UNKNOWN
  D-03 B TB | 24/24 | pack_abi24_b_compare xsim.log | PASS_XSIM not PACK_ABI_24_24_PASS
SUCCESS_VS_FAILURE:
  Success: named CLASS A isolate mechanism on UART harness without new product RTL.
  Failure: GOAL still open; board extra-byte unproven; CLASS B open; FEM persist blocked.
FIRST_DIVERGENCE:
  After ACK, bix 0 vs 1. One 0x00 is the divergence from H16 NAK to H19 UNSUP.
DECISIVE_TEST:
  This run. Next: ILA/host capture of first UART RX byte after CLEAR ACK on identity H.
ROOT_CAUSE_OR_UNKNOWN:
  Mechanism of UNSUP after ACK named (byte phase). Silicon source UNKNOWN. COMMON_ROOT UNKNOWN.
REUSABLE_DECISION_PROCEDURE:
  When board token is UNSUP after a good ACK, first test extra byte BETWEEN ack and payload, not only extra before CLEAR.
STRUCTURAL_GUARD:
  GUARD_ID: G-H19-POST-ACK-PAD
  Do not treat H19 as BOARD_PASS or Pack ladder. Do not change gold to expect UNSUP.
BLAST_RADIUS:
  New TB + xsim dir + STATUS/GOAL/reasoning. Identity H bit, C RTL, B gold, freeze DCP untouched.
VERDICT_BY_LAYER:
  PASS_XSIM: H19 UNSUP mechanism; B 24/24 word.
  PASS_BOARD: no.
  PACK_ABI_24_24_PASS: no.
LESSON_TO_SHARE: D-H19-ACK-PAD-UNSUP-20260917T061500Z
NEXT_DECISIVE_EXPERIMENT:
  Capture silicon first byte after CLEAR ACK (ILA or raw host n=1). If 0x00, H19 maps to board. If not, reopen mig0/query mux.
OWNER_AND_STOP_CONDITION:
  Stop Pack PASS stamps. Stop another clean A-01 baud arm. Owner ILA/program still required to name the extra byte on silicon.
HANDOFF_STATUS: COMPLETE for H19 arm; GOAL_AGENT_D INCOMPLETE
