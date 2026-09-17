# NATIVE_AI_REASONING_EXPERIENCE_V1

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: C-FPGA-STRUCTURAL-AUDIT-01 / C-TO-D-INTEGRATION-HANDOFF / C-20260916-PIPE-AUDIT-HANDOFF
OWNER_AGENT: AGENT_C
DATE: distill 2026-09-17T04:19+07:00 (RTL freeze 2026-09-16, HEAD e3d59ab)
REASONING_DISTILLATION_REQUIRED: YES
PRIOR_HANDOFF_WITHOUT_THIS_FILE: INCOMPLETE_HANDOFF
CURRENT_CLAIM:
  C Q*/SPEAR/FEM at current profile size are structurally approved for D
  integration (CLEAN_WITH_SCALE_WARNINGS). OOC 100 MHz post-synth MET after
  pipeline + P_EXP splits. Not TIMING_PASS, not BOARD_PASS, PROGRAM=NO.
  D must not rewrite C memories to force BRAM at theta=64 / NSLOT=9.
RUN_PROVENANCE:
  Worktree NATIVE_AI/worktrees/AGENT_C HEAD e3d59ab (P_EXP). Prior pipe 7b13f64.
  Part xc7a100tcsg324-1. OOC create_clock -period 10.000 tb/learning/ooc_synth.tcl.
  Vivado v2026.1 Build 6511674. Icarus then XSim.
  qstar_select.v SHA256 d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240
  spear_rank.v    SHA256 11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293
  fem_lifecycle.v SHA256 45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed
  PACKAGE hashes equal worktree at publish (FACT).
  JSON rtl/native_ai/strategy/QSTAR_SPEAR_OOC_PIPE.json
  Audit worktrees/AGENT_C/Temp/c_fpga_structural_audit/
  HD.CLK_SRC unset (Timing 38-242). DESIGN_STATE synthesized/unplaced.
OBSERVATION:
  FACT — Icarus+XSim stayed PASS after every registered split (Q* 12/12, SPEAR 30/30).
  FACT — OOC WNS migrated: Q* −2.330/−2.009 then +1.703; SPEAR −2.739/−1.311/−1.052 then +1.898.
  FACT — D r2_top after bag1: WNS −10.174 → +1.549 (mailbox 20260916T104154).
  FACT — D mig flatten after bag1: mask_r[5]→q_sel[0] −1.482 / 16 LUT / 11.346 ns (20260916T113106).
  FACT — After P_EXP, named OOC cone mask_r→q_sel 3.160 ns slack +6.800 (JSON round2_select_cone).
  FACT — D ui_clk after bag2: setup WNS +1.277; mask cone not top; Q* DSP 6.813 ns slack +3.575 (20260916T132944).
  FACT — Audit: 0 BRAM, 0 LUTRAM; Q* MUXF8=128; max listed levels Q* 14 / SPEAR 10 / FEM 7; WNS all +.
  FACT — FE256 R0 signature was async large mem, 0 BRAM, 144 levels, WNS −75.723. C is not that class at current size.
  FACT — Routed 100 MHz after P_EXP was not produced by C (NOT_EVIDENCED).
HYPOTHESES:
  H1 Extra registered stages close C-owned 100 MHz OOC cones without port/arithmetic change. (CONFIRMED locally at PASS_OOC)
  H2 D-reported flatten mask_r→q_sel was a distinct cone from the OOC-worst DSP path. (CONFIRMED)
  H3 14-level Q* endpoints in the audit listing are the theta mux tree. (STRONG_INFERENCE, not a traced path in audit TCL)
  H4 r2_top vs mig_top difference on the same C RTL is congestion/clock, not a second C bug. (UNKNOWN)
  H5 Forcing BRAM on theta[0:63] async dual-read + async reset-all would be a rewrite, not inference. (EVIDENCED_LOCAL_CAUSAL mapping)
