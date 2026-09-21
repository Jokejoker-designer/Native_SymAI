# RUNTIME_KNOWLEDGE_BINDING_8_8 — workstream

Not `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`. Not FE256_PASS. Not `CT1_BOARD_PASS`.

## Historical (query identity `8fc14f25`)

XSim 20260921T022800Z: **RKB-08 = FAIL_CURRENT_ARCHITECTURE** CLASS A.  
**ROOT_CAUSE** `DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT` = **CAUSALLY CONFIRMED IN XSIM**.

JSON sha256 `18456f1649cabb98f13be02a89e5d8264c09051035a3c515a310cd16fa852c8e`.

## CT1 identity `8bfd993d` (2026-09-21)

T2/dest = SoT. T1 = cache only; host must not write T1. UART query is **hit-bit only** (`03010051`); neighbor B vs C is XSim `dest_rd`/`nb`, not on the wire.

| Case | XSim | UART silicon | Stamp |
|---|---|---|---|
| RKB-01 Install | PASS_XSIM dest_rd=1 nb=`00020100` gen=`b1` | CANDIDATE GOLD+hit TAP after=`000000b1` | NO |
| RKB-02 Relocation | PASS_XSIM 2775 ns dest[1024] SoT (poison dest[0] hit; poison dest[1024] miss) | NOT_RUN | NO |
| RKB-03 A→C | PASS_XSIM dest_rd=1 nb=`00030100` gen=`c1` | CANDIDATE no-CLEAR A2B→A2C TAP `b1→c1` | NO |
| RKB-04 Edge | NOT_RUN BLOCKED_UNTIL_EDGE_MEDIA (no EdgeRecord on CT1 SID→fwd path) | NOT_RUN | NO |
| RKB-05 stale T1 | NOT_RUN (`t1_valid=0`) | NOT_RUN | NO |
| RKB-06 cache parity | NOT_RUN | CT1-05 flush tied off | NO |
| RKB-07 removal | PASS_XSIM rst UNSET | CANDIDATE CLEAR then miss | NO |
| RKB-08 fixture | dir_a.mem **not** on CT1 path | not a poison replay | NO inherit PASS |

Evidence: `D:/FPGA/arty_d/UART_R2/results/CT1_OWNER_PROGRAM_20260921/D_RKB.json`.

**NEXT:** RKB-04 is BLOCKED_UNTIL_EDGE_MEDIA. Do not fake an EdgeRecord TB. Do not more Pack24. dest UART export needs owner YES new SHA. Do not modify FE256 / gold.py / C RTL.
