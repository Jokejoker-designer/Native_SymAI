# Pack24 query on `8fc14f25…` — B `--compare` 6/24; R1 Causal 24/24 CANDIDATE (2026-09-21)

This watch did **not** program Arty. Independently hashed parent COMPLETE artifacts and re-ran `10_pack24_r1_compare.py`. **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **BOARD_PASS=NO.** B `pack_abi24_gold.py` unmodified (sha256 `2986c354acac0f09af5ec678adbeeeb905b8b557d94158fa594a80d85c8d67f3`). R1 zip `4bc37ffe…` remains CURRENT CANDIDATE / owner Pack ABI **authority**, not historical PASS.

## Identity

Live `PROGRAM.txt` SHA256=`8fc14f25f2b9d936b7d412ce41b6d963991cc91137c20587e3ab5a96b5224df5` JTAG `210319BE776EA`. dest_wipe=NO. Owner grant until 12:00 +07. Watch did not nạp.

## Watch re-run (this tick)

```text
python CANON_BLUEPRINT/verification_r1/10_pack24_r1_compare.py PACK24_RESUME_QUERY_R1.jsonl
→ PACK_ABI24_R1_CANDIDATE: 24/24 contract match  rc=0
NOTE: candidate success does NOT authorize historical PACK_ABI_24_24_PASS.
```

DUT sha256 `090b7814d0bbe6d31089e07339bfa64c93651881c429deb83d0621de56639737`.

Historical B `--compare` on sibling B-shaped jsonl remains **6/24** (18 `generation_flipped` None vs TSV 0). Watch did **not** fill 0.

R1 dest-complete kind in that jsonl is `S_RD_WAIT_THEN_S_COMMIT_GOLD` (page `rg_first`), **not** dest hex UART and **not** ManifestHeader `pack_generation` from dest. `PACK_DEST_COMPLETE_BOARD_PASS=NOT_RUN`.

## Artifacts (unique names; 99823c92 hop not overwritten)

| Artifact | SHA256 |
|---|---|
| `PACK24_RESUME_QUERY_R1.jsonl` | `090b7814d0bbe6d31089e07339bfa64c93651881c429deb83d0621de56639737` |
| `PACK24_RESUME_QUERY_DUT.jsonl` | `f5ead405fef0fca13f0393a1e95d8636b2dbaa1289a4dab580ae64f662b3b6c8` |
| `PACK24_FRESH_QUERY_DUT.jsonl` | `398fe3ba2319d49096776fbcf2534798ab2716a6d644bb0fc4bd62d2847637fb` |
| `PACK24_RUN1_QUERY_DUT.jsonl` | `23eb55f7b9653be3ca48e0b2a8dd9b545a0926a939724ce39a8b44bce00675d9` |
| `PACK24_RUN2_QUERY_DUT.jsonl` | `edaedfa899d4c047eebc0d1fba09e59a6a2dc49d2bfe4fb8ecd4cacab3f3a742` |
| `PACK24_RESUME_QUERY.json` | `191700ffc4735dff23e792b8d6a5431077d7c861fd807b53107720ebddc47fe2` |
| `PACK24_FRESH_QUERY.json` | `6abff9e9c701908be433c46eac04df3e0f89e96b1b625a87b765c04f167bdcd2` |
| `PACK24_RUN1_QUERY.json` | `8ad8f88fa63f68b794c1bc99224a8943e917dea0b9c10d957a3b33ec922e53b2` |
| `PACK24_RUN2_QUERY.json` | `8a0636b799483c1a74f58f828f734d736d143ec08837038b6651b80cb1bcd488` |
| `U33OBS_QUERY_ISO_G04_R1_ORDER.json` | `3a6e1cfdc025620508dbe15b11d24e84fc1a1db69c05799f42573e6a12736366` |
| `U33OBS_QUERY_ISO_R04_8FC14F25.json` | `9da6c2d87d398e9b551f16be5466aecf2f04c28162c0223b69d5121c66b5d8a3` |
| `U33OBS_QUERY_ISO_R04.json` (99823c92 hop keep) | `ae394b6b12d38440f3079739af17faa58874e159fb473e68c8a6f24e562bcf7a` |
| freeze `SHA256SUMS.txt` | `998f19c4691bce886727d23ae074a127908c55bd071626ec93e00ec76a0404bf` |
| `D_PACK_ABI24_R1_P0_CLOSE.json` | `fb418579109cdf810f74e1580b9bdb7091712e2cbd3eff8aa0978422ad6950d5` |
| `emit_r1_dut.py` | `5cef710743827176ac44372ab8e3a4b45f7a2312d2b92948a9725d372ecea071` |

Owner freeze `D-PACK-ABI24-R1-AUTHORITY-FREEZE` RUN_ID `20260921T021200Z`: P0 Pack closed on R1 24/24. `U33OBS_DEBUG=CLOSED`. Historical `PACK_ABI_24_24_PASS=NO`. Next: `READBACK_ACTIVE_GENERATION` + `RUNTIME_KNOWLEDGE_BINDING_8_8`. Freeze copy of `pack_abi24_gold.py` hash-matches live B gold (`2986c354…`); not a gold edit.

## Claim ceiling

```text
PACK_ABI24_R1_CANDIDATE          = 24/24 (watch re-ran compare)
PACK_ABI_24_24_PASS              = NO
PROGRAM_PASS                     = NO
BOARD_PASS                       = NO
TIMING_PASS                      = NO
MIG_PASS                         = NO
ASTRA_PASS                       = NO
FE256_PASS                       = NO
PACK_DEST_COMPLETE_BOARD_PASS    = NOT_RUN
UART_MUX_8_8_PASS                = NOT_RE_RUN_THIS_CLOSE
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
READBACK_ACTIVE_GENERATION_PASS  = NOT_RUN
FEM_PERSIST_PASS                 = NO
FINAL_PASS                       = NO
```
