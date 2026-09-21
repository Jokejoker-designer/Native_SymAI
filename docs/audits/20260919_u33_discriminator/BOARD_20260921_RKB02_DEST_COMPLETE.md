# Isolated dest-complete + RKB-02 relocation XSim (2026-09-21)

This watch did **not** program Arty and did **not** resume parent Vivado. Silicon still `8bfd993d…` (`PROGRAM.txt` `e920490d…`). **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **CT1_BOARD_PASS=NO.** **RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.** **READBACK_ACTIVE_GENERATION_PASS=NOT_RUN.** dest UART export **NOT_RUN**.

Isolated DUT `pack_runtime_dut` + `mig_ui_bram` stand-in. Not `mig0`. Not board.

## Hashes

| Artifact | SHA256 |
|---|---|
| `RKB02_OBS.json` | `fd896dab67b90fb6e8926d36b8febb04796fcf7170201e84f8cb622d6328229b` |
| `rkb02_xsim.log` | `f77de28c81dab74bef71b8af10bbea41cf6342c60d79c6b5201bb3b34749f694` |
| `tb_rkb02_reloc.sv` | `16e405d747ca60f79dae5e9f6a88d69488057ff86183a7afcb3914d02083220a` |
| CT1 `PROGRAM.txt` (unchanged SRAM) | `e920490d64d8e3292cd6d932f8849e203abc364167a3785a5e4520a8eda31d6d` |
| `ASK_D_PUBLISHED_ROOT.md` | `62d97c77c196a3701301c0b927033215f5466b30b8dafb7611042c0fe59d1440` |
| D V1 `20260921T043300Z` | `1a5badf8af7fb6c8ac782fd5c9a5468218995fce3490314ed4df1cf46a1ef082` |

`$finish` **2775 ns**. Line `DEST_COMPLETE+RKB-02 PASS_XSIM`. Watch did not re-xelab this tick; hashed live log/json.

## Dest-complete P1 (PASS_XSIM)

GOLD ack, dest handshake `hs=5`, dest[0] contains SID_A, query hit neighbor `00020100`, `dest_rd=1`. `PACK_DEST_COMPLETE_XSIM=1`. Not UART dest hex.

## RKB-02 relocation (PASS_XSIM isolated)

P2 GOLD gen=`000000b2` writes dest[1024]. dest[0] still P1. Poison dest[0] → still hit. Poison dest[1024] → miss. D: SLOT1 dest[1024] is query SoT.

`published_root` probe stayed `0000000` after both COMMITs. D H4 (probe=0 ⇒ lookup dest[0]) **CONTRADICTED**. Why the probe stays 0 is **UNKNOWN**. Owner forbade guess: ASK_D Q1–Q5 unread. Mailbox OWNER→AGENT_D. Paste `CHECK MAILBOX` in D chat to drain.

RKB-04 **BLOCKED_UNTIL_EDGE_MEDIA**. No EdgeRecord on CT1 SID→fwd path. Do not fake an edge TB.

GOAL A R1 Causal 24/24 CLOSED (not historical PASS). GOAL B `gold.py` freeze DUT 6/24 HISTORICAL; CT1 RUN1 DUT 2/24. gold.py `2986c354…` unedited.

## Claim ceiling

```text
PACK_DEST_COMPLETE_XSIM              = 1 (isolated)
RKB02_XSIM                           = 1 (isolated double poison)
published_root why 0 after P2        = UNKNOWN (ASK_D)
UART dest_word_export                = NOT_RUN
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS   = NOT_RUN
PACK_ABI_24_24_PASS                  = NO
PROGRAM_PASS                         = NO
CT1_BOARD_PASS                       = NO
BOARD_PASS                           = NOT_EVIDENCED
```
