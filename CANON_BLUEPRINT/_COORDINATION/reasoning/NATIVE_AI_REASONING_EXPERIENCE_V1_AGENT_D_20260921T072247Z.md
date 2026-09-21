# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: D-RKB-DIR-POST-EDGE-OWNER-PROGRAM
RUN_ID: 20260921T072247Z
OWNER_AGENT: AGENT_D
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES
MAILBOX: NOT_SENT (owner relays)
PROGRAM: OWNER_YES_THIS_TURN_UNIQUE_DAACA9C1
PROGRAM_PASS: NO

CURRENT_CLAIM:
Owner chat “Ok program đi” after the unique SHA was presented is treated as
PROGRAM=YES for `daaca9c1769d097cab03ccc7168aefd46cc91689b123618425531f4455fc9381`
only. JTAG 210319BE776EA End of startup HIGH. UART COM12 smoke
UNSET miss / A2B GOLD+hit / A2C GOLD+hit / FLSH still hit / CLEAR miss is
`UART_BOARD_SMOKE_CANDIDATE`. Query token is hit-bit, not neighbor. Not 8/8.
Not PROGRAM_PASS / BOARD_PASS / TIMING_PASS / MIG_PASS / PACK_ABI_24_24_PASS.
CT1 file `8bfd993d…` remains on disk and was not the programmed file.

RUN_PROVENANCE:
- Tcl `97_program_uart_r2_rkb_edge.tcl` with OWNER_AUTHORIZED
- SHA gate matched live file to `daaca9c1…`; banned `8bfd993d` / `8fc14f25`
- Target localhost:3121/xilinx_tcf/Digilent/210319BE776EA
- Labtools 27-3164 End of startup HIGH 2026-09-21 14:21:51 +07
- PROGRAM.txt sha256 `743dfaefbf93346b014274d69db4865dbfb248252d43e20d53913d2ca6922608`
- UART json sha256 `b7e4aab5f7c5a8fc97f60cc12f22cbeb36e009eea5bf91a6e191294e087d793a`
- Port COM12 FTDI 210319BE776EB 115200
- CLEAR ACK `c1ea50a5`
- gold.py not edited. No Pack24. No mailbox. No 8/8 stamp.

OBSERVATION:
FACT: Programmed unique `build_rkb_edge` bit, not `build_ct1`.
FACT: EOS HIGH. IR.STATUS/PROGRAM.DONE properties returned NA; EOS is the program evidence.
FACT: RKB-UNSET tok `03000051`. RKB-01 GOLD `010000a5` then `03010051`.
FACT: RKB-03 GOLD `010000a5` then `03010051`. RKB-06 FLSH n=0 then `03010051`.
FACT: RKB-07 CLEAR ACK then `03000051`.
FACT: UART token is `03|hit|00|51`. Neighbor bytes are not on the wire.
FACT: Disk CT1 bit hash still `8bfd993d…`.
INFERENCE: RKB-03 hit after A2C GOLD does not prove neighbor C versus leftover B.
INFERENCE: RKB-06 hit after FLSH does not prove T1 occupancy.
UNKNOWN: dest_rd, EdgeRecord.dst_id, leftover SLOT1 B on silicon.

HYPOTHESES:
H1: Owner meant reprogram CT1 `8bfd993d`. REJECTED — pending SHA was unique `daaca9c1`; tcl bans CT1 hash.
H2: Hit token after A2C proves C. REJECTED — same token as after A2B; neighbor not on UART.
H3: Smoke 5/5 is RUNTIME_KNOWLEDGE_BINDING_8_8_PASS. REJECTED — RKB-02/04/05/08 need dest poison/readback.

HOW_TRACE:
Owner YES → unique program tcl SHA gate → JTAG 776EA EOS HIGH → 12s COM-closed settle → UART UNSET/pack/query/FLSH/CLEAR.

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| Unique bit programmed | FACT | program.log EOS HIGH; PROGRAM.txt daaca9c1 |
| CT1 file not overwritten | FACT | build_ct1 bit still 8bfd993d |
| UART hit/miss/GOLD/CLEAR | UART_BOARD_SMOKE_CANDIDATE | UART_RKB_EDGE_BOARD.json b7e4aab5 |
| Neighbor C | UNKNOWN | token 03010051 only |
| 8/8 | NOT_RUN | ceiling file |
| PROGRAM_PASS | NO | PROGRAM.txt |

SUCCESS_VS_FAILURE:
Success: unique SHA on JTAG, EOS HIGH, UART smoke tokens as specified, no global PASS stamps.
Failure would be programming 8bfd993d, mute n=0, NAK instead of GOLD, or stamping 8/8 from hit-bit.

FIRST_DIVERGENCE:
XSim RKB-03 reads dest EdgeRecord.dst_id. Silicon UART returns only hit/miss.

DECISIVE_TEST:
Independent sha256 of programmed file; EOS HIGH; COM12 tokens UNSET miss, GOLD, hit, CLEAR miss.

ROOT_CAUSE_OR_UNKNOWN:
Silicon Directory→Posting→EdgeRecord neighbor remains UNKNOWN on UART. Walk vs leftover B after A2C is not distinguished.

REUSABLE_DECISION_PROCEDURE:
1. Program only the quoted unique SHA; ban prior identities in tcl.
2. Treat informal “program” after that SHA was on screen as THIS SHA, not CT1.
3. Settle COM closed after JTAG.
4. Do not decode 03010051 as neighbor C.
5. Do not stamp 8/8 without dest poison/readback.

STRUCTURAL_GUARD:
97_program refuses non-daaca9c1 and CT1 path. Smoke refuses PROGRAM.txt SHA mismatch. Ceiling file UART_NEIGHBOR=NOT_ON_WIRE.

BLAST_RADIUS:
results/RKB_EDGE_OWNER_PROGRAM_20260921 and unique rkb_edge host/tcl. Isolated rkb_readback, freeze DCPs, gold.py, C RTL untouched. SRAM now holds daaca9c1 not 8bfd993d.

VERDICT_BY_LAYER:
- PASS_IMPLEMENTED: unique bit still daaca9c1
- PROGRAMMED_EOS_HIGH: FACT, PROGRAM_PASS=NO
- UART_BOARD_SMOKE_CANDIDATE: UNSET/01/03/06/07 token checks
- PASS_BOARD / 8/8: NO / NOT_RUN
- PACK_ABI_24_24_PASS: NO

LESSON_TO_SHARE:
Owner program-after-SHA-on-screen is THIS unique identity. UART 03010051 is not EdgeRecord.dst_id.

NEXT_DECISIVE_EXPERIMENT:
Dest/TAP export if owner wants RKB-02/04/05/08 on silicon. Do not Pack24.

OWNER_AND_STOP_CONDITION:
Stop after smoke. Do not stamp 8/8 / PROGRAM_PASS / BOARD_PASS.

HANDOFF_STATUS: COMPLETE
