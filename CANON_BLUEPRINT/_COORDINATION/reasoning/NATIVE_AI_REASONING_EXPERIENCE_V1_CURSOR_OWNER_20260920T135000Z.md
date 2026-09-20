NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-TICK58-U33OBS-REARM-SYNTH / 20260920T135000Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Unique OBS CLEAR TAP re-arm: TAPDUMP PASS_XSIM GOLD2 four-AND after CLEAR; SYNTH_DONE in build_u33obs_rearm WNS=-1.227 unplaced. New bit NOT_BUILT. Silicon still bd541f95. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. This watch did not program, did not Pack24, and did not resume Vivado.
RUN_PROVENANCE: Watch last_github_sha b59873c. Parent jsonl 4814799 @ 13:51:10Z. Disk SYNTH_DONE 13:50:42Z. Overlay NO. Unique dir. 94_synth refuses old OBS/steer/rgoff paths.

OBSERVATION:
  FACT — BUILD.txt SYNTH_DONE CLASS=uart_r2_u33obs_REARM_CANDIDATE TAP_CDC=1 U2UI=1 READY_TO_PROGRAM=NO sha256 4b17baa4…
  FACT — post_synth.dcp sha256 e53a77e5… WNS -1.227 WHS -1.631 unplaced constraints not met
  FACT — TAPDUMP log sha256 031e3d19… PASS_XSIM CLEAR re-arm GOLD2 four-AND
  FACT — old OBS 71b9198f rgoff 251eafa9 steer bd541f95 files intact; no rearm .bit
  FACT — this watch did not invoke synth/impl/program/Pack24
  UNKNOWN — post-route WNS; unique rearm bitstream SHA; board four-AND after CLEAR on new identity

HYPOTHESES: CLEAR re-arm will let Pack24 observe this-pack four-AND after CLEAR. PACK_ABI still blocked until unique bit + board.

HOW_TRACE: Hash BUILD/DCP/XSim log. Copy tcl+obs sources hashes. Do not push DCP. Do not nạp. Do not wait for impl this tick.

EVIDENCE_MATRIX: PASS_XSIM rearm. PASS_IMPLEMENTED synth checkpoint. Not TIMING_PASS. Not PROGRAM_PASS. Not PACK_ABI. Not BOARD_PASS.

SUCCESS_VS_FAILURE: SYNTH_DONE unique dir. BIT not built.

FIRST_DIVERGENCE: b59873c steer silicon vs rearm RTL synth in new dir.

DECISIVE_TEST: Unique dir SYNTH_DONE without overlay of bd541f95 files.

ROOT_CAUSE_OR_UNKNOWN: TAP freeze-once (FACT). CLEAR re-arm synth exists (FACT). Board UNKNOWN until unique bit.

REUSABLE_DECISION_PROCEDURE: Unique new out dir. Hash DCP do not push. Unplaced negative WNS is not TIMING_PASS. Watch does not resume impl.

STRUCTURAL_GUARD: 94/96 refuse old OBS/steer/rgoff paths; READY_TO_PROGRAM=NO; PROGRAM_PASS=NO.

BLAST_RADIUS: New build dir only. Frozen identities and prior unique bits untouched. SRAM unchanged.

VERDICT_BY_LAYER: PASS_XSIM. PASS_IMPLEMENTED synth. Not PACK_ABI / PROGRAM_PASS / BOARD_PASS / TIMING_PASS.

LESSON_TO_SHARE: REARM-SYNTH-UNIQUE-DIR-UNPLACED-WNS-NOT-TIMING-PASS-20260920T135000Z
NEXT_DECISIVE_EXPERIMENT: Unique rearm bit then board. Watch does not nạp. Do not stamp TIMING_PASS from synth WNS.

OWNER_AND_STOP_CONDITION: CURSOR_OWNER github_audit. Stop PACK_ABI / PROGRAM_PASS / BOARD_PASS / TIMING_PASS stamps. Stop if user says dừng theo dõi.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
