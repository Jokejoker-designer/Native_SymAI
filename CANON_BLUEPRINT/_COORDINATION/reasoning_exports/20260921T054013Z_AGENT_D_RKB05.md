# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: D-RKB05-STALE-T1
RUN_ID: 20260921T054013Z
OWNER_AGENT: AGENT_D
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES
MAILBOX: NOT_SENT (owner relays)
PROGRAM: NO

CURRENT_CLAIM:
RKB-05 dest-backed walk: warm dest-filled T1 on A→B, COMMIT A→C without host
T1 poke or t1_flush, query returns C not leftover B. Isolated DUT PASS_XSIM.
T1 is not on the answer path (dest_rd=5 after C). Not 8/8. Not board.

RUN_PROVENANCE:
- Command: `D:\FPGA\arty_d\rkb_readback\run_rkb05_xsim.bat`
- First run (this session, log overwritten): FAIL_XSIM 7015 ns hit B then C dest_rd=5 t1_valid=0/0
- Second run: exit 0 `$finish` 7015 ns `RKB-05 PASS_XSIM`
- RKB05_OBS.json sha256 `cdd8dc7e6856fbfe402feec9f84aa1deadae9fc7d03594d2c62a6e0f8be5e7ac`
- rkb05_xsim.log (PASS rerun) sha256 `383fd72d8078098072316ae915700ccd4077604c8aafd25da7f53b82f96539bf`
- dest_posting_edge_walk.sv sha256 `af2b3b3c79edb2a94a3be062e727cf78d730ffc95fdb93119adb24d260417daa`
- dest_root_cache.sv sha256 `62ba5f1c08be7c698f4308673360d30df44892b9bd6b0b8c9f3613f80791d76b`
- pack_edge_dut.sv sha256 `7888fc7cfa2b9c25ec6c2f57e1432d087736680953355c0be5d7065dbd283953`
- tb_rkb05_edge.sv sha256 `0d2088030f07d5365a4c2abb38ca2c1d900336f065729af1c0ac8cd3617721ea`
- PROGRAM=NO. gold.py not edited. No Pack24. No mailbox. Board unplugged.

OBSERVATION:
FACT: A2B query hit=1 nb=`00020100` dest_rd=5 t1_valid=1 pub=`0000010` gen=`000000b1`.
FACT: After A2C COMMIT, no host flush: t1_valid=0 pub=`0100010` gen=`000000c1`.
FACT: SLOT0 dest[5] leftover dst still `00020100`; SLOT1 dest[1029] dst `00030100`.
FACT: Query after C hit=1 nb=`00030100` dest_rd=5 t1_valid=1.
FACT: First FAIL: same hits and dest_rd, but t1_valid stayed 0 because `pack_loader` `load_ack` is sticky HIGH until next OP_BEGIN.
FACT: Host did not write T1. Old `tb_rkb05_stale_t1.sv` plant path not run.
FACT: Walk still dest-reads after T1 fill (T1 is occupancy/invalidate, not answer bypass).

HYPOTHESES:
H1: Stale T1/SLOT0 B would answer after COMMIT C. REJECTED — leftover dest[5] is B, query is C dest_rd=5.
H2: A2C GOLD using SLOT0 pointers 48/80 would follow leftover B. REJECTED — A2C mem uses SLOT1-absolute post/edge.
H3: Level-sensitive `if (load_ack) t1_v<=0` pins T1 invalid after first COMMIT. CONFIRMED on first FAIL; repaired with rising-edge detect.
H4: Host hierarchical poke of t1_* is a legal RKB-05. REJECTED by owner lock host-must-not-write-T1.

HOW_TRACE:
Pack RKB04-A2B-EDGE SLOT0 → dest-walk dir→post→edge B, fill T1.
Pack RKB05-A2C-EDGE SLOT1 (slot+48 / slot+80) → COMMIT rising edge clears T1.
Query SID A without t1_flush → dest-walk published_root `0100010` → neighbor C.
SLOT0 edge beat remains B (falsifier that leftover media did not win).

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| RKB-05 generation switch dest-walk | PASS_XSIM | RKB05_OBS RKB05_XSIM=1 7015 ns |
| leftover SLOT0 still B | FACT | leftover_slot0_edge_dst 00020100 |
| T1 cleared on COMMIT, refilled on walk | PASS_XSIM | t1 1→0→1 |
| T1 not answer bypass | FACT | dest_rd=5 after C |
| UART RKB-05 | NOT_RUN | board unplugged |
| 8/8 | NOT_RUN | no stamp |
| PACK_ABI_24_24_PASS | NO | owner KEEP |

SUCCESS_VS_FAILURE:
Success: C after COMMIT C without host T1 write; leftover B still in SLOT0; dest_rd>=4; T1 occupancy 1 then 0 then 1.
Failure (first run): C was already returned but t1_valid never occupied because sticky load_ack cleared T1 every cycle.

FIRST_DIVERGENCE:
`pack_loader` S_COMMIT sets `load_ack<=1` and only clears it on next OP_BEGIN. Level-high T1 invalidate cannot refill.

DECISIVE_TEST:
`run_rkb05_xsim.bat`. AND: A2B B dest_rd>=4 t1=1; after C t1=0 leftover dest[5]=B dest[1029]=C; query C dest_rd>=4 t1=1; no T1 poke.

ROOT_CAUSE_OR_UNKNOWN:
RKB-05 product behavior (C not B) was already true while T1 occupancy was pinned 0. Occupancy proof required COMMIT-edge invalidate, not load_ack level. CT1 `T1_OCCUPANCY=NOT_PROVEN` shares this sticky-ack mechanism (INFERENCE for CT1 bit; FACT on this XSim DUT). Board T1 UNKNOWN.

REUSABLE_DECISION_PROCEDURE:
1. Host must not write T1. Warm T1 only by dest-walk.
2. Treat pack_loader load_ack as sticky until BEGIN; invalidate T1 on rising edge.
3. Second GOLD must use the committed slot's absolute posting/edge pointers.
4. Keep leftover prior-slot media as a falsifier; require dest_rd after COMMIT.

STRUCTURAL_GUARD:
TB ANDs t1_b=1, t1_after_c=0, leftover SLOT0 B, SLOT1 C, query C dest_rd>=4, host_write_T1=NO.
Do not stamp RUNTIME_KNOWLEDGE_BINDING_8_8_PASS.

BLAST_RADIUS:
D-owned rkb_readback DUT/TB. dest_root_cache T1 clear is now rising-edge (publish-on-level-high unchanged). pack_loader / C RTL / gold.py / FE256 / bitstream untouched.

VERDICT_BY_LAYER:
PASS_XSIM isolated pack_edge_dut + mig_ui_bram. NOT_RUN UART / RKB-06 / 8/8.
NO PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS / CT1_BOARD_PASS.

LESSON_TO_SHARE: RKB05-LOAD-ACK-STICKY-NOT-T1-LEVEL-CLEAR-20260921T054013Z

NEXT_DECISIVE_EXPERIMENT:
RKB-06 cache parity: flush/rebuild T1 vs dest-walk same C. PROGRAM=NO. Board stays unplugged.

OWNER_AND_STOP_CONDITION:
Owner unplugged board. No mailbox. D does not UART/program. Do not self-stamp 8/8.
