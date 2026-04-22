`timescale 1ns/1ps

//Test Node
module testbench;
  
  parameter WIDTH = 4;
  parameter HEIGHT = 8;
  
  reg clk=1;
  reg[HEIGHT-1:0] D='0;
  reg[WIDTH-1:0] E='0;
  reg[WIDTH-1:0] No='0;
  reg[HEIGHT-1:0] We='0;
  wire[WIDTH-1:0] So;
  wire[HEIGHT-1:0] Ea;
  wire[WIDTH-1:0] Y_H;
  wire[HEIGHT-1:0] Y_V;
  wire[WIDTH-1:0] V;
  wire X1;
  wire X2;
  
  // Instantiate Unit Under Test
  Xnodes #(.V(WIDTH), .H(HEIGHT)) XUT(
    .D(D),
    .E(E),
    .V_i(No),
    .V_o(So),
    .H_i(We),
    .H_o(Ea));
    
  Ynodes_H #(.V(WIDTH)) YHUT(
    .D(D[0]),
    .E(E),
    .H_i(No),
    .H_o(Y_H));
    
  Ynodes_V #(.H(HEIGHT)) YVUT(
    .D(D),
    .E(E[0]),
    .V_i(We),
    .V_o(Y_V));
    
  Vnodes #(.V(WIDTH)) VUT(
    .V_i(No),
    .V_o(V));


  Xnode X0UT(
    .D(D[0]),
    .E(E[0]),
    .I1(No[0]),
    .I2(We[0]),
    .O1(X1),
    .O2(X2));

  task load_prog;
    input [31:0] prog;
    begin
      #10 D=prog[7:0];
      #10 E[0]=1; E[1]=0; E[2]=0; E[3]=0;
      #10 E='0;

      #10 D=prog[15:8];
      #10 E[0]=0; E[1]=1; E[2]=0; E[3]=0;
      #10 E='0;
      
      #10 D=prog[23:16];
      #10 E[0]=0; E[1]=0; E[2]=1; E[3]=0;
      #10 E='0;
      
      #10 D=prog[31:24];
      #10 E[0]=0; E[1]=0; E[2]=0; E[3]=1;
      #10 E='0;
      
      #10 D='0;
    end
  endtask 
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #10 load_prog(32'h00000000);
    #20 No='1;
    #20 No='0;
    #20 We='1;
    #20 We='0;
    
    #10 load_prog(32'h08040201);
    #20 No='1;
    #20 No='0;
    #20 We='1;
    #20 We='0;
    
    #10 load_prog(32'h80402010);
    #20 No='1;
    #20 No='0;
    #20 We='1;
    #20 We='0;
    
  end
  
  //Clocks
  always
    #5 clk = ~clk;   // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #1000 $finish;
  
endmodule
