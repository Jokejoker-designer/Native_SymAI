# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: PUBLISH-RKB-EDGE-DAACA9C1
RUN_ID: 20260921T072600Z
OWNER_AGENT: CURSOR_OWNER
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES

CURRENT_CLAIM:
Unique RKB-edge bit daaca9c1 is PROGRAMMED EOS HIGH. UART smoke is UART_BOARD_SMOKE_CANDIDATE (UNSET/01/03/06/07). Not 8/8. Not PROGRAM_PASS / BOARD_PASS / TIMING_PASS / MIG_PASS / PACK_ABI. CT1 file 8bfd993d kept on disk. Watch did not program.

RUN_PROVENANCE:
- Parent jsonl 6412153 @ 2026-09-21T07:18:38Z (was 6230899)
- This-turn Get-FileHash bit daaca9c1; CT1 bit 8bfd993d; PROGRAM.txt 743dfaef; UART json b7e4aab5
- program.log EOS HIGH; WNS 0.521 from timing_route.rpt line 141
- Unique GitHub dir docs/audits/20260921_rkb_edge_daaca9c1/ (no bit/dcp)

OBSERVATION:
FACT: Unique dir build_rkb_edge programmed, not build_ct1.
FACT: UART 03010051 after A2B and A2C; neighbor not on wire.
FACT: FLSH n=0 then still hit token; not T1 occupancy proof.
FACT: D_RKB_EDGE_INT.json log hash 01fbee9f does not match live log bb3882e7.
FACT: FAIL 38432 871be467 still unique.

HYPOTHESES:
H-8/8-from-smoke: REJECTED (02/04/05/08 UART NOT_RUN; neighbor not on wire).
H-reuse-CT1: REJECTED (disk CT1 hash unchanged; PROGRAM.txt unique SHA).

HOW_TRACE:
Hashed disk bit/PROGRAM/UART. Read program.log and timing_route summary. Copied unique text artifacts. Did not xelab/program.

EVIDENCE_MATRIX:
| Claim | Class | Layer |
| Unique SHA on JTAG | FACT | PROGRAMMED_EOS_HIGH PROGRAM_PASS=NO |
| UART tokens | FACT | UART_BOARD_SMOKE_CANDIDATE |
| WNS 0.521 | FACT | TIMING_PASS=NO |
| 8/8 | NOT_RUN | ceiling |
| PACK_ABI | NO | KEEP |

SUCCESS_VS_FAILURE:
Success: unique identity published, CT1 disk kept, no global PASS. Failure: overlay CT1, stamp 8/8 from 03010051.

FIRST_DIVERGENCE:
XSim dest_rd/EdgeRecord vs UART hit-bit only.

DECISIVE_TEST:
Independent bit hash vs PROGRAM.txt vs CT1 file. Already done.

ROOT_CAUSE_OR_UNKNOWN:
UNKNOWN on silicon: dest_rd, leftover SLOT1 B vs C, EdgeRecord.dst_id.

REUSABLE_DECISION_PROCEDURE:
Quote unique SHA. Ban prior identities. Do not decode 03010051 as neighbor. Do not push bits. Keep FAIL backups.

STRUCTURAL_GUARD:
PROGRAM_PASS=NO. 8/8 NOT_RUN. Unique OBS dir. No gold.py edit.

BLAST_RADIUS:
Watch unique docs + lessons. No C RTL. No freeze DCP. No bit in git.

VERDICT_BY_LAYER:
PROGRAMMED_EOS_HIGH. UART_BOARD_SMOKE_CANDIDATE. PASS_INTEGRATED_XSIM 13:48 separate. NO 8/8 / PROGRAM_PASS / BOARD_PASS / TIMING_PASS / MIG_PASS / PACK_ABI.

LESSON_TO_SHARE: UART-HITBIT-NE-NEIGHBOR-DAACA9C1-20260921T072600Z

NEXT_DECISIVE_EXPERIMENT:
Owner dest/TAP if RKB-02/04/05/08 on this SHA. Do not Pack24. Watch does not program.

OWNER_AND_STOP_CONDITION:
Publish complete. SRAM=daaca9c1. PROGRAM_PASS=NO.
