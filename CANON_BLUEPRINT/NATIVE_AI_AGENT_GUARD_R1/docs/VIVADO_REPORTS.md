# Vivado Evidence Bundle Required by Guard

The guard expects evidence, not a single green implementation status.

Recommended report commands after synthesis/implementation:

```tcl
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose
report_methodology
report_drc
report_clock_interaction
report_cdc -details
report_utilization
report_route_status
report_high_fanout_nets -timing -load_types -max_nets 100
report_qor_suggestions
check_timing -verbose
```

Why each exists:

- **Timing summary:** setup/hold sign-off and unconstrained-path detection.
- **Methodology:** catches RTL/netlist/constraint/implementation methodology violations that can compromise closure.
- **Clock interaction:** reviews relationships among clock domains; a timing PASS with a wrongly declared asynchronous relationship is not trusted.
- **CDC:** detects unsafe asynchronous crossings; simulation may not expose metastability/coherency defects.
- **DRC:** catches device/implementation rule violations.
- **Utilization/high fanout/QoR:** catches late congestion and routing risk before it becomes a bitstream blocker.
- **check_timing:** validates completeness/consistency of timing constraints.

AMD Vivado UG906 treats Report Timing Summary as timing sign-off and provides `report_methodology`, `report_clock_interaction`, and `report_qor_suggestions` for design-analysis/closure workflows. The project still requires human review for report classes the parser cannot prove mechanically.
