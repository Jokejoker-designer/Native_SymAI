# PACK ABI-24 observe XSim query (2026-09-20)

PACK_ABI_24_24_PASS=NO. PROGRAM=NO. Not silicon.

`pack_mig_bind` + `mig_ui_bram` dest-complete XSim 24/24 load at 26165 ns. `generation_flipped` only from Pack `S_COMMIT` four-AND:

```text
commit_event == 1
AND generation_after != generation_before
AND same_capture_epoch
AND capture_valid == 1
```

Rejects without COMMIT omit the field (gold TSV wants 0). Do not invent 0.

QueryRecord observed in TB (CRC16-CCITT-FALSE + dest inner scan), not copied from TSV:

| case | load | flip | query |
| PA24-R-04 | LOAD_OK | 1 (ffffffff→0000002b) | 6/80 PACK_CRC dest_fail=1 |
| PA24-G-04 | LOAD_REJECT reason 5 | absent | 6/84 STALE_GENERATION q_gen=1 active=2 dest_fail=0 |

B `--compare`: **6/24 match, 18 fail**. Six full matches: V-01..V-04, R-04, G-01. Eighteen FAIL = reject `generation_flipped` None vs TSV 0 (includes G-04). Query lines no longer FAIL.

DUT.jsonl sha256 `57a7b65d26af1b7820a17a9fe31f64ab26e9ae2751658d09517a256e9c2705b0`.
