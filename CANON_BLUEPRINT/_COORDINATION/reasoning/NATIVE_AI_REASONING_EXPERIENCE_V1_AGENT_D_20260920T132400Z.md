NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: U33OBS-STEER-ISO-A03-A04 / 20260920T132400Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Unique OBS steer bit bd541f95… with pack_begin=OP_BEGIN low byte. Isolated PA24-A-03 is 0200095a TAP loader 00840001/NAI1 generation_flipped absent. Isolated PA24-A-04 UART 02000f5a TAP frozen. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO.
RUN_PROVENANCE: Exclusive PROGRAM until 2026-09-21 00:00 +07. New dir build_u33obs_steer. Old OBS 71b9198f and rg_off 251eafa9 files intact. No overlay H/U33/FE256. C RTL untouched. B gold/TB unmodified.

OBSERVATION:
  FACT — XSim before fix: A-03 MUTE n_p=0 PASS_XSIM exact-BEGIN gate
  FACT — XSim after pack_begin=(f_data[7:0]==8'h01): A-03 0200095a n_p=34 p0=00840001 reason=09 PASS_XSIM
  FACT — TAPDUMP leftover CLASS_A + GOLD four-AND still PASS_XSIM
  FACT — BIT sha256 bd541f9579dfe0e2ca1b9dc4e220818fe460e293e6a7c42c08ecf8652fc9b46f unique vs H/U33/TAPCDC/71b9198f/251eafa9
  FACT — Route WNS +0.666 WHS +0.070 MET LUT 10942 FF 9832 RAMB36 3 DSP 8 TIMING_PASS=NO
  FACT — PROGRAM EOS HIGH SHA MATCH PROGRAM_PASS=NO JTAG 210319BE776EA
  FACT — ISO A-03 json sha256 d396cb6142970f8f05fd50e118fe6e90504c70e2ab38053faf040b334476cc42 word 0200095a TAP load0=00840001 load1=3149414e commit=0 flip absent
  FACT — ISO A-04 json sha256 ce2ba8b60f7c1f9275a698051fb19a0b559ad4c50782f0feac28243a93b43491 word 02000f5a TAP dump n=0 freeze-once
  CONTRADICTED — A-03/A-04 MUTE is identity-invariant after OP_BEGIN steer (rg_off MUTE; this bit NAK gold reasons)
  INFERENCE — UART exact 00800001 was the MUTE first divergence; pack_loader R_HDR_LEN/R_TRUNC now reachable on UART
  UNKNOWN — Pack24 24 unique on this identity; leftover MAG; gold flip 0-vs-absent; query R-04/G-04

HYPOTHESES: A-03/A-04 UART status hops closed on this CANDIDATE. PACK_ABI still blocked by remaining cases + flip contract + query.

HOW_TRACE: 4-step TAP uart vs loader → XSim MUTE then OP_BEGIN → unique bit → program → iso A-03 NAK+TAP → iso A-04 UART. No Pack24. UART did not invent generation_flipped.

EVIDENCE_MATRIX: PASS_XSIM MUTE then NAK9. PASS_XSIM TAPDUMP four-AND. PASS_BOARD isolated A-03 0200095a + A-04 02000f5a CANDIDATE. Not PACK_ABI. Not PROGRAM_PASS. Not BOARD_PASS. Not TIMING_PASS.

SUCCESS_VS_FAILURE: MUTE class closed for A-03/A-04 on this identity. PACK_ABI unproven.

FIRST_DIVERGENCE: pack_begin==(f_data==32'h00800001) vs OP_BEGIN byte; A-03 mem 00840001.

DECISIVE_TEST: Isolated A-03 after program of bd541f95… equals gold 0200095a; TAP loader saw BEGIN132.

ROOT_CAUSE_OR_UNKNOWN: UART steer exact-match BEGIN (FACT, closed on this bit). Remaining PACK_ABI UNKNOWN.

REUSABLE_DECISION_PROCEDURE: generation_flipped true only Pack S_COMMIT four-AND same epoch. Dump TAP on MUTE. Compare uart vs loader before rewriting pack_loader. Unique RCA bits in a new dir.

STRUCTURAL_GUARD: 97_program bans 71b9198f/251eafa9/H/U33. observe_from_tap_gen four-AND. PROGRAM_PASS=NO.

BLAST_RADIUS: Arty SRAM bd541f95…. Frozen identities and prior OBS/rg_off files untouched. C RTL untouched. B gold unmodified.

VERDICT_BY_LAYER: PASS_XSIM steer. PASS_BOARD isolated A-03/A-04 UART CANDIDATE. Not PACK_ABI / PROGRAM_PASS / BOARD_PASS / TIMING_PASS / MIG_PASS.

LESSON_TO_SHARE: A03-A04-UART-STEER-OP-BEGIN-SILICON-NAK-20260920T132400Z
NEXT_DECISIVE_EXPERIMENT: Do not Pack24 mù. Remaining 22 ABI cases still need isolated or TAP-rearm campaign. Do not invent flip=0. Query still required for R-04/G-04.

OWNER_AND_STOP_CONDITION: AGENT_D. Stop PACK_ABI / PROGRAM_PASS / BOARD_PASS stamps. Stop Pack24 until owner authorizes despite flip/query OPEN.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
