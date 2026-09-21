NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-RKB-DEST-CAUSAL-TAP-OWNER-PROGRAM-BOARD
RUN_ID: 20260921T090734Z
OWNER_AGENT: AGENT_D
LANGUAGE: EN
CURRENT_CLAIM: FACT owner PROGRAM=YES for exact SHA ead830aef3ec2ebc78519700dedf718f1ded9c135c6d390b26367bd5caf0a6a0. JTAG 210319BE776EA End of startup HIGH. UART COM12 RKB-04 A/B/C clean then RKB-02 and RKB-08 clean after CLEAR. PROGRAM_PASS=NO. BOARD_PASS=NO. RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.

RUN_PROVENANCE:
- Owner PROGRAM APPROVAL quoted CLASS RKB_DEST_CAUSAL_TAP and SHA ead830ae… only; banned daaca9c1 and 8bfd993d
- Live SHA recompute MATCH 1968345 bytes
- Unique copy preserved under results/RKB_DEST_TAP_OWNER_PROGRAM_20260921/
- Program 2026-09-21 16:07:34+07 Vivado 2026.1 Labtools 27-3164 EOS HIGH target localhost:3121/xilinx_tcf/Digilent/210319BE776EA
- UART settle 12s COM12 115200 FTDI 210319BE776EB
- Same-session RKB-02 first attempt NAK 02000e5a R_STALE (A2B gen B1 over live C1); queries muted
- Dedicated retry: CLEAR ACK then RKB-02 then RKB-08

OBSERVATION:
- FACT: live bit sha256 ead830aef3ec2ebc78519700dedf718f1ded9c135c6d390b26367bd5caf0a6a0 MATCH owner quote
- FACT: daaca9c1 1974637 bytes UNTOUCHED; 8bfd993d 1928485 bytes UNTOUCHED
- FACT: UART liveness UNSET tok 03000051
- FACT PASS_BOARD_UART RKB-04 A: Pack A2C GOLD 010000a5, query HIT 03010051, WALK_TAP gen=000000c1 root=0000010 sid=00010100 dest_rd=5 delta=5 nb=00030100 hit=1 e0=0000050
- FACT PASS_BOARD_UART RKB-04 DEST_READ e0=00000050 src=00010100 dst=00030100; e1=00000060
- FACT PASS_BOARD_UART RKB-04 B: DEST_POKE zero e0/e1 only; DEST_READ zeros; query MISS 03000051; WALK_TAP hit=0 nb=0 delta=4 e0=0000050 gen still c1 root still 0000010; Directory/Posting DEST_READ unchanged
- FACT PASS_BOARD_UART RKB-04 C: restore exact beats; query HIT; WALK_TAP nb=00030100 e0=0000050
- FACT: t1 leftover 1 on poison miss; DEST_POKE does not clear T1; miss still walked dest (delta=4)
- FACT: first RKB-02 pack A2B after live C NAK 02000e5a R_STALE
- FACT PASS_BOARD_UART RKB-02 after CLEAR: SLOT0 gen b1 e0=0000050 HIT B; SLOT1 gen b2 root=0100010 e0=0100050 HIT B; poison old SLOT0 still HIT B delta=5 e0=0100050; poison active SLOT1 MISS delta=4 e0=0100050; restore HIT B
- FACT PASS_BOARD_UART RKB-08: A2C GOLD HIT C; poison SLOT0 EdgeRecord MISS delta=4; leftover SLOT1 B did not answer; dir/post unchanged; restore HIT C
- FACT: WALK_TAP after CLEAR still showed last lookup (stale C); UNSET query MISS is the unpublished proof
- INFERENCE: silicon dest causality now observed through UART DEST_READ/POKE/WALK_TAP on this identity
- UNKNOWN: T1 occupancy vs cache shortcut on a future FLSH (RKB-05/06 NOT_RUN)
- CONTRADICTED: HIT_ne_neighbor_C on this identity — WALK_TAP nb is EdgeRecord.dst_id 00030100 while query token remains 03|hit|00|51

HYPOTHESES:
- H1: Zeroing only the active EdgeRecord causes MISS without changing generation/root/Directory/Posting. CONFIRMED PASS_BOARD_UART RKB-04
- H2: Relocated query uses the new dest EdgeRecord; old slot poison does not steal the answer. CONFIRMED PASS_BOARD_UART RKB-02
- H3: Leftover dest / fixture cannot recover a poisoned live EdgeRecord. CONFIRMED PASS_BOARD_UART RKB-08 vs leftover SLOT1 B
- H4: Packing a lower generation over a live higher generation is R_STALE and must CLEAR first. CONFIRMED NAK 02000e5a then CLEAR retry