HOW_TRACE:
  legal_mask/feat_flat
    -> S_IDLE latch mask_r, feat_r
    -> serial MAC {P_RD,P_MAC}x8x8 + P_ROW argmax
    -> P_EXP1 (k_expl, explore_hit) -> P_EXP2 (a_expl, mask[a_expl])
    -> P_SEL mux q_row[a_expl_r]|best_q => prop_done/prop_valid
    -> U_CHK pending consume
    -> {U_RD,U_MAC}x8 -> U_DISC -> U_TGT -> U_DELTA -> U_DA -> {U_MUL,U_WRITE}x8
    -> theta[mac_addr] write (REGISTER file, async dual read)
  cand_desc -> S_ACCEPT -> S_CHECK/S_CHECK2 CRC16-56 -> S_MACRD/S_MAC x16
    -> S_ROUND -> S_INSERT (NSLOT=9) -> S_PREFIN/S_FINAL
  FEM T2 we/addr/wdata + t2_ready; registered crc16_n; D media/MIG not C.
  Handshake, not fixed cycle count (RTL_PIPELINE_DEPTH=IMPLEMENTATION_DEFINED).
EVIDENCE_MATRIX:
  F1 Icarus/XSim after splits | PASS_XSIM | run_qstar_local.py / run_spear_local.py
  F2 OOC mid-pipe | FAIL then PASS_OOC | live OOC; final *_timing.rpt + JSON
  F3 D r2_top bag1 | D post-synth keep-hierarchy CANDIDATE | mailbox 104154
  F4 D mig flatten mask cone | FAIL 100 MHz flatten | mailbox 113106
  F5 Named cone after P_EXP | PASS_OOC on that from/to | JSON round2_select_cone
  F6 D ui_clk bag2 | D post-synth CANDIDATE; not PASS_IMPLEMENTED | mailbox 132944
  F7 RAM inference | 0 BRAM/LUTRAM | *_ram.rpt *_inference.txt
  F8 vs FE256 R0 | not SAME_FAILURE_CLASS at current size | levels + WNS vs 144/−75.7
  F9 Routed 100 MHz | NOT_EVIDENCED | none
SUCCESS_VS_FAILURE:
  Semantics: success = bit-exact every split; failure none this run.
  Q* OOC: fail while MAC/update combo; success after P_RD+U_DISC+update pipe (+1.703 DSP).
  SPEAR OOC: fail while CRC/ranking/operand mux combo; success after S_MACRD+S_PREFIN (+1.898).
  Integrated r2_top: success bag1 +1.549 SPEAR desc_ok vs pre-pipe −10.174 Q* feat_r→theta.
  Integrated mig flatten: fail bag1 mask_r→q_sel; after P_EXP D says cone not top (ui_clk +1.277).
  Mapping: FEM sequential T2 vs Q* theta never BRAM (async 2-read + reset-all).
  Board: neither success nor failure — NOT_EVIDENCED.
FIRST_DIVERGENCE:
  Timing (old fabric −10): combinational feat_r*theta MAC+round+add+sat in one cycle.
    Not XDC. Not SPEAR CRC (later C-owned worst after Q* split).
  Timing (mask −1.482): after MAC/CRC MET, flatten still failed P_SEL popcnt+mod+kth_legal+q_row.
    Divergence from OOC-success: which path is worst (DSP vs select LUT cone).
    Divergence bag1 r2_top MET vs mig fail: top/config, not C arithmetic.
  Mapping vs FE256 R0: same coding style (async array + combo reduction);
    first divergence is SIZE (64×16b / NSLOT=9 vs large async ROM + 144-level reduction).
DECISIVE_TEST:
  1) After each RTL split: ooc_synth.tcl 10 ns; quote NEW Source/Dest/levels, not the old path.
  2) Against D-quoted cone: env OOC_FROM=mask_r_reg.* OOC_TO=q_sel_reg.*
     (do not put unquoted | in cmd.exe Tcl regex). Discriminator: cone delay << 11.35 ns.
  3) report_ram_utilization + inference: 0 BRAM at depth 64 is expected, not a D rewrite ticket.
  4) Hash PACKAGE RTL vs worktree before D re-synth. Mismatch => STALE_INDEX (see B L-011 collision note: C uses L-017).
