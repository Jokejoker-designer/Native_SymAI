NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-TICK49-50-U33OBS-STEER-HOPS / 20260920T133000Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: On unique steer bd541f95… after iso A-03/A-04: leftover extra BEGIN is MAG 0200015a TAP CLASS_A flip absent; isolated GOLD DUMP four-AND flip=1; V-04×4 4/4 GOLD. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. This watch did not program and did not Pack24.
RUN_PROVENANCE: Watch last_github_sha 206e33e. Parent jsonl 4725251 @ 13:26:11Z. Disk leftover 13:28:53Z GOLD 13:30:01Z V04x4 13:30:19Z. Overlay NO. Exclusive PROGRAM AGENT_D.

OBSERVATION:
  FACT — leftover json sha256 e82fcf12… word 0200015a MAG TAP CLASS_A p0=p1=00800001 commit=0 generation_flipped null stop LEFTOVER_DONE_NO_PACK24
  FACT — GOLD json sha256 5b552e51… word 010000a5 TAP four-AND commit=1 same_epoch=1 capture_valid=1 flip=1 ffffffff→0000ffff stop GOLD_DUMP_DONE_NO_PACK24
  FACT — V04x4 json sha256 c62c3819… gold=4 mag=0 mute=0 stop V04x4_DONE_NO_PACK24
  FACT — PROGRAM.txt still SHA MATCH bd541f95… PROGRAM_PASS=NO; old OBS 71b9198f and rgoff 251eafa9 files intact
  FACT — this watch invoked neither 97_program nor Pack24
  INFERENCE — OP_BEGIN steer did not remove leftover MAG CLASS_A; GOLD four-AND still measurable on isolated DUMP
  UNKNOWN — MAG_HISTORICAL_NATURAL; gold flip 0-vs-absent leftover; Pack24 24 unique; R-04/G-04 query

HYPOTHESES: Leftover MAG and GOLD TAP four-AND on this identity match prior OBS hops CANDIDATE. PACK_ABI still blocked.

HOW_TRACE: Hash three hop jsons. Compare four-AND vs leftover omit. Copy hashes. Do not nạp. Do not Pack24.

EVIDENCE_MATRIX: PASS_BOARD isolated leftover MAG + GOLD four-AND + V04x4 CANDIDATE. Not PACK_ABI. Not PROGRAM_PASS. Not BOARD_PASS.

SUCCESS_VS_FAILURE: Leftover MAG class confirmed. PACK_ABI unproven.

FIRST_DIVERGENCE: leftover extra BEGIN MAG vs GOLD DUMP four-AND (same SRAM, isolated hops).

DECISIVE_TEST: Isolated leftover then isolated GOLD DUMP on bd541f95… without Pack24.

ROOT_CAUSE_OR_UNKNOWN: Leftover MAG CLASS_A (FACT this hop). Historical natural MAG UNKNOWN.

REUSABLE_DECISION_PROCEDURE: Isolate leftover vs GOLD DUMP. generation_flipped only Pack S_COMMIT four-AND same epoch. V-04×4 is not Pack24.

STRUCTURAL_GUARD: observe_from_tap_gen four-AND; no Pack24 from hops; PROGRAM_PASS=NO; overlay NO.

BLAST_RADIUS: SRAM bd541f95…. Frozen identities and prior unique bits untouched. C RTL untouched. B gold unmodified.

VERDICT_BY_LAYER: PASS_BOARD hops CANDIDATE. Not PACK_ABI / PROGRAM_PASS / BOARD_PASS / TIMING_PASS / MIG_PASS.

LESSON_TO_SHARE: STEER-HOPS-LEFTOVER-MAG-GOLD-FOURAND-V04x4-20260920T133000Z
NEXT_DECISIVE_EXPERIMENT: Do not Pack24. Remaining ABI / flip / query / MAG_HISTORICAL OPEN.

OWNER_AND_STOP_CONDITION: CURSOR_OWNER github_audit. Stop PACK_ABI / PROGRAM_PASS / BOARD_PASS stamps. Stop if user says dừng theo dõi.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
