# Timing/CDC Sign-off Contract

Timing is not a final one-line WNS check. A build is not eligible for post-route acceptance unless all required evidence is present.

## Required post-route evidence

- `report_timing_summary` including setup, hold, pulse width and unconstrained-path checks.
- `check_timing -verbose` review.
- `report_clock_interaction` review for every clock-domain relationship.
- `report_cdc -details` review for asynchronous crossings.
- `report_methodology` with no unresolved critical methodology issue.
- `report_drc` with no unresolved critical DRC.
- `report_utilization` and congestion/QoR review.
- high-fanout review for reset, valid/ready, enable, generation, and global control nets.
- exact XDC hash, top, FPGA part, Vivado version, implementation strategy/seed, and routed DCP hash.

## Timing failure classes to classify before patching

1. **Constraint failure:** missing/generated clock, incorrect uncertainty, false/multicycle exception, unconstrained I/O/path.
2. **CDC/reset failure:** unsafe data crossing, reset deassertion, pulse transfer, multi-bit coherence.
3. **Logic-depth failure:** long combinational chain, wide compare/mux, priority encoder, proof/path logic.
4. **Routing/congestion failure:** high fanout, placement density, BRAM/DSP distance, replicated control.
5. **Memory-interface failure:** MIG domain crossing, app/AXI handshake assumptions, long return path.
6. **Architecture failure:** required parallelism simply cannot close at target clock/resource budget.

Do not "fix" timing by broad `set_false_path` or `set_clock_groups` unless the path is functionally asynchronous and the crossing structure is independently safe. A timing exception is part of the design and must be reviewed like RTL.

## Gate

Default hard gate: WNS >= 0, TNS = 0, WHS >= 0, THS = 0, unconstrained paths = 0. Projects may preregister stricter positive margin, but never loosen the threshold after observing failure.
