# 关于FPGA文件的说明

该工程由RFNOC工具链生成, 具体请参考[官方demo](https://kb.ettus.com/Getting_Started_with_RFNoC_Development#Creating_and_running_HDL_testbenches).

## 解调流程

文件入口: `./noc_block_qpsk.v`

1. 数据流输入
首先在`noc_block`中, AD9361的数据流是通过AXI4-Stream接口进行传输的. `pipe_in_tdata`作为接收的0频信号的数据流. 该信号位宽32位, 高16位为i路信号, 低16位为q路信号, 数据都是二进制补码形式.

```verilog
  wire [15:0] i = pipe_in_tdata[31:16];
  wire [15:0] q = pipe_in_tdata[15:0];
```

2. 极性costas环

极性costas环是一个锁相环, 用于跟踪接收信号的频率与相位, 以消除频率误差和相位误差. 因为存在$\pi/4$的相位模糊, 因此基带数据需要进行差分编码.

```verilog
  polar_costas polar_costas(
    .ce_clk(ce_clk),
    .ce_rst(~ce_rst),
    .i(i),
    .q(q),
    .i_sync(i_out),
    .q_sync(q_out)
  );
```

3. 位同步

锁定之后的信号, 采样率是符号率的16倍(samples per symbol = 16), 加上一般信号调制时需要进行成形滤波, 所以并不是16个采样点随便取一个就可以完成信号的解调, 而是需要位同步, 在信号强度最大时进行采样.

由于在当前的设计中, 参考了别人的位同步程序, 其对应的sps=8, 因此, 在当前工程中先对数据做了二倍降采样, 然后输入到别人的位同步中.

但是, 抄袭的这个位同步有很大的问题, 不够稳定, 所以下一个版本需要迭代优化一下.

## 极性costas环原理

留坑, 之后填!

## 位同步原理

参照这个PDF讲义 [57通信原理第五十七讲.pdf](./57通信原理第五十七讲.pdf)

## 开发心得

通过这次开发, 发现 "Matlab->行为级仿真" 这个过程十分重要.  
先用Matlab验证算法的可靠性, 之后将Matlab算法编程Verilog代码, 之后再进行行为级的仿真验证, 通过之后再进行下一步的操作.  
并且, verilog中的算数运行的运用要小心, 特别是位数问题, 数据表示问题, 这些都可能为系统引入不确定的因素, 所以要进行仿真, 确定逻辑正确之后再进行下一步.
