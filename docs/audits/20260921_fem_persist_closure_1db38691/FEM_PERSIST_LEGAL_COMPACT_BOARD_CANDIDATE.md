# FEM_PERSIST_LEGAL_COMPACT_BOARD_CANDIDATE

LANGUAGE=EN  
FREEZE_UTC: 2026-09-21T162400Z  
AUTHORITY: `07fa414555a7c729cc4d4e4dd093a35a03ea2aa6`  
CLOSURE: `CLOSURE_AUDIT_20260921T162400Z.md`  
CONTRADICTION_FOUND: NO

```text
CLASS=FEM_PERSIST_LEGAL_COMPACT_BOARD_CANDIDATE
IDENTITY=1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668
IDENTITY_BINDING=PROGRAMMED_SHA + NO_REPROGRAM_PROVENANCE + UNIQUE_FEM_UART
LIVE_SRAM_HASH=NOT_READ
C_FEM_RTL=fem_lifecycle.v
C_FEM_SHA256=45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed
C_RTL_EDIT=NO
JSON_SHA256=6378acafe72067f208ba2aae1d324a27bce3f5953cb21188f7275b3d8f34f13f
HARNESS_SHA256=f6da7ae0d3d1fea11ce2d3d2d3d47b3a4a748cd8c3d031a04ce3cab1866b2bbe
KEEP_UART_SMOKE=822f8750d1471c2f24ff7c9291d77d6ca8572f7a5ce88f399ff278ea366cd367
NEW_BITSTREAM=NO
REPROGRAM_AT_FREEZE=NO
DEST_POKE=NO
RED_RESET=NO
```

## Supported scoped result

`FEM_PERSIST_LEGAL_COMPACT_BOARD_CANDIDATE = SUPPORTED`

| Subclaim | Status |
|---|---|
| LEGAL_RESOLVED_PRECONDITION | OBSERVED |
| LEGAL_FCMP | OBSERVED |
| L_COMPACTED | OBSERVED |
| FEM_COMMIT_MAGIC | OBSERVED |
| FEM_INDEX | OBSERVED |
| FEM_PROTOTYPE_CRC | OBSERVED |
| FEM_MEDIA_RETENTION_ACROSS_FRST | OBSERVED |
| FREC_COMMITTED_NEW | OBSERVED |
| FEM_RECOVERY_INTEGRITY_FAULT | 0 |

## Claim ceiling (locked)

```text
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
BOARD_PASS=NO
MIG_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
```

Positive route timing and this board observation are evidence, not formal PASS authority.

## Research closure

Unless a **new** contradiction appears, stop modifying or retesting:

- FEM_BASE mapping
- A_COMMIT address
- FEM legal compaction ordering
- basic T2 write/read mapping
- FRST media retention for this FEM-only reset scope
- COMMITTED_NEW recovery mechanism

Do **not** build a new persist bit merely to repeat COMMIT/FRST/FREC.  
Do **not** edit frozen C FEM RTL for persistence closure.  
Do **not** reopen MEMORY/T2/MIG because a later high-level behavioral test fails; that failure must name its own first causal divergence.

Historical no-FREP DEST_READ-first D/watch notes: `SUPERSEDED_BY_CAUSAL_AUDIT` (append-only; do not delete).

## Explicitly not proven

Power-loss / red-board / reconfiguration persistence. Full MIG_PASS / BOARD_PASS / FEM_PERSIST_PASS. FEM influence on SPEAR/Q* or any later decision. Developmental intelligence. Scale beyond frozen `N_RAW=4`.

## Next research

`DOES RECOVERED FEM EXPERIENCE CAUSALLY CHANGE FUTURE DECISION-MAKING?`

See `FEM_TO_SPEAR_QSTAR_CAUSAL_EXPERIMENT.md`.

Identity `1db38691` cannot run that experiment: unique persist top holds SPEAR/Q* idle (`q_start=0`, `prop_start=0`, `feat_flat=0`); `fem_feat` is FOBS-only.

```text
EXPERIENCE != FACT
FAILURE != TRUTH
FEM != ASTRA
UTILITY != TRUTH
CANDIDATE != VERIFIED
```
