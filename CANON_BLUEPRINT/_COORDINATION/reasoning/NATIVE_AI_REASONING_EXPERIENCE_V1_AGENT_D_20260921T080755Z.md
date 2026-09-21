NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-RKB-DEST-CAUSAL-TAP-XSIM-RKB04
RUN_ID: 20260921T080755Z
OWNER_AGENT: AGENT_D
LANGUAGE: EN
CURRENT_CLAIM: FACT unique RKB_DEST_CAUSAL_TAP identity closed RKB-04 in integrated XSim through UART DEST_READ / DEST_POKE / WALK_TAP, not hierarchical dest[] poke. Owner board hold 45 min: no JTAG/UART/COM/program. daaca9c1 and 8bfd993d disk hashes untouched. NOT silicon causal closure. NOT 8/8. PROGRAM=NO.

RUN_PROVENANCE:
- Owner locked BLOCKER_ID=BOARD_DEST_CAUSAL_OBSERVABILITY_AND_INJECTION_MISSING CLASS=S1_BOARD_CAUSAL_BLOCKER
- Owner "Ok vay khong dung board trong 45 phut" at 2026-09-21T14:52+07. Hold until 15:37+07.
- Unique tree D:/FPGA/arty_d/UART_R2/rkb_dest_tap/ copied from daaca9c1 datapath then dest_diag added
- Integrated XSim finish 7293595 ns PASS_XSIM RKB-04
- Frozen bits this-turn Get-FileHash: daaca9c1769d097cab03ccc7168aefd46cc91689b123618425531f4455fc9381 ; 8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c

OBSERVATION:
- FACT: DEST_READ addr 0x50 returned EdgeRecord.dst_id=00030100 (C)
- FACT: WALK_TAP after valid query: tap_hit=1 tap_nb=00030100 tap_rd=5 e0=0000050
- FACT: DEST_POKE zeros at 0x50/0x60 then query miss dest_rd=4 tap_hit=0 tap_nb=0 gen still 000000c1
- FACT: DEST_POKE restore then query hit C dest_rd=5
- FACT: poison path UART_DEST_POKE; hierarchical dest poke=NO
- FACT: after zero-edge miss, t1_valid remained 1 (DEST_POKE did not clear T1; miss path does not invalidate T1)
- FACT: first restore-query attempt MUTE until ct1_uart_query ignored dg_take words for uart_busy OP_BEGIN
- FACT: no COM12 / hw_server / program_hw_devices this turn after owner hold
- INFERENCE: RKB-04 causal discriminator is implementable on the UART dest_diag plane in XSim
- UNKNOWN: silicon MIG dest_diag vs mig_ui_bram; bitstream SHA not yet built this turn

HYPOTHESES:
- H1: DEST_POKE payload lane with low byte 0x01 set uart_busy and blocked QueryRecord. CONFIRMED_XSIM
- H2: dest_diag_ui hung on restore write. REJECTED — ACK returned; mute was query steal
- H3: T1 leftover after poison miss means T1 is SoT. REJECTED — query missed while t1=1

HOW_TRACE:
QueryRecord -> dest_posting_edge_walk (dir+16, post, entry, e0, e1) -> EdgeRecord.dst_id
DEST_POKE -> dest_diag_uart steal -> dest_diag_cdc -> dest_diag_ui native UI write on mux B (FEM idle)
DEST_READ same path read
WALK_TAP dumps last lookup_done snapshot (gen, pub_root, sid, dest_rd, nb, hit, t1, e0, delta)
wr_beat remains pack-only. DEST_POKE does not COMMIT / fill T1 / change generation / pub_root / synthesize query.

