# SEMANTIC_PRODUCTIZATION_BATCH_R1 XSim

LANGUAGE=EN
BITSTREAM=NOT_BUILT
FROZEN=44546b43 and 435bdc88 untouched

```text
SEMANTIC_PRODUCTIZATION_XSIM_CANDIDATE=SUPPORTED
```

Log `D:/FPGA/arty_d/UART_R2/semantic_product_r1/xsim/semantic_runtime_xsim.log`
sha256 `1f578505325fd2cd1faf667888a8fb44fe7894d87e2e1ccb6e15b3a06467c42b`
Finish 6665 ns.

The descriptor address is `edge_ref[7:4]` from `posting_walk`, after `exact_directory` generation matches `active_generation`. The testbench does not write the descriptor.

| Arm | subject | active gen | dir gen | edge | fetched ref | rank | proposal | command |
|---|---|---|---|---|---|---|---|---|
| Q_A | `00010100` | 1 | 1 | `0x20` | `A1` | `A1` | 0 | `C001` primitive 0 |
| Q_B | `00010101` | 1 | 1 | `0x60` | `B1` | `B1` | 1 | `C002` primitive 1 |
| GEN_MISS | `00010100` | 2 | 1 | walk saw `0x20` | none | none | none | none |
| Q_A2 | `00010100` | 1 | 1 | `0x20` | `A1` | `A1` | 0 | `C003` primitive 0 |

GEN_MISS uses the same QueryRecord subject as Q_A. The posting walk still resolves `edge_ref=0x20`, and the generation compare refuses the fetch. A query-id mux would have returned descriptor A1.

Labeled substitutes: fixed theta, `legal_mask=8'h03`, rank0 `{0,2}` map. Relation, hops, and the score weight are not the retrieval cut.

No board identity yet. Independent audit comes before any new SHA.

Not claimed: BOARD_PASS ASTRA_PASS PROGRAM_PASS TIMING_PASS FE256_PASS PACK_ABI_24_24_PASS FEM_PERSIST_PASS.
