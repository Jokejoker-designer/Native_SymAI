# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: D-RKB04-EDGE-DEREF
RUN_ID: 20260921T051355Z
OWNER_AGENT: AGENT_D
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES
MAILBOX: NOT_SENT (owner relays)

CURRENT_CLAIM:
RKB-04 dest-backed dir→posting→EdgeRecord walk FAIL-CLOSES when only the
EdgeRecord dest beats are zeroed. Posting neighbor_id stays B. Isolated DUT
PASS_XSIM. Not 8/8. Not board.

RUN_PROVENANCE:
- Command: `D:\FPGA\arty_d\rkb_readback\run_rkb04_xsim.bat` exit 0
- `$finish` 3895 ns `RKB-04 PASS_XSIM`
- RKB04_OBS.json sha256 `916a9d90d70d11ccda488a5303a94e6fe19357300ef8fd129cc4e0608d8377c5`
- rkb04_xsim.log sha256 `6ee9e680abcc5a3f7b0d3d838068d2e8fdcf12ede8968e8c0795e4decdaeb963`
- dest_posting_edge_walk.sv sha256 `3556f81264fd757c8b96ff83be06770038d6baf6b1bc12b2303f42e1247811b6`
- PROGRAM=NO. gold.py not edited. No Pack24. No mailbox. Board unplugged.

OBSERVATION:
FACT: GOLD dest page first beat at `pub=0000010` holds CRC `320b651f` plus pad; directory is dest[2] SID `00010100` fwd `00000030`.
FACT: Before poison: hit=1 nb=`00020100` dest_rd=5 (dir, post hdr, post ent, edge0, edge1).
FACT: dest[4] posting entry keeps `edge_ref=00000050` and neighbor `00020100` after poison.
FACT: After zero dest[5] and dest[6] only: hit=0 nb=0 dest_rd=4 (miss on edge beat0; no E1).
FACT: `posting_walk` / `$readmemh post_a.mem` not on this DUT.

HYPOTHESES:
H1: Query returns posting.neighbor_id without EdgeRecord. REJECTED — poison edge, posting still B, miss.
H2: GOLD CRC in dest lane0 misaligns 16-byte T2 objects. CONFIRMED then repaired with 12-byte pad + `dir_addr=published_root+16`.
H3: Fixture `post_a.mem` could still supply B. REJECTED — module not instantiated.

HOW_TRACE:
Pack GOLD payload pad+HotDirectoryEntry+PostingPageHeader+PostingEntry+EdgeRecord
at ddr_offset=16 → dest-read SID → fwd 48 → header SID/count → entry edge_ref 80
→ EdgeRecord src/dst → neighbor=dst_id. Zero only dest[5..6]. Same dir/posting. Miss.

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| RKB-04 dest-backed fail closed | PASS_XSIM | RKB04_OBS RKB04_XSIM=1 3895 ns |
| posting neighbor unchanged | FACT | after dest3 still 00020100 |
| edge beats zero | FACT | after dest4 all zero |
| UART RKB-04 | NOT_RUN | board unplugged |
| 8/8 | NOT_RUN | no stamp |
| PACK_ABI_24_24_PASS | NO | owner KEEP |

SUCCESS_VS_FAILURE:
Success: miss after EdgeRecord-only poison with dest_rd still walking to the edge.
Failure would have been hit=B from posting neighbor_id, or $readmemh posting_walk.

FIRST_DIVERGENCE:
Unpadded payload: posting header split across dest beats (CRC steal 4B). After pad, objects are 16-byte aligned.

DECISIVE_TEST:
`run_rkb04_xsim.bat`. Before: hit B dest_rd=5. After edge poison: hit 0, posting dest[4] still B.

ROOT_CAUSE_OR_UNKNOWN:
CT1 SID→fwd path had no EdgeRecord (prior BLOCKED). This DUT adds dest-backed edge deref. GOLD dest CRC in first region beat is a packing fact, not a second SoT.

REUSABLE_DECISION_PROCEDURE:
1. Do not poison posting neighbor_id and call it EdgeRecord.
2. Neighbor = EdgeRecord.dst_id after dest-read of both edge beats.
3. Align T2 objects after GOLD dest CRC (pad to 16B).
4. Directory lookup is `published_root+16` on this GOLD dest page, not the CRC beat.

STRUCTURAL_GUARD:
RKB-04 TB ANDs: dir/posting dest unchanged, edge dest=0, before hit B dest_rd>=4, after miss dest_rd>=3.
Do not stamp RUNTIME_KNOWLEDGE_BINDING_8_8_PASS.

BLAST_RADIUS:
New D-owned files under `arty_d/rkb_readback/` only. dest_root_cache / C RTL / gold.py / FE256 / bitstream untouched.

VERDICT_BY_LAYER:
PASS_XSIM isolated pack_edge_dut + mig_ui_bram. NOT_RUN UART / RKB-05/06 / 8/8.
NO PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS.

LESSON_TO_SHARE: RKB04-EDGE-POISON-NOT-POSTING-NB-20260921T051355Z

NEXT_DECISIVE_EXPERIMENT:
RKB-05 stale T1 on this dest-backed walk. PROGRAM=NO. Board stays unplugged.

OWNER_AND_STOP_CONDITION:
Owner unplugged board. No mailbox. D does not UART/program. Do not self-stamp 8/8.
