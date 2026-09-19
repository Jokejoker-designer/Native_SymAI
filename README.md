# Native_SymAI

Public snapshot of Native AI developmental hardware on Digilent Arty A7-100T
(`xc7a100tcsg324-1`).

**Start here if you want the unsolved silicon question:**

- [`docs/STATUS_20260919.md`](docs/STATUS_20260919.md) — **current public snapshot**: NOT PASS / SOLVED / UNKNOWN / OPEN issues (2026-09-19)
- [`docs/CHAT_31dc87bc_AUDIT_FEED.md`](docs/CHAT_31dc87bc_AUDIT_FEED.md) — live feed from the working chat, published for audit
- [GitHub Issues](https://github.com/Jokejoker-designer/Native_SymAI/issues) — same taxonomy as issues
- [`results/arty_d/AUDIT_SNAPSHOT_20260919.md`](results/arty_d/AUDIT_SNAPSHOT_20260919.md) — UART_R2 + OBS01 source hashes for audit
- [`docs/OPEN_CAUSES_STILL_UNKNOWN.md`](docs/OPEN_CAUSES_STILL_UNKNOWN.md) — H9–H20 retries, what was REJECTED, what is still UNKNOWN
- [`docs/IDENTITY_TABLE.md`](docs/IDENTITY_TABLE.md) — bit SHA256; H ≠ H-ILA-A ≠ H_OBS
- [`results/arty_d/first_divergence_01/STATUS.md`](results/arty_d/first_divergence_01/STATUS.md) — H19-era D task log

`COMMON_ROOT` of Pack board failures on identity H (`cf62102f…`) is **UNKNOWN**. Extra-byte SOURCE (FTDI/PHY/FPGA) is **UNKNOWN**. CLASS B mute is **UNKNOWN**. This is not `BOARD_PASS` / `PACK_ABI_24_24_PASS` / `PROGRAM_PASS`.

This repository is **new**. It does not push to QUAN-NATIVE-AI, native-ai-full-evidence, or other existing remotes.

## Layout

| Path | Contents |
|---|---|
| `docs/` | Open-cause catalog and identity table |
| `CANON_BLUEPRINT/` | Canon, AGENT_C+D RTL, verification, Tcl, H20 XSim JSON |
| `agent_c_rtl/` | C-owned synthesizable RTL (hash-locked) |
| `results/arty_d/` | Board/XSim evidence, bits, DCPs, UART jsonl (no Vivado project cache) |

Key evidence folders under `results/arty_d/`:

| Folder | Why it exists |
|---|---|
| `first_divergence_01/` | Named H9–H19 board/XSim retries |
| `H_CLASSIFY_H19_H20/` | Identity H: internals NOT_ON_WIRE |
| `H_ILA_A/` | BASIC-blocked ILA; dump on a **different** P&R |
| `H_OBS/` | UART-dump observe identity; **not** H |
| `m4_mig_clear/` | Identity H bit + CLEAR campaign jsonl (7/11 then mute) |
| `pack_abi24_mig_dut/` | 24/24 XSim dest-complete through `mig_ui_bram` only |
| `hold_r2/` | FE256 freeze DCPs (reference, do not overwrite) |
| `UART_R2/` | Isolated UART overlays U1–U32 (source + U31/U32 bits). Not identity H. |
| `D_DEST_LIFECYCLE_OBS_01/` | Dest lifecycle observer; BRAM CLEAN; MIG0 dest-AND CLEAR1 BUSY; PACKAGE-qsc A/B CLEAR1 ACK (V-04 incomplete) |

## AGENT_C RTL (SHA256)

- `qstar_select.v` `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240`
- `spear_rank.v` `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293`
- `fem_lifecycle.v` `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed`

## Claim ceiling

Not BOARD_PASS, PROGRAM_PASS, PACK_ABI_24_24_PASS, TIMING_PASS, MIG_PASS,
ASTRA_PASS, FE256_PASS, or FINAL_PASS.

Do not copy H_OBS `OTHER_ALIGNED_BEGIN` onto identity H.

Xilinx MIG IP is not vendored.

## License

No license file is attached. Default copyright applies unless the owner adds one.
