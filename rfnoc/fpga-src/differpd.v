//这是differpd.v文件的程序清单
module differpd (
	rst,clk32,datain,clk_i,clk_q,
	pd_bef,pd_aft);
	
	input		rst;    //复位信号，高电平有效
	input		clk32;  //FPGA系统时钟:32MHz
	input[5:0] datain; //输入数据
	input    clk_i;  //由控制分频模块送来的同相同步脉冲信号（占空比为1:1）
	input    clk_q;  //由控制分频模块送来的正交同步脉冲信号（占空比为1:1）
	output pd_bef;   //输出的超前脉冲信号
   output pd_aft;	  //输出的滞后脉冲信号
	
   
	
    //取输入数据的符号位为码元起始相位
	 wire din;
	 assign din = datain[5];

    //输入信号微分整流，检测输入信号跳变沿后，产生一个clk32时钟周期的高电平脉冲
	 reg din_d,din_edge;
	 reg pdbef,pdaft;
	 always @(posedge clk32 or posedge rst)
	    if (rst)
		    begin
			    din_d <= 0;
				 din_edge <= 0;
				 pdbef <= 0;
				 pdaft <= 0;
			 end
	    else 
		    begin
			    din_d <= din;
				 din_edge <= (din ^ din_d);//xor
				 //完成鉴相功能
				 pdbef <= (din_edge & clk_i); //and
				 pdaft <= (din_edge & clk_q); //and
			 end
			 
	 assign pd_bef = pdbef;
	 assign pd_aft = pdaft;
	 

endmodule
