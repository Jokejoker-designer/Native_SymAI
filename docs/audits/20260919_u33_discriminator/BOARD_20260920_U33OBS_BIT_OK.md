# U33OBS BIT_OK — unique observe candidate, not programmed (2026-09-20)

Not overlay U33/H/U33TAP/TAPCDC. **TIMING_PASS=NO**. **PROGRAM_PASS=NO**. **READY_TO_PROGRAM=NO**. **OWNER_YES_REQUIRED=YES**. PACK_ABI_24_24_PASS=NO.

`BUILD.txt` STATUS=**BIT_OK**. Bitstream `uart_r2_u33obs_candidate.bit` (unique `build_u33obs/`). Independent SHA256 match:

```
71b9198f512972bae75af04e406d26c17d7940ecadd324e5b5ffecaedcbf6762
```

≠ U33 `ff399e0b…` ≠ TAPCDC `eb99ac69…` ≠ TAP `d448544f…` ≠ H `cf62102f…`. DCP `168359bc…` (same MET route). `write_bitstream` 0 errors; Tcl `PROGRAM=NO`.

Post-route still WNS **+0.303** WHS **+0.008** (constraints MET). That is **not** a `TIMING_PASS` stamp.

This watch **did not program** Arty. Exclusive PROGRAM remains AGENT_D until 00:00 +07. Observe identity needs a **separate owner YES**. Do not Pack24 on this SRAM. Do not overlay frozen product bits.

Bit file not pushed (2 MiB); hash + BUILD + `bit.log` are the public evidence.
