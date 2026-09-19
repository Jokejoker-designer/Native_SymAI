# UART_R2_U9 — commit layer 2 (CDC)

CANDIDATE only. Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS / TIMING_PASS.

## Close this layer

1. Host already encodes PROGRAM != UART-READY (kill hw_server/cs_server, 12s COM-closed, 0.25 drain, same COM, 0 gap after ACK).
2. U9 RTL: `cdc_rst` includes S_DROP; `word_cdc32` 16-cycle holdoff after each-side rst release.
3. Do not mix G3 uart_tx flush-not-abort (that is U10).
4. Repeat T1 + V-04 + CLEAR2 N times. One GOLD is not N/N.
5. Stop before Pack24 24/24 stamp. FEM persist blocked.

## Ban

H `cf62102f…`, M4+mig `f6a6091f…`, U2 `ec322575…`, U3 `17494f2c…`, U8 `2bc835fd…`.
