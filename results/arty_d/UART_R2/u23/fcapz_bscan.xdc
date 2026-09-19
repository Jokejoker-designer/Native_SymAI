# UART_R2_U23 fcapz BSCANE2 TCK vs fabric. Apply AFTER synth (cells exist).
# Clock name matches PACKAGE arty_a7_mig.xdc. Not identity H / freeze.
if {[llength [get_cells -quiet -hierarchical -filter {REF_NAME == BSCANE2}]] == 0} {
  puts "U23_FCAPZ_XDC_WARN no BSCANE2 cells yet"
} else {
  create_clock -name tck_bscan -period 100.0 \
      [get_pins -of_objects [get_cells -hierarchical -filter {REF_NAME == BSCANE2}] \
                -filter {REF_PIN_NAME == TCK}]
  set_clock_groups -asynchronous \
      -group [get_clocks -include_generated_clocks sys_clk_pin] \
      -group [get_clocks tck_bscan]
  puts "U23_FCAPZ_XDC_OK tck_bscan"
}
