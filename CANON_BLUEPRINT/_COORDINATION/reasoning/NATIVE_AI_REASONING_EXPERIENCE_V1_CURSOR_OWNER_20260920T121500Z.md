NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: GITHUB-AUDIT-TICK25-U33OBS-PROGRAM-HOPS / 20260920T121500Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Publish parent Labtools program of unique OBS bit (EOS HIGH, PROGRAM_PASS=NO) plus hops json. SRAM U33OBS_GEN. Dummy-open GOLD. Leftover MAG. Later TAP DUMP MUTE n=0. Not PACK_ABI. This watch did not program and did not run hops.
RUN_PROVENANCE: GitHub was c001dbf. Parent program.log 19:14:11–19:14:32 +07. U33OBS_HOPS.json 19:15:10 +07.
OBSERVATION:
  FACT — program.log End of startup HIGH; uart_r2_u33obs_PROGRAM_OK PROGRAM_PASS=NO
  FACT — PROGRAM.txt STATUS=PROGRAMMED SHA 71b9198f… IR.STATUS=NA PROGRAM.DONE=NA
  FACT — hops 0_sram_gate identity U33OBS_GEN 9-word DUMP
  FACT — 1_dummy_open_v04 GOLD 010000a5; 2_leftover MAG 0200015a
  FACT — TAP after hop1/2/3/4 n=0 MUTE; gold_flip null
  FACT — this watch did not invoke Vivado program and did not run u33obs_hops.py --run
HYPOTHESES: First DUMP works; later DUMP mute is UART/TAP contention or sticky observe — HYPOTHESIS
HOW_TRACE: Hash PROGRAM.txt program.log hops.py hops.json. Copy. No program. No hops --run.
EVIDENCE_MATRIX: Labtools EOS HIGH. UART GOLD/MAG tokens. TAP identity only at gate. Not PROGRAM_PASS. Not PACK_ABI. Not BOARD_PASS.
SUCCESS_VS_FAILURE: OBS identity on SRAM. Dummy-open GOLD (U33 old MUTE not reproduced). Leftover MAG remains. Silicon four-AND on GOLD TAP not captured.
FIRST_DIVERGENCE: TAP DUMP n=36 at gate then n=0 after V-04.
DECISIVE_TEST: hops json sram_gate U33OBS_GEN vs later MUTE_n0.
ROOT_CAUSE_OR_UNKNOWN: Later TAP mute UNKNOWN. MAG leftover on OBS still MAG (FACT).
REUSABLE_DECISION_PROCEDURE: Do not stamp PROGRAM_PASS from EOS HIGH. Do not stamp PACK_ABI from one GOLD. TAP four-AND requires TAP words; UART GOLD is not the field. Unique OBS SHA. No Pack24.
STRUCTURAL_GUARD: This watch PROGRAM=NO. hops --run=NO. PACK_ABI=NO. PROGRAM_PASS=NO.
BLAST_RADIUS: Native_SymAI OWNER_PROGRAM + hops json. Frozen identities not overwritten.
VERDICT_BY_LAYER: Labtools EOS HIGH. UART GOLD/MAG. TAP identity at gate only. Not PROGRAM_PASS / PACK_ABI / BOARD_PASS.
LESSON_TO_SHARE: OBS-SRAM-GATE-THEN-TAP-DUMP-MUTE-20260920T121500Z
NEXT_DECISIVE_EXPERIMENT: Parent may re-DUMP; this watch does not Pack24 and does not program.
OWNER_AND_STOP_CONDITION: Watch until dừng theo dõi. Do not program from this watch.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
