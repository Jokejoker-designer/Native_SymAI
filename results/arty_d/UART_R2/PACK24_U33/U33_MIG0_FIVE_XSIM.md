# U33 mig0 five V-04 — COMPLETE V04_0..4 GOLD

RUN_ID: 20260919T125801Z
OWNER: AGENT_D / CURSOR_OWNER publish
PACK_ABI_24_24_PASS = NO. PROGRAM=NO. MIG_PASS=NO. BOARD_PASS=NO.

## Status PASS_XSIM (this TB only)

Generated `mig0` + U33 bind, five CLEAR→V-04. `$finish` 12207195 ns. Wall elapsed 07:26:23. xsimkernel CPU 15517312 ms. Exit 2026-09-19 19:58:01 +07.

```
U33_MIG0_FIVE_CALIB_DONE t=122810625.0 ps
V04_0 mute=0 got=010000a5 n_p=8 p0=00800001 p1=3149414e rej=0 rsn=00 qsc_ui=1 dest_rdy=1
V04_1 mute=0 got=010000a5 n_p=8 p0=00800001 p1=3149414e rej=0 rsn=00 qsc_ui=1 dest_rdy=1
V04_2 mute=0 got=010000a5 n_p=8 p0=00800001 p1=3149414e rej=0 rsn=00 qsc_ui=1 dest_rdy=1
V04_3 mute=0 got=010000a5 n_p=8 p0=00800001 p1=3149414e rej=0 rsn=00 qsc_ui=1 dest_rdy=1
V04_4 mute=0 got=010000a5 n_p=8 p0=00800001 p1=3149414e rej=0 rsn=00 qsc_ui=1 dest_rdy=1
U33_MIG0_FIVE_XSIM_PASS five GOLD dest=generated_mig0 bind=U33
PACK_ABI_24_24_PASS=NO
$finish 12207195 ns
```

Log sha256 `0778d0a9b939a498982758707d67cdca1e83db06610ccd27c4859b4514406256` (163 lines).

## Claim

**V04_4 GOLD** = board MAG cell analogue (p5 r3, 5th V-04). This TB **CONTRADICTS** “5th V-04 MAG because dest=generated mig0”. Combined with BRAM five GOLD: dest class for board MAG is **CONTRADICTED** on both BRAM and generated mig0 XSim.

Board leftover BEGIN source still **UNKNOWN**. Leftover exact BEGIN remains **sufficient** (CELL A). No overlay. No PACK_ABI stamp.
