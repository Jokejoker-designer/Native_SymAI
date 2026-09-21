# Legal compact UART on existing 1db38691 (2026-09-21)

Watch did **not** program and did **not** rebuild a bit. Independent Get-FileHash of disk persist bit still `1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668`. `PROGRAM.txt` hash still `4c47930a…` (21:33+07). Historical `UART_SMOKE.json` `822f8750…` **not overwritten**. Unique bit-dir `docs/audits/20260921_fem_persist_bit_1db38691/` **not overwritten**. C `fem_lifecycle.v` `45b9b930…` unedited.

LANGUAGE=EN. Not a product PASS stamp.

```text
CLASS = FEM_PERSIST_LEGAL_COMPACT_BOARD_CANDIDATE
NEW_BITSTREAM = NO
REPROGRAM_THIS_RUN = NO
DEST_POKE = NO
RED_RESET = NO
FEM_PERSIST_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
MIG_PASS = NO
TIMING_PASS = NO
PACK_ABI_24_24_PASS = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
```

## Independent hashes

| Artifact | SHA256 |
|---|---|
| persist `.bit` (disk, not committed) | `1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668` |
| `UART_LEGAL_COMPACT.json` | `6378acafe72067f208ba2aae1d324a27bce3f5953cb21188f7275b3d8f34f13f` |
| harness `uart_fem_persist_legal_compact.py` | `f6da7ae0d3d1fea11ce2d3d2d3d47b3a4a748cd8c3d031a04ce3cab1866b2bbe` |
| keep `PROGRAM.txt` | `4c47930a14f9eae4e409d0f06d31bb0e5d4aaf8425507b8c4025a897caa78214` |
| keep `UART_SMOKE.json` (no-FREP) | `822f8750d1471c2f24ff7c9291d77d6ca8572f7a5ce88f399ff278ea366cd367` |
| D V1 20260921T160900Z | `2f24072d06977364305b190b4617082530881e443afaf851321cc206b6fba9d7` |
| independent audit V1 | `fe666bda0c67b565958c98b8de85b87b9c698ba73f602710635386a89bf46194` |
| adversarial V1 | `ebe18ff086460109cb9492e75d1137bf5a3ce0298e52b7d387ff42a9535f831f` |
| C `fem_lifecycle.v` | `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` |

JSON hash matches D `RESULTS_SHA256SUMS.txt`.

## FACT — prior smoke omitted FREP (kept)

Independent audit 15:35Z: no-FREP `UART_SMOKE` FOBS_AFTER_CMP `life=1` `compacted=0` `cmp_result=1`. Missing `C0117ED0` is **not** MIG-first. Adversarial 15:48Z: `cmp_result==0` is reset default; FCMP echo is not compact success.

## FACT — this-run gated sequence on COM12 23:09+07 (CANDIDATE)

CLEAR+FRST virgin FOBS `life=7` `n_raw=0` `key=0`. FING 5/6/4/4 then FOBS CLUSTERED `life=1` `n_raw=2` `key=0x70ea`. FREP `0x0111` x3 then FOBS RESOLVED `life=2` `sar=3` `fr=0`. FCMP then FOBS `life=3` `compacted=1` `cmp_result=0` `n_raw=0`.

DEST_READ `0x0200000` = `03000213 70ea0203 11010000 a5a5552e` (CRC16 CCITT-FALSE over `{0x70ea0203,0x11010000}` = `552e`). DEST_READ `0x0200010` = `c0117ed0 00000001 110170ea 00010000` `commit_magic=1`. After FEM-only FRST, both beats **bit-identical**. FOBS after FRST virgin. FREC FOBS `recov=2` `life=3` `compacted=1` `integrity_fault=0`. DEST_READ COMMIT still magic.

Lane3 of `0x0200010` remains `00010000`. SRAM identity is **STRONG_INFERENCE** (unique FREP/FOBS plane; no bitstream readback).

Closure audit requested. **FEM_PERSIST_PASS=NO.**
