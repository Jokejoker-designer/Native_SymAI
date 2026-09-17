# NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: EXP_A_FRESH + EXP_B_LIVENESS
RUN_ID: 20260917T003500Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Two independent silicon experiments, not a 24-case campaign.
  A: V-02 MAG after fresh reprogram is a stable ingress discriminator.
  B: liveness mute does not need 24-case diversity; CLEAR+same PACK repeats suffice.
OWNER: board-lease protocol dropped. D holds ARTY exclusively. dispatcher=NONE.
RUN_PROVENANCE:
  Live PACKAGE CANON_BLUEPRINT
  Host A D:/FPGA/arty_d/exp_a_b/uart_exp_a_fresh.py
  Host B D:/FPGA/arty_d/exp_a_b/uart_exp_b_liveness.py
  Bit A ISO f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7
  Bit B H cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9
  XSim A tb_exp_a_v02_dualclk.sv finish 2120465 ns
  XSim B tb_exp_b_liveness.sv finish 19326335 ns
  Freeze DCPs not written. C RTL not modified. PROGRAM_PASS=NO.
OBSERVATION:
  FACT — Owner: D holds board; no BOARD_LEASE_REQUEST. Mailbox E OWNER_BOARD_EXCLUSIVE.
  FACT — Host TX V-02 w0=00800001 w1=3149414e bytes head 010080004e414931. mem_sha 3bfa5eb4… same as G-01.
  FACT — Exp A silicon COM12 115200: 3/3 reprogram then V-02 GOLD 010000a5 rx_n=4 a5000001. mag=0 mute=0.
  FACT — Hist ISO 2026-09-16 V-02 got=0200015a MAG on same bit. CONTRADICTED by this 3/3 GOLD.
  FACT — XSim A dual-clk PATH_MATCH 52/52 words host==assem==fifo_wr==fifo_rd==loader MAGIC. STATUS GOLD. dest=BRAM not mig0. BAUD 1e6.
  FACT — Exp B session1 program H: CLEAR ACK then V-04 GOLD; next CLEAR UART n=4 hex=5a070002 = 0200075a R_UNSUP. find_known labeled MUTE (wrong class).
  FACT — Exp B session2 no reprogram: CLEAR ACK then V-04 UNSUP 0200075a; next CLEAR n=0 MUTE.
  FACT — XSim B 8x CLEAR ACK + V-04 GOLD. No mute. dest BRAM. Not mig0.
HYPOTHESES:
  H-A1 MAG is stable fresh fail on ISO V-02. CONTRADICTED (3/3 GOLD).
  H-A2 MAG was flaky / time-varying / settle. OPEN (not reproduced today).
  H-A3 Dual-clk CDC corrupts MAGIC. CONTRADICTED in XSim BRAM; UNKNOWN on mig0 115200.
  H-B1 Mute needs 24-case diversity. CONTRADICTED: mute after CLEAR+same V-04 only.
  H-B2 First failure after GOLD is leftover CLEAR eaten as pack (R_UNSUP), then TX mute. SUPPORTED this run.
  H-B3 find_known ACK/BUSY/ERR hides R_UNSUP as mute. FACT for session1 B1.
HOW_TRACE:
  owner drop lease
  -> D exclusive HELD
  -> XSim A 4-stage dump
  -> silicon A reprogram x3 V-02
  -> program H once
  -> CLEAR+V-04 loop
  -> continue --no-program
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  A host TX MAGIC | sent 3149414e | EXP_A_FRESH.json w1 / bytes 4e414931 | UART_BOARD CANDIDATE
  A ISO MAG stable | hist 0200015a | today 3/3 010000a5 | CONTRADICTED_TODAY
  A 4-stage | loader sees MAGIC | XSim PATH_MATCH 52 | PASS_XSIM not BOARD
  B diversity | need 24 cases | mute after V-04 only | UART_BOARD CANDIDATE
  B first token | mute | 5a070002 = 0200075a | UNSUP then later n=0 MUTE
  B XSim | same loop lives | 8/8 GOLD | PASS_XSIM not BOARD
SUCCESS_VS_FAILURE:
  A success: fresh V-02 GOLD 3/3; host MAGIC correct; XSim 4-stage match.
  A failure-to-use as MAG ILA: MAG not reproduced.
  B success-as-reproducer: GOLD -> UNSUP CLEAR -> UNSUP PACK -> MUTE n=0 without 24 corpus.
  B XSim does not mute: silicon mute is outside this BRAM dual-clk TB.
FIRST_DIVERGENCE:
  A vs hist ISO: same bit+mem, MAG then vs GOLD now. Divergence is time/run, not mem.
  B vs XSim: after first GOLD pack, silicon CLEAR returns 0200075a; XSim still ACK.
  B session1 B1 vs true mute: UART n=4 UNSUP, not n=0. True mute is session2 B1.
DECISIVE_TEST:
  A: reprogram each attempt, single V-02. Result GOLD 3/3.
  B: CLEAR+V-04 repeat, no other cases. Result mute_at without diversity.
ROOT_CAUSE_OR_UNKNOWN:
  A MAG: UNKNOWN (not reproduced). Not accumulated-state (reprogram).
  B mute: UNKNOWN mechanism. Sequence named. First error class after GOLD is R_UNSUP then mute.
REUSABLE_DECISION_PROCEDURE:
  1. Do not fuse 24-case campaign into MAG vs mute.
  2. Classify UART n and token separately: None n=0 MUTE; 0200075a UNSUP; c1ea50a5 ACK.
  3. ILA on B 5-step, not on V-02 MAG (not stable today).
STRUCTURAL_GUARD:
  find_known must not treat pack NAK as mute. Do not stamp PACK_ABI_24_24_PASS.
BLAST_RADIUS:
  UART/CLEAR/pack_lock on H. Freeze DCP and hist bit file untouched. SRAM left MUTE for ILA.
VERDICT_BY_LAYER:
  PASS_XSIM A dualclk GOLD PATH_MATCH
  PASS_XSIM B 8 loops
  UART_BOARD A GOLD 3/3 CANDIDATE
  UART_BOARD B mute after V-04-only CANDIDATE
  PROGRAM_PASS=NO BOARD_PASS=NO PACK_ABI_24_24_PASS=NO MIG_PASS=NO
LESSON_TO_SHARE: D-EXP-A-B-20260917T003500Z
NEXT_DECISIVE_EXPERIMENT: ILA on B sequence (w_data, fifo, p_data, pack_lock, clr_take) starting from H; do not 24-case. Optional: leave MUTE or reprogram H then arm ILA before second CLEAR.
OWNER_AND_STOP_CONDITION: D holds board. Stop 24-case. FEM persist still blocked. ILA next.
HANDOFF_STATUS: COMPLETE
