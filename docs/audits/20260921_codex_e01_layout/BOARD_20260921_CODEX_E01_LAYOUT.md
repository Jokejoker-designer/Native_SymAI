# Codex E01 layout replay — pinned integrated RKB-01 FAIL (2026-09-21)

Watch accepted the Codex delta handoff. Unique copy under this directory. No overlay of the 13:41 FAIL log. Watch did **not** xelab, implement, or program. Checkpoint X isolated RKB remains closed.

LANGUAGE=EN. Not a product PASS stamp.

```text
FIRST_DIVERGENCE = Directory payload layout mismatch
TOP_BLOCKER = INT-B01 producer/consumer offset disagreement
ROOT_CAUSE = Proven for pinned RKB-01 FAIL
SAFE_TO_CONTINUE_INTEGRATED_XSIM = YES
SAFE_TO_BUILD_BITSTREAM = NO
SAFE_TO_PROGRAM_BOARD = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
BOARD_PASS = NO
PROGRAM_PASS = NO
TIMING_PASS = NO
MIG_PASS = NO
PACK_ABI_24_24_PASS = NO
```

## Independent watch hashes (this-turn Get-FileHash)

| Artifact | SHA256 |
|---|---|
| Pinned FAIL `rkb_edge_int_xsim_38432.backup.log` | `871be4671f175d552b20d40458e9c31d6feb56437a874eeb65f0eb7805b587e3` |
| E01 `fail.log` | `45d4f72e09d3ef52e03e3de8d04f9fa1fc0efee0e2c81816e9afaf6ac9da44be` |
| E01 `control.log` | `eeb6b88bbbe0e45f016e73c8eaad615dc6d4d7006dcc7464c6328fc95e0f7228` |
| `CODEX_HANDOFF_20260921.md` | `e3d31e357507beacd14fffd66257ef0a5c4480aa0f9085b1c96c31711e3fb51c` |
| `CODEX_BLOCKER_AUDIT_V1.md` | `64ed6b6b64c8000c47159e4adc31323075533fe57a4618cdd38bf87116dd5697` |
| `CODEX_UNKNOWN_REGISTER_V1.md` | `7c6b86e5917e8349e5ef240dcd75f6e02b0fcfd910a6bcc99eb81191baecb906` |
| `CODEX_CRITICAL_PATH_TO_BOARD_V1.md` | `28ec26c586f8b80811022d3b574c241297fe2ab6af394068cdc9815a565323e4` |
| `CODEX_DECISIVE_EXPERIMENTS_V1.md` | `a8e0b51dd2311c9eb15f728bdeda3f8c78b6c67a49c1151b4d5fa0f6c10e212a` |
| `EVIDENCE_MANIFEST.json` | `f1d2c403d459a1ee24d919053a8b863bd5b0820ec843b4a26087f93e5acb8ec9` |
| Live integrated log 13:48 (not a FAIL substitute) | `bb3882e78eaab88821ae661c64cbcd9ffe457addd48cb4705de3bc77999fe59a` |
| Live `RKB_EDGE_INT_OBS.json` 13:48 | `a6e83f258be3f61abefe4377c56cbf1a280a362c1c2f3a57ad807b9259207d73` |

## FACT — E01 A/B (PASS_XSIM, RKB-01 only)

Same compiled integrated snapshot. Swap only the 72-word UART pack.

- FAIL replay marker `CODEX_FAIL_VECTOR_REPRODUCED`: SID `00010100` at CDC and lookup; Directory beat at `published_root+0x10` (`0x20`) lane0=`00000030`; `match_dir=0`; `dest_rd=1`; miss. Pre-query `walk_sid=0` is TB print before `do_query`; post-query `sid_r=00010100`.
- Control marker `CODEX_CURRENT_VECTOR_CONTROL`: same SID; reads `0x20,0x30,0x40,0x50,0x60`; `dest_rd=5`; hit B `00020100`.

`match_dir` compares SID on `[31:0]`, `[63:32]`, `[95:64]` only. FAIL places SID in `[127:96]`. Do not widen the matcher to rescue a 12-byte pad.

## FACT — later rkb_edge PASS is a different run

Live 13:48 all 01–08=1 is **not** the 13:41 FAIL. Keep `38432` unique. `SOURCE_IDENTITY.txt` still names walk `322e476d…`; live walk `4275f60d…` (INT-B02). E01 used the current walk in **both** arms, so A/B still isolates layout.

## UNKNOWN / NOT_RUN

Generated `mig0`, async clocks, bitstream identity, UART 8/8, board. E01 is `RKB_EDGE_XSIM` + `mig_ui_bram` + shared 100 MHz.

SRAM remains `8bfd993d…`. **PROGRAM_PASS=NO.** **CT1_BOARD_PASS=NO.**
