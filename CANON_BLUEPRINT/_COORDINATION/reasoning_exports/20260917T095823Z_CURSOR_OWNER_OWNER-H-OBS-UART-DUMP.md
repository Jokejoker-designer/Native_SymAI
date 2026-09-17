# NATIVE_AI_REASONING_EXPERIENCE_V1_CURSOR_OWNER_20260917T095823Z

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: OWNER-H-OBS-UART-DUMP
RUN_ID: 20260917T095823Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Path 1 H_OBS UART-dump is the BASIC-license observe reproducer.
  H_OBS ≠ identity H. A dump class on H_OBS must not be reverse-copied onto H.
  Goal is internal observe of first pack-accepted word + bix after CLEAR, not
  an explanation of identity H. H20 remains classifier-only.
RUN_PROVENANCE:
  Owner 2026-09-17 16:31+07 authorized path 1 only.
  Live PACKAGE CANON_BLUEPRINT tcl 41_build_h_obs.tcl / 41b_impl_h_obs.tcl /
  42_program_h_obs.tcl. Observe RTL only under D:/FPGA/arty_d/H_OBS.
  Identity H bit D:/FPGA/arty_d/m4_mig_clear/arty_a7_r2_top_m4_mig_validation_clear.bit
  sha256 cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9
  m4_mig_clear/PROGRAM.txt still records that SHA (disk history; SRAM now H_OBS).
OBSERVATION:
  FACT — TB_H_OBS_CAP_PASS $finish 320675 ns. OTHER first=00800001 sh0=01;
    H19 first=80000100 sh0=00; H20 first=3149414e drop=1. PASS_XSIM cap-only.
  FACT — synth_design completed; opt_design default crashed Vivado 2026.1
    EXCEPTION_ACCESS_VIOLATION at Phase 3 Retarget (hs_err_pid44916).
  FACT — impl from post_synth_h_obs.dcp sha256 ca77d6cdf5e76348a688f8eab12e6ee72b80e7421be19c767f3aefb349142c81
    with opt_design -propconst -sweep -shift_register_opt -control_set_merge
    (no retarget). Bit sha256 07776d516d5f46b2ccf318cc12cf33a2eae886281b1bd824ae7aa55e1f26f7d7
    ≠ H ≠ H-ILA-A. post_route_h_obs.dcp sha256 7b2bed31189f3902c519e5a07c5930bb4f1db8cac0ebfe99755e8469daa49347
    WNS +0.669 WHS +0.032 LUT 11094 FF 10008 RAMB tile 5 DSP 8. Not TIMING_PASS.
  FACT — program JTAG 210319BE776EA End of startup HIGH. H_OBS/PROGRAM.txt
    IDENTITY=H_OBS EXPLAINS_IDENTITY_H=NO PROGRAM_PASS=NO. Did not write
    m4_mig_clear/PROGRAM.txt. Identity H bit hash still cf62102f.
  FACT — trial0 too-soon CLEAR 0200075a UNSUP (timeout stdin abort, no 5s wait).
  FACT — trial1 wait 8s: CLEAR ACK c1ea50a5; A-01 132/132; pack tok MAG 0200015a;
    dump OBS1 3153424f; first_pack_word 00800001; sh=[01,00,80,00];
    bix_at_arm=0 bix_gap=1 bix_at_first_pack=0 drop_seen=0 have_pack_word=1;
    classifier_h_obs=OTHER_ALIGNED_BEGIN; classifier_applies_to=H_OBS_ONLY;
    explains_identity_h=false. PASS_BOARD observe-dump only, not BOARD_PASS.
  FACT — identity H trial1 was NAK_R02 0200025a with no dump. H_OBS trial1 MAG
    plus dump. Different identities / P&R.
  INFERENCE — After a real CLEAR on this H_OBS P&R, the first pack-accepted word
    is aligned BEGIN. That is the H_OBS OTHER path, not H19 leftover, not H20 drop.
  CONTRADICTED — any claim that this dump classifies identity H.
  UNKNOWN — whether identity H internals are OTHER / H19 / H20. Still not on the H wire.
HYPOTHESES:
  H1 H_OBS dump after clean CLEAR shows leftover H19 (80000100) — REJECTED (00800001).
  H2 H_OBS dump after clean CLEAR shows H20 MAGIC with drop_seen — REJECTED.
  H3 H_OBS class may be copied onto H because handshake matched ACK — REJECTED
     (H_OBS ≠ H; H trial1 token MAG≠NAK_R02).
  H4 bix_gap==1 alone is H19 leftover — REJECTED (OTHER also gap=1; discriminator is
     first_pack_word / sh0).
