# NEXT after commit-layer run 20260918T045635Z

Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.

## Closed / failed this run

1. Host windows encoded. PROGRAM Tcl kills hw_server/cs_server.
2. U9 global `word_cdc32` holdoff: **FAIL_BOARD** first CLEAR NONE ×3. A/B U8 ACK same host.
3. U9b DROP `cdc_rst` + PACKAGE CDC: CLEAR ACK, V-04 MAG `0200015a`. Stop. SRAM leftover-dirty.

## Next (one class)

- A/B U8 vs U9b V-04 on fresh program (GOLD vs MAG).
- Do not mix G3 `uart_tx_word` flush-not-abort until MAG class is classified.
- Do not Pack24. FEM persist blocked.

## Ban

H `cf62102f…`, M4+mig `f6a6091f…`, U2 `ec322575…`, U3 `17494f2c…`, U8 `2bc835fd…`, U9 `66fe2bd7…`.
Current dirty SRAM is U9b `4ab8e142…`.
