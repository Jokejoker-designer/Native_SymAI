# G2_TWO_EFFECTS_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: G2_TWO_EFFECTS_XSIM_CANDIDATE=SUPPORTED
BOARD_BUILT=NO
EFFECT_TABLE_SUBSTITUTE=YES
FEM_PERSIST_PASS=NO
MIG_PASS=NO

Log: `D:/FPGA/arty_d/UART_R2/g2_two_effects_r1/xsim/g2_two_effects_r1_xsim.log`
SHA256: `af36b339d6e4ff39ab26b15225f53c6b5d32c4fa61fbe7653ffa2670598f7dcb`
Finish: 9935 ns

Top: `g2_two_effects_r1.sv`
SHA256: `935bf68850c495542f2e38068e776aa9585f8875a10269078d2b4050bf5a1627`

Hold: `command_effect_hold_r1.sv`
SHA256: `45893397cd82a7bc7aa2604fefa618e13bd1c115dca96683e84f99762ad2ee67`

`primitive_executor_r1.sv` and `g2_observe_r1.sv` were not edited. xvlog lists one `qstar_select.v`.

## What the log shows

- Before any command, the primitive-1 row is `FB_SUCCESS` (0). The sense result is `FB_NO_BINDING` (3). `fem_feat` stays 0.
- Generation 2, slot 1, ref `f2a071fe`, status `0x04`, proposal 1. A sense before `decision_done` is still `FB_NO_BINDING`.
- Command `C001` primitive 1. `command_generation` is `16'h0007`. The next proposal stays 1.
- The same id is sensed with code 1, which equals the primitive. `fem_feat` stays 0. The proposal stays 1. The id stays `C001`.
- The same id is sensed with code 4 (`FB_ABORTED`). `fem_feat` becomes 1. The proposal becomes 0. `command_valid` stays 1, the primitive stays 1, and the id stays `C001`.
- The later query is still slot 1, ref `f2a071fe`. The proposal stays 0.

Code 1 was rejected because it equals primitive 1. It was not rejected by a FAILURE classifier. The success row was not returned when no command was latched.

## Self-audit

The table is written by the testbench. It is not a pin and not a sensor. Silicon of this identity would replay the table. `t2_ready` is tied 1. ANSWER is not emitted.
