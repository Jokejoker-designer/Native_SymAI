# M1 pack_loader first-slice EVIDENCE

XSim ≠ board. PROGRAM=NO. Agent D cannot stamp BOARD_PASS or TIMING_PASS.

## Commands and results

1. `python python/m1/pack_vectors.py` — wrote 5 `.mem` files (CANDIDATE gold).
2. Vivado 2026.1 `xvlog` / `xelab` / `xsim` via `vivado/tcl/run_m1.ps1` (`call` + `-tclbatch`).
   - Result: `M1_XSIM_SMOKE PASS 5 vectors` at 2026-09-16 13:32:35 +07, sim time 9565 ns.
   - Log: `vivado/m1_pack_loader/xsim_smoke.log`
3. `vivado -mode batch -source vivado/tcl/02_ooc_synth_pack_loader.tcl`
   - Reports: `vivado/m1_pack_loader/ooc/{utilization,timing_summary,timing_paths,ram}.rpt`

## D-01 storage patch (buf_w → BRAM)

FACT: `page_ram[64x32]` inferred as RAMB18E1 (`page_ram_reg` in `ram.rpt`). Header fields stay FFs (multi-port decode). No async reset on RAM.

| Metric | Before D-01 | After D-01 |
|---|---:|---|
| LUT | 1427 | 644 |
| FF | 2891 | 652 |
| BRAM tiles | 0 | 0.5 (1× RAMB18) |
| DSP | 0 | 0 |
| WNS @ 10 ns | -1.811 | -1.663 |

Critical path after D-01: `rx_words` → CRC 4-byte combo (14 levels, 33% logic / 67% route). Buffer mux is no longer the path.

## D-02 CRC byte-serial (same 5 vectors)

Class: logic-depth of `crc_word` (4× `crc_byte` combo into `crc_reg`). Not random retiming. Constraint `HD.CLK_SRC` still unset — OOC clock delay/skew still incomplete.

FACT after D-02 + handshake-gated S_RX:

| Metric | After D-02 |
|---|---:|
| LUT | 552 |
| FF | 678 |
| BRAM tiles | 0.5 |
| RAMB18 | 1 |
| DSP | 0 |
| WNS | **+2.004 ns** (OOC constraints reported MET) |
| TNS | 0.000 |
| WHS | +0.260 ns |
| Path | `rx_words_reg[1]` → `u_crc/acc_reg[19]` (`crc_byte`, 10 levels, 3.382 ns logic / 4.574 ns route) |

Claim ceiling: **MET_UNPLACED_OOC**. Not post-route. Not TIMING_PASS. `HD.CLK_SRC` still unset.

## Integrity

This slice does not implement FPGA SHA-256. SHA fields are stored/compared as identities only.

## Vivado MCP

Cursor session has no Vivado MCP tool namespace. OOC used Tcl batch.
