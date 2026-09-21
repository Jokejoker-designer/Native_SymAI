# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: GITHUB-AUDIT-RKB04-08-EDGE-DUT
RUN_ID: 20260921T062700Z
OWNER_AGENT: CURSOR_OWNER
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES

CURRENT_CLAIM:
Publish D isolated pack_edge_dut RKB-04/05/06/08 PASS_XSIM. Do not stamp 8/8. CT1 SRAM still 8bfd993d. Board unplugged. PACK_ABI=NO.

RUN_PROVENANCE:
- Parent jsonl 6230899 bytes mtime 2026-09-21T06:11:48Z (was 5943269)
- Watch hashed live files 2026-09-21T13:27+07
- RKB04_OBS `916a9d90…` log `6ee9e680…` $finish 3895 ns
- RKB05_OBS `cdd8dc7e…` PASS log `383fd72d…` FAIL keep `e21aacdb…`
- RKB06_OBS `329f77f7…` log `e8093eef…` $finish 7075 ns
- RKB08_ARCH_OBS `65fb25ba…` SRC `170260ec…` log `373745b2…` $finish 7375 ns
- CLASS A keep `18456f16…`
- PROGRAM.txt `e920490d…` SRAM `8bfd993d…`
- Watch did not xelab or program

OBSERVATION:
FACT: Logs contain the PASS_XSIM lines and $finish times D claimed.
FACT: OBS JSON fields match those V1 claims (RKB-04 edge poison miss, RKB-05 leftover B then C, RKB-06 dest_rd=5 both, RKB-08 A/B/C).
FACT: Historical RKB08_OBS.json is still CLASS A dest_rd=0.
FACT: Live tb_rkb05_edge.sv sha256 `b3cd1b80…` does not match D V1 `0d208803…`. PASS OBS/log hashes do match.
FACT: Live dest_posting_edge_walk.sv is RKB-06 SHA `322e476d…`, not RKB-04 V1 `3556f812…`.
INFERENCE: Walk/TB files moved after earlier runs; do not treat live RTL as every run snapshot.

HYPOTHESES:
H-8/8: isolated 04-08 plus CT1 UART 01/03/07 would be 8/8. REJECTED — mixed DUT/identity, UART 02/04/05/06/08 NOT_RUN, CLASS A unchanged, D stop says no stamp.

HOW_TRACE:
Owner said continue. Watch hashed parent COMPLETE V1s 051355/054013/055337/060110 and published without implementing RKB-04 or programming.

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| RKB-04 edge deref | PASS_XSIM | OBS 916a9d90 log 6ee9e680 |
| RKB-05 stale T1 | PASS_XSIM | OBS cdd8dc7e; FAIL log kept |
| RKB-06 cache parity | PASS_XSIM SEMANTIC_PARITY_ONLY | OBS 329f77f7 |
| RKB-08 current arch | PASS_XSIM | ARCH 65fb25ba; CLASS A 18456f16 keep |
| 8/8 | NOT_RUN | mixed DUT / UART gaps |
| PACK_ABI_24_24_PASS | NO | owner KEEP |

SUCCESS_VS_FAILURE:
Success: GitHub records isolated edge-DUT results without 8/8 and without overlaying CLASS A. Failure would be stamping 8/8 or replacing 18456f16 with ARCH OBS.

FIRST_DIVERGENCE:
CT1 SID→fwd vs pack_edge_dut Directory→Posting→EdgeRecord.

DECISIVE_TEST:
Already run by D. Watch verified hashes + log grep, did not re-xelab.

ROOT_CAUSE_OR_UNKNOWN:
This DUT neighbor is dest EdgeRecord.dst_id. CT1 programmed bit is not this walk. UART/board UNKNOWN (unplugged).

REUSABLE_DECISION_PROCEDURE:
1. Keep FAIL logs unique.
2. Keep CLASS A OBS unique from ARCH OBS.
3. Hash live TB/walk separately from per-run V1 SHAs.
4. Do not stamp 8/8 across mixed identities.

STRUCTURAL_GUARD:
Do not overwrite RKB08_OBS.json. Do not rewrite shared-lessons history. Do not program. Do not stamp PACK_ABI / PROGRAM_PASS / 8/8.

BLAST_RADIUS:
Native_SymAI docs + evidence copies. C RTL / gold.py / FE256 freeze / bitstream untouched.

VERDICT_BY_LAYER:
PASS_XSIM isolated pack_edge_dut (D). Watch publish only. NOT_RUN UART dest / 8/8 / CT1_BOARD_PASS. NO PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS.

LESSON_TO_SHARE: NONE (D already wrote the four case lessons; watch only publishes)

NEXT_DECISIVE_EXPERIMENT:
Owner decides whether to bind this walk into a new identity. Watch does not implement. PROGRAM=NO.

OWNER_AND_STOP_CONDITION:
Board unplugged. Watch stop after publish. No 8/8 self-stamp.
