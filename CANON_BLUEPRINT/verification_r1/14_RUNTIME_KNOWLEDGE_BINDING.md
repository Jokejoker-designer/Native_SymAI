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
| RKB-02 Relocation | PASS_XSIM 2775 ns dest[1024] SoT; dest_rd after poison dest[0] `app_addr=0100000` `widx=1024`; SAMPLE `pub=0` is `load_ack` NBA race | NOT_RUN | NO |
| RKB-03 A→C | PASS_XSIM dest_rd=1 nb=`00030100` gen=`c1` | CANDIDATE no-CLEAR A2B→A2C TAP `b1→c1` | NO |
| RKB-04 Edge | PASS_XSIM 3895 ns dest-backed EdgeRecord; poison dest[5..6] miss; posting neighbor still B | NOT_RUN board unplugged | NO |
| RKB-05 stale T1 | PASS_XSIM 7015 ns dest-walk B then C; t1 1→0→1; leftover SLOT0 B; host did not write T1 | NOT_RUN board unplugged | NO |
| RKB-06 cache parity | PASS_XSIM 7075 ns SEMANTIC_PARITY_ONLY; warm C dest_rd=5; flush t1=0 gen/dest held; post C dest_rd=5; CACHE_ACCELERATION=NO | NOT_RUN board unplugged | NO |
| RKB-07 removal | PASS_XSIM rst UNSET | CANDIDATE CLEAR then miss | NO |
| RKB-08 fixture | Historical `8fc14f25` CLASS A UNCHANGED. Current `pack_edge_dut` PASS_XSIM 7375 ns 08A C+DEADBEEF dest_rd=5; 08B dest-edge poison miss dest_rd=4 fixture C; 08C restore C; 08D no `$readmemh` dir_a/post_a | NOT_RUN board unplugged | NO |

Evidence: `D:/FPGA/arty_d/UART_R2/results/CT1_OWNER_PROGRAM_20260921/D_RKB.json`.

**NEXT:** RKB-08 current-arch closed on isolated `pack_edge_dut` (`65fb25ba…`). Do **not** stamp `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`. Historical CLASS A kept. Mailbox not sent. Board unplugged. PROGRAM=NO. Do not more Pack24. Do not modify FE256 / gold.py / C RTL.
