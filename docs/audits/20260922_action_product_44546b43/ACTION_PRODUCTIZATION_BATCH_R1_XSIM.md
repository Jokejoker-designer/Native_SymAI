# ACTION_PRODUCTIZATION_BATCH_R1 XSim

LANGUAGE=EN
BITSTREAM=NOT_BUILT
FROZEN_BIT=435bdc88cf8dfcc4f1855f3eb5eac31a47347e79ab570b02fa82a9594263ce2d unchanged

```text
ACTION_PRODUCTIZATION_XSIM_CANDIDATE=SUPPORTED
```

Log `D:/FPGA/arty_d/UART_R2/fem_spear_qstar_astra/xsim_apb/action_product_r1_xsim.log`
sha256 `74688ff679bb4dda1eca6a6c9305d34cf54d9bc3e5951c8271d80490531e815b`
Finish 18605 ns.

The host toggles influence and safety. Q* `proposed_action` is the intent primitive. Lookup reads one installed descriptor `capability_id=0xC1`, mask `8'h03`, CRC `0x28AE`. BOUND emits `PrimitiveCommand`. SAFETY_VETO emits none.

| Arm | proposal | intent | lookup | verdict | command | primitive |
|---|---|---|---|---|---|---|
| PRE | 0 | 1 | hit `C1` | B0 | `C001` | 0 |
| OFF1 | 0 | 2 | hit `C1` | B0 | `C002` | 0 |
| ON1 | 1 | 3 | hit `C1` | B0 | `C003` | 1 |
| OFF2 | 0 | 4 | hit `C1` | B0 | `C004` | 0 |
| VETO | 1 | 5 | hit `C1` | B2 | none | not issued |

A structural probe of primitive 2, which Q* does not propose, misses the mask and returns `NO_BINDING` (`B4`) with no command.

Still synthetic: SPEAR descriptors, query, generation, theta, legal_mask, the `{0,2}` feature map, test-controlled safety, and `B0–B4` packing. No executor and no ObservedEffect.

Not claimed: BOARD_PASS ASTRA_PASS PROGRAM_PASS TIMING_PASS FE256_PASS PACK_ABI_24_24_PASS FEM_PERSIST_PASS.
Board identity for this batch is not built. Independent audit comes before any new SHA.
