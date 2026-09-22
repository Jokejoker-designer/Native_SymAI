# EXPERIENCE_AFTER_COMMITTED_COMMAND_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: EXPERIENCE_AFTER_COMMITTED_COMMAND_XSIM_CANDIDATE=SUPPORTED
FEM_PERSIST_PASS=NO
MIG_PASS=NO
BOARD_BUILT=NO

Log: `D:/FPGA/arty_d/UART_R2/experience_after_cmd_r1/xsim/experience_after_command_r1_xsim.log`
SHA256: `c8d53ddcbfc017a349f183e77909977f8b6fa5a7b35e26c8560efbde2de704a7`
Finish: 8125 ns

Wrapper: `experience_after_command_r1.sv`
SHA256: `59756ae42deca1f3a757dc23c20d8870b3776dd20911b527f2abaa004454396a`

`pack_vis_runtime.sv` and `experience_next_r1.sv` were instantiated and not edited.

## What the log shows

- Effect 3 before any command: not accepted, `fem_feat` 0, later proposal 0.
- Commit generation 1 issues command primitive 0, id `C001`.
- With `command_valid` 1 and no new observation, the later proposal stays 0.
- Effect 3 after that command is accepted, `fem_feat` becomes 1, and the later proposal becomes 1.

A first run failed because `command_seen` sampled `result_done` on the edge that raised it. The latch now follows `command_valid`. The hashed log is the run after that fix.

## Self-audit

The later proposal comes from the Q* instance inside `experience_next_r1`. The primitive 0 command comes from the Q* inside `pack_vis_runtime`. They are not the same instance. The new fact is the gate: FEM does not take the effect until a command from the committed generation has been issued, and the effect value is still a testbench constant, not a pin readback.

`t2_ready` remains tied inside the experience module. This is not DDR. The query lane is not part of this identity.
