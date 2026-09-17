# FROZEN historical bitgen. Do NOT run: would overwrite arty_a7_r2_top_m4_mig_candidate.bit f6a6091f...
# CLEAR candidate uses 31_bit_m4_mig_clear.tcl
puts "REFUSE: 27_bit_m4_mig.tcl is historical. Use 31_bit_m4_mig_clear.tcl"
exit 1
# Bitstream from M4+mig0 routed candidate. PROGRAM=NO. Do not program board.
# Do not clobber freeze / mig_uiclk / mig_tx DCPs. Not BOARD_PASS / TIMING_PASS.
set out {D:/FPGA/arty_d/m4_mig}
open_checkpoint [file join $out post_route.dcp]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force [file join $out arty_a7_r2_top_m4_mig_candidate.bit]
puts "M4_MIG_BITSTREAM_WRITTEN"
exit
