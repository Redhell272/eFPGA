`timescale 1ns/1ps

// eFPGA Wrapper Top Module
module eFPGA_wrapper (
  input wire         reset,
  input wire         clock,
  input wire         prog_btn,
  input wire  [15:0] sw,
  output wire [15:0] led
);
  
  // Wires
  logic prog_nres;
  logic prog_clk;
  logic prog_start;
  
  logic reg_nres;
  logic reg_clk;

  logic [62*2+31:0] N_i;
  logic [62*2+31:0] S_o;
  logic [34*2+15:0] S_i;
  logic [34*2+15:0] N_o;
  logic [40*1+31:0] W_i;
  logic [56*1+31:0] E_o;
  logic [16*1+15:0] E_i;
  logic [16*1+15:0] W_o;
  
  // Assigns
  assign prog_nres = ~reset;
  assign prog_clk = clock;
  assign prog_start = prog_btn;

  assign reg_nres = ~reset;
  assign reg_clk = clock;

  assign N_i = '0;
  assign S_i = '0;
  assign W_i = {56'h00000000000000, sw};
  assign E_i = '0;

  assign led = W_o[15:0];

  // Instances
  eFPGA eFPGA0 (.prog_nres(prog_nres), .prog_clk(prog_clk), .prog_start(prog_start),
    .reg_nres(reg_nres), .reg_clk(reg_clk),
    .N_i(N_i), .S_o(S_o), .S_i(S_i), .N_o(N_o), .W_i(W_i), .E_o(E_o), .E_i(E_i), .W_o(W_o));
  
endmodule