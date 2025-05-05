`timescale 1ns/1ps

//Test Node
module testbench;
  
  parameter WIDTH = 8;
  parameter HEIGHT = 4;
  
  reg clk=1;
  reg[(WIDTH*HEIGHT)-1:0] prog='0;
  reg[WIDTH-1:0] N='0;
  reg[HEIGHT-1:0] W='0;
  wire[WIDTH-1:0] S;
  wire[HEIGHT-1:0] E;
  wire[WIDTH-1:0] Y;
  wire[WIDTH-1:0] V;
  
  // Instantiate Unit Under Test
  Xnodes #(.V(WIDTH), .H(HEIGHT)) XUT(
    .prog(prog),
    .V_i(N),
    .V_o(S),
    .H_i(W),
    .H_o(E));
    
  Ynodes #(.V(WIDTH)) YUT(
    .prog(prog[WIDTH-1:0]),
    .V_i(N),
    .V_o(Y));
    
  Vnodes #(.V(WIDTH)) VUT(
    .V_i(N),
    .V_o(V));
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #10 prog='0;
    #20 W='1;
    #20 W='0;
    #20 N='1;
    #20 N='0;
    
    #10 prog=32'h08040201; //'1;
    #20 W='1;
    #20 W='0;
    #20 N='1;
    #20 N='0;
    
  end
  
  //Clocks
  always
    #5 clk = ~clk;   // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #300 $finish;
  
endmodule
