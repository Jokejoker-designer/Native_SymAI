# Unique CT1 `8bfd993d…` — RKB UART + leftover/V04 + Pack24 RUN1 (2026-09-21)

This watch did **not** program Arty and did **not** resume parent Vivado. Silicon unchanged vs tick7 `PROGRAM.txt`. Unique vs query dir `8fc14f25…` **files** kept. **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **CT1_BOARD_PASS=NO.** **RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.** Bit binary not pushed.

Parent jsonl grew 5603516 → **5852278** @ 2026-09-21T04:15:52Z. COMPLETE is on disk.

## Identity (unchanged SRAM)

| Role | SHA256 |
|---|---|
| CT1 bit / SRAM | `8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c` |
| CT1 `PROGRAM.txt` (file hash) | `e920490d64d8e3292cd6d932f8849e203abc364167a3785a5e4520a8eda31d6d` |
| Query `PROGRAM.txt` file kept | `1ab55cbdfb957d7e5b1210916d23a6f2713dece9fcad053160c60669e1745b26` (`8fc14f25…`) |
| `UART_CT1_BOARD.json` (prior smoke) | `b3a8f053d445e9691d16c1924378daa88b2cd55b1e63a1f7e4c7e31846edcfb1` |
| `D_RKB.json` | `c0f7e9194c586c5488b06501fc17cae3d05218f8f912046f1897ee838b15c4f8` |
| `UART_CT1_RKB_TAP.json` | `3e7abe6dfe2d7e0adb9da53e60dd42cf04849f112b94b6a69711bc573e7be70b` |
| `UART_CT1_RKB_NO_CLEAR.json` | `43ce2b97c18f8bec5f30e93d71f0aa7d7ab6f02e6b43592f3e887a7c25bbaff8` |
| `CT1_HOPS_LEFTOVER.json` | `f9c93711f5efa1e9fcaf4f67e1d6f88dd78c4bbfd27150fe8fc5dc3438e9404b` |
| `CT1_HOPS_V04x4.json` | `4e41bf074a1dc7d3793b998ee7721e442101ab8cb0d68ca69ddc61d7d4079438` |
| `D_PACK_ABI_GAP.json` | `70bcd8e38007dea73438832f0a7a8008ce279986e25a81cf28ffe46ad12fa607` |
| `PACK24_CT1_RUN1.json` | `2c27fd4531f235d0c1bb6d44b39b6f33e039b0924ca9a6f7348e139ee915f98a` |
| `PACK24_CT1_RUN1_DUT.jsonl` | `150b716f70fe3f0c29e577f9a2445bf7bc9e20852b305bb233220059717b1c18` |
| B `pack_abi24_gold.py` (unmodified) | `2986c354acac0f09af5ec678adbeeeb905b8b557d94158fa594a80d85c8d67f3` |

Lease HELD AGENT_D until **12:00 +07**. Watch did not nạp.

## RKB UART (CANDIDATE, not 8/8)

COM12 on live `8bfd993d…`. No reprogram.

- RKB-01: GOLD `010000a5` + QUERY `03010051` + TAP after=`000000b1`
- RKB-03 no-CLEAR: A2B then A2C GOLD+hit; TAP `b1→c1` flip=1; UART hit bit **same** `03010051` for B and C (`uart_neighbor_payload=NOT_ON_WIRE_HIT_BIT_ONLY`)
- RKB-07: CLEAR ACK then QUERY `03000051` (CLEAR ≠ FPGA `rst`)
- RKB-02/04/05/06: **NOT_RUN**. CT1-05 flush still tied off. Dest dump **NOT_RUN**. T1 occupancy **NOT_PROVEN**.

## Leftover + V-04×4 (before Pack24)

- Leftover MAG n=40 CLASS_A `p1=BEGIN` TAP `b1→c1` `leftover_tap_not_this_pack=true` (hw TAP from prior hop, not this extra-BEGIN COMMIT)
- V-04×4: GOLD n=4 mag=0 mute=0. Not Pack24.

## Pack24 RUN1 on CT1 (11:14 +07)

`stop=PACK24_RUN1_DONE` (not sticky mute). Recs: **6 GOLD / 17 NAK / 1 MAG**. GOLD cases: V-01..V-04, R-04, G-01. MAG: **PA24-A-02** word `0200015a` n=40 `tap_not_this_pack=true` CLASS_P1_OTHER p1=`4e414931`. Do not invent `generation_flipped=0` on rejects.

Watch re-ran unmodified B `--compare` on `PACK24_CT1_RUN1_DUT.jsonl`:

```text
python pack_abi24_gold.py --compare PACK24_CT1_RUN1_DUT.jsonl
→ compare 2/24 match, 22 fail  rc=1
```

18 rejects fail `generation_flipped got None expected 0`. Extra fails: R-04 GOLD missing `query_status=6`/`query_reason=80`; G-04 NAK missing those plus omit-vs-0. Freeze DUT remains 6/24. D `D_PACK_ABI_GAP.json` `70bcd8e3…` (11:22) splits GOAL_A R1 24/24 CLOSED vs GOAL_B historical mismatch; RUN1 is `DONE_NOT_RESCUE`. **PACK_ABI_24_24_PASS=NO.** gold.py not edited.

## Claim ceiling

```text
UART_BOARD_SMOKE_CANDIDATE      = YES (prior 01..04 + RKB TAP hops)
RKB UART 01/03/07               = CANDIDATE
V04x4 GOLD n=4                  = YES (not Pack ABI)
PACK24_CT1_RUN1                 = 6 GOLD / 17 NAK / 1 MAG DONE
gold.py --compare this DUT      = 2/24 FAIL_COMPARE
PACK_ABI_24_24_PASS             = NO
PROGRAM_PASS                    = NO
CT1_BOARD_PASS                  = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
TIMING_PASS                     = NO
MIG_PASS                        = NO
BOARD_PASS                      = NOT_EVIDENCED
```