HOW_TRACE:
  owner path-1
  -> IDENTITY_LOCK H_OBS ≠ H
  -> cap latches fifo_wr_valid&&fifo_wr_ready after clr_take (not CLEAR word)
  -> XSim three classes
  -> synth; retarget crash; impl skip-retarget
  -> refuse bit hashes H / H-ILA-A
  -> program H_OBS only
  -> UART CLEAR+A-01 parse OBS1
  -> stamp H_OBS_ONLY
EVIDENCE_MATRIX:
  DIMENSION | VALUE | LAYER
  cap TB | TB_H_OBS_CAP_PASS 320675 ns | PASS_XSIM
  H_OBS bit | 07776d51… | BITSTREAM_WRITE CANDIDATE
  H_OBS route | WNS+0.669 WHS+0.032 | PASS_IMPLEMENTED timing-met CANDIDATE; not TIMING_PASS
  H_OBS program | End of startup HIGH | programmed-config CANDIDATE; not PROGRAM_PASS
  H_OBS dump | first=00800001 class OTHER_ALIGNED_BEGIN | PASS_BOARD observe-only
  identity H bit | cf62102f… disk MATCH | DO_NOT_BIND / UNTOUCHED
  identity H class | UNKNOWN | NOT_ON_WIRE
  freeze DCP | not opened this run | DO_NOT_BIND
SUCCESS_VS_FAILURE:
  Success: named H_OBS reproducer dumps pack-side first word; lock prevents H reverse-copy.
  Failure-to-promote: does not explain H; MAG≠GOLD; not PACK_ABI_24_24_PASS / BOARD_PASS.
FIRST_DIVERGENCE:
  1) Identity: H_OBS bit 07776d51 vs H cf62102f vs H-ILA-A b037b355.
  2) Pack token: H_OBS MAG 0200015a vs H trial1 NAK_R02 0200025a.
  3) Observability: H_OBS dump present; H dump absent.
DECISIVE_TEST: trial1 CLEAR ACK then A-01; dump first_pack_word==BEGIN on H_OBS.
  Copying that onto H is forbidden even if ACK matched.
ROOT_CAUSE_OR_UNKNOWN:
  Observe path closed on H_OBS. Identity H silicon class remains UNKNOWN.
  H20 not observed on this clean-CLEAR H_OBS trial (expected unless a word already sat).
REUSABLE_DECISION_PROCEDURE:
  1. Name observe identity; refuse sha cf62102f and b037b355 at bitgen and program.
  2. Latch pack-accepted word after CLEAR, never CLEAR 44524743.
  3. Classify from first_pack_word (80000100 H19 / 3149414e H20 / 00800001 OTHER).
     Do not use bix_gap==1 as leftover proof.
  4. Stamp classifier_applies_to=H_OBS_ONLY; explains_identity_h=false.
  5. Wait after program (Start-Sleep, not cmd timeout with redirected stdin).
  6. Too-soon CLEAR 0200075a is host timing, not H19/H20.
STRUCTURAL_GUARD:
  IDENTITY_LOCK.md; tcl refuse hashes; uart refuse PROGRAM.txt IDENTITY!=H_OBS.
  GUARD_ADDED=NO on product/H. Pad=NO. C RTL untouched. Freeze untouched.
BLAST_RADIUS: D:/FPGA/arty_d/H_OBS + tcl 41/41b/42. SRAM now H_OBS. Disk H bit unchanged.
VERDICT_BY_LAYER:
  PASS_XSIM cap TB
  PASS_IMPLEMENTED H_OBS bit+route (CANDIDATE; not TIMING_PASS)
  PASS_BOARD H_OBS UART dump observe (CANDIDATE; not BOARD_PASS)
  IDENTITY_H class UNKNOWN
  EXPLAINS_IDENTITY_H=NO
LESSON_TO_SHARE: OWNER-H-OBS-NE-H-20260917T095823Z
NEXT_DECISIVE_EXPERIMENT:
  Do not copy OTHER_ALIGNED_BEGIN onto H. If H class is still required, that is a
  new named capture on bit cf62102f, which BASIC UART cannot do. Optional: H_OBS
  leftover-byte trial to see H19 on this P&R only. FEM persist still blocked.
OWNER_AND_STOP_CONDITION: OWNER Anh. STOP: H_OBS dump named and locked ≠ H.
HANDOFF_STATUS: COMPLETE
```
