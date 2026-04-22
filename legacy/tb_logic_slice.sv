`timescale 1ns/1ps

//Test Logic Switch
module tb;

  reg clk=1;
  reg nres=0;
  reg  [31:0] prog_i=32'h00000000;
  reg 		  prog_shft=0;
  wire [31:0] prog_o;
  reg  [29:0] N_i=30'h00000000;
  wire [29:0] S_o;
  reg  [17:0] S_i=18'h1a5a5;
  wire [17:0] N_o;
  reg  [31:0] W_i=32'h00000000;
  wire  [7:0] E_o;
  
  // Instantiate Units Under Test
  logic_slice UUT(
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
    .E_o(E_o)
  );
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #20 nres=1;
    
    #15 prog_shft=1;

    //Ynodes
        prog_i=32'hFFFFFFFF;
    #10 prog_i=32'hFFFFFFFF;
    #10 prog_i=32'hFFFFFFFF;
    #10 prog_i=32'hFFFFFFFF;
    #10 prog_i=32'hFFFFFFFF;
    #10 prog_i=32'hFFFFFFFF;

    //Xnodes
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;
    #10 prog_i=32'h00003C3C;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h00000000;
    #10 prog_i=32'h000C0003;

    //Regs
    #10 prog_i=32'hFFFFFFFF;

    //LUT
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    #10 prog_i=32'h3C3C3C3C;
    
    #10 prog_shft=0;

    #20 N_i=30'h00300C03;

    #10 N_i=30'h00F03C0F;
    #10 N_i=30'h00300C03;
    #10 N_i=30'h00F03C0F;
    #10 N_i=30'h00300C03;
    #10 N_i=30'h00F03C0F;
    #10 N_i=30'h00300C03;
    
    
    
  end
  
  //Clocks
  always
    #5 clk = ~clk;   // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #1000 $finish;
  
endmodule
