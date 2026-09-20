# Unique OBS steer `bd541f95…` hops — leftover MAG, GOLD four-AND, V-04×4 (2026-09-20)

This watch did **not** program Arty and did **not** run Pack24. Same SRAM identity `bd541f95…` after isolated A-03/A-04. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **PACK_ABI_24_24_PASS=NO**. Overlay **NO**. Old OBS `71b9198f…` and rgoff `251eafa9…` files intact. C RTL untouched. B gold unmodified.

| Artifact | SHA256 |
|---|---|
| `U33OBS_STEER_HOPS_LEFTOVER.json` | `e82fcf125c035ed3ab93a0a996c1558bccee320b092f7b419c0432b227255f97` |
| `U33OBS_STEER_HOPS_GOLD.json` | `5b552e515a1b8a8be843776e9f2b5f272ef4f68fbb4a053b2880beed5c2ea0b9` |
| `U33OBS_STEER_HOPS_V04x4.json` | `c62c381905af8e43e8272b3d3d6b30fb6f6520e4ba3542f472cc5d03a07e923d` |
| `D_U33OBS_STEER_HOPS.json` | `37b06f4a00a7540274f0f00a4956b3bc5eb8740a44d278763ac75dcac70e3f27` |

| Hop | UART | TAP |
|---|---|---|
| leftover extra BEGIN | **MAG** `0200015a` | **U33OBS_GEN CLASS_A** p0=p1=`00800001` commit=0 **generation_flipped absent** (four-AND) |
| isolated GOLD DUMP | **GOLD** `010000a5` | four-AND **flip=1** `ffffffff→0000ffff` `gen_stat=470f0002` load0=`00800001` load1=NAI1 |
| V-04 ×4 after CLEAR | **4/4 GOLD** `010000a5` mag=0 mute=0 | (no Pack24) |

Leftover MAG CLASS_A is **PASS_BOARD CANDIDATE this hop**, not MAG_HISTORICAL_NATURAL closed. GOLD four-AND is isolated DUMP after leftover, not Pack 24/24. V-04×4 is **not** 24 ABI cases. **PACK_ABI_24_24_PASS=NO**.
