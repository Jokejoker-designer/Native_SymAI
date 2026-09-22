# NATIVE_AI_REASONING_EXPERIENCE_V1

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: INDEPENDENT_AUDIT_INTEGRATED_BEHAVIORAL_NETLIST / C-20260922-CHAIN-XSIM-AUDIT
OWNER_AGENT: AGENT_C
DATE: 2026-09-22T08:37+07:00
REASONING_DISTILLATION_REQUIRED: YES
CURRENT_CLAIM:
  D claimed INTEGRATED_CAUSAL_XSIM_CANDIDATE=SUPPORTED. C's independent
  verdict on the named hashes is the same ceiling, with CONTRADICTION_FOUND=NO.
  This is not BOARD_PASS, ASTRA_PASS, TIMING_PASS, PROGRAM_PASS, FE256_PASS,
  or PACK_ABI_24_24_PASS. RECOMMEND_BOARD_BUILD=NO.
RUN_PROVENANCE:
  FACT — chain_xsim.log sha256 e112783e8c350633bb8111e13462e894746bc55091cdf6fb895eac52e59ed0ea
    bytes=3714 finish 18555 ns. xsim v2026.1 session 2026-09-22 08:23:27, pid 14464.
  FACT — xvlog.log 08:23:21 and xelab.log 08:23:26 immediately precede that xsim.
  FACT — DUT 39044d771f8d2332a2a929639a1aa56327a69e0bfdc06d142ecbc98f1af6dd29
  FACT — TB  82c445e1e9dafd222e923382c0e82d66a728ef9894e811a35bbb71512b0c2ef5
  FACT — spear_fem_rank.sv 3e1111dd49295b6f98f09d0a60587e831bff24ec08d744e6a9f9be296e49996f
  FACT — astra_action_precheck_v1.sv 6a65a73f336795f687fc02a140aa0210967689453c4ed569d2f6dc7cf8e65dc1
  FACT — compiled fem_lifecycle.v / spear_rank.v / qstar_select.v under
    D:/FPGA/Native_SymAI/CANON_BLUEPRINT match frozen hashes
    45b9b930… / 11e71b50… / d4f64e65… and the AGENT_C worktree copies.
  FACT — xvlog file list has no UART source. run_chain.tcl is "run -all / exit".
    xsim.jou has no add_force.
  FACT — chain_xsim_16804.backup.log is an earlier session (08:21:12, pid 16804,
    finish 18545 ns) and is not the named artifact.
  RTL_EDIT=NO. PROGRAM=NO. BITSTREAM=NOT_BUILT.
