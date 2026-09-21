# Unique CT1 identity `8bfd993d…` — INTEGRATED PASS_XSIM then owner PROGRAMMED + UART smoke (2026-09-21)

This watch did **not** program Arty and did **not** resume parent Vivado. Unique dir `build_ct1/` (does not overwrite `build_u33obs_query` / `8fc14f25…` **files**). **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **CT1_BOARD_PASS=NO.** **TIMING_PASS=NO.** **MIG_PASS=NO.** Bit binary not pushed.

Jsonl was idle at 5603516; COMPLETE is on disk (BIT_OK + PROGRAM.txt + UART json).

## Identity

| Role | SHA256 |
|---|---|
| Unique CT1 bit (file = SRAM after this hop) | `8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c` |
| Prior query silicon (file kept) | `8fc14f25…` `PROGRAM.txt` still `1ab55cbd…` under `U33OBS_QUERY_OWNER_PROGRAM/` |
| `CT1_INT_OBS.json` | `a326139363d6bd27e953a9095201f6174b842e28de5901a197fcacf3b7594195` |
| `ct1_int_xsim.log` | `9a5fb867c59ef008093b3b5c3499daa817fbe4ad51ecab09bf0781f7cabdac1e` |
| CT1 `PROGRAM.txt` | `e920490d64d8e3292cd6d932f8849e203abc364167a3785a5e4520a8eda31d6d` |
| `UART_CT1_BOARD.json` | `b3a8f053d445e9691d16c1924378daa88b2cd55b1e63a1f7e4c7e31846edcfb1` |

BUILD.txt: STATUS=BIT_OK WNS=0.556 READY_TO_PROGRAM=NO PROGRAM=NO STOP_BEFORE_PROGRAM=YES then parent nạp this SHA. Route WHS +0.022 LUT 11275 FF 10146 RAMB18=1 DSP 8. **TIMING_PASS=NO.**

## INTEGRATED PASS_XSIM (not board)

Watch grep: `CT1-01..05 INTEGRATED PASS_XSIM` `$finish` **6047135 ns**. `mig_ui_bram` stand-in, **not** behavioral `mig0`. `dir_a.mem` not on answer path (parent claim; watch did not re-xelab). T1 occupancy **NOT_PROVEN**. Isolated DUT json `372ea910…` unchanged.

## PROGRAMMED (parent) — silicon `8bfd993d…`

`results/CT1_OWNER_PROGRAM_20260921/PROGRAM.txt` STATUS=PROGRAMMED SHA MATCH JTAG `210319BE776EA`. Labtools **End of startup HIGH**. Line `uart_r2_ct1_PROGRAM_OK … PROGRAM_PASS=NO`. **PROGRAM_PASS=NO.** Watch did not nạp. Does not overwrite query unique dirs.

## UART smoke (CANDIDATE, not CT1_BOARD_PASS)

COM12. Tokens observed: CT1-01 QUERY `03000051` miss; pack GOLD `010000a5`; CT1-02 QUERY `03010051` hit; CLEAR `c1ea50a5`; CT1-03 `03000051` miss; GOLD; CT1-04 `03010051` hit. **CT1-05 NOT_RUN** (`FLUSH_TIED_OFF`). CLASS `UART_BOARD_SMOKE_CANDIDATE`. Do not copy isolated XSim as board 5/5.

## Claim ceiling

```text
PASS_XSIM integrated CT1-01..05 = YES (this log)
UART_BOARD_SMOKE_CANDIDATE      = YES (01..04 tokens)
CT1_BOARD_PASS                  = NO
PROGRAM_PASS                    = NO
PACK_ABI_24_24_PASS             = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
```
