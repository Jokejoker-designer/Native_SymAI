NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: U33OBS-GEN-FOURAND-TAPDUMP / 20260920T113500Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: dump-SOF U33OBS ROUTE_DONE is not program-ready (WNS CDC). generation_flipped four-AND is now Pack-owner S_COMMIT observation on TAP dump PASS_XSIM. PACK_ABI=NO. No program.
RUN_PROVENANCE: Exclusive PROGRAM AGENT_D until 2026-09-21 00:00 +07. SRAM TAPCDC eb99ac69. Frozen U33 ff399e0b / H cf62102f / freeze DCPs untouched. dump-SOF DCP backup post_route_dumpsof.dcp sha256 d3e26d3d662e0d5efcd1b24092326977dcc1109fbe7010d2700bd40e67a32ead.
OBSERVATION:
  FACT — impl 722120 exit 0 BUILD.txt STATUS=ROUTE_DONE TAP_CDC_XDC_AT_IMPL=YES
  FACT — post-route WNS -1.516 TNS -6.011 7 setup fail; WHS +0.016 MET; intra sys_clk WNS +0.436 MET
  FACT — failing cells: u_obs_ctrl ack_ui→a0, arm_hold→u0, freeze_r→freeze_ui0, reason_r→dump_w[5], init_calib_complete→cal0, load_reject→nak0 (2.000 ns related-clock)
  FACT — TAP XDC at that impl named only u_cdc_tap / u_cdc_u2ui / busy_u*
  FACT — no U33OBS .bit; READY_TO_PROGRAM=NO; not programmed
  FACT — pack_obs_gen four-AND on S_COMMIT (state==4'd7) then next UI cycle; CLEAR/epoch between snapshots forces generation_flipped=0
  FACT — TAPDUMP PASS_XSIM 6690235 ns GOLD_DUMP_GEN stat=470f0002 before=ffffffff after=0000ffff leftover/DUMP bit16=0
  FACT — core PASS_XSIM 296 ns; 9lane PASS_XSIM leftover+DUMP+GOLD four-AND; dump hops PASS_XSIM CLASS_A
  FACT — pack_obs_gen.sv sha256 c4c79eb8088d08bf802c498c358f04be9c419b5a059d67da83236e91e4427b61
  FACT — TAPDUMP log sha256 61e2e3e176959a1351b056c3bb8df318c2d480adb13b3ecfe1c79463c6d027eb
  INFERENCE — dump-SOF bit from d3e26d3d would not carry four-AND TAP words and would keep WNS CDC
  INFERENCE — expanded XDC + 2FF freeze_reason + gen TAP words belong on the next synth/impl, not this dump-SOF DCP
HYPOTHESES:
  H1 — expanded set_max_delay to first FF of obs 2FF closes the 7 paths — NOT_TESTED until next impl
  H2 — hierarchical u_ld.u_ld.state survives flatten rebuilt (load_reject_reg already survived dump-SOF route) — INFERENCE from dump-SOF netlist names
HOW_TRACE: Route reports → name failing cells vs XDC → do not write dump-SOF bit → encode four-AND at Pack S_COMMIT → TAPDUMP GOLD then DUMP → start re-synth unique build_u33obs. No overlay. No program.
EVIDENCE_MATRIX:
  PASS_IMPLEMENTED dump-SOF post_route.dcp d3e26d3d…
  FAIL_TIMING_POST_ROUTE WNS -1.516 7 CDC
  PASS_XSIM core / TAPDUMP GOLD four-AND / 9lane / dump hops
  SILICON_IDENTITY=NO READY_TO_PROGRAM=NO
  PACK_ABI_24_24_PASS=NO PROGRAM_PASS=NO TIMING_PASS=NO BOARD_PASS=NO
SUCCESS_VS_FAILURE: Route completed; TAP CDC XDC did not except obs_ctrl/NAK/calib/freeze. GOLD four-AND TAP words PASS_XSIM. Leftover MAG does not invent flip.
FIRST_DIVERGENCE: Related-clock 2 ns on unnamed OBS 2FF vs TAP-named CDC cells. Snapshot-delta generation without S_COMMIT rejected by owner Ý5–6.
DECISIVE_TEST: TAPDUMP GOLD_DUMP_GEN t6[19:16]==4'hF and before!=after; leftover t6[16]==0. timing_route Slack(VIOLATED) cell names vs XDC.
ROOT_CAUSE_OR_UNKNOWN: TAP XDC coverage gap (FACT). MUTE silicon hop still OPEN until OBS bit programmed. Historical MAG without leftover inject OPEN.
REUSABLE_DECISION_PROCEDURE: generation_flipped=true only commit_event AND after!=before AND same_capture_epoch AND capture_valid on Pack-owner S_COMMIT. Do not program WNS<0 dump-SOF. Expand CDC exceptions to the actual failing 2FF cells then unique bit. Owner YES required.
STRUCTURAL_GUARD: READY_TO_PROGRAM=NO until BIT_OK unique SHA ≠ ff399e0b/cf62102f/eb99ac69/d448544f + WNS classified + owner YES. Ban overlay H/U33/freeze. 96_bit tcl unique dir PROGRAM=NO.
BLAST_RADIUS: UART_R2/u33obs RTL+XDC+TBs + build_u33obs. Frozen identities on disk. TAPCDC SRAM unchanged.
VERDICT_BY_LAYER: ROUTE_DONE FAIL_TIMING dump-SOF. PASS_XSIM four-AND TAP. SYNTH IN_PROGRESS gen+XDC. Not TIMING_PASS / PACK_ABI / BOARD / PROGRAM.
LESSON_TO_SHARE: GENERATION-FLIPPED-S-COMMIT-NOT-IDLE-SNAPSHOT-AND-OBS-CDC-XDC-GAP-20260920T113500Z
NEXT_DECISIVE_EXPERIMENT: Finish gen+XDC synth then impl with TAP+OBS 2FF XDC at P&R. Hash unique bit. Do not program without owner YES. Do not Pack24 on TAPCDC.
OWNER_AND_STOP_CONDITION: AGENT_D. Stop: BIT_OK unique SHA ready for owner YES, or exclusive PROGRAM expires 00:00+07. No PACK_ABI stamp.
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED=YES
