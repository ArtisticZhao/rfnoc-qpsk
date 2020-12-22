`timescale 1ns / 1ps

module loop_filter
#(
	parameter AVE_DATA_NUM = 64,
	parameter AVE_DATA_BIT = 6
)
(
   input rst_n,
   input clk,
   input signed [16:0] pd,                // 鉴相器输出
   output signed [22:0] dout  // loop filter 输出
);
reg [16:0] data_reg [AVE_DATA_NUM-1:0];

reg [7:0]temp_i;

always @ (posedge clk or negedge rst_n)
if(!rst_n)
	for (temp_i=0; temp_i<AVE_DATA_NUM; temp_i=temp_i+1)
		data_reg[temp_i] <= 'd0;
else
begin
	data_reg[0] <= pd;
	for (temp_i=0; temp_i<AVE_DATA_NUM-1; temp_i=temp_i+1)
		data_reg[temp_i+1] <= data_reg[temp_i];
end

reg signed [22:0] sum;

always @ (posedge clk or negedge rst_n)
if (!rst_n)
	sum <= 'd0;
else
	sum <= sum + {{6{pd[16]}}, pd} - {{6{data_reg[AVE_DATA_NUM-1][16]}}, data_reg[AVE_DATA_NUM-1]}; //将最老的数据换为最新的输入数据

assign dout = sum; //右移3 等效为÷8

endmodule
