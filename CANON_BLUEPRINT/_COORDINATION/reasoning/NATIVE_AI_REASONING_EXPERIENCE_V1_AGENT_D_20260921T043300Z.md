# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: D-PACK-ABI-AUTHORITY-SPLIT-DEST-COMPLETE-RKB02
RUN_ID: 20260921T043300Z
OWNER_AGENT: AGENT_D
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES

CURRENT_CLAIM:
Owner split Pack ABI goals. gold.py --compare cannot become 24/24 on the
frozen contract. Dest-complete is a separate gate. After dest-complete,
continue CT1/RKB. Native AI lessons/training/data must be English.

RUN_PROVENANCE:
- gold.py SHA256 2986c354acac0f09af5ec678adbeeeb905b8b557d94158fa594a80d85c8d67f3 unedited
- freeze DUT --compare 6/24 (18 generation_flipped None vs 0)
- CT1 PACK24_CT1_RUN1_DUT.jsonl --compare 2/24 (same 18 plus missing R-04/G-04 query fields)
- R1 causal 24/24 CLOSED (jsonl sha256 090b7814…)
- XSim tb_rkb02_reloc.sv sha256 16e405d747ca60f79dae5e9f6a88d69488057ff86183a7afcb3914d02083220a
- RKB02_OBS.json sha256 fd896dab67b90fb6e8926d36b8febb04796fcf7170201e84f8cb622d6328229b
- rkb02_xsim.log sha256 f77de28c81dab74bef71b8af10bbea41cf6342c60d79c6b5201bb3b34749f694
- $finish 2775 ns DEST_COMPLETE+RKB-02 PASS_XSIM
- No program this run. gold.py not edited. No more Pack24.

OBSERVATION:
FACT: freeze gold.py --compare is 6/24. The 18 fails are omit vs expected 0.
FACT: CT1 run1 gold.py --compare is 2/24. Extra fails are missing query_status.
FACT: dest-complete P1 GOLD ack, dest_hs=5, dest[0] contains SID_A, query hit B dest_rd=1.
FACT: P2 GOLD gen=000000b2 writes dest[1024] with SID_A and neighbor B. dest[0] still P1.
FACT: published_root probe stayed 0000000 after both COMMITs.
FACT: poison dest[0] → still hit=1 nb=00020100 dest_rd=1.
FACT: poison dest[1024] → hit=0 nb=00000000 dest_rd=1.
FACT: Native AI lesson preambles locked LANGUAGE=EN. Historical bodies not rewritten.

HYPOTHESES:
H1: gold.py 24/24 is impossible without violating R1 or editing gold.py. CONFIRMED by contract plus 6/24 FACT.
H2: dest-complete handshake plus dest peek proves Pack accepted → dest readable. CONFIRMED P1 dest_hs>=1 and SID in dest[0].
H3: After P2, query SoT is SLOT1 dest[1024], not SLOT0 dest[0]. CONFIRMED by double poison.
H4: published_root==0 means lookup uses dest[0]. CONTRADICTED by poison dest[0] still hit and poison dest[1024] miss.
H5: CT1 UART dest hex would close dest_word_export. UNKNOWN / NOT_RUN. Needs new bit + owner YES.

HOW_TRACE:
Pack GOLD → pack_loader S_RD_WAIT dest handshake (dest_hs) → dest beat peek →
query dest_rd. Second GOLD uses slot_bit toggle → SLOT1 dest[1024].
Wipe SLOT0. Query still hits. Wipe SLOT1. Query misses.

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| GOAL A R1 24/24 CLOSED | FACT | freeze 10_pack24_r1_compare prior 24/24 |
| GOAL B gold.py 6/24 HISTORICAL | FACT | this-turn --compare freeze DUT |
| PACK_ABI_24_24_PASS=NO | FACT | owner KEEP |
| dest-complete XSim | PASS_XSIM | RKB02_OBS PACK_DEST_COMPLETE_XSIM=1 |
| RKB-02 relocation XSim | PASS_XSIM | double poison dest1024 miss |
| dest_word_export UART | NOT_RUN | no new bit |
| READBACK_ACTIVE_GENERATION | NOT_RUN | gen still flop-only |
| RKB 8/8 | NOT_RUN | RKB-04 no EdgeRecord on CT1 path |
| published_root probe | FACT 0 / SoT CONTRADICTED | probe vs dest[1024] poison |

SUCCESS_VS_FAILURE:
Success: dest-complete XSim + RKB-02 double-poison without inventing flip=0.
Failure would have been more Pack24, gold.py edit, DUT emit 0, or stamping PACK_ABI_24_24_PASS / 8/8.

FIRST_DIVERGENCE:
gold.py Boolean 0 vs R1 omit, not silicon Pack behavior.
On RKB-02: published_root probe vs actual lookup address.

DECISIVE_TEST:
gold.py --compare freeze DUT → 6/24.
XSim: poison dest[0] hit; poison dest[1024] miss. $finish 2775 ns.

ROOT_CAUSE_OR_UNKNOWN:
Legacy comparator representation mismatch. RKB-02 dest media relocated to SLOT1.
Why published_root stays 0 while lookup uses dest[1024]: UNKNOWN. Do not treat the probe as SoT.

REUSABLE_DECISION_PROCEDURE:
1. Split product authority from historical comparator.
2. Dest-complete = handshake dest read + dest peek. Not gold.py 24/24.
3. Relocation proof = wipe old dest beat then wipe new dest beat.
4. If probe and poison disagree, believe poison.
5. Native AI data in English.

STRUCTURAL_GUARD:
Do not edit gold.py. Do not invent reject flip=0. Do not run Pack24 to rescue GOAL B.
Do not stamp PACK_ABI_24_24_PASS / RUNTIME_KNOWLEDGE_BINDING_8_8_PASS / dest UART from this XSim.
RKB-04 needs an EdgeRecord path; CT1 dest SID→fwd has none.

BLAST_RADIUS:
rkb_readback XSim DUT/TB only. C RTL / gold.py / FE256 freeze / bitstream untouched.

VERDICT_BY_LAYER:
PASS_XSIM dest-complete and RKB-02 on isolated pack_runtime_dut + mig_ui_bram.
NOT_RUN UART dest export, RKB-04, RKB-05/06, 8/8.
NO PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS / CT1_BOARD_PASS.

LESSON_TO_SHARE: GOLD-PY-24-SELF-CONTRADICTS-R1-20260921T043300Z

NEXT_DECISIVE_EXPERIMENT:
RKB-04 edge dereference. CT1 path has no EdgeRecord: classify BLOCKED_UNTIL_EDGE_MEDIA.
Do not fake an edge. Do not more Pack24. dest_word_export UART only with owner YES new SHA.

OWNER_AND_STOP_CONDITION:
Owner KEEP PACK_ABI_24_24_PASS=NO. D does not self-stamp 8/8. PROGRAM=NO this run.
