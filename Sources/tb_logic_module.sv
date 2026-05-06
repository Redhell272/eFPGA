`timescale 1ns/1ps

//Test Logic Module
module testbench;

  reg [8:0] D='0;
  reg [3:0] E='0;
  reg reg_clk=1;
  reg reg_nres=0;
  reg reg_in=0;
  reg[4:0] data_in=5'h00;
  wire[1:0] data_out;
  
  // Instantiate Unit Under Test
  logic_module UUT(
    .D(D),
    .E(E),
    .reg_clk(reg_clk),
    .reg_nres(reg_nres),
    .reg_in(reg_in),
    .data_in(data_in),
    .data_out(data_out));

  task load_prog;
    input [33:0] prog;
    begin
      #10 E = 4'b0000;
      #10 D = {prog[32], prog[7:0]};
      #10 E = 4'b0001;
      #10 E = 4'b0000;
      #10 D = {prog[33], prog[15:8]};
      #10 E = 4'b0010;
      #10 E = 4'b0000;
      #10 D = {1'b0, prog[23:16]};
      #10 E = 4'b0100;
      #10 E = 4'b0000;
      #10 D = {1'b0, prog[31:24]};
      #10 E = 4'b1000;
      
      #10 E = '0;
      #10 D = '0;
    end
  endtask 
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    load_prog(34'h23ACA3ACA);
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
    #5 reg_clk = ~reg_clk;     // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #500 $finish;
  
endmodule
