# GOAL_CHAIN_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: GOAL_CHAIN_XSIM_CANDIDATE=SUPPORTED
ANSWER_EMITTED=NO
ASTRA_PASS=NO
FEM_PERSIST_PASS=NO
MIG_PASS=NO
BOARD_BUILT=NO

Log: `D:/FPGA/arty_d/UART_R2/goal_chain_r1/xsim/goal_chain_r1_xsim.log`
SHA256: `b41e4d7ab7969c286c841d0e15fb1178ba69fcef01455dcdce9ec299e4d9f6ea`
Finish: 722275 ns

Wrapper: `goal_chain_r1.sv`
SHA256: `9f7013cb3ca911095edae830176d9327f8fc5d2e5f95cff71716ef96f82fa27e`

## What one log shows

- No commit: magic `0x4E52`, status `0x02`, evidence ref 0, no command.
- Generation 1: query generation `0x00AB`, evidence generation 1, ref `025bb7b4`, status `0x04`. Status is not `0x01` and is not the action verdict at that snapshot.
- Counted command `C001` primitive 0.
- UART byte `0x00` leaves `fem_feat` at 0 and the later proposal at 0.
- UART byte `0x0A` sets `fem_feat` to 1 and the later proposal to 1 while `command_valid` stays 1.

## Self-audit

At the query snapshot the action verdict is still 0 because the counted command is issued on the next proposal, not inside the query result. That is why the log prints `verd=00` next to status `0x04`.

The query fields are still a projection. The sample is a simulated `uart_rx` word, not a board capture. `pack_vis_runtime` still hides another Q*. `t2_ready` stays tied. This log lines the pieces up. It does not close the product goal.
