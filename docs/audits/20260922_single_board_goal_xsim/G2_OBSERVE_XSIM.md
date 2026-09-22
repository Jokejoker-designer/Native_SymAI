# G2_OBSERVE_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: G2_OBSERVE_XSIM_CANDIDATE=SUPPORTED
BOARD_BUILT=NO
ASTRA_PASS=NO
MIG_PASS=NO
FEM_PERSIST_PASS=NO

Log: `D:/FPGA/arty_d/UART_R2/g2_observe_r1/xsim/g2_observe_r1_xsim.log`
SHA256: `b2da5485a1783ee62db450063eff983217a2693f0b6c6fb182add6674c0cf4dc`
Finish: 1519865 ns

Module: `g2_observe_r1.sv`
SHA256: `6ae92f047b41816b622beb35b1ad4055ffed5f6ae5c28a29d4af105efffde824`

xvlog lists one `qstar_select.v`, `fem_lifecycle.v`, `uart_rx_word.sv`, and `fetch_active_r1.sv`. It does not list `pack_vis_runtime.sv` or `spear_rank.v`. `policy_active_slot_r1.sv` was not edited.

## What the log shows

Query generation stays `0x00AB`. Status is `0x04` with the generation-2 record and `0x02` before any commit. Status `0x01` is not emitted.

- Before a commit, UART byte `0x0A` is not accepted.
- Generation 1 then generation 2: 24 writes. The visible window is slot 1, ref `f2a071fe`, evidence generation 2. The proposal is 1.
- The same byte `0x0A` before `decision_done` is not accepted. The proposal stays 1.
- The command is `C001` primitive 1. `command_generation` is `16'h0007`.
- A later proposal while `command_valid` stays 1 is still 1.
- UART byte `0x01` matches that primitive. `fem_feat` stays 0. The proposal stays 1.
- UART byte `0x0A` is accepted (`saw=1`, `fem_feat=1`). The next proposal is 0. `command_valid` stays 1 and the command primitive stays 1.
- A later query still returns slot 1, ref `f2a071fe`, evidence generation 2. The proposal stays 0.

FEATURE_MAP_SUBSTITUTE=YES. THETA_SUBSTITUTE=YES. Feature 2 is weighted on action 1 so generation 2 selects primitive 1. Feature 1 is weighted on action 0 so the accepted observation moves the proposal from 1 to 0. Two legal actions cannot show a third choice.

T2_READY=TIED_1_LOCAL_MODEL. UART_ROLE=UNKNOWN. The sample is a simulated 115200 waveform on `uart_rx`, not a board capture.

## Self-audit

This is one XSim identity. It is not a programmed SRAM image, not `mig0`, and not an ANSWER with proof. The effect is still a UART nibble, not a sensed pin result.
