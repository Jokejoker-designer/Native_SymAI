// D_DEST_LIFECYCLE_OBS_01 — TB-only change dump at ui_clk. Not synthesizable overlay.
// Does not patch UART / dest_accept / C RTL.
`timescale 1ns/1ps

module dest_lifecycle_obs (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        enable,
  input  logic        calib_done,
  input  logic        p_valid,
  input  logic        p_ready,
  input  logic [31:0] p_data,
  input  logic [3:0]  ld_state,
  input  logic        loader_busy,
  input  logic [15:0] loader_wr_outstanding,
  input  logic [2:0]  ui_state,
  input  logic [15:0] ui_outstanding,
  input  logic        ui_busy,
  input  logic        p_en,
  input  logic        p_rdy,
  input  logic        p_wren,
  input  logic        p_wdf_rdy,
  input  logic        app_en,
  input  logic        app_rdy,
  input  logic        app_wdf_wren,
  input  logic        app_wdf_rdy,
  input  logic        app_rd_data_valid,
  input  logic [1:0]  mux_g,
  input  logic        pack_quiescent,
  input  logic        debug_clear,
  input  logic        load_ack,
  input  logic        load_reject,
  input  logic [7:0]  reason_code,
  input  logic [31:0] active_generation,
  input  logic        ack_d,
  input  logic        st_valid_ui
);
  integer fd;
  logic seen;
  logic calib_r, pv_r, pr_r, lbusy_r, ubusy_r, pen_r, prdy_r, pwren_r, pwdf_r;
  logic aen_r, ardy_r, awren_r, awdf_r, ardv_r, qsc_r, dclr_r, lack_r, lrej_r, ackd_r, stv_r;
  logic [31:0] pdata_r, agen_r;
  logic [3:0] ld_r;
  logic [2:0] ui_r;
  logic [15:0] lout_r, uout_r;
  logic [1:0] g_r;
  logic [7:0] rsn_r;

  function automatic string ld_name(input logic [3:0] s);
    case (s)
      4'd0:  ld_name = "IDLE";
      4'd1:  ld_name = "RX";
      4'd2:  ld_name = "DEC";
      4'd3:  ld_name = "WRITE";
      4'd4:  ld_name = "DRAIN";
      4'd5:  ld_name = "RD_ISSUE";
      4'd6:  ld_name = "RD_WAIT";
      4'd7:  ld_name = "COMMIT";
      4'd8:  ld_name = "OK";
      4'd9:  ld_name = "EDRAIN";
      4'd10: ld_name = "REJECT";
      4'd11: ld_name = "WR_WAIT";
      4'd12: ld_name = "CRC_WAIT";
      default: ld_name = "UNK";
    endcase
  endfunction

  function automatic string ui_name(input logic [2:0] s);
    case (s)
      3'd0: ui_name = "IDLE";
      3'd1: ui_name = "WR";
      3'd2: ui_name = "RD";
      3'd3: ui_name = "WAIT";
      3'd4: ui_name = "HOLD";
      3'd5: ui_name = "RSP";
      default: ui_name = "UNK";
    endcase
  endfunction

  initial begin
    fd = $fopen("dest_ui_clk.csv", "w");
    if (fd == 0)
      fd = $fopen("D:/FPGA/arty_d/D_DEST_LIFECYCLE_OBS_01/out/dest_ui_clk.csv", "w");
    $fwrite(fd, "t_ps,event,calib,p_valid,p_ready,p_data,ld_st,ld_name,ld_busy,ld_out,ui_st,ui_name,ui_out,ui_busy,p_en,p_rdy,p_wren,p_wdf_rdy,app_en,app_rdy,app_wdf_wren,app_wdf_rdy,app_rdv,mux_g,qsc,debug_clear,load_ack,load_reject,reason,agen,ack_d,st_valid_ui\n");
  end

  task automatic dump(input string ev);
    begin
      if (fd != 0)
        $fwrite(fd, "%0t,%s,%0b,%0b,%0b,%08h,%0d,%s,%0b,%0d,%0d,%s,%0d,%0b,%0b,%0b,%0b,%0b,%0b,%0b,%0b,%0b,%0b,%0d,%0b,%0b,%0b,%0b,%02h,%08h,%0b,%0b\n",
                $time, ev, calib_done, p_valid, p_ready, p_data,
                ld_state, ld_name(ld_state), loader_busy, loader_wr_outstanding,
                ui_state, ui_name(ui_state), ui_outstanding, ui_busy,
                p_en, p_rdy, p_wren, p_wdf_rdy,
                app_en, app_rdy, app_wdf_wren, app_wdf_rdy, app_rd_data_valid,
                mux_g, pack_quiescent, debug_clear,
                load_ack, load_reject, reason_code, active_generation,
                ack_d, st_valid_ui);
    end
  endtask

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      seen <= 1'b0;
    end else if (enable) begin
      if (!seen) begin
        dump("ARM");
        seen <= 1'b1;
      end else begin
        if (debug_clear && !dclr_r) dump("DEBUG_CLEAR_RISE");
        else if (!debug_clear && dclr_r) dump("DEBUG_CLEAR_FALL");
        else if (load_ack && !lack_r) dump("LOAD_ACK_RISE");
        else if (!load_ack && lack_r) dump("LOAD_ACK_FALL");
        else if (load_reject && !lrej_r) dump("LOAD_REJECT_RISE");
        else if (st_valid_ui && !stv_r) dump("ST_VALID_UI_RISE");
        else if (p_valid && p_ready && (p_data == 32'h00800001)) dump("P_BEGIN");
        else if (p_valid && p_ready && (p_data != pdata_r)) dump("P_FIRE");
        else if (ui_state != ui_r) dump("UI_ST");
        else if (ld_state != ld_r) dump("LD_ST");
        else if (ui_outstanding != uout_r) dump("UI_OUT");
        else if (loader_wr_outstanding != lout_r) dump("LD_OUT");
        else if (mux_g != g_r) dump("MUX_G");
        else if (pack_quiescent != qsc_r) dump("QSC");
        else if (app_rd_data_valid && !ardv_r) dump("APP_RDV");
        else if ((p_en && p_rdy) || (app_en && app_rdy) || (p_wren && p_wdf_rdy) || (app_wdf_wren && app_wdf_rdy))
          dump("UI_BEAT");
      end
      calib_r <= calib_done;
      pv_r <= p_valid; pr_r <= p_ready; pdata_r <= p_data;
      ld_r <= ld_state; lbusy_r <= loader_busy; lout_r <= loader_wr_outstanding;
      ui_r <= ui_state; uout_r <= ui_outstanding; ubusy_r <= ui_busy;
      pen_r <= p_en; prdy_r <= p_rdy; pwren_r <= p_wren; pwdf_r <= p_wdf_rdy;
      aen_r <= app_en; ardy_r <= app_rdy; awren_r <= app_wdf_wren; awdf_r <= app_wdf_rdy;
      ardv_r <= app_rd_data_valid; g_r <= mux_g; qsc_r <= pack_quiescent; dclr_r <= debug_clear;
      lack_r <= load_ack; lrej_r <= load_reject; rsn_r <= reason_code; agen_r <= active_generation;
      ackd_r <= ack_d; stv_r <= st_valid_ui;
    end
  end
endmodule
