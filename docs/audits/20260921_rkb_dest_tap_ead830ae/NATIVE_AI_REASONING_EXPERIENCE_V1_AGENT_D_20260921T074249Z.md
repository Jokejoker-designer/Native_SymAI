# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: D-RKB-EDGE-SILICON-TAP-DEST
RUN_ID: 20260921T074249Z
OWNER_AGENT: AGENT_D
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES
MAILBOX: NOT_SENT
PROGRAM_PASS: NO

CURRENT_CLAIM:
On programmed unique `daaca9c1…`, TAP dumps pack generation, not dest words.
TAP after A2B is gen `000000b1`; TAP after first-pack A2C post-CLEAR is `000000c1`;
B != C. RKB-02 relocate UART (SLOT0 then SLOT1 A2B) GOLD+hit both. End-of-chain
TAP `b2→c1` after A2C. Query remains hit-bit. RKB-02 dest poison, RKB-04, and
RKB-08 dest poison are BLOCKED_UNTIL_DEST_POKE on this bit. Not 8/8.

RUN_PROVENANCE:
- Command: `python D:\FPGA\arty_d\UART_R2\rkb_edge\rkb_edge_tap_dest.py` exit 0
- SHA programmed: `daaca9c1769d097cab03ccc7168aefd46cc91689b123618425531f4455fc9381`
- UART_RKB_EDGE_TAP_DEST.json sha256 `56f61d650da0434482c1d92c2363437105ee7f3b4219e119131776a7e8a6c953`
- COM12 115200 FTDI 210319BE776EB
- DUMP 44554D50 TAP1 31504154 identity U33OBS_GEN four-AND flip=1
- No reprogram. gold.py not edited. No Pack24. No mailbox.

OBSERVATION:
FACT: tapB generation_before=ffffffff after=000000b1 commit_event=1 same_epoch=1 capture_valid=1 flipped=1.
FACT: reloc SLOT0 GOLD+hit, SLOT1 GOLD+hit, A2C GOLD+hit. TAP_END before=000000b2 after=000000c1.
FACT: tapC before=ffffffff after=000000c1.
FACT: TAP hop class CLASS_P1_OTHER p1=3149414e (not dest EdgeRecord).
FACT: Query tokens 03010051 after B and after C. Neighbor not on UART.
FACT: dest_rd_cnt and dest[] are not TAP lanes on this bitstream.
FACT: XSim RKB-02/04/08 poison wrote u_mig.dest hierarchically; that poke is absent here.
INFERENCE: TAP_END b2→c1 is last two pack commits, not leftover dest[1029]=B.
UNKNOWN: silicon EdgeRecord.dst_id, dest_rd count, leftover SLOT1 dest word.

HYPOTHESES:
H1: TAP dump exports dest EdgeRecord. REJECTED — TAP words are SOF + gen_stat + gen before/after.
H2: Hit after A2C is neighbor C. REJECTED — same 03010051 as after B.
H3: Relocate GOLD+hit is RKB-02 full (includes dest poison). REJECTED — poison cells blocked.
H4: A second DUMP without CLEAR captures the next pack. Not tested as primary; DUMP freezes TAP until CLEAR.

HOW_TRACE:
CLEAR → A2B → query → DUMP (gen B) → CLEAR → SLOT0 A2B → SLOT1 A2B → A2C → DUMP (b2→c1) → CLEAR → A2C → DUMP (C).

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| TAP gen B vs C | FACT | tapB 000000b1 tapC 000000c1 TAP_B_NE_TAP_C=1 |
| RKB-02 relocate UART | UART hit/GOLD | RKB02_RELOCATE_UART=1 |
| RKB-02 dest poison | BLOCKED | dest_poke NOT_ON_THIS_BIT |
| RKB-04 / RKB-08 dest poison | BLOCKED | same |
| RKB-08 fixture | N/A | DIR_A_MEM_FILES=0 at synth |
| 8/8 | NOT_RUN | ceiling |
| dest_word_export | NOT_ON_THIS_TAP | pack_obs_dump dump_w[0..8] |

SUCCESS_VS_FAILURE:
Success this run: TAP gens match emit B/C; relocate packs GOLD; blocked cells named.
Failure would be mute DUMP, TAP gen still UNSET, or stamping 8/8 / neighbor C.

FIRST_DIVERGENCE:
XSim RKB-04 zeros dest[5]/[6] then miss dest_rd=4. Silicon TAP cannot write or read those words.

DECISIVE_TEST:
rkb_edge_tap_dest.py TAP_B_IS_GEN_B TAP_C_IS_GEN_C TAP_END_IS_GEN_C RKB02_RELOCATE_UART. Poison fields remain BLOCKED.

ROOT_CAUSE_OR_UNKNOWN:
This observer TAP is pack generation. Dest EdgeRecord SoT tests need dest poke or dest export. Neighbor is computed (q_nb) but UART TX is 03|hit|00|51.

REUSABLE_DECISION_PROCEDURE:
1. DUMP after GOLD to read gen_after. CLEAR rearms TAP and UNSETS gen.
2. Multi-pack relocate cannot DUMP between packs if DUMP freeze requires CLEAR to rearm.
3. Do not call TAP gen C a dest EdgeRecord C.
4. Do not stamp RKB-04/08 from UART hit-bit.
5. Next dest-poison identity needs a dest write or TAP lanes for dest_rd/q_nb, then a new SHA.

STRUCTURAL_GUARD:
JSON fields dest_word_export=NOT_ON_THIS_TAP, RKB04=BLOCKED_UNTIL_DEST_POKE, RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.

BLAST_RADIUS:
Host script + results JSON only. Unique bit unchanged. No C/gold/FE256.

VERDICT_BY_LAYER:
- UART_BOARD_SMOKE_CANDIDATE: prior
- TAP_PACK_GEN: PASS on B vs C four-AND
- PASS_BOARD dest poison: NOT_RUN / BLOCKED
- RUNTIME_KNOWLEDGE_BINDING_8_8_PASS: NOT_RUN
- PROGRAM_PASS / PACK_ABI: NO

LESSON_TO_SHARE:
TAP gen != dest EdgeRecord. DUMP freeze vs relocate: dump at end of chain. Poison RKB-02/04/08 need dest poke.

NEXT_DECISIVE_EXPERIMENT:
If owner wants dest poison on silicon: new unique TAP/export or dest-write path, new SHA, PROGRAM only after quoted YES. Do not Pack24.

OWNER_AND_STOP_CONDITION:
Stop. Do not stamp 8/8. Board still holds daaca9c1 until unplug.

HANDOFF_STATUS: COMPLETE
