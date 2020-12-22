//这是controldivfreq.v文件的程序清单
module controldivfreq(
	rst,clk32,clk_d1,clk_d2,pd_before,pd_after,
	clk_i,clk_q);
	
	input		rst;    //复位信号，高电平有效
	input		clk32;  //FPGA系统时钟:32MHz
	input    clk_d1;  
	input    clk_d2;   
	input    pd_before;   
	input    pd_after;   
   output   clk_i;	  
   output   clk_q;

   wire gate_open,gate_close,clk_in;
	assign gate_open  = (~ pd_before) & clk_d1;
	assign gate_close = pd_after & clk_d2;
	//对gate_open及gate_close相“或”后，作为分频器的驱动时钟
	assign clk_in = gate_open | gate_close;
	
	reg clki,clkq;
	reg [1:0] c;
	always @(posedge clk32 or posedge rst)
	   if (rst)
		   begin
			   c = 0;
				clki <= 0;
				clkq <= 0;
			end
		else 
		   begin
			   if (clk_in)
				   c = c + 2'b01;
			   clki <= ~c[1];
				clkq <= c[1];
			end
			
   assign clk_i = clki;
	assign clk_q = clkq;
	
endmodule

	