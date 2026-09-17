// clk_arty_mig.sv — 100 MHz Arty osc -> MIG sys 166.667 MHz + 200 MHz ref.
// CANDIDATE. PROGRAM=NO. Generated mig0 InputClkFreq=166.666 (CLKIN_PERIOD=6000).
`timescale 1ns/1ps

module clk_arty_mig (
  input  logic clk100,
  input  logic rst_n,
  output logic clk_sys166,
  output logic clk_ref200,
  output logic clk_locked
);
  logic clkfb, clkfb_u;
  logic clk166_u, clk200_u;

  MMCME2_ADV #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKIN1_PERIOD(10.000),
    .CLKFBOUT_MULT_F(10.000),
    .DIVCLK_DIVIDE(1),
    .CLKOUT0_DIVIDE_F(6.000),
    .CLKOUT1_DIVIDE(5),
    .REF_JITTER1(0.010)
  ) mmcm (
    .CLKIN1(clk100),
    .CLKIN2(1'b0),
    .CLKINSEL(1'b1),
    .CLKFBIN(clkfb),
    .CLKFBOUT(clkfb_u),
    .CLKFBOUTB(),
    .CLKOUT0(clk166_u),
    .CLKOUT0B(),
    .CLKOUT1(clk200_u),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .LOCKED(clk_locked),
    .PWRDWN(1'b0),
    .RST(~rst_n),
    .DADDR(7'h0),
    .DCLK(1'b0),
    .DEN(1'b0),
    .DI(16'h0),
    .DWE(1'b0),
    .DO(),
    .DRDY(),
    .PSCLK(1'b0),
    .PSEN(1'b0),
    .PSINCDEC(1'b0),
    .PSDONE(),
    .CLKINSTOPPED(),
    .CLKFBSTOPPED()
  );

  BUFG bfb (.I(clkfb_u), .O(clkfb));
  BUFG b166 (.I(clk166_u), .O(clk_sys166));
  BUFG b200 (.I(clk200_u), .O(clk_ref200));
endmodule
