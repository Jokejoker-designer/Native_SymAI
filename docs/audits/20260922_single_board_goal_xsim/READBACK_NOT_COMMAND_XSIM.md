# READBACK_NOT_COMMAND_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: READBACK_NOT_COMMAND_XSIM_CANDIDATE=SUPPORTED
READBACK_IS_NOT_A_PIN=YES
FEM_PERSIST_PASS=NO
BOARD_BUILT=NO

Log: `D:/FPGA/arty_d/UART_R2/readback_r1/xsim/readback_not_command_r1_xsim.log`
SHA256: `983249e58c1b08de46b64e5baa2c9010ed59604c8daf1ec997ababe440aaf7c8`
Finish: 8045 ns

Gate: `readback_not_command_r1.sv`
SHA256: `78b5828d5da410a953a140a49cc2093dc69d04a9b386533a08212ee42b64d3d0`

`one_qstar_then_experience_r1.sv` was instantiated and not edited.

## What the log shows

Generation 1 is retrieved. The counted command is primitive 0 and stays valid.

- Sample `0`, equal to that primitive: not admitted, `fem_feat` stays 0, the next proposal stays 0.
- Sample `A`, different from the primitive and from `command_valid`: admitted, `fem_feat` becomes 1, the next proposal becomes 1, `command_valid` stays 1.

## Self-audit

The sample is a testbench value. It is not a pin readback. The gate only refuses a sample that equals the command primitive or the one-bit command flag. It does not observe the LED bus.

`pack_vis_runtime` still contains its own Q*. That Q* is not this counted path.
