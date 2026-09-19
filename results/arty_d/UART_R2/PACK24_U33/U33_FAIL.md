# U33 exclusive board — FAIL p5 V-04 round 3 MAG, not 24/24

PACK_ABI_24_24_PASS = NO.
PROGRAM_PASS = NO. D does not self-stamp.
BOARD_PASS = NOT_EVIDENCED. MIG_PASS = NO. TIMING_PASS = NO.

Owner PROGRAM=YES 2026-09-19 (“Board ready program được rồi đó”).
Bit `uart_r2_u33_candidate.bit` sha256 `ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350`
JTAG `210319BE776EA` End of startup HIGH (`Labtools 27-3164`).
`PROGRAM.txt` sha256 `81ae5dd569cfcd3f68aaa50f42cbf2318ff9a13e4f217eaaa3f4617bc02a9505`
STATUS=PROGRAMMED CLASS=uart_r2_u33_CANDIDATE. IR.STATUS=NA PROGRAM.DONE=NA.
Tcl `97_program_uart_r2_u33.tcl` WANT match. Ban includes U32 `0df4de2e…`. Identity H / freeze DCPs untouched.

Campaign `u33_campaign.py nwp4p5` WANT MATCH. COM12 115200 FTDI `210319BE776EB`. Settle 12s after kill hw_server.

```
CLEAR1 ACK n=4 a550eac1  (word c1ea50a5)
V04_0 GOLD n=4 a5000001  (word 010000a5)  PHASE4_OK
p5 r0 CLEAR ACK / V04 GOLD
p5 r1 CLEAR ACK / V04 GOLD
p5 r2 CLEAR NONE n=0 then CLEAR_RETRY ACK / V04 GOLD
p5 r3 CLEAR ACK / V04 OTHER_0200015a n=4 raw 5a010002
stop V04 round=3 mag=1
```

LAST_EQUIVALENT = p5 V-04 round 2 GOLD `010000a5`.
FIRST_DIVERGENCE = p5 V-04 round 3 MAG `0200015a`.

Contrast U32 same exclusive path: FAIL CLEAR1 BUSY `c1ea50b5`, no GOLD.
U33 PACKAGE-style qsc (no dest_ui_rdy AND) unblocked CLEAR1 on board (FACT this run).
That is not 24/24 GOLD n=4. Pack24 run1/run2/fresh not started.

json `results/PACK24_U33/CLEAR_V04_24.json` sha256 `b289fd4e9796ccbc2c31bb7039d334ad8a4a99d9b49bea80c51dafc3e8b8855f`
raw `RAW_UART/p5_v03.json` sha256 `01962c633adca31e3992b7702d8cc2bca2fa7cb14c307f911964fd7a71012d4f`
bind `UART_R2/u33/pack_mig_bind.sv` sha256 `eade06c85af164a00cf6c35bb5e31cc51547fa7dbab2a5a3ccf801ce72e596c5`

U33 frozen FAIL_BOARD. No UART/dest_accept overlay. No second identity this turn.
