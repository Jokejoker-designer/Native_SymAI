# U22 bitstream — revert lock-fall FIFO flush

PROGRAM = NO until this identity is programmed
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
TIMING_PASS = NO

## Why this identity

U21 exclusive: CLEAR ACK then V-04 n=0. New U21 delta vs U20 was
`fifo_flush = uart_flush | pack_lock_fall` plus TX.flush=0.
U22 keeps TX.flush=0 and `clr_ack_ready=mux_ready`. FIFO flush = uart_flush only.
Do not edit frozen U21.

## PASS_XSIM (not board)

- DROP_FLUSH
- junk-after-GOLD GOLD
- GOLD then CLEAR ACK then GOLD2 dest=bram (`UART_R2_U22_G2C_XSIM_PASS`)

## Bit

```
D:/FPGA/arty_d/UART_R2/build_u22/uart_r2_u22_candidate.bit
SHA256 ba45936f117e0d8eb6b903dc498dc66e4c36f94314bdcaa8afd366306f8a2be9
bytes  2025977
DCP    5e32176ac1e44c35a191405c1e6197ce322302051874607742530438e4778ec2
WNS    +0.407 ns (observation)
WHS    +0.020 ns (observation)
```

`97_program_uart_r2_u22.tcl` bans U21 `09736afe…`. Not TIMING_PASS / BOARD_PASS.
