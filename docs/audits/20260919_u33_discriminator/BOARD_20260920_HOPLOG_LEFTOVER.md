# Leftover MAG hop_log (starter logger) — PASS_XSIM only

Not U33OBS 7-lane. Not silicon. Not PACK_ABI_24_24_PASS.

TB: `UART_R2/u33obs/tb_u33obs_leftover_hoplog.sv` on frozen U32 harness `p_fire` → `pack_hop_log` load lane.

Command: `run_tb_u33obs_leftover_hoplog.bat`

Log: `UART_R2/xsim_u33obs_hoplog/u33obs_leftover_hoplog.log` sha256 `564d22e7f719d1631e0e3152e0bc5461b5c8f0f7ce62891ba378f80e80e9980c`

```
STATUS mute=0 got=0200015a n_ld=8 p0=00800001 p1=00800001 n_ev=64 PACK_ABI_24_24_PASS=NO
HOPLOG_CLASS_A p_fire p0=BEGIN p1=BEGIN first_divergent=p1
PASS_XSIM leftover hop_log CLASS_A
```

`$finish` 2401265 ns.

FACT: leftover extra BEGIN after CLEAR then V-04 is MAG; first two loader accepts are BEGIN, BEGIN. First divergent hop in this TB = p1.

LIMIT: DEPTH=64 filled (`n_ev=64`); ring can wrap; first eight `p_fire` captured before wrap so p0/p1 still valid. Silent overflow is why this logger is not the frozen U33OBS identity.

Do not program this starter on the board.
