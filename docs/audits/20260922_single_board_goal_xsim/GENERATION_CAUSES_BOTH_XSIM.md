# GENERATION_CAUSES_BOTH_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: GENERATION_CAUSES_BOTH_XSIM_CANDIDATE=SUPPORTED
ANSWER_EMITTED=NO
ASTRA_PASS=NO
FEM_PERSIST_PASS=NO
MIG_PASS=NO
BOARD_BUILT=NO

Log: `D:/FPGA/arty_d/UART_R2/generation_both_r1/xsim/generation_causes_both_r1_xsim.log`
SHA256: `4dcf42753993cf3af2c74bb514246bc239bb701ecfcffa3aeb48fa0c63b06f31`
Finish: 6755 ns

Wrapper: `generation_causes_both_r1.sv`
SHA256: `c550e225296cccab71d7b70a4ee3b8f7cbdf6b3c0cad514b22c61db04ca86441`

`pack_vis_runtime.sv` and `experience_next_r1.sv` were instantiated and not edited.

## What the log shows

Query generation is `0x00AB` on every query.

- No commit: status `0x02`, evidence ref 0, no command. Effect 3 is not accepted.
- Commit generation 1: directory generation 1, evidence ref `025bb7b4`, status `0x04`, action verdict `B0`, command primitive 0. The later proposal stays 0.
- Effect 3 after that command: `fem_feat` 1, later proposal 1.

## Self-audit

The query fields are still a projection of the pack descriptor, not a second walker. Status `0x01` is not emitted.

The command primitive comes from the Q* inside `pack_vis_runtime`. The later proposal comes from the Q* inside `experience_next_r1`. One commit causes both the evidence identity and the command that opens the experience gate. It does not yet make that later proposal the same Q* instance that issued the command.

The effect value is still a testbench constant. `t2_ready` stays tied. This is not a pin readback and not DDR.
