# NATIVE_AI_REASONING_EXPERIENCE_V1_CURSOR_OWNER_20260920T131100Z

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: U33OBS-A03-STEER-XSIM / 20260920T131100Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Parent A-03 UART steer OP_BEGIN XSim is PASS_XSIM NAK 0200095a.
  New unique bit NOT_BUILT. PACK_ABI remains NO. Watch did not program or patch.
RUN_PROVENANCE:
  jsonl still 4671465; disk tb/harness/top + xsim logs vs GitHub 7872dd8
OBSERVATION:
  FACT — pack_begin now (f_data[7:0]==8'h01) in top sha256 2dbb8e67… and harness 378f51f2…
  FACT — u33obs_a03_steer.log sha256 557c467c… PASS_XSIM got=0200095a p0=00840001 reason=09 n_p=34
  FACT — xsim FATAL_ERROR after $finish; PASS lines already printed
  FACT — READY_TO_PROGRAM=NO; no new BUILD.txt/bit; silicon still 251eafa9
  FACT — this watch did not invoke xvlog/xelab/xsim/program
HYPOTHESES:
  H1 — isolated A-03 on a unique new bit will NAK 0200095a (HYPOTHESIS; not silicon)
HOW_TRACE:
  Tick 44 jsonl delta=0. Newer top/tb/log. Read PASS_XSIM. Copied sources+logs. Did not nạp.
EVIDENCE_MATRIX:
  PASS_XSIM | FACT | steer.log
  new bit | FACT | NOT_BUILT
  PACK_ABI | FACT | NO
SUCCESS_VS_FAILURE:
  SUCCESS — UART path now reaches pack_loader A-03 NAK 9
  FAILURE — not silicon; not 24/24; xsim kernel FATAL after finish
FIRST_DIVERGENCE:
  7872dd8 still exact 00800001; this hop OP_BEGIN low byte
DECISIVE_TEST:
  TB EXPECT_NAK send PA24-A-03.mem; expect 0200095a and p0=00840001
ROOT_CAUSE_OR_UNKNOWN:
  Steer exact-BEGIN closed in XSim (FACT). Silicon on patched RTL UNKNOWN until unique bit.
REUSABLE_DECISION_PROCEDURE:
  Publish PASS_XSIM from log even if parent jsonl idle. Do not program the patched RTL onto 251eafa9 overlay.
STRUCTURAL_GUARD:
  New unique out dir for next bit. Ban overlay 251eafa9/71b9198f/H/U33. PACK_ABI=NO.
BLAST_RADIUS:
  OBS top+harness candidate only. C RTL untouched. SRAM still 251eafa9.
VERDICT_BY_LAYER:
  PASS_XSIM A-03 steer NAK9. NOT PROGRAM_PASS / BOARD_PASS / PACK_ABI / TIMING_PASS
LESSON_TO_SHARE: A03-STEER-OP-BEGIN-XSIM-NAK9-20260920T131100Z
NEXT_DECISIVE_EXPERIMENT:
  Parent unique new bit (new dir) then iso A-03 0200095a. Watch does not build/program.
OWNER_AND_STOP_CONDITION:
  CURSOR_OWNER watch. Stop on dung theo doi. Do not program. Do not overlay 251eafa9.
HANDOFF_STATUS: COMPLETE
```
