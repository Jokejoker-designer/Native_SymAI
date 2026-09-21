# Isolated CT1-01..05 PASS_XSIM after dest-lane SID decode — no board program (2026-09-21)

This watch did **not** program Arty and did **not** resume parent xelab. Independently hashed live `CT1_OBS.json` and `ct1_xsim.log`. **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **CT1_BOARD_PASS=NO.** **RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.**

Owner `PROGRAM=YES` 09:52+07 authorizes a unique CT1 bit **when it exists**. Parent did **not** nạp. Live SRAM still `8fc14f25…` (`PROGRAM.txt` `1ab55cbd…`). No CT1 bitstream on disk.

## Keep first FAIL vs later PASS — do not mix

| Role | Path | SHA256 |
|---|---|---|
| First DUT FAIL_XSIM (tick 5) | `results/.../CT1_OBS.json` | `5f875a49fe0f11ae87e991747b4d2e0e4e3faa33f80dfbd713dd04931a783636` |
| Same FAIL log | `ct1_xsim.log` | `9ac1161007db87a6ae0364aef713764344dfcae4b19ece0d256f36d1580995bd` |
| Lane-scan PASS_XSIM | `CT1_OBS_PASS_XSIM.json` | `372ea910653cf608024833c20b0c2b8ce190554c00cd790f265bab7721326a3c` |
| PASS log | `ct1_xsim_PASS.log` | `3d07636590db90d12a32d1661dc261b56283f4e45c9a8c8e51a15fd8dae6f4a3` |
| `dest_root_cache.sv` | CANDIDATE XSim | `bc2b7cd2d4e15bd3532202fb1ce1cc059f6c6b068ca410fcfb9de0d7c0f62631` |
| Grant file | `OWNER_PROGRAM_YES_20260921.md` | `e0f3aca39d50d602b0750c8c31bee9407d41e99e0f763c39c7bb6ecf080844e0` |

Watch grep of PASS log: `CT1-01..05 PASS_XSIM` then `$finish` 4885 ns. Isolated `mig_ui_bram`, not `mig0`, not board.

CT1-02 dest beat FACT: `[31:0]=page CRC`, SID `[63:32]`. First FAIL compared lane0 as SID. T1 occupancy stayed 0; query dest-reads T2. Host did not write T1.

## Claim ceiling

```text
PASS_XSIM isolated CT1-01..05 = YES (this log)
CT1_PASS / CT1_BOARD_PASS     = NO
PROGRAM_PASS                  = NO
BOARD_PASS                    = NO
PACK_ABI_24_24_PASS           = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
```
