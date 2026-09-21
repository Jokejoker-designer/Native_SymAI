# Isolated pack_edge_dut RKB-04/05/06/08 XSim (2026-09-21 12:13–13:01+07)

This watch did **not** program Arty and did **not** implement the DUT. `PROGRAM.txt` still `e920490d…` / SRAM `8bfd993d…`. D: board **unplugged**. Mailbox **NOT_SENT**. **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **CT1_BOARD_PASS=NO.** **RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.**

These runs are isolated `pack_edge_dut` + `dest_posting_edge_walk` + `mig_ui_bram`. Not `mig0`. Not the CT1 SID→fwd bit. Historical `8fc14f25` RKB-08 CLASS A JSON `18456f16…` is **UNCHANGED** (kept as `RKB08_OBS.json`).

## Hashes (this-turn Get-FileHash)

| Artifact | SHA256 |
|---|---|
| `RKB04_OBS.json` | `916a9d90d70d11ccda488a5303a94e6fe19357300ef8fd129cc4e0608d8377c5` |
| `rkb04_xsim.log` PASS 3895 ns | `6ee9e680abcc5a3f7b0d3d838068d2e8fdcf12ede8968e8c0795e4decdaeb963` |
| `rkb04_xsim_39720.backup.log` FAIL keep | `1f24237ea88ccaf47454a7e882313eed16d3f16a63b02dc0d77ec42db1ae40ae` |
| `RKB05_OBS.json` | `cdd8dc7e6856fbfe402feec9f84aa1deadae9fc7d03594d2c62a6e0f8be5e7ac` |
| `rkb05_xsim.log` PASS 7015 ns | `383fd72d8078098072316ae915700ccd4077604c8aafd25da7f53b82f96539bf` |
| `rkb05_xsim_21056.backup.log` FAIL keep | `e21aacdbcbb9fcecfd9c9ea0a7f29975ad416ee70e9bec77cbb296d5571ab241` |
| `RKB06_OBS.json` | `329f77f753672e7d3949d53380315dfea0f334c58bbcf2d6dff3edcb0bf0b454` |
| `rkb06_xsim.log` | `e8093eef378028aa71c3109f0b9a5a148e1017736e37a156ebaa016d1ca66f07` |
| `tb_rkb06_parity.sv` | `37f378c9ab59b80ae7d8daca4f3caa26f9e7ca4628086d152590c1b0099c0136` |
| `RKB08_ARCH_OBS.json` | `65fb25bae8993d456a1d31e648a047332c814cb18d493d635cca0e75f4fdb817` |
| `RKB08D_SRC.json` | `170260ec8bd64c943c0d8985276bddca88112107a1e7fbec371562efc67a1c12` |
| `rkb08_arch_xsim.log` | `373745b2679adb833d5b95913676ea8cfa64b974034bc8f0d245b4f1a56293a2` |
| `tb_rkb08_arch.sv` | `945423305b0b9ec9f8ec6505a60be1d13822a207c7260bb6e998b2d89d32e5b2` |
| `RKB08_OBS.json` CLASS A keep | `18456f1649cabb98f13be02a89e5d8264c09051035a3c515a310cd16fa852c8e` |
| live `dest_posting_edge_walk.sv` (RKB-06 era) | `322e476d7f947e72f1091101c4aa54ec1f9578818f91782445dd895188045d27` |
| live `pack_edge_dut.sv` | `bad9c50016d22ae5a9b0537fbf4deedc1f10623aba518fd536b440db3ebec5d9` |
| live `dest_root_cache.sv` | `62ba5f1c08be7c698f4308673360d30df44892b9bd6b0b8c9f3613f80791d76b` |
| live `tb_rkb05_edge.sv` | `b3cd1b805f9d50677730ccc58b8d6f45ca9acb2780737d907d13a1baa67c5db1` |
| `D_RKB.json` | `897be8d1c98a6c3f1b7cf07ecf1ba3452e70b3691c9cea78289c5a33899fd272` |
| CT1 `PROGRAM.txt` | `e920490d64d8e3292cd6d932f8849e203abc364167a3785a5e4520a8eda31d6d` |

FACT: D V1 `20260921T054013Z` listed `tb_rkb05_edge.sv` `0d208803…`. Live file is `b3cd1b80…`. PASS OBS/log hashes still match that V1. Walk hash at RKB-04 V1 was `3556f812…`; live walk is the RKB-06 SHA. Do not treat live RTL as the RKB-04 snapshot.

## RKB-04 PASS_XSIM 3895 ns

Before: hit B `00020100` dest_rd=5. After zero dest[5..6] only: miss dest_rd=4. Posting dest[4] still neighbor B. Neighbor is EdgeRecord.dst_id. First FAIL log 3245 ns kept (`h1=0 rd1=2`).

## RKB-05 PASS_XSIM 7015 ns

A2B B dest_rd=5 t1=1. COMMIT C t1=0 leftover SLOT0 dest still B. Query C dest_rd=5 t1=1. Host did not write T1. First FAIL: hits already B then C but t1 stayed 0 (`load_ack` sticky HIGH). T1 is occupancy, not answer bypass.

## RKB-06 PASS_XSIM 7075 ns SEMANTIC_PARITY_ONLY

Warm C dest_rd=5 t1=1. Flush T1 only: t1=0 gen/pub held dest_unchanged=1. Post C dest_rd=5. `CACHE_ACCELERATION=NO`.

## RKB-08 current-arch PASS_XSIM 7375 ns

08A fixture DEADBEEF still C dest_rd=5. 08B dest edge poison miss dest_rd=4 fixture still C. 08C restore C. 08D DUT `$readmemh dir_a/post_a` hits=[]. Historical CLASS A **not** rewritten.

## Claim ceiling

Isolated XSim on `pack_edge_dut` is not CT1 silicon and is not `RUNTIME_KNOWLEDGE_BINDING_8_8_PASS`. UART 02/04/05/06/08 **NOT_RUN**. CT1 `T1_OCCUPANCY` **NOT_PROVEN** on the programmed bit.

```text
RKB04_XSIM / RKB05_XSIM / RKB06_XSIM / RKB08_ARCH_XSIM = 1 (isolated)
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
PACK_ABI_24_24_PASS                = NO
PROGRAM_PASS                       = NO
CT1_BOARD_PASS                     = NO
BOARD_PASS                         = NOT_EVIDENCED
```
