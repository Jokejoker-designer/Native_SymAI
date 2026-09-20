# NATIVE_AI_REASONING_EXPERIENCE_V1_CURSOR_OWNER_20260920T132100Z

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: U33OBS-STEER-BIT / 20260920T132100Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Unique OBS steer bitstream exists in a new dir; hashes are
  public-audit complete; silicon still rgoff 251eafa9; PACK_ABI remains NO.
RUN_PROVENANCE:
  jsonl still 4671465; disk build_u33obs_steer BIT_OK 20:21:14+07 vs GitHub 9f09522
  this watch copied hashes/sources; did not program
OBSERVATION:
  FACT — BIT sha256 bd541f9579dfe0e2ca1b9dc4e220818fe460e293e6a7c42c08ecf8652fc9b46f
  FACT — DCP sha256 29c974a17a6df2ecd5d6222276589e6e1043ded8eb06e5e04e666ae07889c456
  FACT — old OBS 71b9198f… and rgoff 251eafa9… files intact
  FACT — BUILD.txt STATUS=BIT_OK; bit.log uart_r2_u33obs_steer_BIT_OK PROGRAM=NO
  FACT — timing_route WNS=0.666 WHS=0.012 constraints MET
  FACT — LUT=10942 FF=9832 RAMB36=3 RAMB18=2 DSP=8
  FACT — no 97_program steer tcl invoked; this watch did not program
HYPOTHESES:
  H1 — iso A-03 on this SHA will NAK 0200095a (HYPOTHESIS; not silicon)
HOW_TRACE:
  Tick 45 saw synth in new dir. Waited for BIT_OK. Hashed unique vs 251eafa9/71b9198f.
EVIDENCE_MATRIX:
  unique SHA | FACT | Get-FileHash
  overlay | FACT | old bits unchanged
  PACK_ABI | FACT | NO
SUCCESS_VS_FAILURE:
  SUCCESS — unique dir + unique SHA + no overlay
  FAILURE — not programmed; PACK_ABI still NO
FIRST_DIVERGENCE:
  9f09522 new_bit=NOT_BUILT vs this hop BIT_OK in build_u33obs_steer
DECISIVE_TEST:
  Independent SHA256 vs banned identities
ROOT_CAUSE_OR_UNKNOWN:
  Unique steer bit built (FACT). Silicon still 251eafa9 (FACT).
REUSABLE_DECISION_PROCEDURE:
  Wait BIT_OK in unique dir. Never copy .bit/.dcp. Never program from watch.
STRUCTURAL_GUARD:
  96_bit refuses overwrite of old OBS and rgoff paths; READY_TO_PROGRAM=NO
BLAST_RADIUS:
  New build_u33obs_steer only. Frozen H/U33/FE256/old OBS/rgoff untouched. SRAM 251eafa9.
VERDICT_BY_LAYER:
  PASS_IMPLEMENTED unique bit on disk. NOT TIMING_PASS / PROGRAM_PASS / PACK_ABI / BOARD_PASS
LESSON_TO_SHARE: STEER-BIT-UNIQUE-DIR-NOT-OVERLAY-RGOFF-20260920T132100Z
NEXT_DECISIVE_EXPERIMENT:
  Owner-authorized program of bd541f95… then iso A-03 0200095a. Watch does not nạp.
OWNER_AND_STOP_CONDITION:
  CURSOR_OWNER watch. Stop on dung theo doi. Do not program.
HANDOFF_STATUS: COMPLETE
```
