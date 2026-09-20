# Unique OBS steer `bd541f95…` Pack24 run1 — UART 24 replies, MUTE=0, not PACK_ABI (2026-09-20)

This watch did **not** program Arty and did **not** invoke Pack24. Parent ran `run1_steer` on SRAM `bd541f95…`. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **PACK_ABI_24_24_PASS=NO**. Overlay **NO**. Old OBS `71b9198f…` and rgoff `251eafa9…` files intact. B gold/TB unmodified. `compare_ready=false`. B `--compare` **NOT_RUN**.

| Artifact | SHA256 |
|---|---|
| `PACK24_RUN1_STEER.json` | `97961d2d5a087fa48825412ae7bccf8f967fc7f1be8335fca6cfbe04b21b388a` |
| `PACK24_RUN1_STEER_DUT.jsonl` | `79962e9e80ce7f54ee80e9333ad09e19ee39cfc9f0158a4b2f8b25858af8b6b7` |
| `D_U33OBS_STEER_PACK24_RUN1.json` | `4b0ce0f6a621e0b0b8a32e8e672723d1bb098c53f8512222ce4b4c8baf6cca2b` |

`stop=PACK24_RUN1_DONE`. Cases **24**. UART **MUTE=0**. GOLD UART: V-01..V-04, R-04, G-01 (`010000a5`). A-02 **MAG** `0200015a`. A-03 `0200095a` / A-04 `02000f5a` (same as isolated hops). S-01..S-04 `0200035a`. C-01..C-04 `02000d5a`. R-01 `0200055a` R-02 `0200045a` R-03 `0200055a`. G-02/G-03 `0200075a` G-04 `0200055a`.

S-01 rec n=40 concatenates TAP four-AND `ffffffff→0000ffff`; DUT jsonl sets `generation_flipped=1` on S-01. Owner of that TAP vs prior V-04 GOLD freeze-once is **UNKNOWN**. UART GOLD/MAG must not invent `generation_flipped`. Four-AND remains Pack `S_COMMIT` law.

Old OBS Pack24 run1 had A-03/A-04 MUTE and V-03 R_SENTINEL. This steer run has **no MUTE** and V-03 GOLD. That is **PASS_BOARD CANDIDATE this campaign only**, not Pack ABI 24/24, not gold-field compare.
