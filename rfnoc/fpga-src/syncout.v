//这是syncout.v文件的程序清单
module syncout(
	rst,clk32,clk_i,clk_d2,datain,
	Bit_Sync,dataout);
	
	input		rst;    //复位信号，高电平有效
	input		clk32;  //FPGA系统时钟:32MHz
	input    clk_d2;   
	input    clk_i;  
	input   [5:0] datain;   
   output   Bit_Sync;	  
   output  [5:0] dataout;
	

	
    //检测分频器输出的同相支路信号，上升沿产生位同步脉冲
	 reg clki,sync;
	 always @(posedge clk32 or posedge rst)
	    if (rst)
		    begin
			    sync <= 0;
				 clki <= 0;
			 end
		 else
		    begin
			    clki <= clk_i;
				 if ((clki==1'b0) & (clk_i==1'b1))
				    sync <= 1'b1;
				 else
				    sync <= 1'b0;
			end	 
	assign Bit_Sync = sync;	
  
   //为补偿位同步脉冲在运算过程中产生的延时，根据仿真结果对数据进行移相处理
   //使位同步脉冲与接收数据同步
	reg clk_d2_d;
	reg [5:0] dtem;
	always @(posedge clk32 or posedge rst)
	   if (rst)
		   begin
			   clk_d2_d <= 0;
				dtem <= 0;
			end
		else
		   begin
			   clk_d2_d <= clk_d2;
				if ((clk_d2==1'b0) & (clk_d2_d==1'b1))
				   dtem <= datain;
			end
	assign dataout = dtem;
	
endmodule

