# UART_RX_SAMPLE_XSIM

D_IMPLEMENTED=YES
D_SELF_AUDITED=YES
INDEPENDENT_C_AUDIT=NOT_RUN

CLAIM: UART_RX_SAMPLE_XSIM_CANDIDATE=SUPPORTED
SAMPLE_PORT=uart_rx
SEMANTIC_ROLE=UNKNOWN
BOARD_BUILT=NO
FEM_PERSIST_PASS=NO

Log: `D:/FPGA/arty_d/UART_R2/uart_sample_r1/xsim/uart_rx_sample_r1_xsim.log`
SHA256: `ad481a21970023a932e446b3aa4c252c88a81df1d734b2817632dfd223905e18`
Finish: 782225 ns

Wrapper: `uart_rx_sample_r1.sv`
SHA256: `9f8a89243026fc1a88110f7121c9c5097ea6032608f159295d52ede19870545f`

The receiver is `uart_rx_word` at 115200 8N1, the same module the pack-visibility top uses. `uart_rx` is that top's input pin name. No role was attached.

## What the log shows

A counted command primitive 0 stays valid.

- A UART word whose first byte is `0x00` yields nibble 0. It is not accepted. The next proposal stays 0.
- A UART word whose first byte is `0x0A` yields nibble `A`. It is accepted, `fem_feat` becomes 1, and the next proposal becomes 1. `command_valid` stays 1.

The printed `admitted=0` on the second UART line is the gate after `readback_valid` has already fallen. Acceptance is `ing_accepted=1` together with `fem_feat=1`.

## Self-audit

This is a simulated pin wiggle, not a board capture. The nibble is payload that entered through `uart_rx`. It is not an LED readback and not a semantic role. The hidden Q* inside `pack_vis_runtime` is still not the counted path.
