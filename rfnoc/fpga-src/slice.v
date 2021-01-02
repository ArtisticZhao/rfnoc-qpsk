//
// Copyright 2016 Ettus Research
// Copyright 2018 Ettus Research, a National Instruments Company
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//
// Note: n == 0 lets everything through.
// Warning: Sample / packet counts reset when n is changed, caution if changing during operation!

module slice #(
  parameter KEEP_FIRST=0,  // 0: Drop n-1 words then keep last word, 1: Keep 1st word then drop n-1
  parameter WIDTH=16,
  parameter MAX_N=65535
)(
  input clk, input reset,
  input vector_mode,
  input [$clog2(MAX_N+1)-1:0] n,
  input [WIDTH-1:0] i_tdata, input i_tlast, input i_tvalid, output i_tready,
  output [WIDTH-1:0] o_tdata, output o_tlast, output o_tvalid, input o_tready
);

reg [$clog2(MAX_N+1)-1:0] sample_cnt, pkt_cnt;
  reg [WIDTH-1:0] o_tdata_reg;
  wire [$clog2(MAX_N+1)-1:0] n_reg = 4;   // according to input/output data n = 4;

  wire on_last_sample  = ( sample_cnt >= n_reg );
  wire on_last_pkt     = ( pkt_cnt >= n_reg    );
  
  always @(posedge clk) begin
    if (reset) begin
       sample_cnt <= 1;
       pkt_cnt    <= 1;
       o_tdata_reg <= 32'd0;
    end else begin
      if (i_tvalid & i_tready) begin
        if (on_last_sample) begin
          sample_cnt <= 1;
                  o_tdata_reg[15:8]  <= {i_tdata[31], i_tdata[27:25] ,i_tdata[15], i_tdata[11:9]};
        end else begin
          sample_cnt <= sample_cnt + 1'd1;
          case (sample_cnt)
              1: begin
                  o_tdata_reg[23:16] <= {i_tdata[31], i_tdata[27:25] ,i_tdata[15], i_tdata[11:9]};
              end
              2: begin
                  o_tdata_reg[31:24] <= {i_tdata[31], i_tdata[27:25] ,i_tdata[15], i_tdata[11:9]};
              end
              3: begin
                  o_tdata_reg[7:0]   <= {i_tdata[31], i_tdata[27:25] ,i_tdata[15], i_tdata[11:9]};
              end
              4: begin
                  o_tdata_reg[15:8]  <= {i_tdata[31], i_tdata[27:25] ,i_tdata[15], i_tdata[11:9]};
              end
          endcase
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
  reg on_last_sample_d;
  always @(posedge clk or posedge reset) begin
      if (reset) begin
          on_last_sample_d <= 1'b0;
      end
      else begin
          on_last_sample_d <= on_last_sample;
      end
  end
  assign i_tready = o_tready | ~on_last_sample_d;
  assign o_tvalid = i_tvalid & on_last_sample_d;
  assign o_tdata  = o_tdata_reg;
  assign o_tlast  = i_tlast  & on_last_pkt;

endmodule // keep_one_in_n_vec

