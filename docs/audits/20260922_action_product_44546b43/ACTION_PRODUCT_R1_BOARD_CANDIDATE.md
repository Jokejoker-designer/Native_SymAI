# Action productization board candidate

LANGUAGE=EN
SHA256=44546b432ddc6137954689b0875bdaa161768f2217d79cf84a1f3366fe637d17
JTAG=210319BE776EA
EOS=HIGH
PROGRAM.DONE=NA
UART=COM12

```text
ACTION_PRODUCTIZATION_BOARD_CANDIDATE=SUPPORTED
```

Re-hash matched before `program_hw_devices`. Labtools `End of startup status: HIGH`.

JSON `D:/FPGA/arty_d/UART_R2/results/ACTION_PRODUCT_R1_20260922/UART_ACTION_PRODUCT_R1.json`
sha256 `f6b50b7dc133b02f8d80c404013d4b914afaaf7b8a97a8130e0e6785a9f5da52`

FREC restored life 3, failure_total 2, compacted 1, recover 2.
Lookup id on every arm is `0xC1`.

| Arm | proposal | verdict | command_valid | command_id | command primitive |
|---|---|---|---|---|---|
| PRE | 0 | B0 | 1 | `C001` | 0 |
| OFF1 | 0 | B0 | 1 | `C002` | 0 |
| ON1 | 1 | B0 | 1 | `C003` | 1 |
| OFF2 | 0 | B0 | 1 | `C004` | 0 |
| VETO | 1 | B2 | 0 | none | not issued |

`435bdc88` was not rebuilt.

Not claimed: FEM_PERSIST_PASS PROGRAM_PASS BOARD_PASS ASTRA_PASS TIMING_PASS FE256_PASS PACK_ABI_24_24_PASS.

FREEZE_UTC: 2026-09-22T031400Z
RERUN: FORBIDDEN
See FREEZE_44546b43.md. Do not split further ActionIntent, lookup, or PrimitiveCommand tests unless a new contradiction appears.
