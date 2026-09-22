# G2_PLANT_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: G2_PLANT_XSIM_CANDIDATE=SUPPORTED
BOARD_BUILT=NO
PLANT_SUBSTITUTE=YES
EFFECT_CODE_FROM_TB=NO
FEM_PERSIST_PASS=NO

Log: `D:/FPGA/arty_d/UART_R2/g2_plant_r1/xsim/g2_plant_r1_xsim.log`
SHA256: `f66a75fbd86918b4f87af866655edab1e683f9e19b5cad68885c5df1338e8ebd`
Finish: 9865 ns

Plant: `command_plant_r1.sv`
SHA256: `6689462b43589b782ea5b99ae66bbd1c55a17469387d1ecd1f7dab65bc8a2a6f`

Top: `g2_plant_r1.sv`
SHA256: `b184053b34bd201aa39ac931586d5b73a93786bbf3d8c2515f5962e79a68ad64`

The testbench has no effect-code port. `g2_two_effects_r1.sv` and `primitive_executor_r1.sv` were not edited.

## What the log shows

Plant state starts at 0. Each act after a latched command does `state <= state + primitive`.

- Before a command, an act returns `FB_NO_BINDING` and the plant stays 0.
- Generation 2, slot 1, ref `f2a071fe`, status `0x04`. Command `C001` primitive 1. The proposal is 1.
- First act: `0 + 1 = 1`. That equals the primitive, so FEM does not take it. The proposal stays 1. The id stays `C001`.
- Second act: `1 + 1 = 2`. FEM takes it. The proposal becomes 0. `command_valid` stays 1, the primitive stays 1, and the id stays `C001`.
- The later query is still slot 1, ref `f2a071fe`. The proposal stays 0.

## Self-audit

The plant is an adder inside the FPGA design. It is not a pin, not a sensor, and not `mig0`. A bitstream of this identity would replay the adder. `t2_ready` is tied 1. ANSWER is not emitted. This run does not justify programming.
