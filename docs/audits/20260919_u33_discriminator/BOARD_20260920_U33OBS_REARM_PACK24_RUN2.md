# Unique OBS rearm `08c647ee…` Pack24 run2 — UART 24 MUTE=0, AGENT_D compare 2/24, not PACK_ABI (2026-09-20)

This watch did **not** program Arty, did **not** invoke Pack24, and did **not** run B `--compare`. Parent `run2_rearm` on the same SRAM `08c647ee…` (`fresh=false`). **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **PACK_ABI_24_24_PASS=NO**. Overlay **NO**. Prior unique bits intact. B gold/TB unmodified. No `COMPARE_PACK24_RUN2*.txt` on disk.

| Artifact | SHA256 |
|---|---|
| `PACK24_RUN2_REARM.json` | `f5aa975a3044791deda6d97bd575883241497c97caeda3780a392595bdf5d655` |
| `PACK24_RUN2_REARM_DUT.jsonl` | `1e471d4611abcb2cd49de56937abf2098477b4e72f8bd6555435999c0bc9f82c` |
| `D_U33OBS_REARM_PACK24_RUN2.json` | `fb7f1ff50de913f5a520b04e9ca545bbdd79f8858b378beb8eff3978947860f6` |

JSON field `stop=PACK24_RUN1_DONE` despite `run=run2_rearm` (script leftover). Cases **24**. UART **MUTE=0**. Same UART words as run1: GOLD V-01..V-04 / R-04 / G-01 `010000a5` with dump-after-gold **flip=1**; A-02 MAG `0200015a`; A-03 `0200095a`; A-04 `02000f5a`; rejects omit `generation_flipped`; S-01 `tap_not_this_pack`. LOAD_OK dump-after-gold six four-AND this pack (V-01 epoch 28).

AGENT_D D json `compare_print`: **compare 2/24 match, 22 fail**. B nfail counts **fields** not cases. LOAD_OK six `generation_flipped=1` had no FAIL. 18 reject flip None vs TSV 0; R-04 query 6/80; G-04 flip+query 6/84. Watch did **not** invoke `--compare`; cite AGENT_D D json only.

Leftover extra-BEGIN after run1 is MAG CLASS_A; TAP four-AND is **stale G-01** (`leftover_tap_not_this_pack`), not leftover COMMIT. Query OPEN pack-only. G-01 dest-complete two-step and fresh dest-complete **NOT_RUN**. **PACK_ABI_24_24_PASS=NO**.
