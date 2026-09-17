// AGENT_B ASTRA adv constants. Not DUT RTL. PROGRAM=NO.
`ifndef ASTRA_ADV_CONSTANTS_SVH
`define ASTRA_ADV_CONSTANTS_SVH
localparam integer ASTRA_ADV_N = 21;
localparam integer ASTRA_ADV_MAX_WORDS = 16;
localparam integer ASTRA_ADV_RESULT_WORDS = 12;
localparam [7:0] ASTRA_ADV_ST_UNKNOWN = 8'h02;
localparam [7:0] ASTRA_ADV_ILLEGAL_00 = 8'h00;
localparam [7:0] ASTRA_ADV_ILLEGAL_22 = 8'h22;
localparam [7:0] ASTRA_ADV_ILLEGAL_55 = 8'h55;
localparam [7:0] ASTRA_ADV_ILLEGAL_80 = 8'h80;
localparam integer ASTRA_ADV_MODE_COMPARE = 0;
localparam integer ASTRA_ADV_MODE_CLASSIFY = 1;
localparam integer ASTRA_ADV_MODE_PROTOCOL = 2;
localparam integer ASTRA_ADV_MODE_REWARD = 3;
localparam [7:0] ASTRA_ADV_ILLEGAL_23 = 8'h23;
localparam [7:0] ASTRA_ADV_ILLEGAL_56 = 8'h56;
`endif
