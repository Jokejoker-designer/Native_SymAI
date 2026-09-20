# GOAL PACK_ABI_24_24_PASS — gates vs live evidence

Objective: `PACK_ABI_24_24_PASS=PASS` per [§31.2] / [§32]. Agent does **not** self-stamp. Owner/user final-stamp.

Gold `--selfcheck` 2026-09-20T17:01+07: **24/24** (generator only).  
`pack_abi24_gold.py` sha256 `2986c354acac0f09af5ec678adbeeeb905b8b557d94158fa594a80d85c8d67f3`  
`pack_abi24_expect.tsv` sha256 `9ec497042feb729325124a3170aedc3b15b2feb38ec340252061126d023d064c` (Native_SymAI = PACKAGE TSV).

## What the stamp is

DUT matches all 24 preregistered cases via `python pack_abi24_gold.py --compare DUT.jsonl`.

JSONL fields: `case_id/outcome/reason/ack/reject/generation_flipped` + `query_status/query_reason` for R-04/G-04.

Not: `--selfcheck`, 24× V-04 GOLD, UART token vs TSV `expect` word, `PACK_ABI24_XSIM_PASS`, `PACK_ABI24_MIG_DUT_XSIM_PASS`, PROGRAM HIGH.

§32.4: this stamp is still not `BOARD_PASS`. D does not self-stamp either.

## Requirement matrix

| # | Requirement | Live evidence | Status |
|---|---|---|---|
| 1 | Frozen gold 24 IDs V/S/A/C/R/G | TSV 24 rows; selfcheck 24/24 | MET generator |
| 2 | B TB unmodified | MIG DUT JSON `b_tb_modified=false` | MET XSim era |
| 3 | XSim 24/24 isolated pack_mig_bind dest-complete | `PACK_ABI24_MIG_DUT_XSIM_PASS` 24/24 21965 ns dest=`mig_ui_bram` not mig0 | PASS_XSIM only |
| 4 | Post-PROGRAM identity recorded | U33 `ff399e0b…` PROGRAMMED_CANDIDATE_ONLY 16:47+07 DONE=1 | Not PROGRAM_PASS |
| 5 | Board 24 cases dest-complete through `pack_mig_bind` | Historical U33 MAG `0200015a` on V-04 repeat; no PACK24_RUN1.jsonl this identity after CONTROL2 | FAIL_BOARD / MISSING |
| 6 | Honest DUT.jsonl `--compare` | Campaign jsonl is `got` UART word, **not** B fields. UART GOLD has no `generation_flipped`. | NOT MET |
| 7 | R-04/G-04 query_status | U33 `uart_fe256_host.in_valid=1'b0`; `tb_steer=0` | BLOCKED on frozen U33 |
| 8 | run1/run2/fresh | Not run on post-CONTROL2 U33 | MISSING |
| 9 | MUTE/MAG RCA closed (owner 4-step) before product fix | MUTE dummy-open isolated once; DTR/close follow-up all GOLD (not deterministic). MAG OPEN. Capture identity not programmed. | OPEN |
| 10 | Overlay H/U33/freeze | Untouched | HOLD |

## First divergence vs “24 UART GOLD”

Frozen U33 UART status is `{01,00,reason,A5}` / `{02,00,reason,5A}`. That can score load ACK/NAK **reason**, not `generation_flipped`, not R-04/G-04 query.

Copying TSV `flip` into DUT.jsonl would false-PASS `--compare`. Forbidden.

Owner 2026-09-20 lock on Ý 5–6: `generation_flipped=true` only from a Pack-owner COMMIT transition:

```text
commit_event == 1
AND generation_after != generation_before
AND same_capture_epoch
AND capture_valid == 1
```

Two snapshots that differ across CLEAR/reset/epoch are not a flip. Absent field ⇒ `compare_ready=false`.

Therefore board PACK_ABI needs either (a) observe dump of `load_ack/load_reject/reason_code/active_generation` plus a query path for R-04/G-04, or (b) a **new** identity that wires query UART — not overlay U33.

## Path (owner 4-step kept)

1. MUTE/MAG: capture identity YES (U33 reprogram grant does **not** include this).  
2. First-divergent hop → narrow fix on **new** SHA if RTL.  
3. Host without dummy-open (campaign currently dummy-open at `u33_campaign.py:137`). Do not edit frozen campaign in place.  
4. Emit honest DUT.jsonl → B `--compare` 24/24.  
5. run1/run2/fresh. Owner stamps PACK_ABI_24_24_PASS.

`PACK_ABI_24_24_PASS=NO` now.
