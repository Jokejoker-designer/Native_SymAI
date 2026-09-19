# U32 leftover + GOLD-then-next XSim

Dest = `mig_ui_bram` (not `mig0`, not board).
PACK_ABI_24_24_PASS = NO.
No dest_accept / dest_ui_rdy overlay. No program this file.

U32 TX CDC: `rst100_tx_b_n <= ~(clr_ui_req || tx_busy_rst)`. S_REQ still b-resets (ACK before `debug_clear`). S_BUSY/S_DROP_B hold TX CDC a+b reset and drop `st_valid_ui` without clearing `ack_d`.

## leftover opcode-01

TB `UART_R2/u32/tb_u32_leftover_op01.sv` sha256 `b88fb04eae30b102685c6af8f82e42c263761f13320044edf4e8385ad4cb4452`.
Log `UART_R2/xsim_u32l/xsim.log` sha256 `7db28c85e39f116ad1bf1bc8f825537c92a934ff98b585d45cc699838f76186c`.
`$finish` 4893695 ns.

```
CLEAR2 mute=0 got=c1ea50a5
V04_1 mute=0 got=010000a5 first_p=00800001
UART_R2_U32_LEFTOVER_XSIM_PASS GOLD after unlocked opcode-01 junk
```

Prior `~cdc_rst_100`-only overlay FAIL_XSIM CLEAR2 `got=00000000` (a-reset before b-reset injects hold=0). This overlay restores ACK `c1ea50a5`.

## four V-04 GOLD-then-next

TB `UART_R2/u32/tb_u32_two_v04.sv` sha256 `d142fd0783a9f03e1412707c917f31ce2ffc2a815876d81d7aaa997869cd0c1d`.
Log `UART_R2/xsim_u32t/xsim.log` sha256 `427cf1a861a21f95878b5d4d5e619067ad85a69b8d83b2b2deb1214038fd604e`.
`$finish` 9666815 ns.

```
V04_1 ... 010000a5 first_p=00800001
V04_2 ... 010000a5 first_p=00800001
V04_3 ... 010000a5 first_p=00800001
UART_R2_U32_TWO_V04_XSIM_PASS four GOLD through loader-only debug_clear
```

FACT PASS_XSIM GOLD-then-next class on BRAM. Not board 24/24. Not PACK_ABI_24_24_PASS / BOARD_PASS / MIG_PASS.
