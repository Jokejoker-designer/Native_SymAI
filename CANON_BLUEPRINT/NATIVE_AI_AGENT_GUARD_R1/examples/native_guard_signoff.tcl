# Example. Prefer generating a fresh version with:
# native-guard vivado-tcl --out native_guard_signoff.tcl --reports-dir reports/signoff
set outdir "reports/signoff"
file mkdir $outdir
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file "$outdir/timing_summary.rpt"
report_methodology -file "$outdir/methodology.rpt"
report_drc -file "$outdir/drc.rpt"
report_clock_interaction -file "$outdir/clock_interaction.rpt"
catch { report_cdc -details -file "$outdir/cdc.rpt" }
catch { report_utilization -file "$outdir/utilization.rpt" }
catch { report_route_status -file "$outdir/route_status.rpt" }
catch { report_high_fanout_nets -timing -load_types -max_nets 100 -file "$outdir/high_fanout.rpt" }
catch { report_qor_suggestions -file "$outdir/qor_suggestions.rpt" }
catch { check_timing -verbose > "$outdir/check_timing.rpt" }
