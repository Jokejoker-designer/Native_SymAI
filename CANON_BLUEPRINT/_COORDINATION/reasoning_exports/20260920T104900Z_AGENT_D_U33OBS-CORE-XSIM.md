NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: U33OBS-CORE-XSIM-20260920T104900Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: U33OBS core RTL implements contract 112-bit lane (no wrap, CLEAR does not wipe) and generation_flipped four-AND. PASS_XSIM core 296 ns and leftover MAG loader lane CLASS_A p0=p1=BEGIN n_ev=33. Not a silicon identity. Not PACK_ABI_24_24_PASS.
RUN_PROVENANCE: Goal continue PACK_ABI 4-step Ý5. Owner exclusive PROGRAM until midnight does not authorize programming this incomplete OBS core. No overlay U33/H. pack_loader unmodified.

OBSERVATION:
- FACT: tb_pack_obs_core PASS_XSIM CLEAR-survive overflow gen-4AND. Log sha256 4c32d005…
- FACT: leftover pack_obs_lane p0=BEGIN p1=BEGIN MAG 0200015a n_ev=33 ov=0. Log sha256 8d6e7132…
- FACT: TAPCDC silicon leftover already CLASS_A; this names the same hop on contract ABI.
- UNKNOWN: MUTE first-divergent hop (needs DUMP freeze + UART/FIFO/CDC lanes on a board top).

HYPOTHESES: Full 9-lane top + DUMP token is the next MUTE capture identity. Programming core-only would be an incomplete observer.

HOW_TRACE: Contract ABI → lane/gen/ctrl → unit TB → leftover harness bind on p_fire.

EVIDENCE_MATRIX:
- pack_obs_lane.sv sha256 3e8a304f… FACT
- pack_obs_gen.sv sha256 5a43f604… FACT
- xsim core/lane logs FACT PASS_XSIM
- No PROGRAM this identity FACT

SUCCESS_VS_FAILURE: Core+leftover CLASS_A PASS_XSIM. Silicon OBS / MUTE / Pack24 DUT.jsonl missing.

FIRST_DIVERGENCE: leftover MAG still p1 second BEGIN at loader (named on 112-bit lane).

DECISIVE_TEST: Already run leftover lane TB. MUTE DUMP-without-NAK TB not run.

ROOT_CAUSE_OR_UNKNOWN: Leftover MAG hop named. Historical MAG without inject OPEN. MUTE hop OPEN.

REUSABLE_DECISION_PROCEDURE: Do not program U33OBS until DUMP+all hop lanes XSim. generation_flipped only via pack_obs_gen four-AND. Do not Pack24 on TAPCDC SRAM.

STRUCTURAL_GUARD: Lane overflow stops writes. Gen absent if epoch/CLEAR/capture_valid fail.

BLAST_RADIUS: UART_R2/u33obs new modules + XSim dirs. Frozen U33/H/TAP bits untouched.

VERDICT_BY_LAYER: PASS_XSIM core and leftover lane. Not PASS_BOARD OBS. Not PROGRAM_PASS. Not PACK_ABI_24_24_PASS.

LESSON_TO_SHARE: U33OBS-LANE-ABI-NOT-41BIT-STARTER-20260920T104900Z
NEXT_DECISIVE_EXPERIMENT: DUMP 44554D50 freeze without NAK + UART/FIFO/CDC/LOADER lanes; then OBS top. Do not UpdateGoal complete.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop Pack24. Stop overlay. Stop programming incomplete OBS core.
HANDOFF_STATUS: COMPLETE
