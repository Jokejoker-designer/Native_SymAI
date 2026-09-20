# U33OBS DUMP hops — PASS_XSIM only (2026-09-20)

Not silicon. Not overlay U33. Not PACK_ABI_24_24_PASS. READY_TO_PROGRAM=NO.

## Result

`tb_u33obs_dump_hops` `$finish` 2763675 ns  
Log `D:/FPGA/arty_d/UART_R2/xsim_u33obs_dump/u33obs_dump_hops.log`  
sha256 `b36151b8d74c726c7865477177b0f1b37079a4ef8a90bc8390c13d99b0e25d5b`

Leftover MAG: `got=0200015a` `freeze_reason=1`  
`n_uart=34 n_fw=33 n_fr=33 n_ca=33 n_cb=33 n_ld=33`  
loader `p0=p1=00800001` UART `u0=44524743 u1=00800001`  
HOPS_CLASS_A first_divergent=p1

DUMP-without-NAK: `freeze_reason=3` `load_reject=0`  
`n_uart=2 n_fw=0 n_ld=0` UART `u0=CLEAR u1=44554D50`  
extra BEGIN after freeze does not increment `n_ev`. DUMP never enters FIFO.

## Ctrl fix

`armed` is sticky after epoch handshake. Wiring `armed` to handshake ack `a1`/`u1` left lanes empty after arm completed.

## Unchanged law

`generation_flipped=true` iff `commit_event==1 AND generation_after!=generation_before AND same_capture_epoch AND capture_valid==1` (`pack_obs_gen.sv` sha256 `5a43f604…`).

## Still missing

CONTROL / STATE / TERMINAL lanes, COMMIT peek, dedicated DUMP TAP CDC, board top. Do not program hops-only. Query UART still tied off.
