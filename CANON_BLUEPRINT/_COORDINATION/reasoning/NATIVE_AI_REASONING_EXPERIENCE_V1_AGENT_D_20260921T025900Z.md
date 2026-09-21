NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: 20260921T025900Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Owner 09:52+07 PROGRAM=YES. Isolated COMMIT→T1 DUT CT1-01..05 PASS_XSIM. Did not program board. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO.
RUN_PROVENANCE: Live bit 8fc14f25 remains programmed. CT1 RTL is XSim-only (pack_runtime_dut + dest_root_cache + mig_ui_bram). No unique CT1 bitstream. FE256/ASTRA/Q*/SPEAR/FEM/C RTL/gold.py not modified. Host does not write T1.

OBSERVATION:
FACT — Owner authorized PROGRAM=YES at 2026-09-21 09:52+07. Lease HELD AGENT_D until 12:00+07, program=true.
FACT — No CT1 FPGA top/bit exists. Live identity 8fc14f25 does not contain dest_root_cache.
FACT — First CT1 XSim: CT1-01/03 OK; CT1-02/04 dest_rd=1 hit=0. Dest beat 00000000_00020100_00010100_b1e16688 (CRC in lane0, SID lane1, fwd lane2).
FACT — After lane-scan decode: CT1-01..05 PASS_XSIM at 4885 ns. JSON sha256 372ea910653cf608024833c20b0c2b8ce190554c00cd790f265bab7721326a3c.
FACT — t1_valid stayed 0; query dest-reads T2 each time.
FACT — This run did not call program_hw_devices. 8fc14f25 SRAM evidence kept.
INFERENCE — Programming 8fc14f25 again would wipe Pack SRAM without testing COMMIT→T1.
INFERENCE — CT1 PASS_XSIM is isolated UI-BRAM, not mig0, not board, not RKB 8/8.

HYPOTHESES:
H1: Lane0 CRC is pack dest-complete rg_first / page header CRC sitting in the same 128b beat as the 16B directory entry. (leading)
H2: T1 valid flag never rises because rebuild handshake / pub_v display is stale; semantics still dest-backed.

HOW_TRACE: RKB-08 CLASS A → lock T1=cache → first DUT queried T1[31:0] as SID → miss → dump dest0 → scan lanes → CT1-02/04/05 hit from dest. PROGRAM grant recorded; nạp skipped (no CT1 bit; do not wipe 8fc14f25).

EVIDENCE_MATRIX:
- CT1_OBS.json sha256 372ea910… PASS_XSIM CT1_01..05=1
- ct1_xsim.log sha256 3d076365… $finish 4885 ns
- dest_root_cache.sv sha256 bc2b7cd2…
- OWNER_PROGRAM_YES_20260921.md (grant; not PROGRAM_PASS)
- PROGRAM.txt live 8fc14f25 unchanged

SUCCESS_VS_FAILURE: Isolated DUT now dest-reads committed A→B then A→C; UNSET fail-closed. Failure would have been programming 8fc14f25 or claiming board CT1.

FIRST_DIVERGENCE: Query compared beat[31:0] to SID; committed SID is beat[63:32].

DECISIVE_TEST: Same Pack dest + QueryRecord; lane-scan vs lane0-only.

ROOT_CAUSE_OR_UNKNOWN: DIRECTORY_INSTALL_MISSING on current silicon (FACT). Isolated DUT hole was SID lane vs dest-complete CRC word (FACT). T1 occupancy UNKNOWN.

REUSABLE_DECISION_PROCEDURE: Dump dest beat before encoding expected SID lane. Owner PROGRAM=YES ≠ a bit exists. Do not nạp a live identity to “use” a grant.

STRUCTURAL_GUARD: CT1 decoder scans lanes; host must not write T1; no program of 8fc14f25; no freeze DCP.

BLAST_RADIUS: arty_d/rkb_readback + verification_r1/ct1. Not C RTL. Not gold.py. Not FE256. Not live SRAM.

VERDICT_BY_LAYER:
PASS_XSIM — CT1-01..05 isolated DUT
PASS_IMPLEMENTED — grant file + lease note
NOT_RUN — CT1 bitstream / board
NO — PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS / RUNTIME_KNOWLEDGE_BINDING_8_8_PASS

LESSON_TO_SHARE: OWNER-PROGRAM-YES-IS-NOT-A-BIT-20260921T025900Z

NEXT_DECISIVE_EXPERIMENT: Unique identity bitstream of COMMIT→T1 only after independent audit; do not nạp 8fc14f25. Optional: prove T1 occupancy after rebuild.

OWNER_AND_STOP_CONDITION: AGENT_D. Stop: no program this turn; no PACK_ABI / PROGRAM_PASS stamp.

HANDOFF_STATUS: COMPLETE
