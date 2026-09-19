# U32 S_REQ→nack leftover — BUSY n=4, no GOLD

Dest = `mig_ui_bram` (not `mig0`, not board).
PACK_ABI_24_24_PASS = NO.
Does not overlay dest_ui_rdy / dest_accept.

TB `UART_R2/u32/tb_u32_sreq_nack_leftover.sv` sha256 `4add6bb765fdd6d05d6871417eda022c83cf2ef7f736a00f865d0cf8e1b3efca`.
Log `UART_R2/xsim_u32r/xsim.log` sha256 `47fe3ed6cf0a35ef1d7152c2c11a220e602b777e3c9cf0b6db43877b4a7dea6b`.
`$finish` 4512895 ns.

U31 same cell scored BUSY_THEN_GOLD_N8 (`xsim_u31r`). U32 after nack: `req_a=0 last_b=0`.

```
AFTER_NACK_WIN st=0 ui_req=0 rst100_tx_b_n=1 st_valid_100=0 nack=0 req_a=0 last_b=0
CLR2_WORD 1 c1ea50b5
UART_R2_U32_SREQ_NACK_SCORE BUSY_N4_NO_GOLD
UART_R2_U32_SREQ_NACK_XSIM_DONE PACK_ABI_24_24_PASS=NO
```

FACT PASS_XSIM: S_REQ probe + nack does not replay GOLD. Dest-stall SAMPLE `!qsc` remains BUSY n=4. Board leftover on `mig0` still UNKNOWN.

Not PACK_ABI_24_24_PASS / BOARD_PASS / MIG_PASS.
