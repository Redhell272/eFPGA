`timescale 1ns/1ps

//Test FPGA Structure
module testbench;

  reg prog_nres=1'b0;
  reg prog_clk=1'b0;
  reg [7:0] prog_D='0;
  reg prog_en=1'b0;
  reg prog_apply=1'b0;
  reg [2*2:0] prog_s='0;
  reg reg_nres=1'b0;
  reg reg_clk=1'b0;
  reg  [62*3+31:0] N_i=218'h0000000000000000000000000000000000000000000000000000000;
  wire [62*3+31:0] S_o;
  reg  [34*3+15:0] S_i=118'h000000000000000000000000000000;
  wire [34*3+15:0] N_o;
  reg  [40*2+31:0] W_i=112'h0000000000000000000000000000;
  wire [56*2+31:0] E_o;
  reg  [16*2+15:0] E_i=48'h000000000000;
  wire [16*2+15:0] W_o;
  
  // Instantiate Units Under Test
  fpga #(.V(3), .H(2)) UUT (
    .prog_nres(prog_nres),
    .prog_clk(prog_clk),
    .prog_D(prog_D),
    .prog_en(prog_en),
    .prog_apply(prog_apply),
    .prog_s(prog_s),
    .reg_nres(reg_nres),
    .reg_clk(reg_clk),
    .N_i(N_i),
    .S_o(S_o),
    .S_i(S_i),
    .N_o(N_o),
    .W_i(W_i),
    .E_o(E_o),
    .E_i(E_i),
    .W_o(W_o)
  );
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #20 prog_nres=1;
    #40 prog_nres=1;
    #20 reg_nres=1;

    // programming...

    #10 prog_apply=0;
    
    
    
  end
  
  //Clocks
  always
    #5 prog_clk = ~prog_clk;   // 100 Mhz clock

  always
    #5 reg_clk = ~reg_clk;   // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #1000 $finish;
  
endmodule
