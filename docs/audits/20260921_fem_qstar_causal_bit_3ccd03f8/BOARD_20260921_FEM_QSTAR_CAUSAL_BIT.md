# Unique FEM Q* causal bit 3ccd03f8 BIT_OK (2026-09-22)

Watch did **not** program. No `.bit` / no `.dcp` in git. Independent Get-FileHash of `uart_r2_fem_qstar_causal_candidate.bit` equals `3ccd03f80677607acfba6e45aab1fe05d6a8a99055224a244dbc3b7de275229d`. Unique vs persist `1db38691…`, dest TAP `ead830ae…`, RKB-edge `daaca9c1…`, CT1 `8bfd993d…`.

Program + UART evidence is in a **separate** unique dir `docs/audits/20260922_fem_qstar_causal_uart_3ccd03f8/`. This directory is BIT_OK / timing only.

LANGUAGE=EN. Not a product PASS stamp.

```text
CLASS = FEM_QSTAR_CAUSAL_UNIQUE
STATUS = BIT_OK
FEM_PERSIST_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
TIMING_PASS = NO
MIG_PASS = NO
PACK_ABI_24_24_PASS = NO
```

## Independent hashes

| Artifact | SHA256 |
|---|---|
| Q* causal `.bit` (disk, not committed) | `3ccd03f80677607acfba6e45aab1fe05d6a8a99055224a244dbc3b7de275229d` |
| `post_route.dcp` (disk, not committed) | `5dd47dcd544ec5b808c92587c87a35944ca8d02083de7c70834dd81cfd7c4661` |
| persist `.bit` disk keep | `1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668` |
| `BUILD.txt` | `4bf5ffd506e339eb18e5ff5c7b2f004e6bdf203d67664cc0f1671193c56420f7` |
| `BIT_SHA256.txt` | `e08fddcc8d6cf0124add09c4a312932b57bd8e0d0a8640b785b26d3763668358` |
| `TIMING_SUMMARY.txt` | `d0619943967c640c249cc988458fe8d4859ca364e03ff17f8eb15ca7789523cc` |
| `check_timing.rpt` | `e39a970c099d984098e02734ffd00e7b5cb1b7c288d046d4efd813183e78eb3a` |
| C `fem_lifecycle.v` | `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` |
| C `qstar_select.v` | `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240` |
| C `spear_rank.v` | `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293` |

`BIT_SHA256.txt` body matches independent bit hash.

## FACT — unique BIT_OK (not TIMING_PASS)

Unique out `D:/FPGA/arty_d/UART_R2/build_fem_qstar_causal`. Design Timing Summary in `timing_route.rpt` WNS=+0.468 WHS=+0.010 TNS=0 THS=0. Intra-clock `sys_clk_pin` hold worst slack +0.019. `check_timing.rpt` loops=0. Route util LUT=12266 FF=12982 Block RAM Tile=0.5 DSP=8. WNS path `u_rx/w_data_reg[17]/C` → `u_dump/u1_reg[14]/CE`. `TIMING_PASS=NO`.
