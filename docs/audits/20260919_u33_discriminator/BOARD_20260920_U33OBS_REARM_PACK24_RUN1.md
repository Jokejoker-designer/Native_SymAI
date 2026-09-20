# Unique OBS rearm `08c647ee…` Pack24 run1 — UART 24 MUTE=0, dump-after-gold four-AND, 22 field fails, not PACK_ABI (2026-09-20)

This watch did **not** program Arty, did **not** invoke Pack24, and did **not** run B `--compare`. Parent `run1_rearm` on SRAM `08c647ee…`. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **PACK_ABI_24_24_PASS=NO**. Overlay **NO**. Prior unique bits intact. B gold/TB unmodified. No `COMPARE_PACK24_RUN1_REARM.txt` on disk; field-fail count is from `D_U33OBS_REARM_PACK24_RUN1.json`.

| Artifact | SHA256 |
|---|---|
| `PACK24_RUN1_REARM.json` | `aefc8b3611a3fab1dfb5f1de9bf1ce4a70d8e335fbf049c013795e583b0ac157` |
| `PACK24_RUN1_REARM_DUT.jsonl` | `4ac6eb3c5776a15bc9c53931c0238a710e4e22ceaf3d2d137b7adee4c62fe389` |
| `D_U33OBS_REARM_PACK24_RUN1.json` | `d4ddd36d663471538d338afd554741e54dc93bd5ea3abcf1c4226f81f5fc15cf` |

`stop=PACK24_RUN1_DONE`. Cases **24**. UART **MUTE=0**. GOLD UART + TAP dump four-AND **flip=1**: V-01..V-04, R-04, G-01. A-02 **MAG** `0200015a`. A-03 `0200095a` / A-04 `02000f5a`. S-01..S-04 `0200035a`. C-01..C-04 `02000d5a`. R-01 `0200055a` R-02 `0200045a` R-03 `0200055a`. G-02/G-03 `0200075a` G-04 `0200055a`.

DUT.jsonl: six LOAD_OK rows include `generation_flipped=1`. Eighteen LOAD_REJECT rows **omit** the field (`tap_not_this_pack` on S/A/C/G rejects). S-01 TAP after CLEAR is prior V-04 COMMIT, omitted.

AGENT_D compare: **22 field fails** — 18 reject flip absent vs TSV 0; R-04 query 6/80; G-04 query 6/84; LOAD_OK flip=1 matched. UART outcome/reason/ack/reject **24/24** gold tokens. Run2/fresh **NOT_RUN**. **PACK_ABI_24_24_PASS=NO**.
