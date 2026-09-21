# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: D-RKB06-CACHE-PARITY
RUN_ID: 20260921T055337Z
OWNER_AGENT: AGENT_D
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES
MAILBOX: NOT_SENT (owner relays)
PROGRAM: NO

CURRENT_CLAIM:
RKB-06 dest-backed walk: after G2 A→C, warm query returns C; flush T1 only
(no dest write, no COMMIT, no generation change); same SID still returns C.
Isolated DUT PASS_XSIM SEMANTIC_PARITY_ONLY. Warm and post-flush both dest_rd=5.
Not cache acceleration. Not 8/8. Not board.

RUN_PROVENANCE:
- Command: `D:\FPGA\arty_d\rkb_readback\run_rkb06_xsim.bat` exit 0
- `$finish` 7075 ns `RKB-06 PASS_XSIM SEMANTIC_PARITY_ONLY`
- RKB06_OBS.json sha256 `329f77f753672e7d3949d53380315dfea0f334c58bbcf2d6dff3edcb0bf0b454`
- rkb06_xsim.log sha256 `e8093eef378028aa71c3109f0b9a5a148e1017736e37a156ebaa016d1ca66f07`
- dest_posting_edge_walk.sv sha256 `322e476d7f947e72f1091101c4aa54ec1f9578818f91782445dd895188045d27`
- pack_edge_dut.sv sha256 `bad9c50016d22ae5a9b0537fbf4deedc1f10623aba518fd536b440db3ebec5d9`
- tb_rkb06_parity.sv sha256 `37f378c9ab59b80ae7d8daca4f3caa26f9e7ca4628086d152590c1b0099c0136`
- PROGRAM=NO. gold.py not edited. No Pack24. No mailbox. Board unplugged.

OBSERVATION:
FACT: Warm query hit=1 nb=`00030100` dest_rd=5 t1=1 gen=`000000c1` pub=`0100010` posting_ref=`0100030` edge_ref=`0100050`.
FACT: After t1_flush pulse: t1=0, gen still `000000c1`, pub still `0100010`.
FACT: Post-flush query hit=1 nb=`00030100` dest_rd=5 t1=1 same gen/pub/post/edge.
FACT: SLOT1 dest beats 1025..1030 unchanged (dest_unchanged=1).
FACT: Host did not poke t1_sid/t1_nb/t1_v. Flush is a dedicated port.
FACT: No dir_a.mem / post_a.mem on this DUT.

HYPOTHESES:
H1: Flush also changes T2 or generation. REJECTED — dest_unchanged=1 gen sticky C1.
H2: Warm T1 is an answer bypass (dest_rd=0). REJECTED — dest_rd=5 both queries.
H3: Post-flush C comes from a static fixture. REJECTED — dest-walk posting+edge refs SLOT1.
H4: TB repaired T1 after flush. REJECTED — only t1_flush then dest-walk refill.

HOW_TRACE:
Pack A2B SLOT0 then A2C SLOT1 → query SID A (warm T1 from dest-walk) → pulse t1_flush
→ t1_valid=0, dest snapshot held → query SID A again → dest-walk refill T1, neighbor C.

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| RKB-06 semantic cache parity | PASS_XSIM | RKB06_OBS RKB06_XSIM=1 7075 ns |
| cache acceleration | NO | dest_rd=5 warm and post |
| dest/gen unchanged across flush | FACT | dest_unchanged=1 gen=c1 |
| UART RKB-06 | NOT_RUN | board unplugged |
| 8/8 | NOT_RUN | no stamp |
| PACK_ABI_24_24_PASS | NO | owner KEEP |

SUCCESS_VS_FAILURE:
Success: C before and after T1-only flush; dest and generation unchanged; dest_rd>=4 both times; host_write_T1=NO.
Failure would be miss after flush, C from T1 poke, dest mutation, generation change, or dest_rd=0 claimed as acceleration.

FIRST_DIVERGENCE:
None this run. Prior RKB-05 sticky load_ack already repaired; this flush is a separate port.

DECISIVE_TEST:
`run_rkb06_xsim.bat`. AND: warm C dest_rd>=4 t1=1; flush t1=0 gen/pub held; post C dest_rd>=4 dest_same=1.

ROOT_CAUSE_OR_UNKNOWN:
T1 occupancy is dest-filled and flushable. Answer remains dest Directory→Posting→EdgeRecord.
CACHE_KIND=SEMANTIC_PARITY_ONLY because the warm path still dest-reads.
Board flush UNKNOWN. CT1-05 flush remains tied off on silicon.

REUSABLE_DECISION_PROCEDURE:
1. Flush T1 through a dedicated port. Do not poke t1_* and do not rst/COMMIT.
2. Snapshot dest beats and active_generation before flush; AND equality after.
3. If dest_rd stays high after warm T1, label SEMANTIC_PARITY_ONLY. Do not claim acceleration.
4. Do not stamp 8/8 from isolated DUT cache parity.

STRUCTURAL_GUARD:
TB ANDs warm C, flush t1=0, post C, gen=c1 thrice, dest_unchanged, dest_rd>=4 both, host_write_T1=NO.
JSON CACHE_ACCELERATION=NO.

BLAST_RADIUS:
D-owned rkb_readback: t1_flush on dest_posting_edge_walk + pack_edge_dut. tb_rkb04/05 tie flush=0.
pack_loader / C RTL / gold.py / FE256 / bitstream untouched.

VERDICT_BY_LAYER:
PASS_XSIM isolated pack_edge_dut SEMANTIC_PARITY_ONLY. NOT_RUN UART / RKB-08 closure / 8/8.
NO PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS / CT1_BOARD_PASS / TIMING_PASS / MIG_PASS.

LESSON_TO_SHARE: RKB06-T1-FLUSH-NOT-DEST-AND-NOT-ACCEL-20260921T055337Z

NEXT_DECISIVE_EXPERIMENT:
RKB-08 current-architecture fixture-independence closure. PROGRAM=NO. Board stays unplugged.
Do not start it in this run.

OWNER_AND_STOP_CONDITION:
Owner unplugged board. No mailbox. D does not UART/program. Stop after RKB-06 evidence.
Do not self-stamp 8/8.