HOW_TRACE:
Query token 03|hit|00|51. Neighbor and dest_rd from WALK_TAP. DEST_READ 5 words DRD1+4 LE beats. DEST_POKE ACK DPK1. Poison path UART dest_diag through mig0, not hierarchical dest[]. Walk stops at e0 when src!=sid or dst==0 so delta=4 (no e1).

EVIDENCE_MATRIX:
- FACT: bit sha256 ead830aef3ec2ebc78519700dedf718f1ded9c135c6d390b26367bd5caf0a6a0
- FACT: program.log sha256 97b8ea59248878916c4cc5ad8a8a9866f67478167e5ed85c460d9e73884f478d EOS HIGH
- FACT: PROGRAM.txt sha256 adc4ec9b182b84b3e390363d75d3337be0fdef4c610a1315d57a344c391caaaf
- FACT: UART_RKB_DEST_TAP_RKB04_BOARD.json sha256 f5dbafcf4d0ac1b70ac850a0dda88cd095e23d9ad0281492e4208322230746f9 RKB04=1
- FACT: UART_RKB_DEST_TAP_RKB02_RKB08_BOARD.json sha256 4bfbd1ae2317fc9f6d2e42dd8c18a6f7d81807915603eabdcc3a84678d8f81ee RKB02=1 RKB08=1
- FACT: edge bit daaca9c1 UNTOUCHED; CT1 bit 8bfd993d UNTOUCHED
- FACT: TIMING_PASS=NO MIG_PASS=NO PROGRAM_PASS=NO BOARD_PASS=NO PACK_ABI_24_24_PASS=NO

SUCCESS_VS_FAILURE:
- SUCCESS: quoted SHA programmed; RKB-04 A/B/C; RKB-02 relocate poison; RKB-08 leftover independence
- FAILURE: first same-session RKB-02 without CLEAR = R_STALE + mute; not a dest-causal fail

FIRST_DIVERGENCE:
RKB-02 first pack used GEN_B=0xB1 while active_generation was 0xC1. pack_loader R_STALE 8'h0E. Dest TAP itself remained live (WALK_TAP still answered).

DECISIVE_TEST:
CLEAR ACK then UNSET miss then A2B/SLOT1 DEST_POKE sequence. Poison old still HIT B from e0=0100050; poison active MISS delta=4 at that same e0.

ROOT_CAUSE_OR_UNKNOWN:
RKB-04 silicon causal dependency on the live EdgeRecord is confirmed. The first RKB-02 fail was ABI stale-generation, not dest TAP.

REUSABLE_DECISION_PROCEDURE:
1. Recompute SHA; program only the quoted identity; record JTAG and EOS; do not stamp PROGRAM_PASS.
2. Run RKB-04 first: Pack A2C, HIT, WALK_TAP, DEST_READ EdgeRecord, zero only those beats, MISS delta=4 gen/root/dir/post held, restore HIT.
3. For RKB-02 after a higher live generation: CLEAR first, then SLOT0 then SLOT1. Do not pack B over C.
4. Use WALK_TAP e0 as DEST_READ/POKE address; do not assume folded XSim indexes on mig0.
5. WALK_TAP is last lookup snapshot; CLEAR is proven by query MISS, not by TAP gen going UNSET.
6. Do not stamp 8/8 from RKB-04/02/08.

STRUCTURAL_GUARD:
- 97_program want_fixed ead830ae; ban daaca9c1 and 8bfd993d
- DEST_POKE diagnostic-only; host must not write T1
- RKB-02 after live C requires CLEAR
- Claim ceiling PROGRAM_PASS=NO BOARD_PASS=NO RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN

BLAST_RADIUS:
Unique dest TAP identity in SRAM now. Frozen daaca9c1/8bfd993d/FE256 DCP/gold.py/C RTL untouched. T1 leftover occupancy still unproven (RKB-05/06 NOT_RUN).

VERDICT_BY_LAYER:
- PASS_IMPLEMENTED unique program tcl/host
- PASS_XSIM prior RKB-04 dest_diag
- PASS_BOARD_UART RKB-04 A/B/C, RKB-02, RKB-08 on ead830ae
- PROGRAM_PASS=NO BOARD_PASS=NO TIMING_PASS=NO MIG_PASS=NO
- PACK_ABI_24_24_PASS=NO RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN

LESSON_TO_SHARE: RKB02-CLEAR-BEFORE-STALE-GEN-PACK-20260921T090734Z
NEXT_DECISIVE_EXPERIMENT: RKB-05/06 T1 occupancy not priority. FEM persist remains D_MAIN_ROADMAP. Do not return to Pack24/FE256. Do not stamp 8/8.
OWNER_AND_STOP_CONDITION: Anh. Stop 8/8. Stop PROGRAM_PASS/BOARD_PASS self-stamp. Stop more Pack24.
HANDOFF_STATUS: COMPLETE
