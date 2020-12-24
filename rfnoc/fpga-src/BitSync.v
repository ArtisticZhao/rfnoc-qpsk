//这是BitSync.v文件的程序清单
module BitSync (
    rst,clk,datain,
    dataout,Bit_Sync);

    input  rst;                   // 复位信号，高电平有效
    input  clk;                   // FPGA系统时钟:32MHz
    input  signed [5:0] datain;   // 输入数据
    output signed [5:0] dataout;  // 延时处理后的输出数据
    output Bit_Sync;              // 位同步脉冲输出


    //双相时钟产生单元：产生周期为码速率的8倍(采样速率)，占空比为1:3的双相时钟信号
    //两路双相时钟相位相差一个clk32时钟周期
    wire clk_d1,clk_d2;
    clktrans u2(
        .rst   (rst),
        .clk32 (clk),
        .clk_d1(clk_d1),
        .clk_d2(clk_d2));

    //微分鉴相单元：对输入信号微分整流，检测输入信号跳变沿，与分频器输入的信号进行鉴相
    wire clk_i,clk_q,pd_bef,pd_aft;
    differpd u3(
        .rst    (rst),
        .clk32  (clk),
        .datain (datain),
        .clk_i  (clk_i),
        .clk_q  (clk_q),
        .pd_bef (pd_bef),
        .pd_aft (pd_aft));

    //单稳态触发器：检测到一个高电平脉冲后，输出4个clk32周期的高电平
    wire pd_before,pd_after;
    monostable u4 (
        .rst   (rst),
        .clk32 (clk),
        .din   (pd_bef),
        .dout  (pd_before));

    monostable u5 (
        .rst   (rst),
        .clk32 (clk),
        .din   (pd_aft),
        .dout  (pd_after));


    //控制分频单元：对两路单稳输出的信号及双相时钟信号进行处理，分频产生相位
    //相差180度的同步信号clk_i,clk_q;
    controldivfreq u6 (
        .rst       (rst),
        .clk32     (clk),
        .clk_d1    (clk_d1),
        .clk_d2    (clk_d2),
        .pd_before (pd_before),
        .pd_after  (pd_after),
        .clk_i     (clk_i),
        .clk_q     (clk_q));

    //位同步形成及移相单元：形成位同步信号，对输入数据进行移相处理
    // wire Bit_Sync_pre;  // 仿真中发现同步标志位稳定的地方过于靠前, 需要delay一段时间 11个clk32
    syncout u7 (
        .rst      (rst),
        .clk32    (clk),
        .clk_i    (clk_i),
        .clk_d2   (clk_d2),
        .datain   (datain),
        .Bit_Sync (Bit_Sync),
        .dataout  (dataout));

endmodule


