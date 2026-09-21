# published_root Q1–Q5 dest_rd dump (2026-09-21 11:52+07)

This watch did **not** program Arty and did **not** start RKB-04. Silicon still `8bfd993d…` (`PROGRAM.txt` `e920490d…`). Mailbox **NOT_SENT** (owner relay). **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **CT1_BOARD_PASS=NO.** **RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.**

Isolated DUT `pack_runtime_dut` + `mig_ui_bram`. Not `mig0`. Not board.

## Hashes (this-turn Get-FileHash)

| Artifact | SHA256 |
|---|---|
| `D_PUBLISHED_ROOT_Q1Q5.json` | `f3185a77dd721750829cffc6f6c0ecbdb40d009f74e68958612c5554f4923043` |
| `RKB02_OBS.json` (instrumented) | `9ec76529e99a946adb749d15951d17f2dfd3c694e2484f9704d04030113321e3` |
| `rkb02_xsim.log` | `550c1fbb60661addaa5b5d601ce14018cf35e3c8319b3bceab0e96c9d60d05a2` |
| `tb_rkb02_reloc.sv` | `f07d28c460a4a8d09d564c6c0c599521348cd84d4a19708718095e7acedc3a5f` |
| prior OBS (ASK_D-era, keep) | `fd896dab67b90fb6e8926d36b8febb04796fcf7170201e84f8cb622d6328229b` |
| CT1 `PROGRAM.txt` | `e920490d64d8e3292cd6d932f8849e203abc364167a3785a5e4520a8eda31d6d` |

Command `D:\FPGA\arty_d\rkb_readback\run_rkb02_xsim.bat` exit 0. `$finish` **2775 ns** `DEST_COMPLETE+RKB-02 PASS_XSIM`. D's JSON listed the TB hash with one hex digit dropped (`…acdc3a5f`); live file is `…acedc3a5f`.

## Q1 FACT — dest_rd after poison dest[0]

Log line `DEST_RD phase=3 t=2545000`:

| signal | value |
|---|---|
| `app_addr` / `pub_root` | `28'h010_0000` |
| `pub_v` / `root_valid` | 1 / 1 |
| `widx` / `ridx` | 1024 / 1024 |
| dest[0] | 0 |
| dest[1024] | SID+B |
| hit / nb | 1 / `00020100` |

Lookup after P2 is SLOT1, not dest[0].

## Q2 — pub=0 after P2 is (B), UNKNOWN closed

- **A REJECTED:** DEST_RD after P2 and after poison dest[0] both `widx=1024`. Poison dest[1024] miss.
- **C REJECTED:** first P2 `WR_BEAT wr_beat=0100000`; SAMPLE P2 `pending=0100000 have_wr=1`; later dest_rd `pub_root=0100000 have_wr=0`.
- **B CONFIRMED:** TB samples `published_root` at `pack_quiescent` (`load_mem` return) in the same posedge `dest_root_cache` NBA-copies `pending_root` → `pub_root`. SAMPLE P2 `pub=0000000 have_wr=1`. Query dest_rd sees `0100000`.

FACT: SAMPLE vs later dest_rd disagree. INFERENCE (RTL-supported): same-posedge `load_ack` NBA. D classifies the pick as FACT.

## Q3 FACT — `root_valid` at TB samples

- SAMPLE P1: `root_valid=0` `pub_v=0` (pre-ack).
- SAMPLE P2: `root_valid=1` leftover from P1 ack, not P2 publish.
- dest_rd after P2: `root_valid=1` `pub_root=0100000`.

## Q4 FACT — query does not walk `dest[]`

One dest-read: `app_addr=pub_root`, `match_dir` on that beat. One `DEST_RD` line per query. This DUT does not instantiate `posting_walk`. Cite `dest_root_cache.sv` `assign app_addr = pub_root` and `S_WAIT` `match_dir(app_rd_data, sid_r)`.

## Q5 FACT — not an M4/ASTRA object

`published_root` is the 28-bit native-UI address of the first dest write of the last COMMIT (`pending_root` → `pub_root` on `load_ack`). Not QueryRecord / StructuredResult / ASTRA.

## Next

RKB-04 dest-backed Posting+EdgeRecord **XSim** owned by AGENT_D. This watch does not implement it. **No board.** Do not fake EdgeRecord.

```text
PACK_DEST_COMPLETE_XSIM              = 1 (isolated)
RKB02_XSIM                           = 1 (isolated double poison + dest_rd dump)
published_root Q2                    = B (SAMPLE vs load_ack NBA)
UART dest_word_export                = NOT_RUN
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS   = NOT_RUN
PACK_ABI_24_24_PASS                  = NO
PROGRAM_PASS                         = NO
CT1_BOARD_PASS                       = NO
BOARD_PASS                           = NOT_EVIDENCED
```
