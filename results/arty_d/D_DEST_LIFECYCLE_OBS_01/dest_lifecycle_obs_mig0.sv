// OBS01-MIG0 checkpoint observer. TB-only. Not an overlay.
// P0..P15 locked causal chain after arm (BEGIN2 after CLEAR2).
// Q4 still BEGIN2→COMMIT→load_ack rise→st_valid. lack_fell is not proof.
// debug_clear MUST NEVER occur while cmd_acc XOR wdf_acc.
`timescale 1ps/1ps

module dest_lifecycle_obs_mig0 #(
  parameter string FNAME = "dest_ckpt_mig0.csv"
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        arm,
  input  logic        p_valid,
  input  logic        p_ready,
  input  logic [31:0] p_data,
  input  logic        mem_cmd_valid,
  input  logic        mem_cmd_ready,
  input  logic        mem_cmd_write,
  input  logic        app_en,
  input  logic        app_rdy,
  input  logic        app_wdf_wren,
  input  logic        app_wdf_rdy,
  input  logic        app_rd_data_valid,
  input  logic [2:0]  ui_st,
  input  logic        cmd_acc,
  input  logic        wdf_acc,
  input  logic        wr_r,
  input  logic [31:0] wdata_r,
  input  logic [31:0] rdata_r,
  input  logic        err_r,
  input  logic [1:0]  lane_r,
  input  logic [127:0] app_rd_data,
  input  logic [15:0] ui_out,
  input  logic        mem_resp_valid,
  input  logic        mem_resp_ready,
  input  logic        mem_resp_err,
  input  logic [3:0]  ld_st,
  input  logic [15:0] ld_out,
  input  logic [1:0]  chk_i,
  input  logic [1:0]  n_rg,
  input  logic        loader_busy,
  input  logic        ui_busy,
  input  logic        debug_clear,
  input  logic        pack_quiescent,
  input  logic [1:0]  mux_g,
  input  logic        load_ack,
  input  logic        st_valid_ui,
  input  logic        st_valid_100,
  output logic [15:0] p_seen,
  output logic [4:0]  last_eq,
  output logic [4:0]  first_div,
  output logic        partial_wr_cmd_only,
  output logic        partial_wr_wdf_only,
  output logic        half_txn_clear,
  output logic [15:0] hist_app_rdy,
  output logic [15:0] hist_app_wdf_rdy,
  output logic [15:0] hist_app_rdv,
  output logic [2:0]  snap_ui_st,
  output logic [15:0] snap_ui_out,
  output logic [3:0]  snap_ld_st,
  output logic [15:0] snap_ld_out,
  output logic [1:0]  snap_mux,
  output logic        snap_dclr,
  output logic        snap_qsc
);
  localparam logic [31:0] BEGINW = 32'h00800001;
  localparam logic [2:0] S_IDLE = 3'd0, S_WR = 3'd1, S_RD = 3'd2, S_WAIT = 3'd3, S_HOLD = 3'd4, S_RSP = 3'd5;
  localparam logic [3:0] LD_COMMIT = 4'd7, LD_DRAIN = 4'd4, LD_RD_WAIT = 4'd6;

  integer fd;
  integer settle_n;
  logic lack_r, stv_r, arm_r, dclr_r;
  logic [15:0] ui_out_r;
  logic p2_now, p3_now, lane_ok;
  logic [15:0] p_lat;
  time t_p [0:15];

  function automatic string pname(input int n);
    case (n)
      0: pname = "P0_BEGIN_ACCEPT";
      1: pname = "P1_MEM_CMD_WRITE_HS";
      2: pname = "P2_APP_EN_RDY_WR";
      3: pname = "P3_APP_WDF_HS_WR";
      4: pname = "P4_ENTER_S_RD_AFTER_P2P3";
      5: pname = "P5_RD_CMD_ACCEPT";
      6: pname = "P6_APP_RD_DATA_VALID";
      7: pname = "P7_LANE_MATCH_WDATA_R";
      8: pname = "P8_UI_OUTSTANDING_DEC";
      9: pname = "P9_MEM_RESP_CONSUME";
      10: pname = "P10_LOADER_OUT_ZERO";
      11: pname = "P11_SENTINEL_OK";
      12: pname = "P12_S_COMMIT";
      13: pname = "P13_LOAD_ACK_RISE";
      14: pname = "P14_STATUS_VALID_RISE";
      15: pname = "P15_SETTLE_IDLE";
      default: pname = "P?";
    endcase
  endfunction

  function automatic logic [31:0] extract32(input logic [127:0] beat, input logic [1:0] ln);
    extract32 = beat[32*ln +: 32];
  endfunction

  initial begin
    fd = $fopen(FNAME, "w");
    if (fd != 0)
      $fwrite(fd, "t_ps,ckpt,ui_st,ui_out,ld_st,ld_out,cmd_acc,wdf_acc,app_en,app_rdy,app_wdf_wren,app_wdf_rdy,app_rdv,mux_g,dclr,qsc,lack,stv\n");
  end

  task automatic dump_p(input int n);
    begin
      if (fd != 0)
        $fwrite(fd, "%0t,%s,%0d,%0d,%0d,%0d,%0b,%0b,%0b,%0b,%0b,%0b,%0b,%0d,%0b,%0b,%0b,%0b\n",
                $time, pname(n), ui_st, ui_out, ld_st, ld_out, cmd_acc, wdf_acc,
                app_en, app_rdy, app_wdf_wren, app_wdf_rdy, app_rd_data_valid,
                mux_g, debug_clear, pack_quiescent, load_ack, st_valid_ui);
      $display("OBS01_CKPT %s t=%0t ui_st=%0d ui_out=%0d ld_st=%0d ld_out=%0d cmd_acc=%0b wdf_acc=%0b",
               pname(n), $time, ui_st, ui_out, ld_st, ld_out, cmd_acc, wdf_acc);
    end
  endtask

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      p_seen <= 16'h0;
      p_lat <= 16'h0;
      partial_wr_cmd_only <= 1'b0;
      partial_wr_wdf_only <= 1'b0;
      half_txn_clear <= 1'b0;
      hist_app_rdy <= 16'h0;
      hist_app_wdf_rdy <= 16'h0;
      hist_app_rdv <= 16'h0;
      snap_ui_st <= 3'd0;
      snap_ui_out <= 16'h0;
      snap_ld_st <= 4'd0;
      snap_ld_out <= 16'h0;
      snap_mux <= 2'd0;
      snap_dclr <= 1'b0;
      snap_qsc <= 1'b0;
      lack_r <= 1'b0;
      stv_r <= 1'b0;
      arm_r <= 1'b0;
      dclr_r <= 1'b0;
      ui_out_r <= 16'h0;
      settle_n <= 0;
    end else begin
      hist_app_rdy     <= {hist_app_rdy[14:0], app_rdy};
      hist_app_wdf_rdy <= {hist_app_wdf_rdy[14:0], app_wdf_rdy};
      hist_app_rdv     <= {hist_app_rdv[14:0], app_rd_data_valid};
      snap_ui_st <= ui_st;
      snap_ui_out <= ui_out;
      snap_ld_st <= ld_st;
      snap_ld_out <= ld_out;
      snap_mux <= mux_g;
      snap_dclr <= debug_clear;
      snap_qsc <= pack_quiescent;

      if (arm && !arm_r) begin
        p_seen <= 16'h0;
        p_lat <= 16'h0;
        settle_n <= 0;
        partial_wr_cmd_only <= 1'b0;
        partial_wr_wdf_only <= 1'b0;
        half_txn_clear <= 1'b0;
      end

      if (arm) begin
        if (ui_st == S_WR) begin
          if (cmd_acc && !wdf_acc) partial_wr_cmd_only <= 1'b1;
          if (wdf_acc && !cmd_acc) partial_wr_wdf_only <= 1'b1;
        end
        if (debug_clear && !dclr_r && (cmd_acc ^ wdf_acc)) begin
          half_txn_clear <= 1'b1;
          $display("OBS01_HALF_TXN_CLEAR cmd_acc=%0b wdf_acc=%0b ui_st=%0d ui_out=%0d ld_st=%0d",
                   cmd_acc, wdf_acc, ui_st, ui_out, ld_st);
        end

        p2_now = (ui_st == S_WR) && app_en && app_rdy;
        p3_now = (ui_st == S_WR) && app_wdf_wren && app_wdf_rdy;
        lane_ok = (extract32(app_rd_data, lane_r) == wdata_r);

        if (!p_lat[0] && p_valid && p_ready && (p_data == BEGINW)) begin
          p_lat[0] <= 1'b1; t_p[0] <= $time; dump_p(0);
        end
        if (p_lat[0] && !p_lat[1] && mem_cmd_valid && mem_cmd_ready && mem_cmd_write) begin
          p_lat[1] <= 1'b1; t_p[1] <= $time; dump_p(1);
        end
        if (p_lat[1] && !p_lat[2] && p2_now) begin
          p_lat[2] <= 1'b1; t_p[2] <= $time; dump_p(2);
        end
        if (p_lat[1] && !p_lat[3] && p3_now) begin
          p_lat[3] <= 1'b1; t_p[3] <= $time; dump_p(3);
        end
        if (p_lat[2] && p_lat[3] && !p_lat[4] && (ui_st == S_RD)) begin
          p_lat[4] <= 1'b1; t_p[4] <= $time; dump_p(4);
        end
        if (p_lat[4] && !p_lat[5] && (ui_st == S_RD) && app_en && app_rdy) begin
          p_lat[5] <= 1'b1; t_p[5] <= $time; dump_p(5);
        end
        if (p_lat[5] && !p_lat[6] && app_rd_data_valid && wr_r) begin
          p_lat[6] <= 1'b1; t_p[6] <= $time; dump_p(6);
          if (lane_ok) begin
            p_lat[7] <= 1'b1; t_p[7] <= $time; dump_p(7);
          end
        end
        if (p_lat[6] && !p_lat[7] && (rdata_r == wdata_r) && !err_r && wr_r) begin
          p_lat[7] <= 1'b1; t_p[7] <= $time; dump_p(7);
        end
        if (p_lat[7] && !p_lat[8] && (ui_out < ui_out_r)) begin
          p_lat[8] <= 1'b1; t_p[8] <= $time; dump_p(8);
        end
        if (p_lat[8] && !p_lat[9] && mem_resp_valid && mem_resp_ready) begin
          p_lat[9] <= 1'b1; t_p[9] <= $time; dump_p(9);
        end
        if (p_lat[9] && !p_lat[10] && (ld_out == 16'h0) && ((ld_st == LD_DRAIN) || (ld_st == 4'd5))) begin
          p_lat[10] <= 1'b1; t_p[10] <= $time; dump_p(10);
        end
        if (p_lat[10] && !p_lat[11] && (ld_st == LD_RD_WAIT) && mem_resp_valid && !mem_resp_err
            && ((chk_i + 2'd1) >= n_rg)) begin
          p_lat[11] <= 1'b1; t_p[11] <= $time; dump_p(11);
        end
        if (p_lat[11] && !p_lat[12] && (ld_st == LD_COMMIT)) begin
          p_lat[12] <= 1'b1; t_p[12] <= $time; dump_p(12);
        end
        if (p_lat[12] && !p_lat[13] && load_ack && !lack_r) begin
          p_lat[13] <= 1'b1; t_p[13] <= $time; dump_p(13);
        end
        if (p_lat[13] && !p_lat[14] && st_valid_ui && !stv_r) begin
          p_lat[14] <= 1'b1; t_p[14] <= $time; dump_p(14);
        end
        if (p_lat[14] && !p_lat[15]) begin
          if ((ld_st == 4'd0) && !loader_busy && (ui_st == S_IDLE) && !ui_busy
              && (ui_out == 16'h0) && !st_valid_ui && !st_valid_100) begin
            if (settle_n >= 63) begin
              p_lat[15] <= 1'b1; t_p[15] <= $time; dump_p(15);
            end else
              settle_n <= settle_n + 1;
          end else
            settle_n <= 0;
        end
      end

      p_seen <= p_lat;
      lack_r <= load_ack;
      stv_r <= st_valid_ui;
      arm_r <= arm;
      dclr_r <= debug_clear;
      ui_out_r <= ui_out;
    end
  end

  always_comb begin
    last_eq = 5'd31;
    first_div = 5'd0;
    if (!p_seen[0]) begin last_eq = 5'd31; first_div = 5'd0; end
    else if (!p_seen[1]) begin last_eq = 5'd0; first_div = 5'd1; end
    else if (!p_seen[2]) begin last_eq = 5'd1; first_div = 5'd2; end
    else if (!p_seen[3]) begin last_eq = 5'd2; first_div = 5'd3; end
    else if (!p_seen[4]) begin last_eq = 5'd3; first_div = 5'd4; end
    else if (!p_seen[5]) begin last_eq = 5'd4; first_div = 5'd5; end
    else if (!p_seen[6]) begin last_eq = 5'd5; first_div = 5'd6; end
    else if (!p_seen[7]) begin last_eq = 5'd6; first_div = 5'd7; end
    else if (!p_seen[8]) begin last_eq = 5'd7; first_div = 5'd8; end
    else if (!p_seen[9]) begin last_eq = 5'd8; first_div = 5'd9; end
    else if (!p_seen[10]) begin last_eq = 5'd9; first_div = 5'd10; end
    else if (!p_seen[11]) begin last_eq = 5'd10; first_div = 5'd11; end
    else if (!p_seen[12]) begin last_eq = 5'd11; first_div = 5'd12; end
    else if (!p_seen[13]) begin last_eq = 5'd12; first_div = 5'd13; end
    else if (!p_seen[14]) begin last_eq = 5'd13; first_div = 5'd14; end
    else if (!p_seen[15]) begin last_eq = 5'd14; first_div = 5'd15; end
    else begin last_eq = 5'd15; first_div = 5'd31; end
  end
endmodule
