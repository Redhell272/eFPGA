`timescale 1ns/1ps
//Test Logic Switch
module testbench;

  reg clk=1;
  reg nres=0;
  reg  [31:0] prog_i=32'h3ACA3ACA;
  reg 		  prog_shft=0;
  wire [31:0] prog_o;
  reg  [31:0] data_in=32'h96969696;
  reg 		  en=0;
  wire [31:0] data_oCB;
  wire  [7:0] data_oCBV;
  
  // Instantiate Unit Under Test
  input_logic UUT(
    .clk(clk),
    .nres(nres),
    .prog_i(prog_i),
    .prog_shft(prog_shft),
    .prog_o(prog_o),
    .data_in(data_in),
    .en(en),
    .data_oCB(data_oCB),
    .data_oCBV(data_oCBV));
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #20 nres=1;
    
    #15 prog_shft=1;
    
        prog_i=32'h87654321;
    #10 prog_i=32'hFEDCAB98;
    #10 prog_i=32'hFEDCAB98;
    #10 prog_i=32'h87654321;
    
    #10 prog_i=32'hFEDCAB98;
    #10 prog_i=32'h87654321;
    
    #10 prog_i=32'h80000000;
    
    #10 prog_shft=0;
    
    #20 en=1;
    
    #10 data_in=32'h16969696;
    #10 data_in=32'h96969696;
    
    #10 data_in=32'h16161617;
    #10 data_in=32'h96161617;
    
    #10 data_in=32'h16969697;
    #10 data_in=32'h96969697;
    
    #10 data_in=32'h16161617;
    #10 data_in=32'h96161617;
    
    #10 data_in=32'h16969697;
    #10 data_in=32'h96969697;
    
    #10 data_in=32'h16161617;
    #10 data_in=32'h96161617;
    
    #10 data_in=32'h16969697;
    #10 data_in=32'h96969697;
    
    #10 data_in=32'h16161617;
    #10 data_in=32'h96161617;
    
    #10 data_in=32'h16969697;
    #10 data_in=32'h96969697;
    
    #10 data_in=32'h16161617;
    #10 data_in=32'h96161617;
    
    #10 data_in=32'h16969697;
    #10 data_in=32'h96969697;
    
    #10 data_in=32'h16161617;
    #10 data_in=32'h96161617;
    
    #10 data_in=32'h16969697;
    #10 data_in=32'h96969697;
    
    #10 data_in=32'h16161617;
    #10 data_in=32'h96161617;
    
    #10 data_in=32'h16969697;
    #10 data_in=32'h96969697;
    
    #10 data_in=32'h16161617;
    #10 data_in=32'h96161617;
    
    #10 data_in=32'h16969697;
    #10 data_in=32'h96969697;
    
    #10 data_in=32'h16161617;
    #10 data_in=32'h96161617;
    
    #10 data_in=32'h16969697;
    #10 data_in=32'h96969697;
    
    #10 data_in=32'h16161617;
    #10 data_in=32'h96161617;
    
    
  end
  
  //Clocks
  always
    #5 clk = ~clk;   // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #600 $finish;
  
endmodule
