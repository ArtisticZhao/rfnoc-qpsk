//这是monostable.v文件的程序清单
module monostable(
	rst,clk32,din,
	dout);
	
	input		rst;    //复位信号，高电平有效
	input		clk32;  //FPGA系统时钟:32MHz
	input    din;    
   output   dout;	  //检测到din为高电平后，输出4个时钟周期的高电平信号
	
   //单稳态触发器：检测到一个高电平脉冲后，输出4个clk32时钟周期的高电平
	reg [1:0] c;
	reg start,dtem;
	always @(posedge clk32 or posedge rst)
	   if (rst)
		   begin
			   c = 0;
				start = 0;
				dtem <= 0;
			end 
		else
		   begin
			   if (din)
				   begin
					   start = 1'b1;
						dtem <= 1'b1;
					end
				if (start)
				   begin
					   dtem <= 1'b1;
						if (c<1) 
						   c = c+2'b01;
						else
						   start = 1'b0;
				   end
				else
				   begin
					   c = 0;
						dtem <= 1'b0;
					end
			end
			
	assign dout = dtem;
	
endmodule

					

