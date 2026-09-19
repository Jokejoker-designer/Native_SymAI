# uart_rx stop_hold — extra BEGIN CONTRADICTED by RTL

File `UART_R2/u11/uart_rx_word.sv` STOP (full module read). When `bix==3 && !can_take`, `stop_hold` stays in STOP until `can_take`, then emits **one** word. Incoming bits during hold are not sampled into a second word. That is **drop/mute**, not DUP4 MAG `0200015a`.

Do not overlay uart_rx from concurrent MAG. Next is host write granularity (52×4 vs 208 bulk).
