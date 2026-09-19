NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: UART-R2-U33-PHANTOM-CDC-20260919T114421Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: FACT PASS_XSIM — CLEAR does not emit phantom CDC BEGIN on BRAM. 5th V-04 without inject GOLD. Leftover 00010001 GOLD. FACT — leftover exact BEGIN remains the only reproduced MAG mechanism. Board leftover source UNKNOWN. mig0 5× IN_PROGRESS. PACK_ABI_24_24_PASS=NO. PROGRAM=NO.
RUN_PROVENANCE: tb_u33_phantom_cdc.sv sha256 6729702fa99bf864763fef6158bd620b5c88a8e9994ddc153d8bfb76d7753b1e. xsim_u33ph.log sha256 4bbe8035e8d08d377c220d0202e68abf2096d9b43945c0ea95055885097e5ce1. cells sha256 a06cac4a4d3e9e2fe4efe8fba5c8032d62d41dcc9dbda1c1ce7803899156e423. xsimk 5488 left running (UserModeTime still climbing).
OBSERVATION:
  FACT — AFTER_CLEAR1 and BEFORE_5TH: lock=0 empty=1 f_valid=0 cdc idle hold=0 req_a=0 last_b=0 n_ph=0.
  FACT — f_data sticky 00800001 with f_valid=0 is not a fire.
  FACT — PROBE_THEN_V04 GOLD; FIFTH_GOLD_WITHOUT_INJECT; ABI01_LEFTOVER_GOLD.
  FACT — $finish 19773145 ns.
HYPOTHESES:
  H_CDC_RST_PHANTOM_BEGIN CONTRADICTED BRAM.
  H_FIFTH_BRAM_NO_INJECT_MAG CONTRADICTED.
  H_ABI01_AS_BEGIN_MAG CONTRADICTED (unlocked drop).
  H_LEFTOVER_EXACT_BEGIN_MAG CONFIRMED (prior CELL A).
  H_BOARD_BEGIN_SOURCE UNKNOWN.
HOW_TRACE: Dump CDC after CLEAR; wait; 5th V-04; leftover 00010001 vs exact BEGIN class.
EVIDENCE_MATRIX: PASS_XSIM phantom probe. FAIL_BOARD U33 MAG r3 unchanged. mig0 V04_0..2 GOLD only.
SUCCESS_VS_FAILURE: SUCCESS_ARTIFACT phantom log. FAILURE_ARTIFACT still board MAG source.
FIRST_DIVERGENCE: none on this TB (all GOLD / idle CDC). Board divergence remains p5 r3 MAG.
DECISIVE_TEST: n_ph after CLEAR before next UART word.
ROOT_CAUSE_OR_UNKNOWN: MAG mechanism if leftover exact BEGIN CONFIRMED. Autogenous leftover after CLEAR CONTRADICTED on BRAM. Source UNKNOWN.
REUSABLE_DECISION_PROCEDURE: After CLEAR, require cdc idle + fifo empty + !f_valid + n_p=0 before blaming reset leftover. Sticky f_data is not valid.
STRUCTURAL_GUARD: No overlay from phantom-negative. Do not treat FIFO rd_data hold as leftover.
BLAST_RADIUS: UART_R2/u33 TB + xsim_u33ph + PACK24_U33 docs. Product RTL / xsim_u33m untouched.
VERDICT_BY_LAYER: PASS_XSIM phantom-negative. Not PACK_ABI_24_24_PASS.
LESSON_TO_SHARE: U33-CLEAR-NO-PHANTOM-BEGIN-BRAM
NEXT_DECISIVE_EXPERIMENT: mig0 5× V04_3/V04_4. PROGRAM=NO.
OWNER_AND_STOP_CONDITION: AGENT_D. No overlay/program/PASS.
HANDOFF_STATUS: COMPLETE
