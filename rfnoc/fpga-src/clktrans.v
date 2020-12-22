//这是clktrans.v文件的程序清单
module clktrans (
	rst,clk32,      // [INFO] clk32 = 32倍符号速率!
	clk_d1,clk_d2);
	
	input		rst;   //复位信号，高电平有效
	input		clk32; //FPGA系统时钟:32MHz
	output clk_d1;  //双相时钟输出信号1
    output clk_d2;	 //双相时钟输出信号2，与信号1相互正交
	
	 //产生周期为码速率的8倍(采样速率)，占空比为1：3的双相时钟
    //双相时钟相位相差一个clk32时钟周期
    //从这段程序可以看出，由于双相时钟clk_d1、clk_d2的周期为码元的采样周期，
    //产生双相时钟信号的时钟频率不能小于双相时钟的4倍，
    //因此，位同步环路中的系统时钟频率为数据采样频率的4倍
	 reg [1:0] c;
	 reg clkd1,clkd2;
	 always @(posedge clk32 or posedge rst)
	    if (rst)
		    begin
			    c = 0;
				 clkd1 <= 0;
				 clkd2 <= 0;
			end
		else
		   begin
			   c = c+1'b1;
				if (c==0)
				   begin 
					   clkd1 <= 1'b1;
						clkd2 <= 1'b0;
					end
				else if (c==2)
				   begin
					   clkd1 <= 1'b0;
						clkd2 <= 1'b1;
					end
				else 
				   begin
					   clkd1 <= 1'b0;
						clkd2 <= 1'b0;
					end
			end
			
   assign clk_d1 = clkd1;
   assign clk_d2 = clkd2;
	
endmodule
 
