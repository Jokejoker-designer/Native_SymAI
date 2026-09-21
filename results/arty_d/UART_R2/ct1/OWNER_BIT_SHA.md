# uart_r2_ct1 — exact SHA for owner nạp authorize

**STOP BEFORE PROGRAM.** This file is the identity the owner must quote.

```text
BIT   D:/FPGA/arty_d/UART_R2/build_ct1/uart_r2_ct1_candidate.bit
SHA256  8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c
```

Not `8fc14f25f2b9d936b7d412ce41b6d963991cc91137c20587e3ab5a96b5224df5`.
Bytes compared: **different files**. Live SRAM identity preserved (not programmed this run).

| Artifact | SHA256 |
|---|---|
| bitstream | `8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c` |
| post_route.dcp | `1bd53079c9d0932c891e2e6561aaf82e78ac53dee249614e42b836e74b037b82` |
| post_synth.dcp | `36b73b2b328660e3a1d20b11e59420e5b4cef2092e61ec7e247ccbcec483396e` |
| top.sv | `eec28b9c20b057d616fd6fc3d2eba33002a1ecbdf68b3c3d597f81e3127de1de` |
| dest_root_cache.sv | `c70c733ae1977438612f83482622e1213b9643c8376b0a890999bc7fbd5e87ad` |
| CT1_INT_OBS.json | `a326139363d6bd27e953a9095201f6174b842e28de5901a197fcacf3b7594195` |

Route (BUILD.txt): WNS **+0.556** WHS **+0.022** LUT 11275 FF 10146 RAMB36=0 RAMB18=1 DSP 8.  
`check_timing`: unconstrained_internal_endpoints=0, no_clock=0. DRC: warnings only.  
`TIMING_PASS=NO` `PROGRAM_PASS=NO` `PACK_ABI_24_24_PASS=NO` `RUNTIME_KNOWLEDGE_BINDING_8_8=NOT_RUN`.

Integrated XSim CT1-01..05 `PASS_XSIM` 6047135 ns (`mig_ui_bram` stand-in, not behavioral mig0). T1 occupancy NOT_PROVEN.
