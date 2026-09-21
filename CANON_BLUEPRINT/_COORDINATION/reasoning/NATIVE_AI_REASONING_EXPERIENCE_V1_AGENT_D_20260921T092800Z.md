NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-RKB-DEST-TAP-BOARD-RKB05-RKB06
RUN_ID: 20260921T092800Z
OWNER_AGENT: AGENT_D
LANGUAGE: EN
CURRENT_CLAIM: FACT on identity ead830ae… UART RKB-05 is STALE_KNOWLEDGE_EXCLUSION and RKB-06 is SEMANTIC_PARITY_ONLY. T1 live drop is NOT_PROVEN. RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN. PROGRAM_PASS=NO. BOARD_PASS=NO.

RUN_PROVENANCE:
- Owner continue after dest causal close. No red RESET. No reprogram.
- First RKB-05 FAIL: pack SLOT1-B then SLOT0-C. pack_loader slot_bit toggles at COMMIT so leftover DEST_READ 0x100050 saw C.
- Retry: CLEAR, pack B SLOT0, pack C SLOT1 mem (pointers match slot_base), no FLSH, no DEST_POKE.

OBSERVATION:
- FACT: leftover SLOT0 e0=0000050 dst=00020100 identical before/after C pack
- FACT: after C, WALK_TAP gen=000000c1 root=0100010 e0=0100050 nb=00030100 delta=5 HIT
- FACT: WALK_TAP after COMMIT before query still last B snapshot
- FACT: RKB-06 warm C, FLSH n=0, T2 edge unchanged, gen/root held, query HIT C dest_rd 77->82 delta=5
- FACT: WALK_TAP t1 after FLSH still 1
- INFERENCE: post-FLSH dest_rd +5 means answer path walked dest, not T1 shortcut
- UNKNOWN: live t1_valid around COMMIT/FLSH (not exported)

HYPOTHESES:
- H1: leftover physical B does not answer after C publish. CONFIRMED PASS_BOARD_UART
- H2: FLSH drops t1_valid observably on this UART TAP. REJECTED_ON_THIS_BIT snapshot stays 1
- H3: pack_loader slot_bit must match graph pointers. CONFIRMED by first FAIL then retry

HOW_TRACE:
CLEAR slot_bit=0. Pack B writes SLOT0. COMMIT slot_bit=1. Pack C SLOT1 mem writes 0x0100000+ddr. Directory/Posting/Edge of B remain at 0x50. Query uses published_root 0x0100010.

EVIDENCE_MATRIX:
- FACT: UART_RKB_DEST_TAP_RKB05_RKB06_BOARD.json sha256 f1615793e38d690a915341f6b71b25bfbf272157e5b8a7bfd16d0d0c965c63a6
- FACT: RKB05-A2C-SLOT1.mem sha256 b569333ad5bdf369fae653b94a2303d9adaccd11f74520182f84013221d35348
- FACT: bit ead830ae UNCHANGED; daaca9c1/8bfd993d UNTOUCHED
- FACT: CLOSURE_AUDIT_8_8 does not stamp 8/8

SUCCESS_VS_FAILURE:
- SUCCESS: leftover B physical + active C WALK_TAP; FLSH semantic C held
- FAILURE: first RKB-05 leftover check used the wrong physical address

FIRST_DIVERGENCE:
First attempt leftover DEST_READ used walk e0 from B-on-SLOT1 (0x100050) after C pack had written that slot.

DECISIVE_TEST:
B SLOT0 then C SLOT1. DEST_READ 0x50 still B. Query C. WALK_TAP e0=0100050 nb=C.

ROOT_CAUSE_OR_UNKNOWN:
RKB-05 silicon stale-knowledge exclusion is confirmed. T1 cache lifecycle remains unexported.

REUSABLE_DECISION_PROCEDURE:
After CLEAR, pack N lands on slot_bit. Graph pointers must match physical slot_base. Leftover DEST_READ the previous e0, not the new walk e0. Do not stamp 8/8 from class-limited 05/06.

STRUCTURAL_GUARD:
- RKB05-A2C-SLOT1.mem for second pack after CLEAR
- T1_LIVE_STATE_EXPORT=NO claim ceiling
- CLOSURE_AUDIT_8_8 inventory not PASS

BLAST_RADIUS:
dest TAP host sequence and one new pack mem. Not gold.py. Not C RTL. Not FE256 freeze. Not dest poison.

VERDICT_BY_LAYER:
- PASS_BOARD_UART RKB-05 STALE_KNOWLEDGE_EXCLUSION
- PASS_BOARD_UART RKB-06 SEMANTIC_PARITY_ONLY
- T1_DROP_PROVEN=NO CACHE_LIFECYCLE_COMPLETE=NO
- RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN PROGRAM_PASS=NO BOARD_PASS=NO

LESSON_TO_SHARE: RKB05-SLOT-BIT-MATCH-POINTERS-20260921T092800Z
NEXT_DECISIVE_EXPERIMENT: FEM persist / developmental memory. Do not dest-poison unless new contradiction. Do not stamp 8/8.
OWNER_AND_STOP_CONDITION: Anh. Stop 8/8 self-stamp. Stop Pack24/FE256. Stop red RESET unless UART dead.
HANDOFF_STATUS: COMPLETE
