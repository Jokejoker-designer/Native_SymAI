# FEM Q* A/B/A/B XSim

LANGUAGE=EN
RUN_ID: 20260921T165800Z
RESULT: PASS_XSIM
FINISH: 12445 ns
LOG_SHA256: a4d5576ea6212dad70719b95dece8b4e6d62bd2a9deb38c399c167e30edee944

```text
A   infl=1 feat0=0 ft=0 life=7 greedy=0 q_sel=0
B   infl=1 feat0=2 ft=2 life=3 greedy=1 q_sel=2
A2  infl=0 feat0=0 ft=2 life=3 greedy=0 q_sel=0
B2  infl=1 feat0=2 ft=2 life=3 greedy=1 q_sel=2
```

A2 kept recovered `failure_total=2` and `life=3` while greedy returned to 0. Same-clock `mig_ui_bram`. CDC into a separate Q* clock is NOT_TESTED. Not `mig0`. Not silicon.

```text
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
BOARD_PASS=NO
MIG_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
BIT=NOT_BUILT
PROGRAM=NO
```

C RTL unedited. Identity `1db38691` was not programmed and cannot run this mux.
