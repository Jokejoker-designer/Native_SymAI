# U27 XSim FAIL — not programmed

Soft CLEAR (ACK, `debug_clear=0`) CONTRADICTED as a 24/24 path.

- leftover: `UART_R2_U27_LEFTOVER_XSIM_PASS` 4852145 ns
- four V-04: V04_1 GOLD then V04_2 mute `UART_R2_U27_TWO_V04_XSIM_FAIL` 27167995 ns dest=`mig_ui_bram`

Repeated V-04 needs `debug_clear` of loader/ui32 even on BRAM. Do not build/program U27. Do not patch U25/U26.
