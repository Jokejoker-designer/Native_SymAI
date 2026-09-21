# Closure audit of 1db38691 legal-compact (2026-09-21)

Watch did **not** program. No new bit. JSON hash still `6378acafe72067f208ba2aae1d324a27bce3f5953cb21188f7275b3d8f34f13f`. Disk persist bit still `1db38691…`. `PROGRAM.txt` still `4c47930a…`. Historical no-FREP `UART_SMOKE.json` `822f8750…` kept. C `fem_lifecycle.v` `45b9b930…` unedited.

LANGUAGE=EN. Not a product PASS stamp.

```text
CLASS = FEM_PERSIST_LEGAL_COMPACT_BOARD_CANDIDATE
CONTRADICTION_FOUND = NO
LIVE_SRAM_HASH = NOT_READ
PROGRAM.DONE = NA
FEM_PERSIST_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
MIG_PASS = NO
TIMING_PASS = NO
PACK_ABI_24_24_PASS = NO
```

## Independent hashes

| Artifact | SHA256 |
|---|---|
| `UART_LEGAL_COMPACT.json` | `6378acafe72067f208ba2aae1d324a27bce3f5953cb21188f7275b3d8f34f13f` |
| `CLOSURE_AUDIT_20260921T162400Z.md` | `c12cb9546ba70021635b1e163db01c656743141535a9453f1bdea03b1bc79936` |
| freeze `FEM_PERSIST_LEGAL_COMPACT_BOARD_CANDIDATE.md` | `6a1cfdddef17b8e4bda14ed3410db0010a9c5b167b6a0edb89f089e2a849832d` |
| superseded next-step `FEM_TO_SPEAR_QSTAR_CAUSAL_EXPERIMENT.md` | `b5c857c04d6d4e891c081c57421da5b5065b0da4f38b8869b258d356238cffc1` |
| persist `.bit` disk keep | `1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668` |
| keep `PROGRAM.txt` | `4c47930a14f9eae4e409d0f06d31bb0e5d4aaf8425507b8c4025a897caa78214` |
| keep `UART_SMOKE.json` | `822f8750d1471c2f24ff7c9291d77d6ca8572f7a5ce88f399ff278ea366cd367` |
| C `fem_lifecycle.v` | `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` |

JSON has eight `c0117ed0` strings and **no** `44504B31`. Independent harness CRC16 over `{0x70ea0203,0x11010000}` = `0x552e` (`A_CRCW=a5a5552e`).

## FACT — scoped freeze, not FEM_PERSIST_PASS

Closure search found no DEST_POKE, no pack alias of FEM_BASE `0x0200000`, no dest_hold explaining post-FRST DEST_READ. Identity binding is programmed SHA + no-reprogram provenance + unique FEM UART, **not** live SRAM hash.

This unique dir does **not** overlay `docs/audits/20260921_fem_persist_legal_compact_1db38691/` or the BIT_OK unique dir.

Next design is a **new** tree `fem_qstar_causal` (SHA NOT_ASSIGNED). Do not persist-repeat COMMIT/FRST/FREC. Do not edit C.
