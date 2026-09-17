# Parallel-Agent FPGA Failure Model

| ID | Failure mode | Why it can destroy the project | Preventive control |
|---|---|---|---|
| A01 | Two agents edit same RTL/XDC/canon file | semantic merge conflict or silent override | separate worktrees + file leases + protected paths |
| A02 | Source changes while Vivado is running | bitstream no longer corresponds to reviewed source | pre/post source manifest; mid-build change = FAIL |
| A03 | Agents share `.runs/.Xil/IP` state | stale DCP/generated IP contaminates build | isolated per-run directories; never shared implementation state |
| A04 | Wrong top/part/XDC selected | valid bitstream for wrong design | build manifest pins top/part/XDC hashes |
| A05 | Tool/version/strategy/seed drift | irreproducible QoR/timing | record exact Vivado/version/strategy/seed; compare manifests |
| A06 | Timing falsely passes due to missing constraints | hardware failure despite green WNS | unconstrained-path=0, check_timing, clock interaction, methodology review |
| A07 | Broad false/multicycle path masks real bug | corruption in silicon | exception inventory + CDC/functional review |
| A08 | CDC/reset crossing unsafe | intermittent board-only failures | report_cdc, clock interaction, synchronizer/async FIFO/reset assertions |
| A09 | Hold/recovery/removal ignored | intermittent startup/runtime failure | setup+hold+reset timing gate |
| A10 | High fanout/congestion explosion | route/timing collapse late in project | early OOC synth, utilization budget, high-fanout/QoR reports |
| A11 | BRAM/LUT/DSP budget drift | integration cannot fit | per-block resource envelope + delta tracking |
| A12 | Incremental checkpoint contamination | stale implementation hides functional change | clean rebuild for acceptance; DCP lineage hash |
| A13 | Host/RTL/pack ABI drift | correct components talk incompatible formats | ABI fingerprint gate across compiler/host/RTL/schema |
| A14 | Gold/threshold edited after failure | false benchmark PASS | protected benchmark files + hash freeze + role separation |
| A15 | Compiler and verifier share bug | invalid pack self-validates | independent verifier implementation and test vectors |
| A16 | Negative evidence overwritten | impossible causal audit | append-only hash-chained evidence log |
| A17 | Agent promotes old bit/pack | stale lineage accepted | candidate manifest binds source→reports→bit→pack→tests |
| A18 | Two agents access JTAG/UART/board | corrupt programming/capture | exclusive hardware leases |
| A19 | Loader ACK before memory commit | apparent load PASS but stale DDR | write-drain/readback gate and assertions |
| A20 | Cache generation stale | ablation/pack switch returns old answer | generation tags + cache parity + atomic switch |
| A21 | Simulation hangs/deadlocks | agent waits forever / mislabels timeout | watchdog runner + exact PASS marker + timeout = FAIL |
| A22 | Random test seed not recorded | unreproducible failure | seed in run manifest and logs |
| A23 | Warnings treated as harmless | hidden latch/blackbox/multidriver | critical-pattern log scanner + explicit waiver registry |
| A24 | Agent self-stamps BOARD_PASS | governance collapse | owner-only promotion workflow; agent output limited to candidate |
| A25 | Disk/path/locked-file issues on Windows | partial/generated artifacts | atomic writes; quarantine, not delete; isolated paths |
| A26 | Security/destructive command | source/evidence loss | sandbox paths, predefined stage commands, no implicit shell execution |