ROOT_CAUSE_OR_UNKNOWN:
  RC1 EVIDENCED_LOCAL_CAUSAL: software-shaped one-cycle datapaths (MAC, CRC-112, ranking, explore pick).
  RC2 EVIDENCED_LOCAL_CAUSAL: P_SEL combo popcnt+mod_small(7)+kth_legal+q_row mux (fixed by P_EXP).
  RC3 EVIDENCED_LOCAL_CAUSAL: theta async 2-read + async reset-all blocks BRAM/LUTRAM.
  RC4 UNKNOWN: why mig flatten exposed mask cone while r2_top MET SPEAR CRC.
  RC5 STRONG_INFERENCE: 14-level Q* endpoints = theta mux; not path-traced in audit TCL.
REUSABLE_DECISION_PROCEDURE:
  ON a C timing complaint:
    A. Freeze hashes + commit. Do not edit ports/arithmetic unless a vector fails.
    B. Classify layer: PASS_XSIM vs PASS_OOC vs flatten vs route.
    C. If D quoted Source/Dest, measure THAT cone (named report_timing / OOC_FROM/TO).
    D. Split only the still-combo C-owned cone. Re-measure. Repeat until current worst MET or not C-owned.
    E. Publish PACKAGE hashes; D consumes hashes, not a measurement-only mail.
    F. If RAM=0 at small async-reset arrays: approve + C_SCALE_GUARD; do not force BRAM.
    G. Stamp at most PASS_OOC / PASS_XSIM. Never TIMING_PASS / BOARD_PASS / PROGRAM.
    H. Write NATIVE_AI_REASONING_EXPERIENCE_V1 before claiming handoff complete.
STRUCTURAL_GUARD:
  C_SCALE_GUARD: halt C integration / wake C if theta depth>64, actions>8, features>8,
    K_HARD_MAX>9, FEM N_RAW material increase.
  C_CONE_CONSUME_GUARD: D-quoted failing path must appear in C OOC bag as that from/to.
  C_PUBLISH_HASH_GUARD: mail D only after PACKAGE SHA256 matches worktree for named C RTL.
  C_OOC_LAYER_GUARD: OOC WNS>0 is PASS_OOC only.
BLAST_RADIUS:
  D spear_profile_bind / u_q / u_spear: ports unchanged; cycle count grew — use done/prop_valid.
  Fabric 100 MHz vs ui_clk ~12 ns: P_EXP required for 10 ns sys_clk select cone; not for MIG bind if Q* stays on ui_clk and 11.35 ns MET.
  FEM T2/MIG remains D-owned. A/B contracts (32-bit ID, pending credit, k_invalid, integrity_fault) unchanged.
  Unrelated dirty _COORDINATION mailbox files in C worktree are not this RTL delta.
VERDICT_BY_LAYER:
  PASS_UNIT / PASS_XSIM: Q* 12/12 SPEAR 30/30 after final RTL
  PASS_OOC: Q* +1.703 SPEAR +1.898 FEM +3.669 (unplaced estimate)
  Integrated post-synth: D-reported CANDIDATE; C did not re-run those tops
  PASS_IMPLEMENTED / PASS_BOARD: NOT_EVIDENCED
  vs FE256 R0: not SAME_FAILURE_CLASS at current size; PARTIAL style overlap on Q* theta
  PROGRAM / TIMING_PASS / BOARD_PASS / FINAL_PASS: not claimed
LESSON_TO_SHARE: L-015 CONE_MIGRATION; L-016 OOC_HIDES_FLATTEN_CONE; L-017 PUBLISH_HASH_BEFORE_D; L-018 SMALL_ASYNC_ARRAY_NOT_BRAM_TICKET
NEXT_DECISIVE_EXPERIMENT:
  OWNER AGENT_D. Control hashes d4f64e65 / 11e71b50 / 45b9b930.
  Single variable: implementation stage (flatten vs place/route) on the exact top under test.
  Discriminator: if routed WNS on a C-owned Source/Dest is negative, wake C; if positive, C stays asleep.
  Stop: one quoted path + layer label. PROGRAM=NO unless owner says otherwise.
  C does not run this while ON_DEMAND.
OWNER_AND_STOP_CONDITION:
  OWNER AGENT_D for integration; AGENT_C ON_DEMAND.
  STOP: C PRIMARY_QUEUE CLOSED unless C_SCALE_GUARD fires or a C-owned path fails on these hashes.
  CLAIM CEILING: PASS_OOC + PASS_XSIM only.
HANDOFF_STATUS: COMPLETE
```
