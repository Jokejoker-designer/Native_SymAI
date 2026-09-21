# UART_R2_CT1 unique identity — STOP BEFORE PROGRAM

Owner 2026-09-21 10:46+07: **board YES** for this quoted identity only:

`8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c`

Do **not** nạp `8fc14f25…`. `PROGRAM_PASS=NO`. `PACK_ABI_24_24_PASS=NO`. `CT1_BOARD_PASS=NO`.

## Identity

- CLASS: `uart_r2_ct1_CANDIDATE`
- Sources: `D:/FPGA/arty_d/UART_R2/ct1/`
- Build: `D:/FPGA/arty_d/UART_R2/build_ct1/`
- Bit name: `uart_r2_ct1_candidate.bit`
- Does **not** overwrite `build_u33obs_query` / live `8fc14f25…`

## Invariants

- T2/dest = source of truth
- T1 = cache only; host must not poke T1
- `active_generation` UNSET fail-closed (query dest_rd=0)
- `dir_a.mem` / `post_a.mem` / `exact_directory` / `query_result_bind` are **not** on the answer path
- FE256 / ASTRA / Q* / SPEAR / FEM RTL files untouched
- `pack_abi24_gold.py` untouched
- C RTL untouched
- `PACK_ABI_24_24_PASS=NO`
- `RUNTIME_KNOWLEDGE_BINDING_8_8=NOT_RUN`
- T1 occupancy (`t1_valid`) is **NOT_PROVEN** in this identity (query dest-reads T2)

## XSim claim ceiling

`PASS_XSIM` on `arty_a7_r2_top_m4_mig_candidate` with `CT1_XSIM` (`mig_ui_bram` stand-in,
ui_clk=clk100, UART 1e6). **Not** behavioral `mig0`. **Not** board. **Not** CT1_BOARD_PASS.

Integrated CT1-01..05 JSON: `D:/FPGA/arty_d/UART_R2/ct1/xsim/CT1_INT_OBS.json`

## Bitstream claim ceiling

If BIT_OK: candidate identity only. WNS MET is not TIMING_PASS. No PROGRAM_PASS.

## Independent audit (before any nạp)

Confirm: no host poke T1, no fixture fallback, no bypass around `active_generation`,
no `dir_a.mem` in synth files, bit SHA matches the file owner authorizes.
