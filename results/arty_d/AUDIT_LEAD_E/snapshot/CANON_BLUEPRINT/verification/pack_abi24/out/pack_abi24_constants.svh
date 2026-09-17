// AGENT_B Pack/ABI-24 constants. Not DUT RTL. PROGRAM=NO.
`ifndef PACK_ABI24_CONSTANTS_SVH
`define PACK_ABI24_CONSTANTS_SVH
localparam integer PACK_HDR_BYTES = 128;
localparam integer PACK_HDR_PREFIX = 112;
localparam integer PACK_HDR_RESERVED = 12;
localparam [31:0] PACK_MAGIC_NAI1 = 32'h3149414E;
localparam [7:0] PACK_RC_OK = 8'h00;
localparam [7:0] PACK_RC_BAD_MAGIC = 8'h01;
localparam [7:0] PACK_RC_ABI_MISMATCH = 8'h02;
localparam [7:0] PACK_RC_SCHEMA_MISMATCH = 8'h03;
localparam [7:0] PACK_RC_MANIFEST_CRC = 8'h04;
localparam [7:0] PACK_RC_PAGE_CRC = 8'h05;
localparam [7:0] PACK_RC_UNSUPPORTED = 8'h07;
localparam [7:0] PACK_RC_HEADER_LENGTH = 8'h09;
localparam [7:0] PACK_RC_RESERVED_NZ = 8'h0A;
localparam [7:0] PACK_RC_CONTENT_MISMATCH = 8'h0D;
localparam [7:0] PACK_RC_STALE_PACK_GENERATION = 8'h0E;
localparam [7:0] PACK_RC_TRUNCATED = 8'h0F;
localparam integer PACK_ABI24_N = 24;
localparam [255:0] PACK_SCHEMA_ID_R01 = 256'h689ead99996082016c91c9d41ced054b1c9d5e02d86214b64e4599babd5a5a20;
`endif
