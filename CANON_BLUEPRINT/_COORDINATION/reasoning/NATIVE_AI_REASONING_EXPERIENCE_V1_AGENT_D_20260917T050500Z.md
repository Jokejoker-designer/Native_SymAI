NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: GOAL_AGENT_D FINAL R2 / D-PACK-SILICON-FIRST-DIVERGENCE-01
RUN_ID: 20260917T050500Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Owner said JTAG nạp is allowed. GOAL PROGRAM=NO is no PROGRAM_PASS stamp. Host pad3 recovers silicon CLASS A leftover and prevents CLASS B mute.
RUN_PROVENANCE:
  Tcl 32_program_m4_mig_clear.tcl / run_program.bat
  bit sha256 cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9
  JTAG 210319BE776EA xc7a100t_0 End of startup HIGH 2026-09-17T12:04:42+07
  PROGRAM.txt sha256 67431fa5e68c0e6b8ec86d6f191f6a7899ba8578acbc4783fdab1586e78cf39d PROGRAM_PASS=NO
  host uart_h12_resync.py sha256 dbae13f5839a9bbf760237bfecc3462c968df23e395987711d2260b72ad1cce7
  jsonl H12_BOARD_RESYNC.jsonl sha256 901322c382cbbe328a39cb95e6059adc50e035361a4660c376d806464a2a964c
  frozen campaign host not edited. Freeze DCPs untouched. Hist bit f6a6091f file untouched.
OBSERVATION:
  FACT — owner 2026-09-17: "Toi có cấm bạn nạp lên board đâu".
  FACT — JTAG program identity H MATCH, End of startup HIGH, PROGRAM_PASS=NO.
  FACT — immediately after program, frozen --mode probe: n=4 hex=5a070002 find_known tok=None. Classified UNSUP (WRONG_VALID, not mute).
  FACT — then H12 pad3 host PA24-V-04 n=8: i0–4 CLEAR ACK + PACK GOLD 010000a5; i5 CLEAR ACK + PACK MAG 0200015a; i6 CLEAR NO_BYTE; pad3 CLEAR still NO_BYTE; stop. gold=5 unsup=0 mag=1 mute=1 nrec=14.
  FACT — leave-state frozen probe: n=0 tok=None CLASS B sticky mute.
  FACT — pad3 after MAG did not restore CLEAR ACK.
  FACT — H17 stall XSim CLEAR is BUSY c1ea50b5, not n=0.
HYPOTHESES:
  H_JTAG_BAN — REJECTED by owner quote.
  pad3 recovers CLASS A bix leftover on silicon — INCONCLUSIVE this loop (no UNSUP after aligned start; MAG is CLASS A but different injection).
  pad3 recovers CLASS B n=0 — REJECTED (PASS_BOARD failure of that claim).
  MAG then mute is extra-after-BEGIN then UART TX death — HYPOTHESIS.
  CLASS B n=0 equals H17 S_RX BUSY — REJECTED (BUSY produces 4 bytes).
  First post-program UNSUP is FTDI leftover mixing with CLEAR — HYPOTHESIS.
HOW_TRACE:
  owner correction → JTAG H → frozen probe UNSUP → uart_h12_resync V-04 x8 → leave-state n=0
EVIDENCE_MATRIX:
  DIMENSION | RESULT | LAYER
  JTAG H | startup HIGH sha MATCH | programmed-config CANDIDATE; not PROGRAM_PASS
  post-program probe | 5a070002 UNSUP | PASS_BOARD CLASS A
  GOLD streak | 5 consecutive V-04 | PASS_BOARD candidate packets; not PACK_ABI_24_24_PASS
  MAG i=5 | 0200015a | PASS_BOARD CLASS A
  pad3 after MAG | CLEAR n=0 | PASS_BOARD fail of pad3-vs-mute
  leave-state | n=0 | PASS_BOARD CLASS B
  H17 BUSY vs n=0 | different tokens | PASS_XSIM vs PASS_BOARD split
SUCCESS_VS_FAILURE:
  Success: nạp allowed and executed; 5 GOLD then named MAG then named CLASS B; pad3 vs mute classified.
  Failure: GOAL not complete; CLASS B remains; pad3 is not a silicon mute cure.
FIRST_DIVERGENCE:
  After MAG 0200015a the next CLEAR is n=0. pad3 does not re-open TX. This is not the XSim 1-stray→UNSUP path.
DECISIVE_TEST: uart_h12_resync.py --case PA24-V-04 --n 8 after identity H. Done.
ROOT_CAUSE_OR_UNKNOWN:
  CLASS B mute after MAG is not host pad3/bix leftover. Silicon MAG extra source UNKNOWN. COMMON_ROOT UNKNOWN.
REUSABLE_DECISION_PROCEDURE:
  After MAG or GOLD, if next CLEAR is n=0, do not treat as uart_rx_word bix. pad3 is for UNSUP/prefix leftover only.
  Frozen find_known tok=None on 5a070002 is WRONG_VALID UNSUP.
STRUCTURAL_GUARD:
  Do not edit uart_rx_word without grant. Do not stamp PROGRAM_PASS. Do not overwrite freeze DCPs. No Identity I.
BLAST_RADIUS: board SRAM + evidence jsonl. Synthesizable RTL untouched. Frozen campaign host untouched.
VERDICT_BY_LAYER:
  PASS_BOARD: GOLD 5, MAG 1, mute 1, leave n=0, pad3 fail on CLASS B
  PASS_XSIM: prior H12 pad3 GOLD (BRAM dualclk)
  PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS: NO
LESSON_TO_SHARE: D-H12-BOARD-PAD3-CLASS-B-20260917T050500Z
NEXT_DECISIVE_EXPERIMENT:
  ILA on bix, loader st, uart TX after MAG; or mig0 calib/stall vs BRAM. FEM persist blocked.
OWNER_AND_STOP_CONDITION:
  AGENT_D. Stop if CLASS B n=0 after MAG is named on ILA or RTL grant. GOAL_AGENT_D FINAL R2 NOT complete.
HANDOFF_STATUS: COMPLETE
