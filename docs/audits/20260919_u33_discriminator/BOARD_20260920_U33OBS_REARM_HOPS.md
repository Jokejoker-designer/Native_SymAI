# Unique OBS rearm `08c647ee…` hops — leftover MAG, GOLD four-AND after CLEAR, V-04×4 (2026-09-20)

This watch did **not** program Arty and did **not** run Pack24. Same SRAM identity `08c647ee…` after parent PROGRAMMED. **PROGRAM_PASS=NO**. **BOARD_PASS=NOT_EVIDENCED**. **PACK_ABI_24_24_PASS=NO**. Overlay **NO**. Old OBS `71b9198f…`, rgoff `251eafa9…`, steer `bd541f95…` files intact. C RTL untouched. B gold unmodified.

| Artifact | SHA256 |
|---|---|
| `U33OBS_REARM_HOPS_LEFTOVER.json` | `6868bc4ea7eb71151498aafb230bc7f1135c6cb55696e9cdddd57e4248945975` |
| `U33OBS_REARM_HOPS_GOLD.json` | `52eeebb6d6b193305657a231acc20c83922603982bc0aa2610f14d57fb71aab1` |
| `U33OBS_REARM_HOPS_V04x4.json` | `530c02c41bcf5d8b6a4745340dc6bdf00563bcd3a7a85d1bcf3097e7328c021c` |

Prior leftover capture `bf1ff9dc…` (21:03, TAP commit=0, `leftover_flip` absent) remains historical. Live leftover **21:11** after Pack24 run1: UART MAG `0200015a` CLASS_A; TAP snapshot four-AND `ffffffff→00000002` epoch 27; **`leftover_flip=null`**; **`leftover_tap_not_this_pack=true`**. Latch matches Pack24 run1 PA24-G-01, not leftover extra-BEGIN `S_COMMIT`.

| Hop | UART | TAP |
|---|---|---|
| leftover extra BEGIN (21:11 after run1) | **MAG** `0200015a` | TAP four-AND present on snapshot; **this-hop `leftover_flip` ABSENT**; `leftover_tap_not_this_pack` |
| isolated GOLD DUMP after CLEAR | **GOLD** `010000a5` | four-AND **flip=1** `ffffffff→0000ffff` `gen_stat=470f0002` load0=`00800001` load1=NAI1 |
| V-04 ×4 after CLEAR | **4/4 GOLD** `010000a5` mag=0 mute=0 | (no Pack24) |

Isolated GOLD DUMP after leftover+CLEAR is **PASS_BOARD CANDIDATE this hop** for CLEAR TAP re-arm (this-pack four-AND). Not Pack 24/24. V-04×4 is **not** 24 ABI cases. Leftover MAG CLASS_A does **not** close MAG_HISTORICAL_NATURAL. Two TAP snapshots across CLEAR/epoch are **not** a flip. **PACK_ABI_24_24_PASS=NO**.
