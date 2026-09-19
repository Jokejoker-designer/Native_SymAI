# DESTINATION_COMPLETE_EVIDENCE

U12 campaign. Not BOARD_PASS / PACK_ABI_24_24_PASS.

## What the UART token can prove

Product top emits:

- LOAD_OK  `010000a5` from `load_ack` rising
- LOAD_REJECT `02rrrr5a` from `load_reject` rising

`pack_loader` commits `active_generation` only on the dest-complete path
(`wr_outstanding == 0` after intended writes / integrity / sentinel).
FIFO empty is not that path.

## What UART cannot observe on this board interface

No UART register exports:

- `wr_outstanding`
- destination readback words
- `active_generation` itself
- MIG `app_rdy` / calib internals

Therefore GOLD/NAK tokens are **necessary** board evidence that the
status CDC/TX path ran, and they **correlate** with the RTL commit
law, but they are not an independent probe of destination memory.

```text
M1_CLOSURE_BLOCKED_BY_MISSING_OBSERVABILITY = YES_FOR_INDEPENDENT_WR_OUTSTANDING
TOKEN_GOLD != DESTINATION_READBACK
FIFO_EMPTY != DESTINATION_COMPLETE
ACK != WRITE_ISSUED
```

If Pack24 board tokens match frozen gold exactly, record:

```text
DDR_DESTINATION_COMPLETE = TOKEN_CORRELATED_WITH_RTL_COMMIT_NOT_INDEPENDENTLY_PROBED
```

Do not self-stamp destination-complete PROVEN unless a later identity
exports wr_outstanding/readback on a legal debug channel. ILA is not
available (BASIC license).
