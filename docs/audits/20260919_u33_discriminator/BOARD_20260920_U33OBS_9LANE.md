# U33OBS 9-lane — PASS_XSIM only (2026-09-20)

Not silicon. Not overlay U33. Not PACK_ABI_24_24_PASS. READY_TO_PROGRAM=NO.

## Result

`tb_u33obs_9lane` `$finish` 5164993750 ps  
Log sha256 `2f94eb348c9a19c38380cfef9b2b2ced1cb9a65aff03839349b81b4ecc249042`

| Cell | UART token | freeze | gen | notes |
|---|---|---|---|---|
| leftover MAG | `0200015a` | 1 | `flip_present=0` | n_ctrl=5 n_state=5 n_term=1 NAK flags=`0004` n_ld=33 p0=p1=BEGIN |
| DUMP | — | 3 | no COMMIT | n_fw=0 n_ld=0 no NAK |
| GOLD V-04 | `010000a5` | 0 | `generation_flipped=1` | four-AND: commit, before=`ffffffff` after=`0000ffff`, same_epoch, capture_valid. TERM COMMIT flags=`0001` |

Dump hops TB re-run after harness ports: still PASS_XSIM.

`generation_flipped=true` iff `commit_event==1 AND generation_after!=generation_before AND same_capture_epoch AND capture_valid==1`. Leftover NAK does not invent 0/1.

## Still missing for silicon OBS

Board top, dedicated DUMP TAP CDC, synthesizable COMMIT tap if hierarchical `u_ld.u_ld.state` is rejected at impl, query UART (out of scope). Do not program 9-lane XSim as a bit. Do not Pack24 on TAPCDC SRAM.
