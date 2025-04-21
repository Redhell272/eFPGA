`timescale 1ns/1ps
//Test Logic Module
module testbench;

  reg prog_clk=1;
  reg prog_nres=0;
  reg[33:0] prog_in=34'h23ACA3ACA;
  reg reg_clk=1;
  reg reg_nres=0;
  reg reg_in=0;
  reg[4:0] data_in=5'h00;
  wire[1:0] data_out;
  
  // Instantiate Unit Under Test
  logic_module UUT(
    .prog(prog_in),
    .reg_clk(reg_clk),
    .reg_nres(reg_nres),
    .reg_in(reg_in),
    .data_in(data_in),
    .data_out(data_out));
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #20 prog_nres=1;
    #20 reg_nres=1;
    
    #10 data_in=5'h00;
    #10 data_in=5'h01;
    #10 data_in=5'h02;
    #10 data_in=5'h03;
    #10 data_in=5'h04;
    #10 data_in=5'h05;
    #10 data_in=5'h06;
    #10 data_in=5'h07;
    #10 data_in=5'h08;
    #10 data_in=5'h09;
    #10 data_in=5'h0A;
    #10 data_in=5'h0B;
    #10 data_in=5'h0C;
    #10 data_in=5'h0D;
    #10 data_in=5'h0E;
    #10 data_in=5'h0F;
    #10 data_in=5'h10;
    #10 data_in=5'h11;
    #10 data_in=5'h12;
    #10 data_in=5'h13;
    #10 data_in=5'h14;
    #10 data_in=5'h15;
    #10 data_in=5'h16;
    #10 data_in=5'h17;
    #10 data_in=5'h18;
    #10 data_in=5'h19;
    #10 data_in=5'h1A;
    #10 data_in=5'h1B;
    #10 data_in=5'h1C;
    #10 data_in=5'h1D;
    #10 data_in=5'h1E;
    #10 data_in=5'h1F;
    
  end
  
  //Clocks
  always
    #5 prog_clk = ~prog_clk;   // 100 Mhz clock
  always
    #5 reg_clk = ~reg_clk;     // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #500 $finish;
  
endmodule
