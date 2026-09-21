# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: PUBLISH-DEST-TAP-EAD830AE-FEM-XSIM
RUN_ID: 20260921T134300Z
OWNER_AGENT: CURSOR_OWNER
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES

CURRENT_CLAIM:
Unique dest TAP ead830ae was programmed EOS HIGH and exercised dest causality on UART. 8/8 NOT_RUN. FEM persist is PASS_XSIM only; unique persist bit was still generating. Restore after USB DONE=0 is the same SHA. PROGRAM_PASS=NO. PACK_ABI=NO. FEM_PERSIST_PASS=NO.

RUN_PROVENANCE:
- This-turn Get-FileHash bit ead830ae; PROGRAM adc4ec9b; RKB04 f5dbafcf; RKB02/08 4bfbd1ae; RKB05/06 f1615793
- Restore PROGRAM 058a7fc5; iso log c260ce51; uart log a25d2017
- C fem_lifecycle 45b9b930
- Unique git dirs; no bit/dcp. Watch did not program. Did not wait for fem_persist BIT_OK.

OBSERVATION:
FACT: daaca9c1 TAP-gen B!=C; dest poison blocked on that TAP.
FACT: ead830ae WALK_TAP nb is EdgeRecord.dst_id; query token still hit-bit.
FACT: CLOSURE_AUDIT_8_8 forbids 8/8.
FACT: FEM_COMMIT not on dest TAP silicon.
INFERENCE: Persist needs a new unique SHA after BIT_OK.

HYPOTHESES:
H-8/8-from-inventory: REJECTED.
H-restore-is-persist: REJECTED (garbage DEST_READ).

HOW_TRACE:
Hashed PROGRAM/UART/XSim. Copied unique text. FEM bat still running.

EVIDENCE_MATRIX:
| Claim | Class | Layer |
| ead830ae EOS | FACT | PROGRAMMED_EOS_HIGH PROGRAM_PASS=NO |
| RKB-04/02/08 dest | FACT | PASS_BOARD_UART CANDIDATE |
| RKB-05/06 classes | FACT | STALE_KNOWLEDGE / SEMANTIC_PARITY T1 NOT_PROVEN |
| FEM XSim COMMIT hold | FACT | PASS_XSIM |
| FEM persist silicon | NOT_RUN | FEM_PERSIST_PASS=NO |

SUCCESS_VS_FAILURE:
Success: unique publish, no 8/8, no bit in git. Failure: wait forever on impl or stamp persist.

FIRST_DIVERGENCE:
daaca9c1 TAP=pack gen. ead830ae TAP=walk dest snapshot.

DECISIVE_TEST:
Independent bit hash vs PROGRAM vs banned identities.

ROOT_CAUSE_OR_UNKNOWN:
Dest causality on this TAP identity is UART-observed. Persist UNKNOWN on silicon until new bit.

REUSABLE_DECISION_PROCEDURE:
Quote SHA. Keep unique dirs. CLOSURE_AUDIT is inventory. Do not overwrite frozen bits. Check JTAG DONE after USB.

STRUCTURAL_GUARD:
8/8 NOT_RUN. FEM_PERSIST_PASS=NO. No gold.py. No C RTL.

BLAST_RADIUS:
Watch unique docs. Running fem_persist Vivado left alone.

VERDICT_BY_LAYER:
PROGRAMMED_EOS_HIGH ead830ae. PASS_BOARD_UART dest TAP subset. PASS_XSIM FEM persist. NO 8/8 / PROGRAM_PASS / BOARD_PASS / PACK_ABI / FEM_PERSIST_PASS.

LESSON_TO_SHARE: FEM-PERSIST-XSIM-NOT-SILICON-20260921T134300Z

NEXT_DECISIVE_EXPERIMENT:
After unique persist BIT_OK, owner quotes NEW SHA. Watch does not program.

OWNER_AND_STOP_CONDITION:
Publish complete. Do not wait bitgen.
