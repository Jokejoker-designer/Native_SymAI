# ASTRA_ACTION_PRECHECK_V1 XSim freeze

LANGUAGE=EN
RUN_ID: 20260922T074000Z

```text
ASTRA_ACTION_PRECHECK_V1=PASS_XSIM
BOARD=NOT_TESTED
BITSTREAM=NOT_BUILT
```

Proposal fixed at `3'd1`. Verdict codes `B0–B4` are XSim packing, not a locked ABI. They are not query status `0x01–0x06`.

Log: `D:/FPGA/arty_d/UART_R2/astra_action_precheck/xsim/astra_action_precheck_v1_xsim.log`

```text
ASTRA_PASS=NO
BOARD_PASS=NO
PROGRAM_PASS=NO
TIMING_PASS=NO
MIG_PASS=NO
FEM_PERSIST_PASS=NO
FE256_PASS=NO
PACK_ABI_24_24_PASS=NO
```

Silicon identity, when built, must be a new tree. Do not rebuild `8b632b4a…`.
