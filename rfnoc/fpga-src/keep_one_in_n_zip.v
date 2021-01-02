// 说明: 这是基于keep one in n的数据压缩模块
//       原始输入的数据为32位    (即 一个符号由16位I和16位Q组成)
//       现在需要将其进行剪裁8位 (即 一个符号由4位I和4位Q组成)
//       从数据量的角度 该模块每4个点输出一次 这个行为与keep one in n保持一致
//       的

module keep_one_in_n_zip #(
  parameter WIDTH=32,
  parameter MAX_N=15
)(
  input clk, input reset,
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
                  o_tdata_reg[23:16]  <= i_tdata[31:24];
        end else begin
          sample_cnt <= sample_cnt + 1'd1;
          case (sample_cnt)
              4: begin
                  o_tdata_reg[23:16] <= i_tdata[31:24];
              end
              1: begin
                  o_tdata_reg[31:24] <= i_tdata[31:24];
              end
              2: begin
                  o_tdata_reg[7:0]   <= i_tdata[31:24];
              end
              3: begin
                  o_tdata_reg[15:8]  <= i_tdata[31:24];
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
  reg on_last_sample_dd;
  always @(posedge clk or posedge reset) begin
      if (reset) begin
          on_last_sample_d <= 1'b0;
          on_last_sample_dd <= 1'b0;
      end
      else begin
          on_last_sample_d <= on_last_sample;
          on_last_sample_dd <= on_last_sample_d;
      end
  end
  assign i_tready = o_tready | ~on_last_sample_dd;
  assign o_tvalid = i_tvalid & on_last_sample_dd;
  assign o_tdata  = o_tdata_reg;
  assign o_tlast  = i_tlast  & on_last_pkt;

endmodule // keep_one_in_n_vec
