NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-RKB-DEST-CAUSAL-TAP-BIT-STOP
RUN_ID: 20260921T083300Z
OWNER_AGENT: AGENT_D
LANGUAGE: EN
CURRENT_CLAIM: FACT unique RKB_DEST_CAUSAL_TAP bitstream sha256 ead830aef3ec2ebc78519700dedf718f1ded9c135c6d390b26367bd5caf0a6a0 is READY_FOR_OWNER_PROGRAM_DECISION. STOP_BEFORE_PROGRAM. First route WNS=-0.647 aborted bitgen; RTL fix then WNS=+0.092 WHS=+0.016 loops=0. TIMING_PASS=NO. PROGRAM=NO. daaca9c1 and 8bfd993d disk hashes untouched.

RUN_PROVENANCE:
- First unique synth/route 2026-09-21 15:19+07 WNS=-0.647 CUT=SETUP_NOT_MET
- RTL: tap_sid_ui from walk last_sid (ui_clk) not clk100 sid_hold; break q_take/dg_take combo loop
- Re-XSim RKB-04 PASS_XSIM 7293595 ns
- Rebuild BIT_OK 15:32+07 sha ead830ae… 1968345 bytes
- BOARD_HOLD until 15:37+07 still in force at freeze; no JTAG

OBSERVATION:
- FACT: WNS +0.092 TNS 0 WHS +0.016 THS 0 WPWS +0.187 constraints met
- FACT: combinational loops 0 (was 1 on q_take)
- FACT: LUT 11869 FF 12180 RAMB18=1 DSP 8 DRC errors 0 checks 38 Warning
- FACT: unconstrained_internal_endpoints 0
- FACT: XSim RKB04=1 UART DEST_POKE not hierarchical
- INFERENCE: 2 ns related-clock SID path was the only SETUP_NOT_MET class
- UNKNOWN: silicon MIG dest_diag vs XSim mig_ui_bram

HYPOTHESES:
- H1: sid_hold->tap_sid_ui CDC caused WNS=-0.647. CONFIRMED by timing_route then closed after last_sid
- H2: combo loop was a DRC HIGH not the WNS source. CONFIRMED_DRC; still had to remove it

HOW_TRACE:
First route failing paths all sys_clk_pin sid_hold -> ui_clk tap_sid_ui requirement 2.000 ns. Walk last_sid is already ui_clk. q_take no longer combo-depends on dg_take.

EVIDENCE_MATRIX:
- FACT: bit sha256 ead830aef3ec2ebc78519700dedf718f1ded9c135c6d390b26367bd5caf0a6a0
- FACT: post_route.dcp sha256 66bb25d1c2768920841a7cd552017a4e4ce9f6a702a85ff2bfff9fe3a1f98ade
- FACT: BOARD_CANDIDATE.json sha256 9433cf76979cb42f5990f1a30c2e56dc38261e13310dd356e3e54ccad89bf278
- FACT: SHA256SUMS.txt sha256 719aa1825c54009d4b84430fe16394cfd0226677b0f7c2e4d40f5ba4df79dcad
- FACT: daaca9c1 1974637 bytes UNTOUCHED; 8bfd993d UNTOUCHED
- FACT PASS_XSIM: log b596296b3d1cc2b3be89c90da4f91d0441f9ec36017957b654112af3c29ad321
- FACT: TIMING_PASS=NO MIG_PASS=NO by claim ceiling even with WNS>0

SUCCESS_VS_FAILURE:
- SUCCESS: BIT_OK STOP_BEFORE_PROGRAM unique identity
- FAILURE: first bitgen SETUP_NOT_MET WNS=-0.647

FIRST_DIVERGENCE:
tap_sid_ui <= lookup_sid sampled clk100 hold into ui_clk FF.

DECISIVE_TEST:
Rebuild after last_sid. WNS=+0.092 loops=0 unique SHA != daaca9c1.

ROOT_CAUSE_OR_UNKNOWN:
Illegal related-clock sample of Query SID CDC hold into WALK_TAP snapshot. Combo steal loop was a separate DRC defect.

REUSABLE_DECISION_PROCEDURE:
Snapshot TAP fields from same-clock walk/pack FFs. Do not sample sid_hold on ui_clk. Opcode-disjoint UART steal must not combo-couple q_take and dg_take. Abort bitgen if WNS<0. Do not stamp TIMING_PASS from met constraints.

STRUCTURAL_GUARD:
- 96_bit SETUP_NOT_MET if WNS<0
- unique last_sid from dest_posting_edge_walk
- q_take MAGIC without dg_take; dg_take dest cmds without q_take
- BOARD_CANDIDATE OWNER_MUST_QUOTE_THIS_SHA
- FORBIDDEN overwrite build_rkb_edge / build_ct1

BLAST_RADIUS:
Unique build_rkb_dest_tap only. SRAM still daaca9c1. Not FE256 freeze. Not gold.py. Not C RTL.

VERDICT_BY_LAYER:
- PASS_IMPLEMENTED unique bit file + hashes
- PASS_XSIM RKB-04 dest_diag UART
- Route WNS/WHS FACT; TIMING_PASS=NO
- PROGRAM=NO BOARD_PASS=NO MIG_PASS=NO
- PACK_ABI_24_24_PASS=NO RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN

LESSON_TO_SHARE: TAP-SID-UI-FROM-WALK-NOT-SID-HOLD-20260921T083300Z
NEXT_DECISIVE_EXPERIMENT: After board hold, owner quotes ead830ae… then PROGRAM that SHA only. Board tests RKB-04 then RKB-02 then RKB-08. No Pack24/FE256.
OWNER_AND_STOP_CONDITION: Anh. Do not program until quoted NEW SHA. Do not reuse daaca9c1. Do not stamp 8/8.
HANDOFF_STATUS: COMPLETE
