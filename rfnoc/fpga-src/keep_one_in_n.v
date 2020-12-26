//
// Copyright 2016 Ettus Research
// Copyright 2018 Ettus Research, a National Instruments Company
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//
// Note: n == 0 lets everything through.
// Warning: Sample / packet counts reset when n is changed, caution if changing during operation!

module keep_one_in_n #(
  parameter WIDTH=32,
  parameter MAX_N=65535
)(
  input clk, input reset,
  input [$clog2(MAX_N+1)-1:0] n,
  input [WIDTH-1:0] i_tdata, input i_tlast, input i_tvalid, output i_tready,
  output [WIDTH-1:0] o_tdata, output o_tlast, output o_tvalid, input o_tready
);

  reg [$clog2(MAX_N+1)-1:0] sample_cnt, pkt_cnt, n_reg;

  always @(posedge clk) begin
    if (reset) begin
       n_reg      <= 1;
    end else begin
       n_reg      <= n;
    end
  end

  wire on_last_sample  = ( sample_cnt >= n_reg );
  wire on_last_pkt     = ( pkt_cnt >= n_reg    );

  always @(posedge clk) begin
    if (reset) begin
       sample_cnt <= 1;
       pkt_cnt    <= 1;
    end else begin
      if (i_tvalid & i_tready) begin
        if (on_last_sample) begin
          sample_cnt <= 1;
        end else begin
          sample_cnt <= sample_cnt + 1'd1;
        end
      end
      if (i_tvalid & i_tready & i_tlast) begin
        if (on_last_pkt) begin
          pkt_cnt <= 1;
        end else begin
          pkt_cnt <= pkt_cnt + 1'd1;
        end
      end
    end
  end

  assign i_tready = o_tready | ~on_last_sample;
  assign o_tvalid = i_tvalid & on_last_sample;
  assign o_tdata  = i_tdata;
  assign o_tlast  = i_tlast  & on_last_pkt;

endmodule // keep_one_in_n_vec
