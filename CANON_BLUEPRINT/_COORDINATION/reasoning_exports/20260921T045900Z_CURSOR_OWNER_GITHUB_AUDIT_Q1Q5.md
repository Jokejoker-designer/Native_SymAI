# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: GITHUB-AUDIT-PUBLISHED-ROOT-Q1Q5
RUN_ID: 20260921T045900Z
OWNER_AGENT: CURSOR_OWNER
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES

CURRENT_CLAIM:
Publish D dest_rd dump that closes ASK_D Q1-Q5. Lookup after P2 is SLOT1 `28'h010_0000`. SAMPLE `published_root=0` is TB vs `load_ack` NBA (Q2=B). Next RKB-04 is D XSim. No board. No 8/8 stamp.

RUN_PROVENANCE:
- Parent chat `31dc87bc` owner relay of D JSON (mailbox NOT_SENT)
- Watch hashed live files 2026-09-21T11:59+07
- `D_PUBLISHED_ROOT_Q1Q5.json` sha256 `f3185a77dd721750829cffc6f6c0ecbdb40d009f74e68958612c5554f4923043`
- `RKB02_OBS.json` sha256 `9ec76529e99a946adb749d15951d17f2dfd3c694e2484f9704d04030113321e3`
- `rkb02_xsim.log` sha256 `550c1fbb60661addaa5b5d601ce14018cf35e3c8319b3bceab0e96c9d60d05a2`
- `tb_rkb02_reloc.sv` sha256 `f07d28c460a4a8d09d564c6c0c599521348cd84d4a19708718095e7acedc3a5f`
- Prior OBS keep `fd896dab67b90fb6e8926d36b8febb04796fcf7170201e84f8cb622d6328229b`
- `PROGRAM.txt` sha256 `e920490d64d8e3292cd6d932f8849e203abc364167a3785a5e4520a8eda31d6d` SRAM `8bfd993d…`
- Watch did not re-run xelab/xsim. Watch did not program.

OBSERVATION:
FACT: Log DEST_RD phase=3 t=2545 ns matches Q1 table (`app_addr=0100000` `widx=1024` dest[0]=0 dest[1024]=SID+B hit=1).
FACT: SAMPLE P2 `pub=0000000 have_wr=1 pending=0100000`; DEST_RD phase=2/3 `pub_root=0100000 have_wr=0 widx=1024`.
FACT: SAMPLE P1 `root_valid=0`; SAMPLE P2 `root_valid=1`; P1 DEST_RD `pub_root=0000000 widx=0`.
FACT: `pack_runtime_dut.sv` has no `posting_walk` instance. `dest_root_cache.sv` `assign app_addr = pub_root`; `S_WAIT` uses `match_dir(app_rd_data, sid_r)`.
FACT: D JSON TB hash dropped one hex digit vs live file.
INFERENCE: Q2 B same-posedge `load_ack` NBA matches `dest_root_cache` `if (load_ack) pub_root <= pending_root` plus TB `load_mem` exit on `pack_quiescent`.

HYPOTHESES:
H-A SLOT0 published beat: REJECTED by dest_rd widx=1024 and poison dest[1024] miss.
H-B TB sample stale vs NBA: CONFIRMED as the lookup-address explanation.
H-C pending never latched SLOT1: REJECTED by WR_BEAT/SAMPLE/DEST_RD pending=0100000.
H-D still UNKNOWN: CLOSED.

HOW_TRACE:
Owner forbade guessing pub=0. Watch published ASK_D. D instrumented dest_rd_pulse and re-ran `run_rkb02_xsim.bat`. Watch hashed those artifacts and published without starting RKB-04.

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| Q1 dest_rd after poison dest[0] | FACT | log DEST_RD phase=3; OBS dest_rd_after_poison_p1 |
| Q2 pick B | FACT (sample vs dest_rd) + INFERENCE (NBA) | SAMPLE P2 vs DEST_RD; dest_root_cache.sv load_ack |
| Q3 SAMPLE root_valid | FACT | SAMPLE P1/P2 lines |
| Q4 one dest-read | FACT | dest_root_cache.sv; pack_runtime_dut no posting_walk |
| Q5 not M4/ASTRA | FACT | published_root=pub_root 28-bit UI addr |
| RKB 8/8 | NOT_RUN | no stamp |
| PACK_ABI_24_24_PASS | NO | owner KEEP |

SUCCESS_VS_FAILURE:
Success: GitHub records Q1-Q5 closed without guessing and without 8/8. Failure would be treating SAMPLE pub=0 as SLOT0 SoT, or starting RKB-04/board in this watch.

FIRST_DIVERGENCE:
TB `published_root` at `pack_quiescent` vs `pub_root` after `load_ack` NBA.

DECISIVE_TEST:
Already run by D: dest_rd_pulse $display. Watch verified hash + log grep, did not re-xelab.

ROOT_CAUSE_OR_UNKNOWN:
Lookup after P2 is SLOT1. SAMPLE pub=0 is TB sampling. Remaining UNKNOWN: UART dest export / board published_root (NOT_RUN).

REUSABLE_DECISION_PROCEDURE:
1. Do not treat `published_root` sampled at `pack_quiescent` as the lookup address.
2. Use dest_rd-cycle `app_addr`/`widx`.
3. Relocation SoT remains double-poison dest beats.
4. This `published_root` is not QueryRecord/StructuredResult/ASTRA.

STRUCTURAL_GUARD:
Do not AND TB `pub==SLOT1` at `load_mem` return. Do not stamp 8/8 / PACK_ABI / PROGRAM_PASS. Do not start RKB-04 from the watch. Do not rewrite shared-lessons history.

BLAST_RADIUS:
Native_SymAI docs + evidence copies. C RTL / gold.py / FE256 freeze / bitstream untouched. Watch did not xelab or program.

VERDICT_BY_LAYER:
PASS_XSIM isolated dest_rd dump (D). Watch publish only. NOT_RUN UART dest, RKB-04, 8/8. NO PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS.

LESSON_TO_SHARE: PUBLISHED-ROOT-SAMPLE-RACES-LOAD-ACK-NBA-20260921T045200Z (already written by D; watch appends to GitHub copy only)

NEXT_DECISIVE_EXPERIMENT:
AGENT_D RKB-04 dest-backed Posting+EdgeRecord XSim. Watch does not implement. PROGRAM=NO.

OWNER_AND_STOP_CONDITION:
Owner: no board for this step. Watch stop for RKB-04 implementation. No 8/8 self-stamp.
