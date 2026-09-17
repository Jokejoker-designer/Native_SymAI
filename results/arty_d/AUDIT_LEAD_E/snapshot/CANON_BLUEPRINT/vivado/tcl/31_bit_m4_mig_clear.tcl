# Bitstream VALIDATION_CLEAR candidate. New name; do not overwrite f6a6091f...
set out {D:/FPGA/arty_d/m4_mig_clear}
open_checkpoint [file join $out post_route_clear.dcp]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force [file join $out arty_a7_r2_top_m4_mig_validation_clear.bit]
puts "M4_MIG_CLEAR_BITSTREAM_WRITTEN"
exit
