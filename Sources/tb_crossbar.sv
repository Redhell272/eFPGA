`timescale 1ns/1ps

//Test Logic Switch
module testbench;

  reg clk=1;
  reg nres=0;
  reg  [31:0] prog_i=32'h00000000;
  reg 		  prog_shft=0;
  wire [31:0] prog_o;
  reg  [31:0] N_i=32'h87654321;
  reg  [29:0] N_i_H=30'h87654321;
  wire [31:0] S_o;
  wire [31:0] S_o_V;
  wire [29:0] S_o_H;
  reg  [15:0] S_i=16'ha5a5;
  reg  [17:0] S_i_H=18'h5a5a5;
  wire [15:0] N_o;
  wire [15:0] N_o_V;
  wire [17:0] N_o_H;
  reg  [31:0] W_i=32'h0fedcba9;
  reg   [7:0] W_i_L=8'ha5;
  wire [31:0] E_o;
  wire [31:0] E_o_H;
  wire [31:0] E_o_L;
  reg  [15:0] E_i=16'h5a5a;
  wire [15:0] W_o;
  wire [15:0] W_o_H;
  
  // Instantiate Units Under Test
  crossbar CBUT(
    .clk(clk),
    .nres(nres),
    .prog_i(prog_i),
    .prog_shft(prog_shft),
    .prog_o(prog_o),
    .N_i(N_i),
    .S_o(S_o),
    .S_i(S_i),
    .N_o(N_o),
    .W_i(W_i),
    .E_o(E_o),
    .E_i(E_i),
    .W_o(W_o)
  );

  V_crossbar CBVUT(
    .clk(clk),
    .nres(nres),
    .prog_i(prog_i),
    .prog_shft(prog_shft),
    .prog_o(prog_o),
    .N_i(N_i),
    .S_o(S_o_V),
    .S_i(S_i),
    .N_o(N_o_V),
    .W_i(W_i_L),
    .E_o(E_o_L)
  );

  H_crossbar CBHUT(
    .clk(clk),
    .nres(nres),
    .prog_i(prog_i),
    .prog_shft(prog_shft),
    .prog_o(prog_o),
    .N_i(N_i_H),
    .S_o(S_o_H),
    .S_i(S_i_H),
    .N_o(N_o_H),
    .W_i(W_i),
    .E_o(E_o_H),
    .E_i(E_i),
    .W_o(W_o_H)
  );
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #20 nres=1;
    
    #15 prog_shft=1;
    
    //SE
        prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;

    //SW
    #10 prog_i=32'h0003000c;
    #10 prog_i=32'h003000c0;
    #10 prog_i=32'h03000c00;
    #10 prog_i=32'h3000c000;
    #10 prog_i=32'h000c0003;
    #10 prog_i=32'h00c00030;
    #10 prog_i=32'h0c000300;
    #10 prog_i=32'hc0003000;

    //NE
    #10 prog_i=32'h80000000;
    #10 prog_i=32'h40000000;
    #10 prog_i=32'h20000000;
    #10 prog_i=32'h10000000;
    #10 prog_i=32'h08000000;
    #10 prog_i=32'h04000000;
    #10 prog_i=32'h02000000;
    #10 prog_i=32'h01000000;
    #10 prog_i=32'h00800000;
    #10 prog_i=32'h00400000;
    #10 prog_i=32'h00200000;
    #10 prog_i=32'h00100000;
    #10 prog_i=32'h00080000;
    #10 prog_i=32'h00040000;
    #10 prog_i=32'h00020000;
    #10 prog_i=32'h00010000;
    #10 prog_i=32'h00008000;
    #10 prog_i=32'h00004000;
    #10 prog_i=32'h00002000;
    #10 prog_i=32'h00001000;
    #10 prog_i=32'h00000800;
    #10 prog_i=32'h00000400;
    #10 prog_i=32'h00000200;
    #10 prog_i=32'h00000100;
    #10 prog_i=32'h00000080;
    #10 prog_i=32'h00000040;
    #10 prog_i=32'h00000020;
    #10 prog_i=32'h00000010;
    #10 prog_i=32'h00000008;
    #10 prog_i=32'h00000004;
    #10 prog_i=32'h00000002;
    #10 prog_i=32'h00000001;

    //NW
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    
    #10 prog_i=32'hFEDCAB98;
    #10 prog_i=32'h87654321;
    #10 prog_i=32'haaaa5555;
    
    #10 prog_shft=0;
    
    
    
    
  end
  
  //Clocks
  always
    #5 clk = ~clk;   // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #1000 $finish;
  
endmodule
