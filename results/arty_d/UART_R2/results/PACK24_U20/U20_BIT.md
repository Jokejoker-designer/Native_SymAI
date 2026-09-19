# U20 bitstream — STOP before program

PROGRAM = NO
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
PACK_ABI_24_24_PASS = NO
TIMING_PASS = NO

## Why this identity

U19 exclusive board: CLEAR ACK then V-04 n=0. Host `WAIT_AFTER_ACK_S=0`.
U18/U19 `uart_flush` stayed 1 for the whole `S_DROP` window. That wipes a
following command already on RX (V-04 after ACK, or CLEAR after GOLD).

U20: flush `S_CDC|S_QUIET` plus **one** `S_DROP`/`S_DROP_B` cycle (`cnt==0`),
then flush=0. Keep U19 `steer_pack`. Do not edit frozen U19.

## PASS_XSIM (not board)

- `UART_R2_U20_DROP_FLUSH_XSIM_PASS` pulse then flush=0 while DROP held
- `UART_R2_U20_FOLLOWON_DROP_XSIM_PASS` BEGIN parked during long DROP
- parked-0 GOLD (U18 class still destroyed on first DROP cycle)
- junk-after-GOLD GOLD (U19 steer kept)

## Bit

```
D:/FPGA/arty_d/UART_R2/build_u20/uart_r2_u20_candidate.bit
SHA256 1c3f954f93caac75d5ff63089261ea45790d0879fcf15aaf668c2ffcdc539ff9
bytes  1900785
DCP    c18e4877a433fc157ea1046451bb1c8c6d81de12489588cc0ffe835da167ddf1
WNS    +0.506 ns (observation)
WHS    +0.008 ns (observation)
```

`97_program_uart_r2_u20.tcl` exists and bans U19 `cecb020f…`. **Not run.**
No `PROGRAM.txt` under `build_u20`.
