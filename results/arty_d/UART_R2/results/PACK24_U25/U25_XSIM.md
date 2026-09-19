# UART_R2 U25 XSim (mig_ui_bram)

Not BOARD_PASS / not PACK_ABI_24_24_PASS / not MIG_PASS / not TIMING_PASS.

## Overlay (do not patch U20/U24)

- Unlocked steer = exact BEGIN `32'h00800001` (U24).
- `fifo_flush = uart_flush || st_fire` where `st_fire` is GOLD/NAK TX accept.
- `TX.flush` stays `uart_flush` (U20; not U21 TX.flush=0).
- `pack_lock` falls on `st_fire`, not U21 `pack_lock_d && !pack_lock` delayed unlock-flush.
- Query leftover off: `uart_fe256_host.in_valid = 0`.

## PASS_XSIM only

| TB | Result | finish |
| --- | --- | --- |
| `tb_u25_leftover_op01` | `UART_R2_U25_LEFTOVER_XSIM_PASS` GOLD `010000a5` first_p=`00800001` after unlocked `00010001` | 4892095 ns |
| `tb_u25_two_v04` | `UART_R2_U25_TWO_V04_XSIM_PASS` second V-04 GOLD first_p=`00800001` fifo empty | 4832065 ns |

Dest = `mig_ui_bram`, not generated `mig0`, not board.

JSON: `U25_XSIM.json`
