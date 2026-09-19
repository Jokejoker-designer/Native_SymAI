NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-WATCH-PKGQSC-GOLD1 / 20260919T034100Z
OWNER_AGENT: CURSOR_OWNER (side chat 94223db6 watching 31dc87bc)
CURRENT_CLAIM: PACKAGE-qsc OBS01-MIG0 txn1 is COMPLETE on log: P0–P15 all seen (`t1_seen=ffff`) and GOLD1 `010000a5` mute=0 last=P15_SETTLE_IDLE div=NONE. Q1 YES at GOLD1 settle. CLEAR2/GOLD2 still IN_PROGRESS. Publish that txn1 result. Do not stamp PACK_ABI / MIG_PASS / BOARD_PASS. Do not overlay. Do not kill parent xsim. Do not overwrite MIG0_PATH_THIS_SEQUENCE=FAIL_XSIM_CLEAR1_BUSY (that label is the U32 dest-AND seq).
RUN_PROVENANCE: Parent jsonl still 3002316 (mtime 2026-09-19T02:34:51Z). Native_SymAI was de59648. Live xsim/xsimk still hold xsim_mig0_pkgqsc.log. Publish from log $display, not from parent chat text.
OBSERVATION:
  FACT — OBS01_GOLD1 mute=0 got=010000a5 t1_seen=ffff last=P15_SETTLE_IDLE div=NONE.
  FACT — P0 at 451550625.0 ps through P15 at 2492666625.0 ps; P2 and P3 same cycle; P4 cmd_acc=1 wdf_acc=1; P15 ui/ld idle out=0 cmd_acc=0 wdf_acc=0.
  FACT — AFTER_GOLD1_SETTLE q1_ui_idle=1 ui_st=0 ui_out=0 ld_st=0.
  FACT — BEFORE_CLEAR2 q2_out0=1 idle; QSC_VS_RDY dest_rdy=1 dest_wdf=1 p_rdy=0 mux_g=0 qsc_ui=1 qsc_c1=1 dest_accept=1; n_qsc0_idle=0 at that print.
  FACT — later OBS01_QSC0_WHILE_IDLE t=2581202625.0 ps dest_rdy=1 dest_wdf=1 p_rdy=0 mux_g=0 qsc_c1=1 dest_accept=1. No OBS01_CLEAR2 / GOLD2 / $finish yet.
  FACT — U32 pack_mig_bind sha256 7cee4df2… unchanged.
  FACT — csv snapshot truncated (last row cut at 2452323000.0 ps UI_ST); csv lags log; P10–GOLD1 scored from log only.
  FACT — TB-only QSC_USE_DEST_RDY=0 force dest ready 1 into pack_mig_bind ports.
HYPOTHESES:
  H1 dest-ready-in-qsc remains the CLEAR1 ACK vs BUSY cause (already PASS_XSIM). INFERENCE: txn1 dest path on generated mig0 is reachable once CLEAR is not BUSY. HYPOTHESIS: board exclusive CLEAR1 BUSY is the same class. UNKNOWN: CLEAR2 token on this PACKAGE-qsc seq; meaning of QSC0_WHILE_IDLE with dest_rdy=1.
HOW_TRACE: Tick 36 csv 45 P_FIRE + log P12–P15 → re-read full log → GOLD1 already printed → snapshot Get-Content (file locked) → publish Native_SymAI → no parent xelab.
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  CLEAR1 A/B | ACK vs BUSY | ckpt lines ACK c1ea50a5 vs prior BUSY | PASS_XSIM H1
  txn1 P0-P15 | all 16 bits | t1_seen=ffff P0..P15 $display | PASS_XSIM
  GOLD1 | 010000a5 mute=0 | OBS01_GOLD1 | PASS_XSIM
  Q1 | ui idle after GOLD1 | AFTER_GOLD1_SETTLE | PASS_XSIM snapshot
  csv completeness | score P10+ from csv | truncated last row | FAIL as csv evidence; log used
  product bind | dest AND removed | pack_mig_bind 7cee4df2… | CONTRADICTED (unchanged)
  CLEAR2 | ACK | no OBS01_CLEAR2 yet | UNKNOWN this tick
  board | same class | none this tick | UNKNOWN
SUCCESS_VS_FAILURE:
  Success: log shows P0–P15 + GOLD1 without FAIL V04_0; Q1 idle snapshot YES.
  Failure-to-promote: TB forces dest ready; csv incomplete; CLEAR2 not done; not board; not PACK_ABI.
FIRST_DIVERGENCE: Wall-time stall after P0 was UART ingest into ddr3_model+gui/wdb, not a missing P1. First dest handshake P1 at 2451602625.0 ps (~2.00 ms after P0).
DECISIVE_TEST: This GOLD1 $display vs FAIL V04_0. Next: OBS01_CLEAR2 token then GOLD2/Q3/Q4.
ROOT_CAUSE_OR_UNKNOWN: Txn1 dest+GOLD PASS_XSIM on PACKAGE-qsc. CLEAR1 mechanism still dest-ready-in-qsc. CLEAR2 / board UNKNOWN.
REUSABLE_DECISION_PROCEDURE: When OBS01_GOLD1 prints with t1_seen=ffff, publish txn1 as PASS_XSIM even if CLEAR2 still running. Do not wait for $finish. Do not score from a truncated csv.
STRUCTURAL_GUARD: Keep product pack_mig_bind dest_ui AND until owner overlay identity. Snapshot live log; do not kill xsim. Do not relabel U32 dest-AND seq as CLEAN.
BLAST_RADIUS: Native_SymAI OBS01 evidence + STATUS. C RTL / H / freeze DCP / U32 bind / identity H untouched.
VERDICT_BY_LAYER: PASS_XSIM PACKAGE_QSC_GOLD1 and P0–P15. Not PASS_BOARD. Not PACK_ABI_24_24_PASS. Not MIG_PASS. CLEAR2 INCOMPLETE.
LESSON_TO_SHARE: PACKAGE-QSC-MIG0-TXN1-GOLD1-P0-P15
NEXT_DECISIVE_EXPERIMENT: Wait for parent OBS01_CLEAR2 / GOLD2 / $finish; copy finished log/csv.
OWNER_AND_STOP_CONDITION: Watch continues. This turn stops after push of GOLD1/P0–P15. No program.
HANDOFF_STATUS: COMPLETE
