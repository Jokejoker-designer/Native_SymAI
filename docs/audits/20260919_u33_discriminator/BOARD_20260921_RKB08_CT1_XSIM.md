# RKB-08 CLASS A + first CT1 candidate FAIL_XSIM (2026-09-21)

This watch did **not** program Arty and did **not** resume parent xelab. Independently hashed parent COMPLETE XSim artifacts. **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.** Silicon still `8fc14f25…` (`PROGRAM.txt` `1ab55cbd…`). `U33OBS_DEBUG=CLOSED`.

## RKB-08 — FAIL_CURRENT_ARCHITECTURE (COMPLETE)

`$finish` 6455 ns. CLASS **A**. Query sid `00010100` hit fixture `dir_a.mem` at boot / GOLD / reset (`dest_rd=0`). Poison rom[0] → hit=0, still `dest_rd=0`.

```text
DIRECTORY_INSTALL_MISSING_AFTER_PACK_COMMIT = CAUSALLY CONFIRMED IN XSIM
```

| Artifact | SHA256 |
|---|---|
| `RKB08_OBS.json` | `18456f1649cabb98f13be02a89e5d8264c09051035a3c515a310cd16fa852c8e` |
| `xsim.log` (RKB-08) | `4a7c22203c62e3107b6036aa6c33d601a24d2be43daa35a60c4e1f4ac6ddab7d` |
| `tb_rkb08_gen_lifecycle.sv` | `6f6f6b2f9c70ba5d3b78e3c0cc19e718e3a74f49c3b2ad0159695ea56299ebbb` |

Stop: no `post_a.mem` poison. No RKB-01..07. No board.

## First CT1 DUT — FAIL_XSIM (COMPLETE observation, not CT1_PASS)

`$finish` 4885 ns. `CT1-01=1` `CT1-03=1` `CT1-02=0` `CT1-04=0` `CT1-05=0`. Log line `CT1-01..05 FAIL_XSIM`. Not the locked product RTL. Host must not write T1 after Pack.

| Artifact | SHA256 |
|---|---|
| `CT1_OBS.json` | `5f875a49fe0f11ae87e991747b4d2e0e4e3faa33f80dfbd713dd04931a783636` |
| `ct1_xsim.log` | `9ac1161007db87a6ae0364aef713764344dfcae4b19ece0d256f36d1580995bd` |

## Claim ceiling

```text
PACK_ABI_24_24_PASS                    = NO
PROGRAM_PASS                           = NO
BOARD_PASS                             = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS     = NOT_RUN
READBACK_ACTIVE_GENERATION_PASS        = NOT_RUN
CT1_PASS                               = NO
```
