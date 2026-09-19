NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: UART-R2-U33-LEFTOVER-MAG-20260919T111705Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: FACT PASS_XSIM — extra exact BEGIN 00800001 after CLEAR IDLE is sufficient for board MAG token 0200015a (R_BAD_MAGIC, hw0=BEGIN). FACT — unlocked non-BEGIN leftover, n=0-retry, and zero-settle are not MAG on BRAM 1M. HYPOTHESIS — board leftover BEGIN source still UNKNOWN. PACK_ABI_24_24_PASS=NO. PROGRAM=NO. No overlay.
RUN_PROVENANCE: TB `UART_R2/u33/tb_u33_leftover_begin_mag.sv` sha256 7eba977d09a5958be2634d3a694df4c8e139f95bc739cae04d903097cc715909. xsim_u33mag.log sha256 020506a7c2451861e63bfeff66ff17dd029f35c00aff75dbc34e11c3fa57a63b. cell log sha256 efbf8e842b0e01812c4797415da62e566e0c7ee6ee7079f05f2641a36f5f8c7e. Bind U33 eade06c8… unchanged. Harness U32 dualclk BRAM dest. Parallel mig0 five-V-04 xsimk PID 5488 left running.
OBSERVATION:
  FACT — CELL_A MAG mute=0 got=0200015a n_p=8 p0=00800001 p1=00800001 p2=3149414e rej=1 rsn=01.
  FACT — CELL_C GOLD after leftover 010000a5; p0=BEGIN p1=MAGIC.
  FACT — CELL_B ACK-overlap BEGIN then V-04 mute n_p=0 (not board n=4 NAK).
  FACT — CELL_D CLEAR short mute + retry ACK then two V-04 GOLD.
  FACT — CELL_E no DIV*8 settle GOLD.
  FACT — $finish 34548945 ns; wall ~6 s; BAUD=1M dest=BRAM.
  FACT — xvlog first fail was SV keyword `cell` in task port; renamed `tag`; re-run PASS compile.
HYPOTHESES:
  H_LEFTOVER_BEGIN_SUFFICIENT CONFIRMED PASS_XSIM (CELL A).
  H_ANY_LEFTOVER_MAG CONTRADICTED (CELL C).
  H_N0_RETRY_MAG CONTRADICTED on BRAM (CELL D).
  H_ZERO_SETTLE_MAG CONTRADICTED on BRAM 1M (CELL E).
  H_ACK_OVERLAP_IS_BOARD_MAG CONTRADICTED (CELL B mute vs board MAG).
  H_BOARD_HAS_EXTRA_BEGIN UNKNOWN (campaign does not send extra BEGIN).
HOW_TRACE: Board MAG = R_BAD_MAGIC after OP_BEGIN. Inject extra BEGIN vs extra GOLD vs r2-retry vs zero-settle vs ACK-overlap. Only extra BEGIN reproduced 0200015a with p1=BEGIN.
EVIDENCE_MATRIX: PASS_XSIM leftover cells. FAIL_BOARD U33 MAG r3 still the silicon token. mig0 5× IN_PROGRESS (V04_0..2 GOLD printed). Not BOARD_PASS.
SUCCESS_VS_FAILURE: SUCCESS_ARTIFACT leftover MAG TB+logs. FAILURE_ARTIFACT still U33 CLEAR_V04_24.json MAG r3 (source of extra BEGIN unknown).
FIRST_DIVERGENCE: CELL A first loader word after leftover BEGIN is second 00800001 (hw0) vs MAGIC 3149414e.
DECISIVE_TEST: CELL A vs CELL C same CLEAR/V-04 path; only exact BEGIN leftover NAKs.
ROOT_CAUSE_OR_UNKNOWN: Mechanism given leftover BEGIN CONFIRMED. Board leftover source UNKNOWN.
REUSABLE_DECISION_PROCEDURE: To MAG-classify, capture p0/p1 on NAK. If p1=BEGIN, leftover BEGIN. If p1=scrambled, UART align. If five GOLD on mig0, MAG is not dest=mig0 5th.
STRUCTURAL_GUARD: Do not overlay qsc/UART/dest_accept/pack_loader from this TB. Do not spawn U34. PROGRAM=NO until leftover BEGIN is seen without injection or owner authorizes.
BLAST_RADIUS: UART_R2/u33 TB + xsim_u33mag + PACK24_U33 docs. Product RTL / H / freeze DCP / Pack24 gold / running xsim_u33m untouched.
VERDICT_BY_LAYER: PASS_XSIM leftover-inject. FAIL_BOARD U33 MAG unchanged. Not PACK_ABI_24_24_PASS / PROGRAM_PASS / MIG_PASS.
LESSON_TO_SHARE: U33-LEFTOVER-BEGIN-SUFFICIENT-FOR-MAG
NEXT_DECISIVE_EXPERIMENT: Finish mig0 5× (V04_3/V04_4). Do not overlay unless p0/p1 on that MAG or a non-injected leftover BEGIN is shown.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop overlay/program/PASS. Keep mig0 sim.
HANDOFF_STATUS: COMPLETE
