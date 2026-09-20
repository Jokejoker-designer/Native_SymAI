NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: U33OBS-V03-SENTINEL-RDADDR / 20260920T124000Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: PA24-V-03 board R_SENTINEL is dest readback at region base while PAGE wrote at base+wr_off. Isolated V-03 first after reprogram still NAK. Isolated V-01 GOLD same boot. Dirty-BRAM XSim reproduced R_SENTINEL then LOAD_OK after rg_off readback. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO.
RUN_PROVENANCE: Exclusive PROGRAM until 2026-09-21 00:00 +07. Reprogrammed same OBS 71b9198f HIGH PROGRAM_PASS=NO. No overlay H/U33/freeze. C RTL untouched. B gold unmodified.

OBSERVATION:
  FACT — iso V-03 first: CLEAR ACK, NAK 0200085a, TAP 40 B, load0=BEGIN load1=NAI1, commit_event=0, generation_flipped absent, gen_stat 47000002
  FACT — open_drain n=0 (not dummy-open GOLD this boot)
  FACT — same boot iso V-01 GOLD 010000a5; DUMP n=0 (TAP freeze)
  FACT — dirty XSim before fix: wr region1 @0000020 first=99b0ba25; rd chk_i=1 @0000010 rdata=cafebabe; reason 08
  FACT — dirty XSim after rg_off: rd chk_i=1 @0000020 rdata=99b0ba25; LOAD_OK
  FACT — obs_dut 24/24 load still PASS_XSIM (simulation only)
  FACT — gold V-03 ddr_offset=16 and page offset=16; PAY_S first 0x5E47E001
  INFERENCE — empty-BRAM 24-case XSim previously false-passed the unread region-base beat
  CONTRADICTED — V-03 fail is only leftover from V-01/V-02 in the same campaign (iso-first still NAK)
  UNKNOWN — A-03/A-04 MUTE on silicon; gold flip 0-vs-absent; query R-04/G-04

HYPOTHESES: Closed for V-03 class. Remaining PACK_ABI: MUTE A-03, flip contract, query, new unique bit on board.

HOW_TRACE: 4-step iso V-03 TAP after reprogram → iso V-01 control → dirty dest XSim address log → pack_loader rg_off readback → XSim 24/24 load. No Pack24. No TSV flip. Did not overwrite OBS bit 71b9198f.

EVIDENCE_MATRIX: PASS_BOARD V-03 hop named R_SENTINEL + TAP ingest. PASS_XSIM dirty dest after fix. PASS_XSIM 24/24 load. Not PACK_ABI_24_24_PASS. Not PROGRAM_PASS. Not BOARD_PASS. Not MIG_PASS.

SUCCESS_VS_FAILURE: RCA for V-03 closed in XSim+board hop. Silicon still old loader. Compare 24/24 still blocked by flip/query/MUTE.

FIRST_DIVERGENCE: S_RD_ISSUE addr = rg_ddr+0 vs S_WRITE addr = rg_ddr+wr_off (V-03 region 1: 0x10 vs 0x20).

DECISIVE_TEST: tb_v03_rdaddr dest prefill DEAD/CAFE; before reason 08 read@10; after LOAD_OK read@20.

ROOT_CAUSE_OR_UNKNOWN: pack_loader sentinel did not read the first written word. FACT. A-03 mute UNKNOWN.

REUSABLE_DECISION_PROCEDURE: Prefill dest before claiming dest-complete XSim. Log write vs read addresses on first unique ABI fail. Do not treat empty BRAM X as dest-complete.

STRUCTURAL_GUARD: rg_off captured with rg_first; S_RD uses rg_ddr+rg_off. New board bit must be a unique SHA, not overwrite 71b9198f / H / U33.

BLAST_RADIUS: pack_loader.sv sha256 bb59f068… in PACKAGE and Native_SymAI. Arty SRAM still 71b9198f. Frozen identities untouched. C RTL untouched. B TB unmodified.

VERDICT_BY_LAYER: PASS_BOARD hop classify. PASS_XSIM dirty V-03 + 24 load after fix. Not TIMING_PASS / MIG_PASS / PROGRAM_PASS / PACK_ABI / BOARD_PASS.

LESSON_TO_SHARE: V03-SENTINEL-READS-REGION-BASE-NOT-WRITTEN-WORD-20260920T124000Z
NEXT_DECISIVE_EXPERIMENT: New unique OBS bit (new build dir) with this pack_loader; isolated V-03 GOLD on silicon; then A-03 MUTE TAP. Do not invent flip=0. Do not overlay 71b9198f file.

OWNER_AND_STOP_CONDITION: AGENT_D. Stop PACK_ABI / PROGRAM_PASS / BOARD_PASS stamps. Stop Pack24 on current old-loader SRAM.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
