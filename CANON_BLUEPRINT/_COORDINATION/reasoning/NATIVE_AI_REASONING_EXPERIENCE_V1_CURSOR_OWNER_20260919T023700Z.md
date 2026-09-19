NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-WATCH-PKGQSC-CLEAR1 / 20260919T023700Z
OWNER_AGENT: CURSOR_OWNER (side chat 94223db6 watching 31dc87bc)
CURRENT_CLAIM: Parent PACKAGE-qsc A/B CLEAR1 is COMPLETE: ACK c1ea50a5 vs prior U32 dest-AND BUSY c1ea50b5. H1_CAUSAL_CLEAR1_ACK PASS_XSIM. V-04 still IN_PROGRESS. Publish that CLEAR1 contrast only. Do not stamp PACK_ABI / MIG_PASS / BOARD_PASS. Do not overlay. Do not resume parent xelab.
RUN_PROVENANCE: Parent jsonl 2993307 → 3002316 (mtime 2026-09-19T02:34:51Z). Native_SymAI was b3a5f60. Live xsim still holds xsim_mig0_pkgqsc.log.
OBSERVATION:
  FACT — log line OBS01_CLEAR1 ACK got=c1ea50a5 USE_DEST_RDY=0 dest_rdy=1 dest_wdf=1 qsc_ui=1 qsc_c1=1 dest_accept=1.
  FACT — BRANCH H1_CAUSAL_CLEAR1_ACK PACKAGE_QSC dest_rdy_not_in_qsc.
  FACT — OBS01_CKPT P0_BEGIN_ACCEPT t=451550625.0 ps; no $finish at snapshot.
  FACT — U32 pack_mig_bind sha256 7cee4df2… unchanged (still ANDs dest_ui_*).
  FACT — TB-only: harness dest_ui_qsc_* = 1 when QSC_USE_DEST_RDY=0; xvlog -d OBS01_QSC_PKG.
HYPOTHESES: H1 causal for CLEAR1_ACK on this XSim A/B. Board exclusive CLEAR1 BUSY still HYPOTHESIS. V-04 outcome UNKNOWN this tick.
HOW_TRACE: Tick 15 jsonl delta → parent text COMPLETE CLEAR1 ACK + V-04 continuing → snapshot locked log via Get-Content → publish sources+STATUS.
EVIDENCE_MATRIX: FACT ACK vs BUSY contrast. INFERENCE H1_CAUSAL_CLEAR1_ACK. UNKNOWN P1–P15/GOLD1. CONTRADICTED: PACKAGE-qsc still BUSY at CLEAR1 (it ACK'd).
SUCCESS_VS_FAILURE: A/B CLEAR1 success is ACK on PACKAGE qsc vs BUSY on dest-AND. Failure would be publishing V-04 as done or stamping PASS.
FIRST_DIVERGENCE: First xvlog -d QSC_USE_DEST_RDY=0 split `=0` as filename; parent switched to -d OBS01_QSC_PKG.
DECISIVE_TEST: This CLEAR1 A/B. Next: wait for parent V-04 $finish / P0–P15.
ROOT_CAUSE_OR_UNKNOWN: PASS_XSIM mechanism for CLEAR1_ACK vs dest-ready in qsc. Board UNKNOWN. PACK_ABI unknown.
REUSABLE_DECISION_PROCEDURE: Publish CLEAR1 A/B as soon as ACK/BUSY contrast is on log; do not wait for later V-04 if parent marked CLEAR1 complete.
STRUCTURAL_GUARD: Do not patch product pack_mig_bind. Snapshot live log; do not kill parent xsim.
BLAST_RADIUS: Native_SymAI OBS01 TB/harness/bat + STATUS. C RTL / H / freeze DCP / U32 bind untouched.
VERDICT_BY_LAYER: PASS_XSIM_H1_CAUSAL_CLEAR1_ACK. Not PASS_BOARD. Not PACK_ABI_24_24_PASS. V-04 INCOMPLETE.
LESSON_TO_SHARE: PACKAGE-QSC-CLEAR1-ACK-VS-U32-BUSY
NEXT_DECISIVE_EXPERIMENT: Parent V-04 on same PACKAGE-qsc sim; then copy finished log/csv.
OWNER_AND_STOP_CONDITION: Watch continues. This turn stops after push of CLEAR1 A/B. No program.
HANDOFF_STATUS: COMPLETE
