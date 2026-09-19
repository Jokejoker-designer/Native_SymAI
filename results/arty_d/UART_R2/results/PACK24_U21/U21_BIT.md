# U21 bitstream — TX flush uncoupled from CLEAR RX/FIFO flush

PROGRAM = NO until owner/this-run program of THIS identity only
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
TIMING_PASS = NO

## Why this identity

U20 exclusive board: Phase4 ACK+GOLD then Phase5 CLEAR r0 n=0.
U16 first-divergence: S_REQ uart_flush on TX muted ACK after GOLD.
U17 (no TX flush at S_REQ; flush only S_CDC|S_QUIET; no steer) got CLEAR ACK after GOLD.
U20 still flushes uart_tx_word during S_CDC|S_QUIET|1-cycle DROP.
1M bram harness does not reproduce n=0 (G2C PASS). Board class remains product-MIG0 / TX-mux.

U21 (do not edit frozen U20):
- `uart_tx_word.flush = 0`
- `clr_ack_ready = mux_ready` (not gated by uart_flush)
- FIFO flush = uart_flush OR pack_lock falling edge
- RX still U20 one-cycle DROP flush; U19 steer_pack kept

## PASS_XSIM (not board)

- DROP_FLUSH / FOLLOWON_DROP (U20 CLEAR FSM)
- TX ACK after QUIET-length flush (unit)
- parked-0 GOLD
- junk-after-GOLD GOLD
## Bit

```
D:/FPGA/arty_d/UART_R2/build_u21/uart_r2_u21_candidate.bit
SHA256 09736afe958400d4a7bf6e41b81cb0247f119f8678780aef585cccf0ba4f1ff9
bytes  1952245
DCP    27a27d90cac408a46ffbb2bc39267cf11bd55e535041b1f294427d636f4cdd02
WNS    +0.609 ns (observation)
WHS    +0.012 ns (observation)
```

`97_program_uart_r2_u21.tcl` bans U20 `1c3f954f…` and `uart_r2_u20_candidate`.
SRAM last-writer before this program was GOAL_M2 `0128e8e7…` (PROGRAM.txt 18:30:29). Not TIMING_PASS / BOARD_PASS.
