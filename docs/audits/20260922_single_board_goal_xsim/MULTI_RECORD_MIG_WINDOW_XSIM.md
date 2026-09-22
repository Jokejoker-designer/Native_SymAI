# Multi-record MIG-window XSim

LANGUAGE=EN
Status: `MULTI_RECORD_MIG_WINDOW_XSIM_CANDIDATE=SUPPORTED`
This is a new identity. It does not modify `90220cb5` or the private-RAM multi-record log.

Log: `D:/FPGA/arty_d/UART_R2/pack_mig_window/xsim/pack_mig_window_xsim.log`
finish 16045 ns
sha256 `6d9b62ab37494d6595fe9e36e5e0fc2632fc3f0e4a688d09667ca6e22ea53591`

Storage is `pack_loader` through `mig_ui32` into `mig_ui_bram`.
The beat index is `{addr[21:20], addr[13:4]}`.
Beat 0 holds subject `0x00010100`. Beat 4 holds subject `0x00010101`.
This stand-in is not generated `mig0`. It is not `MIG_PASS`.

The discriminator matches the multi-record XSim: one generation, two subjects, unknown subject misses, stale reject leaves the root, and the next query issues a new command.

```text
MIG_PASS=NO BOARD_PASS=NO PROGRAM_PASS=NO TIMING_PASS=NO PACK_ABI_24_24_PASS=NO ASTRA_PASS=NO
```

No bitstream until an independent audit says this new cut needs silicon.
