NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: 20260921T040400Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Owner asked D to ignore GitHub and pursue GOAL = RUNTIME_KNOWLEDGE_BINDING after CT1. RKB-01/03/07 UART CANDIDATE on 8bfd993d. RKB-03 no-CLEAR TAP b1→c1. 8/8 PASS not stamped.
RUN_PROVENANCE: No reprogram. Live PROGRAM.txt SHA 8bfd993d. Scripts ct1_rkb_dump.py + ct1_rkb_no_clear.py COM12. XSim CT1_INT_OBS a3261393 dest_rd/nb. FE256/C/gold not edited.

OBSERVATION:
FACT — leave query after prior smoke still 03010051 then DUMP TAP after=000000c1.
FACT — CLEAR ACK then query 03000051 (RKB-07).
FACT — Pack A2B GOLD + query 03010051 + DUMP after=000000b1 before=ffffffff flip=1.
FACT — Pack A2C after CLEAR GOLD + query 03010051 + DUMP after=000000c1.
FACT — No-CLEAR hop: UNSET miss; A2B GOLD+hit; A2C GOLD+hit NAK none; TAP before=000000b1 after=000000c1 flip=1 commit_event=1.
FACT — UART token remains 03010051 for both B and C (hit bit only).
FACT — Integrated XSim dest nb B=00020100 C=00030100 dest_rd=1.
INFERENCE — Silicon query follows committed generation; dest neighbor is proven in XSim not UART.
UNKNOWN — dest bytes on DDR after no-CLEAR A2C (no dest-word UART).
UNKNOWN — T1 occupancy.

HYPOTHESES:
H1: dest_root_cache publishes new wr_beat on second COMMIT without CLEAR (leading; TAP b1→c1 + XSim dest C).
H2: second GOLD is ACK without dest write (CONTRADICTED by TAP after=c1 matching XSim gen c1; dest dump still UNKNOWN).

HOW_TRACE: GOAL RKB → TAP after GOLD → CLEAR miss → A2B/A2C gens → no-CLEAR mutation TAP b1→c1.

EVIDENCE_MATRIX:
- UART_CT1_RKB_TAP.json 3e7abe6d…
- UART_CT1_RKB_NO_CLEAR.json 43ce2b97…
- D_RKB.json c0f7e919…
- CT1_INT_OBS.json a3261393…

SUCCESS_VS_FAILURE: Success = classify 8 cases without 8/8 stamp; UART 01/03/07 CANDIDATE; TAP proves gen switch. Failure would be stamping RKB 8/8 or claiming UART carries B vs C.

FIRST_DIVERGENCE: UART hit bit does not distinguish B vs C; TAP generation_after does.

DECISIVE_TEST: Same SID_A; Pack A2B then A2C no CLEAR; TAP before/after.

ROOT_CAUSE_OR_UNKNOWN: Old RKB-08 CLASS A remains historical on 8fc14f25. CT1 dest path is CANDIDATE. Relocation/edge/cache still UNKNOWN.

REUSABLE_DECISION_PROCEDURE: DUMP after query not before (freeze). CLEAR vs no-CLEAR are different RKB claims. Do not encode UART 03010051 as neighbor identity.

STRUCTURAL_GUARD: D_RKB.json uart_neighbor_payload=NOT_ON_WIRE; 8/8=NOT_RUN.

BLAST_RADIUS: UART hops on live CT1 SRAM. No new bit. No GitHub from D.

VERDICT_BY_LAYER:
PASS_XSIM — RKB-01/03/07 dest_rd/nb (prior CT1-02/03/04)
UART_BOARD_SMOKE_CANDIDATE — hit/miss + TAP gens
NOT_RUN — RKB-02/04/05/06; dest dump; 8/8 PASS
NO — PROGRAM_PASS / CT1_BOARD_PASS / PACK_ABI_24_24_PASS / RUNTIME_KNOWLEDGE_BINDING_8_8_PASS

LESSON_TO_SHARE: UART-HIT-BIT-IS-NOT-NEIGHBOR-20260921T040400Z

NEXT_DECISIVE_EXPERIMENT: RKB-02 relocation XSim (second dest root + poison P1). Then RKB-04 edge fail-closed.

OWNER_AND_STOP_CONDITION: AGENT_D. Stop: no 8/8 stamp; no new bit without quoted SHA; no GitHub from this agent.

HANDOFF_STATUS: COMPLETE
