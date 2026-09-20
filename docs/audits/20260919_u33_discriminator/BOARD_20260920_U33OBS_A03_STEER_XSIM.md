# A-03 UART steer OP_BEGIN — PASS_XSIM NAK reason 9, not PACK_ABI (2026-09-20)

This watch did **not** program, did **not** run Pack24, and did **not** patch RTL (parent changed `pack_begin`). **PACK_ABI_24_24_PASS=NO**. **READY_TO_PROGRAM=NO**. **PROGRAM_PASS=NO**. New unique bit **NOT_BUILT**. Silicon still `251eafa9…` (exact `00800001` gate). Overlay **NO**. C RTL untouched. B gold unmodified.

`pack_begin` is now `(f_data[7:0] == 8'h01)` in OBS top and `pack_obs_harness.sv`. TB `tb_u33obs_a03_steer.sv` with `EXPECT_NAK`:

```
CLEAR_ACK
A03_STATUS mute=0 got=0200095a n_p=34 p0=00840001 reason=09 want_nak=1
PASS_XSIM A-03 UART steer OP_BEGIN NAK reason 9
PACK_ABI_24_24_PASS=NO READY_TO_PROGRAM=NO
```

`u33obs_a03_steer.log` sha256 `557c467c…`. xsim then printed `FATAL_ERROR` after `$finish` (kernel); PASS lines already logged. Isolated A-03 GOLD/NAK on a **new unique** bit is **not** evidenced. Do not overlay `251eafa9` / `71b9198f`.
