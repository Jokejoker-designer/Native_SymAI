# POSTING_WORD_TO_COMMAND XSim

LANGUAGE=EN
BITSTREAM=NOT_BUILT
desc_sem.mem=NOT_ON_PATH
CANON_post_a.mem=UNTOUCHED

```text
POSTING_WORD_TO_COMMAND_XSIM_CANDIDATE=SUPPORTED
```

Log `D:/FPGA/arty_d/UART_R2/semantic_product_r1/xsim/semantic_runtime_xsim.log`
sha256 `cad860034f716f319bb960cff84b0b1757238b5779579f4350f09d8ee51f6963`
Finish 6605 ns.

`posting_walk` latches `entry_word` from the same `post_q` that supplies the entry. That word is `cand_desc`. There is no second descriptor memory.

The sim-local `post_a.mem` keeps canonical headers. Entry slots for subjects `0x00010100` and `0x00010101` are valid SPEAR descriptors so the fetched record can pass SPEAR. Those bytes are the posting entry, not `desc_sem.mem[edge_ref]`.

| Arm | active gen | posting word == SPEAR word | rank | proposal_valid | command |
|---|---|---|---|---|---|
| Q_A | 1 | yes, ref `A1` | `A1` | 1 | `C001` primitive 0 |
| Q_B | 1 | yes, ref `B1` | `B1` | 1 | `C002` primitive 1 |
| GEN_MISS | 2 | SPEAR word is 0; walk still saw the A1 entry | none | 0 | none |
| Q_A2 | 1 | yes, ref `A1` | `A1` | 1 | `C003` primitive 0 |

GEN_MISS: directory generation stays 1, `descriptor_valid=0`, `proposal_valid=0`, `command_valid=0`, `command_id=0`.

Labeled substitutes: theta, `legal_mask=8'h03`, rank0 `{0,2}` map.

Not a board identity. Not BOARD_PASS, ASTRA_PASS, PROGRAM_PASS, TIMING_PASS, FE256_PASS, PACK_ABI_24_24_PASS, or FEM_PERSIST_PASS.