OBSERVATION:
  FACT — log arms:
    PRE  infl=1 safe=1 life=7 ft=0 dB=0   rank0=A1 feat=0 prop=0 verdict=b0 final=00 qsel=0
    OFF1 infl=0 safe=1 life=3 ft=2 dB=0   rank0=A1 feat=0 prop=0 verdict=b0 final=00
    ON1  infl=1 safe=1 life=3 ft=2 dB=256 rank0=B1 feat=2 prop=1 verdict=b0 final=01 qsel=2
    OFF2 infl=0 safe=1 life=3 ft=2 dB=0   rank0=A1 feat=0 prop=0 verdict=b0 final=00
    VETO infl=1 safe=0 life=3 ft=2 dB=256 rank0=B1 feat=2 prop=1 verdict=b2 final=ff
    theta8=0001 theta_we_count=1 on every printed epoch. $finish at TB line 377.
  FACT — TB arm() assigns only fem_infl_en, safety_ok, run_start. want_* values
    are compares. No force, deposit, or hierarchical write. failure_total is a DUT output.
  FACT — chain wires failure_total to spear_fem_rank.fem_ft; rank0_id into
    feat0_r = (rank0_id==REF_B)?2:0; feat_flat={56'h0,feat0_r} into qstar;
    qstar.proposed_action (q_proposed) into astra.proposed_action;
    astra.final_action into the captured final.
  FACT — spear_fem_rank delta is {1'b0,ft_r,7'h0} only when infl_r && ft_r!=0
    and that side has the lower base score. ft=2 yields 256. life_r and comp_r
    are latched and never read. adm_ref_flat is unused. fem_feat is unused.
  FACT — qstar mac_addr={a_i,f_i}; theta_addr=8 is action 1 feature 0.
    exam=1 forces explore_hit=0. upd_start=0. Log greedy==proposed and qsel is 0 or 2.
  FACT — astra: safety_ok=0 selects V_SAFETY and final 8'hFF; else final is
    {5'h0, proposed_action}. intent_legal=1, stale=0, capability=1 are tied.
HYPOTHESES:
  H1 TB or UART overwrites a discriminator net. REJECTED. No such driver; no UART in xvlog.
  H2 Arm name selects rank or action. REJECTED. No arm-id port. Arm string is $display only.
  H3 Sticky rank or proposal survives OFF1→ON1→OFF2. REJECTED by the hashed log and by
    feat0_r being rewritten from rank0_id on each sr_done.
  H4 Influence alone produces dB=256. REJECTED. PRE is infl=1, ft=0, dB=0, action 0.
    Delta equation does not read life or compacted, so the PRE life/comp difference
    is not an alternate cause.
  H5 VETO changes the proposal. REJECTED. Upstream rank/dB/feat/prop match ON1;
    only safety_ok and the ASTRA final/verdict change.
  H6 The 08:21 NOT_SUPPORTED log contradicts this netlist. REJECTED as a different
    snapshot (theta boot rdata=0, different finish). The hashed run prints theta8=0001
    and passes the arm theta check.
HOW_TRACE:
  fem_lifecycle.failure_total
    -> fem_on_mig.failure_total
    -> spear_fem_rank.fem_ft latched to ft_r at run_start
    -> delta_b when infl_r && ft_r!=0 && base_b<base_a
    -> rank0_id from the same compare
    -> feat0_r map {0,2}
    -> qstar feat_flat, greedy proposed_action
    -> astra_action_precheck_v1.proposed_action
    -> final_action
EVIDENCE_MATRIX:
  F1 hashes | MATCH | Get-FileHash on named paths and compiled C RTL
  F2 four arms + PRE | MATCH log vs TB wants | chain_xsim.log lines 29-33
  F3 no downstream driver | FACT | full TB/DUT read; xvlog has no UART
  F4 delta equation | FACT | spear_fem_rank.sv S_RANK; life_r/comp_r unread
  F5 Q* consumes feat | FACT | qstar feat_r/mac_addr; log qsel 0 vs 2
  F6 ASTRA gates final | FACT | astra_action_precheck_v1.sv; VETO final=ff prop=1
  F7 prior NOT_SUPPORTED | DIFFERENT RUN | backup log pid 16804 finish 18545 ns
SUCCESS_VS_FAILURE:
  Success: hashed run reaches TB line 377 with nfail==0 and the discriminator above.
  Non-claim: no route, no bitstream, no UART, synthetic fixtures remain synthetic.
  Earlier boot-check failure is outside this identity.
FIRST_DIVERGENCE:
  The in-log SUPPORTED banner and the backup NOT_SUPPORTED banner diverge from
  each other before either is evidence. The audited identity is the hash.
  Inside that netlist, the first causal split is infl_r && ft_r!=0, not life or
  compacted and not the arm name.
DECISIVE_TEST:
  1) SHA256 of log, DUT, TB, wrapper, precheck, and the three compiled C files.
  2) Read every assign of failure_total, delta_*, rank0_id, feat0_r, q_proposed, final_w.
  3) Confirm TB arm() writes only fem_infl_en, safety_ok, run_start.
  4) Confirm OFF2 equals OFF1 and VETO upstream equals ON1 in the hashed log.
  Discriminator: a second driver, a force, or a rank/action that does not return
  on OFF2 would be a contradiction. None found.
ROOT_CAUSE_OR_UNKNOWN:
  No contradiction. Delta magnitude is the latched failure_total shifted by 7,
  not a literal 256. Feature codes 0 and 2 are a labeled synthetic map selected
  only by live rank0_id. Final FF is ASTRA safety, not a second action source.
REUSABLE_DECISION_PROCEDURE:
  Hash the named log and every file in that run's xvlog list.
  Ignore same-directory banners and backup logs until their hashes are the named ones.
  Trace each discriminator to one driver.
  Treat TB want_* as oracles.
  Unread latches are not causal.
  Stop at PASS_XSIM candidate. Do not recommend a bit.
STRUCTURAL_GUARD:
  C_CHAIN_HASH_GUARD: no verdict without SHA match of the log and the xvlog sources.
  C_OOC_LAYER_GUARD still applies: this result is PASS_XSIM only.
  C RTL freeze unchanged. C_SCALE_GUARD unchanged.
BLAST_RADIUS:
  Audit verdict only. No edit to fem_lifecycle.v, spear_rank.v, qstar_select.v.
  Synthetic descriptors, query, theta[8]=1, legal_mask=8'h03, {0,2} map,
  test-controlled safety_ok, and B0-B4 packing stay non-product.
VERDICT_BY_LAYER:
  PASS_XSIM: INTEGRATED_CAUSAL_XSIM_CANDIDATE=SUPPORTED on the named behavioral run
  NOT_EVIDENCED: BOARD_PASS ASTRA_PASS TIMING_PASS PROGRAM_PASS FE256_PASS
    PACK_ABI_24_24_PASS
  RECOMMEND_BOARD_BUILD=NO
LESSON_TO_SHARE: L-026 C-CHAIN-XSIM-HASH-NOT-BANNER-20260922
NEXT_DECISIVE_EXPERIMENT:
  None required for this ceiling. A board build is a different claim and is not
  authorized by this XSim.
OWNER_AND_STOP_CONDITION:
  OWNER of the audit verdict: AGENT_C. Integration remains AGENT_D.
  STOP: C returns the field block and does not edit RTL, build a bit, or program.
HANDOFF_STATUS: COMPLETE
```
