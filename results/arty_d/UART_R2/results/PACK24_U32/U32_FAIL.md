# U32 exclusive board — FAIL CLEAR1, no GOLD

PACK_ABI_24_24_PASS = NO.
PROGRAM_PASS = NO. D does not self-stamp.

Bit `0df4de2ec075bfdbe567bb661702da088a1be5322cc9112ad2ebf959d116f6ff` JTAG `210319BE776EA` End of startup HIGH (`Labtools 27-3164`). `PROGRAM.txt` SHA MATCH. IR.STATUS=NA PROGRAM.DONE=NA.

Campaign `u32_campaign.py p4p5` SHA MATCH WANT. COM12.

```
WARMUP_CLEAR BUSY n=4 b550eac1
CLEAR1 n=0
CLEAR1_RETRY n=0
REOPEN_AFTER_N0
CLEAR1_REOPEN n=0 then BUSY/n=0 mix through BUSY7
stop CLEAR1  (no ACK, no V-04)
```

No Phase4 GOLD. Same UART class as prior first-exclusive C1 / E6 warmup, not leftover n=8 (never reached GOLD). Dest_accept hang vs hold UNKNOWN (no V-04 TX).

json `results/PACK24_U32/BOARD_BASELINE.json`. Not BOARD_PASS / MIG_PASS / TIMING_PASS.
