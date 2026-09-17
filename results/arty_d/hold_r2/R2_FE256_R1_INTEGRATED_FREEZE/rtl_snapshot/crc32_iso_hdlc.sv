// CRC-32/ISO-HDLC (zlib.crc32 / Ethernet). Bit-reflected poly 0xEDB88320.
// init 0xFFFFFFFF, xorout 0xFFFFFFFF.
// D-02: one reflected byte per cycle (not 4-byte combo) so the CRC D-input
// is not a 32-iteration chain. Caller must hold valid data only when !busy
// and must not sample crc_out until busy==0 after the last covered beat.
module crc32_iso_hdlc (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        init,
  input  logic        valid,
  input  logic [31:0] data,
  input  logic [2:0]  nbytes,
  output logic        busy,
  output logic [31:0] crc_reg,
  output logic [31:0] crc_out
);
  logic [31:0] acc;
  logic [31:0] hold;
  logic [2:0]  nleft;

  function automatic [31:0] crc_byte(input [31:0] c_in, input [7:0] b);
    logic [31:0] x;
    integer i;
    begin
      x = c_in ^ {24'h0, b};
      for (i = 0; i < 8; i++) begin
        if (x[0])
          x = (x >> 1) ^ 32'hEDB88320;
        else
          x = (x >> 1);
      end
      crc_byte = x;
    end
  endfunction

  function automatic [31:0] crc_word(input [31:0] c_in, input [31:0] d, input [2:0] n);
    logic [31:0] x;
    begin
      x = c_in;
      x = crc_byte(x, d[7:0]);
      if (n[1] | n[2])
        x = crc_byte(x, d[15:8]);
      if (n[1] & n[0] | n[2])
        x = crc_byte(x, d[23:16]);
      if (n[2])
        x = crc_byte(x, d[31:24]);
      crc_word = x;
    end
  endfunction

  assign crc_reg = acc;
  assign crc_out = ~acc;
  assign busy = (nleft != 3'd0);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc <= 32'hFFFF_FFFF;
      hold <= 32'd0;
      nleft <= 3'd0;
    end else if (init) begin
      acc <= 32'hFFFF_FFFF;
      nleft <= 3'd0;
    end else if (nleft != 3'd0) begin
      acc <= crc_byte(acc, hold[7:0]);
      hold <= {8'h00, hold[31:8]};
      nleft <= nleft - 3'd1;
    end else if (valid && nbytes != 3'd0) begin
      acc <= crc_byte(crc_byte(crc_byte(crc_byte(acc, data[7:0]), data[15:8]), data[23:16]), data[31:24]);
      nleft <= 3'd0;
    end
  end
endmodule