EVIDENCE_MATRIX:
- FACT PASS_XSIM: rkb_dest_tap_int_xsim.log sha256 33a2c0a0c950b543903d87f71a73843b1f600a8d7f03359fa3e2101e771fc996 "RKB-04 DEST_TAP INTEGRATED PASS_XSIM" 7293595 ns
- FACT PASS_IMPLEMENTED: RKB_DEST_TAP_INT_OBS.json sha256 dcc265464fd0b26f0a104b60cb6498fed077d6b3524ddc3f1bae5fd8f139e9af RKB04=1 hierarchical_dest_poke=NO
- FACT PASS_IMPLEMENTED: RKB_DEST_TAP_INT_SRC.json sha256 dcb9dcc883981eabbc77194042197d8d37d14296c28940591c4c73fb636da55f hits=[]
- FACT: walk sha256 de8209f773e6c3aea10e6efb765e96e8b76f5555600c6926152c3b682495278d (debug last_e0/last_e1 only)
- FACT: dest_diag_ui 1718ab675fb6ff03115d817c105da50f8e8420deeb78fedcb6cda7d4e4ad9de0
- FACT: dest_diag_cdc f5c10ffb3d1d6705a4e0da54caf0c4c6db4c71cede4ea0656ddffa6e0b003049
- FACT: dest_diag_uart d13de4a662285a46ca7e881291c204d5c05e807564212c44213d728239a89bb2
- FACT: unique top 0fb24ebfd402d29d6b1a0ee9b7dce01dab1840631da56b3e9198d0c5edd0a84f
- FACT: unique ct1_uart_query bc81451270842192594163516db4c9a78a956f03b353d0060d561318817edc5a (dg_take uart_busy guard)
- FACT: daaca9c1 bit 1974637 bytes UNTOUCHED; 8bfd993d UNTOUCHED
- UNKNOWN: unique bitstream SHA; TIMING; MIG on silicon

SUCCESS_VS_FAILURE:
- SUCCESS: valid EdgeRecord -> hit C; zero EdgeRecord only -> miss; restore -> hit C; WALK_TAP neighbor C then 0 then C; DEST_READ dst=C; gen held C1 across poison
- FAILURE: restore query mute when uart_busy latched from DEST_POKE payload 0x01 byte

FIRST_DIVERGENCE:
ct1_uart_query uart_busy used w_data[7:0]==OP_BEGIN without excluding dest_diag steal. Zero poke (all 0) did not trip it. Restore poke of live EdgeRecord did.

DECISIVE_TEST:
RKB-04 via UART dest_diag only. No u_mig.dest[] assignments in TB. PASS_XSIM after dg_take uart_busy exclude.

ROOT_CAUSE_OR_UNKNOWN:
Diagnostic UART payload can look like pack OP_BEGIN. Query steal must ignore dest_diag words. Dest causality of the miss/hit is dest EdgeRecord contents (PASS_XSIM). Silicon remaining UNKNOWN until unique bit + owner PROGRAM SHA.

REUSABLE_DECISION_PROCEDURE:
1. Keep semantic walk unchanged.
2. Put DEST_READ/POKE on unused mux B; never wr_beat / load_ack / T1 / generation.
3. Steal diagnostic opcodes before pack FIFO.
4. Any clk100 UART observer that keys on low-byte OP_BEGIN must also exclude dg_take.
5. Prove RKB-04 in XSim through the same UART commands the board will use.
6. Do not program until owner quotes the NEW unique SHA. Do not overwrite daaca9c1.

STRUCTURAL_GUARD:
- BLOCKER.json BOARD_DEST_CAUSAL_OBSERVABILITY_AND_INJECTION_MISSING
- DEST_POKE diagnostic-only comment in dest_diag_ui.sv
- unique ct1_uart_query dg_take on uart_busy and q_take
- TB hierarchical_dest_poke=NO
- BOARD_HOLD.txt JTAG/UART=NO until 15:37+07
- 96_bit forbids overwrite of build_rkb_edge / build_ct1; STOP_BEFORE_PROGRAM=YES

BLAST_RADIUS:
Unique rkb_dest_tap tree and unique ct1_uart_query copy only. Not CT1 live identity. Not daaca9c1 RTL/bit. Not C RTL. Not gold.py. Not FE256 freeze.

VERDICT_BY_LAYER:
- PASS_IMPLEMENTED source scan hits=[]
- PASS_XSIM RKB-04 dest_diag UART discriminator 7293595 ns
- PASS_XSIM WALK_TAP neighbor/dest_rd/e0
- NOT_RUN unique bitstream this turn at export time
- NOT_RUN silicon dest poison
- PROGRAM_PASS=NO BOARD_PASS=NO TIMING_PASS=NO MIG_PASS=NO
- PACK_ABI_24_24_PASS=NO RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN
- CT1_BOARD_PASS=NO

LESSON_TO_SHARE: DEST-POKE-OP-BEGIN-UART-BUSY-20260921T080755Z
NEXT_DECISIVE_EXPERIMENT: Unique synth/impl/bit in build_rkb_dest_tap. STOP for owner SHA. After board hold, RKB-04 BOARD then RKB-02 then RKB-08. No Pack24/FE256/isolated XSim. No program until quoted NEW SHA.
OWNER_AND_STOP_CONDITION: Anh. Board unused until 15:37+07. Do not program daaca9c1 or the new bit without quoted SHA. Do not stamp 8/8.
HANDOFF_STATUS: COMPLETE
