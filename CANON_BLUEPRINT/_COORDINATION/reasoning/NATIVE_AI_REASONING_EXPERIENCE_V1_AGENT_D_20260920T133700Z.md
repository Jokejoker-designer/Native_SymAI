NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: U33OBS-STEER-V01-FOURAND-REARM-XSIM / 20260920T133700Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Isolated PA24-V-01 on steer bd541f95… is GOLD TAP four-AND generation_flipped=1 from THIS pack S_COMMIT (ffffffff→00000001). XSim CLEAR re-arm then GOLD2 four-AND PASS_XSIM. Unique synth dir build_u33obs_rearm SYNTH_DONE, does not overlay steer bit. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO.
RUN_PROVENANCE: Exclusive PROGRAM until 2026-09-21 00:00 +07. Steer bit intact. C RTL untouched. B gold unmodified.

OBSERVATION:
  FACT — ISO V-01 json sha256 64a8e6f2e983702e6e010fe5ed0bb7b7c0e9ea2ee88f0d9e7a9118d326c8f7d8 GOLD 010000a5 TAP commit=1 same=1 cap=1 flip=1 after=00000001
  FACT — XSim CLEAR_REARM then GOLD2_DUMP stat=470f0003 ffffffff→0000ffff four-AND PASS_XSIM
  FACT — A-03 steer EXPECT_NAK still 0200095a PASS_XSIM
  FACT — Synth unique D:/FPGA/arty_d/UART_R2/build_u33obs_rearm SYNTH_DONE TAP_CDC_CELLS=1 post-synth WNS -1.227 unplaced
  INFERENCE — TAP freeze-once is the Pack24 four-AND observation limiter; CLEAR re-arm is diagnostic not pack_loader
  UNKNOWN — route WNS/WHS of rearm bit; silicon re-arm; query R-04/G-04; gold TSV flip=0 vs absent

HYPOTHESES: H2 TAP re-arm on CLEAR enables per-case GOLD DUMP four-AND. XSim SUPPORTED. Silicon UNKNOWN until unique bit programmed.
HOW_TRACE: Reprogram steer → iso V-01 GOLD DUMP four-AND → pack_obs_ctrl rearm_clear while freeze → XSim GOLD2 → unique synth.
EVIDENCE_MATRIX: PASS_BOARD iso V-01 four-AND CANDIDATE. PASS_XSIM CLEAR re-arm GOLD2. PASS_IMPLEMENTED synth only. Not PACK_ABI. Not PROGRAM_PASS.
SUCCESS_VS_FAILURE: this-pack V-01 flip=1 observed. Pack24 per-case four-AND still needs rearm silicon.
FIRST_DIVERGENCE: TAP freeze-once vs CLEAR re-arm handshake.
DECISIVE_TEST: XSim GOLD DUMP then CLEAR then GOLD DUMP2 four-AND (pass). Silicon pending unique bit.
ROOT_CAUSE_OR_UNKNOWN: TAP freeze-once after DUMP/NAK (FACT). Per-case Pack24 four-AND UNKNOWN on silicon until rearm bit.
REUSABLE_DECISION_PROCEDURE: generation_flipped only this-pack four-AND. DUMP after GOLD before CLEAR. Unique new dir for TAP re-arm. Do not invent flip=0.
STRUCTURAL_GUARD: pack_obs_ctrl rearm_clear while freeze still 1; 96 bans overlay steer/rgoff/old OBS; PROGRAM_PASS=NO.
BLAST_RADIUS: Live SRAM still bd541f95…. New synth dir only. Frozen identities untouched.
VERDICT_BY_LAYER: PASS_BOARD iso V-01 CANDIDATE. PASS_XSIM rearm. SYNTH_DONE not TIMING_PASS. Not PACK_ABI.
LESSON_TO_SHARE: CLEAR-REARM-THEN-GOLD2-FOURAND-XSIM-20260920T133700Z
NEXT_DECISIVE_EXPERIMENT: Route+bit unique rearm dir, program, Pack24 --run1-rearm dump_after_gold. Do not stamp PACK_ABI.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop PACK_ABI / PROGRAM_PASS / BOARD_PASS stamps.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
