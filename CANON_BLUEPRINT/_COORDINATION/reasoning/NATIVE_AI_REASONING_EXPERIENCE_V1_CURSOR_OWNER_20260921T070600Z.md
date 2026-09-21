# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: ACCEPT-CODEX-HANDOFF-E01
RUN_ID: 20260921T070600Z
OWNER_AGENT: CURSOR_OWNER
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES

CURRENT_CLAIM:
Codex integrated delta handoff is accepted. Pinned RKB-01 FAIL is layout (12-byte pad vs reader root+16), not SID/CDC. Live 13:48 PASS_XSIM must not replace FAIL 871be467. SAFE_TO_PROGRAM=NO. 8/8 NOT_RUN.

RUN_PROVENANCE:
- User closed Codex at D:/FPGA/arty_d/AUDIT_CODEX_20260921/CODEX_HANDOFF_20260921.md sha256 e3d31e35
- Watch Get-FileHash matched E01 fail/control, 38432 backup, four V1 reports
- Unique GitHub copy docs/audits/20260921_codex_e01_layout/ (no xsim.dir)

OBSERVATION:
FACT: fail.log CODEX_FAIL_VECTOR_REPRODUCED dest_rd=1 sid_r=00010100 match_dir=0 beat 0x20.
FACT: control.log CODEX_CURRENT_VECTOR_CONTROL dest_rd=5 neighbor 00020100.
FACT: walk_sid=0 is pre-query; CODEX_CDC_SOURCE eval_sid=00010100.
INFERENCE: INT-B01 proven for those 72 reconstructed words on current compile.
FACT: INT-B02 SOURCE_IDENTITY stale vs live walk 4275f60d.

HYPOTHESES:
H-lost-SID: REJECTED.
H-layout: CONFIRMED sufficient.
H-8/8-from-13:48: REJECTED (identity drift; UART/mig0 not run).

HOW_TRACE:
Read handoff + four reports + fail/control. Rehashed. Copied unique artifacts. Did not resume parent xelab/program.

EVIDENCE_MATRIX:
| Claim | Class | Layer |
| INT-B01 layout | FACT | PASS_XSIM E01 |
| Pinned FAIL identity | FACT | 871be467 |
| 13:48 integrated PASS | FACT | separate run bb3882e7 |
| 8/8 / board / bit | NOT_RUN | SAFE_TO_BUILD=NO |

SUCCESS_VS_FAILURE:
Success: keep FAIL unique, accept layout cause, continue XSim only. Failure: stamp 8/8 or program from E01.

FIRST_DIVERGENCE:
Directory beat at published_root+0x10. FAIL SID in lane3; control SID in lane0.

DECISIVE_TEST:
E01 COMPLETED. Next: pin SOURCE_IDENTITY to live hashes; hardware-boundary XSim. PROGRAM=NO.

ROOT_CAUSE_OR_UNKNOWN:
ROOT_CAUSE for pinned FAIL: producer/consumer 12 vs 16 byte pad. UNKNOWN: mig0/async, bitstream identity (INT-U01/U02).

REUSABLE_DECISION_PROCEDURE:
Keep PAD=16 bound to walker root+16. Do not expand match_dir. Keep FAIL backups unique. Do not substitute later live logs.

STRUCTURAL_GUARD:
SAFE_TO_BUILD_BITSTREAM=NO until frozen manifest. Do not overwrite 38432. Do not reopen Checkpoint X.

BLAST_RADIUS:
Watch unique docs + lessons append. No C RTL. No gold.py. No bit.

VERDICT_BY_LAYER:
PASS_XSIM E01 pair. PASS_XSIM live 13:48 (separate). NO PACK_ABI / PROGRAM_PASS / BOARD_PASS / 8/8.

LESSON_TO_SHARE: INT-RKB-DIR-PAD16-MATCH-DIR-20260921T070600Z

NEXT_DECISIVE_EXPERIMENT:
Pin corrected integrated identity. Hardware-facing clock/MIG later. PROGRAM=NO.

OWNER_AND_STOP_CONDITION:
Handoff accepted. Watch does not build bit.
