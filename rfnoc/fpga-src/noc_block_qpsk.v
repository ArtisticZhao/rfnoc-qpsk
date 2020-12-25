
//
/*
 * Copyright 2020 <+YOU OR YOUR COMPANY+>.
 *
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

//
module noc_block_qpsk #(
  parameter NOC_ID = 64'h3A1D01E879CEB9B3,
  parameter STR_SINK_FIFOSIZE = 11)
(
  input bus_clk, input bus_rst,
  input ce_clk, input ce_rst,
  input  [63:0] i_tdata, input  i_tlast, input  i_tvalid, output i_tready,
  output [63:0] o_tdata, output o_tlast, output o_tvalid, input  o_tready,
  output [63:0] debug
);

  ////////////////////////////////////////////////////////////
  //
  // RFNoC Shell
  //
  ////////////////////////////////////////////////////////////
  wire [31:0] set_data;
  wire [7:0]  set_addr;
  wire        set_stb;
  reg  [63:0] rb_data;
  wire [7:0]  rb_addr;

  wire [63:0] cmdout_tdata, ackin_tdata;
  wire        cmdout_tlast, cmdout_tvalid, cmdout_tready, ackin_tlast, ackin_tvalid, ackin_tready;

  wire [63:0] str_sink_tdata, str_src_tdata;
  wire        str_sink_tlast, str_sink_tvalid, str_sink_tready, str_src_tlast, str_src_tvalid, str_src_tready;

  wire [15:0] src_sid;
  wire [15:0] next_dst_sid, resp_out_dst_sid;
  wire [15:0] resp_in_dst_sid;

  wire        clear_tx_seqnum;

  noc_shell #(
    .NOC_ID(NOC_ID),
    .STR_SINK_FIFOSIZE(STR_SINK_FIFOSIZE))
  noc_shell (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .i_tdata(i_tdata), .i_tlast(i_tlast), .i_tvalid(i_tvalid), .i_tready(i_tready),
    .o_tdata(o_tdata), .o_tlast(o_tlast), .o_tvalid(o_tvalid), .o_tready(o_tready),
    // Computer Engine Clock Domain
    .clk(ce_clk), .reset(ce_rst),
    // Control Sink
    .set_data(set_data), .set_addr(set_addr), .set_stb(set_stb), .set_time(), .set_has_time(),
    .rb_stb(1'b1), .rb_data(rb_data), .rb_addr(rb_addr),
    // Control Source
    .cmdout_tdata(cmdout_tdata), .cmdout_tlast(cmdout_tlast), .cmdout_tvalid(cmdout_tvalid), .cmdout_tready(cmdout_tready),
    .ackin_tdata(ackin_tdata), .ackin_tlast(ackin_tlast), .ackin_tvalid(ackin_tvalid), .ackin_tready(ackin_tready),
    // Stream Sink
    .str_sink_tdata(str_sink_tdata), .str_sink_tlast(str_sink_tlast), .str_sink_tvalid(str_sink_tvalid), .str_sink_tready(str_sink_tready),
    // Stream Source
    .str_src_tdata(str_src_tdata), .str_src_tlast(str_src_tlast), .str_src_tvalid(str_src_tvalid), .str_src_tready(str_src_tready),
    // Stream IDs set by host
    .src_sid(src_sid),                   // SID of this block
    .next_dst_sid(next_dst_sid),         // Next destination SID
    .resp_in_dst_sid(resp_in_dst_sid),   // Response destination SID for input stream responses / errors
    .resp_out_dst_sid(resp_out_dst_sid), // Response destination SID for output stream responses / errors
    // Misc
    .vita_time('d0), .clear_tx_seqnum(clear_tx_seqnum),
    .debug(debug));

  ////////////////////////////////////////////////////////////
  //
  //
  // AXI Wrapper
  // Convert RFNoC Shell interface into AXI stream interface
  //
  ////////////////////////////////////////////////////////////
  wire [31:0] m_axis_data_tdata;
  wire        m_axis_data_tlast;
  wire        m_axis_data_tvalid;
  wire        m_axis_data_tready;
  wire [127:0] m_axis_data_tuser;
  wire [31:0] s_axis_data_tdata;
  wire        s_axis_data_tlast;
  wire        s_axis_data_tvalid;
  wire        s_axis_data_tready;
  wire [127:0] s_axis_data_tuser;

  axi_wrapper #(
    .SIMPLE_MODE(0))   // don't auto process the header! auto handle header require package 1-to-1 !!!
  axi_wrapper (
    .clk(ce_clk), .reset(ce_rst),
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .clear_tx_seqnum(clear_tx_seqnum),
    .next_dst(next_dst_sid),
    .set_stb(set_stb), .set_addr(set_addr), .set_data(set_data),
    .i_tdata(str_sink_tdata), .i_tlast(str_sink_tlast), .i_tvalid(str_sink_tvalid), .i_tready(str_sink_tready),
    .o_tdata(str_src_tdata), .o_tlast(str_src_tlast), .o_tvalid(str_src_tvalid), .o_tready(str_src_tready),
    .m_axis_data_tdata(m_axis_data_tdata),
    .m_axis_data_tlast(m_axis_data_tlast),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tready(m_axis_data_tready),
    .m_axis_data_tuser(m_axis_data_tuser),
    .s_axis_data_tdata(s_axis_data_tdata),
    .s_axis_data_tlast(s_axis_data_tlast),
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tready(s_axis_data_tready),
    .s_axis_data_tuser(s_axis_data_tuser),
    .m_axis_config_tdata(),
    .m_axis_config_tlast(),
    .m_axis_config_tvalid(),
    .m_axis_config_tready(),
    .m_axis_pkt_len_tdata(),
    .m_axis_pkt_len_tvalid(),
    .m_axis_pkt_len_tready());

  ////////////////////////////////////////////////////////////
  //
  // User code
  //
  ////////////////////////////////////////////////////////////
  // NoC Shell registers 0 - 127,
  // User register address space starts at 128
  localparam SR_USER_REG_BASE = 128;

  // Control Source Unused
  assign cmdout_tdata  = 64'd0;
  assign cmdout_tlast  = 1'b0;
  assign cmdout_tvalid = 1'b0;
  assign ackin_tready  = 1'b1;

  // Settings registers
  //
  // - The settings register bus is a simple strobed interface.
  // - Transactions include both a write and a readback.
  // - The write occurs when set_stb is asserted.
  //   The settings register with the address matching set_addr will
  //   be loaded with the data on set_data.
  // - Readback occurs when rb_stb is asserted. The read back strobe
  //   must assert at least one clock cycle after set_stb asserts /
  //   rb_stb is ignored if asserted on the same clock cycle of set_stb.
  //   Example valid and invalid timing:
  //              __    __    __    __
  //   clk     __|  |__|  |__|  |__|  |__
  //               _____
  //   set_stb ___|     |________________
  //                     _____
  //   rb_stb  _________|     |__________     (Valid)
  //                           _____
  //   rb_stb  _______________|     |____     (Valid)
  //           __________________________
  //   rb_stb                                 (Valid if readback data is a constant)
  //               _____
  //   rb_stb  ___|     |________________     (Invalid / ignored, same cycle as set_stb)
  //
  localparam [7:0] SR_QPSK_DISP_MODE = SR_USER_REG_BASE;

  wire [31:0] qpsk_disp_mode;
  setting_reg #(
    .my_addr(SR_QPSK_DISP_MODE), .awidth(8), .width(32))
  sr_test_reg_0 (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(qpsk_disp_mode), .changed());


  // Readback registers
  // rb_stb set to 1'b1 on NoC Shell
  always @(posedge ce_clk) begin
    case(rb_addr)
      8'd0 : rb_data <= {32'd0, qpsk_disp_mode};
      default : rb_data <= 64'h0BADC0DE0BADC0DE;
    endcase
  end

  // Modify packet header data, same as input except SRC / DST SID fields.
  cvita_hdr_modify cvita_hdr_modify (
    .header_in(m_axis_data_tuser),
    .header_out(s_axis_data_tuser),
    .use_pkt_type(1'b0),       .pkt_type(),
    .use_has_time(1'b0),       .has_time(),
    .use_eob(1'b0),            .eob(),
    .use_seqnum(1'b0),         .seqnum(),
    .use_length(1'b0),         .length(),
    .use_payload_length(1'b0), .payload_length(),
    .use_src_sid(1'b1),        .src_sid(src_sid),
    .use_dst_sid(1'b1),        .dst_sid(next_dst_sid),
    .use_vita_time(1'b0),      .vita_time());

  // add fifo and get i, q data
  wire [31:0] pipe_in_tdata;
  wire pipe_in_tvalid, pipe_in_tlast;
  wire pipe_in_tready;

  // wire [31:0] pipe_out_tdata;
  // wire pipe_out_tvalid, pipe_out_tlast;
  // wire pipe_out_tready;

  // // Adding FIFO to ensure Pipeline
  // axi_fifo_flop #(.WIDTH(32+1))
  // pipeline0_axi_fifo_flop (
  //   .clk(ce_clk),
  //   .reset(ce_rst),
  //   .clear(clear_tx_seqnum),
  //   .i_tdata({m_axis_data_tlast,m_axis_data_tdata}),
  //   .i_tvalid(m_axis_data_tvalid),
  //   .i_tready(m_axis_data_tready),
  //   .o_tdata({pipe_in_tlast,pipe_in_tdata}),
  //   .o_tvalid(pipe_in_tvalid),
  //   .o_tready(pipe_in_tready));
  assign pipe_in_tdata = m_axis_data_tdata;
  assign pipe_in_tlast = m_axis_data_tlast;
  assign pipe_in_tready = m_axis_data_tready;
  assign pipe_in_tvalid = m_axis_data_tvalid;

  wire [15:0] i = pipe_in_tdata[31:16];
  wire [15:0] q = pipe_in_tdata[15:0];

  // processing the iq data
  wire [15:0] i_out;
  wire [15:0] q_out;

  // ----------- instance ip
  // instance Polar costas
  polar_costas polar_costas(
    .ce_clk(ce_clk),
    .ce_rst(~ce_rst),
    .i(i),
    .q(q),
    .i_sync(i_out),
    .q_sync(q_out)
  );
  wire [31:0] iq_out = {i_out, q_out};

  // instance BitSync ip
  // NOTE: in this design the sample_rate = 16*symbol_rate
  //       the bitsync require clk = 32*symbol_rate
  //       So. downsample 2 times of i q data and use the ce_clk to satisfy
  //       the bitsync clk requirement.

  // Down sample
  reg [15:0] i_out_div2;
  reg div_flag;
  always @(posedge ce_clk or posedge ce_rst) begin
      if (ce_rst) begin
          div_flag <= 0;
          i_out_div2 <= 16'b0;
      end
      else begin
          div_flag <= div_flag + 1'b1;
          if (div_flag == 1'b1) begin
              i_out_div2 <= i_out;
          end
          else begin
              i_out_div2 <= i_out_div2;
          end
      end
  end

  wire Bit_Sync;
  wire signed [5:0] datain;   // Bit_Sync data input
  assign datain = {6{i_out_div2[15]}};
  BitSync tb_bs(
    .rst(ce_rst),       // 复位信号，高电平有效
    .clk(ce_clk),
    .datain(datain),    // 输入数据 每个符号8个点
    // .dataout(dataout),  // 延时处理后的输出数据
    .Bit_Sync(Bit_Sync) // 位同步脉冲输出
  );

  // wire [31:0] iq_out = {i_out, q_out};
  reg [31:0] iq_out_bitsync;
  // keep bit sync data
  always @(posedge ce_clk or posedge ce_rst) begin
      if (ce_rst) begin
          iq_out_bitsync <= 32'b0;
      end
      else begin
          if (Bit_Sync) begin
              iq_out_bitsync <= iq_out;
          end
          else begin
              iq_out_bitsync <= iq_out_bitsync;
          end
      end
  end

  // ----------- add out fifo and packing axis data
  // axi_fifo_flop #(.WIDTH(32+1))
  // pipeline1_axi_fifo_flop (
  //   .clk(ce_clk),
  //   .reset(ce_rst),
  //   .clear(clear_tx_seqnum),
  //   .i_tdata({Bit_Sync,iq_out_bitsync}),
  //   .i_tvalid(Bit_Sync),
  //   .i_tready(pipe_in_tready),
  //   .o_tdata({pipe_out_tlast,pipe_out_tdata}),
  //   .o_tvalid(pipe_out_tvalid),
  //   .o_tready(pipe_out_tready));

  // generate on_last_pkt: this signal is the newest tlast after Bit_Sync
  // valid;
  reg Bit_Sync_flag;
  reg Bit_Sync_flag_lengcy;
  wire on_last_pkt;
  always @(posedge ce_clk) begin
      if(ce_rst) begin
          Bit_Sync_flag <= 1'b0;
          Bit_Sync_flag_lengcy <= 1'b0;
      end else begin
          Bit_Sync_flag_lengcy = Bit_Sync_flag;
          if (Bit_Sync) begin
              Bit_Sync_flag <= 1'b1;
          end
          if (pipe_in_tlast) begin
              Bit_Sync_flag <= 1'b0;
          end
      end
  end
  assign on_last_pkt = Bit_Sync_flag_lengcy & pipe_in_tlast;

  /* Output Signals */
  assign m_axis_data_tready = ~Bit_Sync;
  assign s_axis_data_tvalid = Bit_Sync;       // use bitsync signal to ctrl axis bus sample
  assign s_axis_data_tdata  = iq_out_bitsync;
  assign s_axis_data_tlast  = on_last_pkt;
endmodule
