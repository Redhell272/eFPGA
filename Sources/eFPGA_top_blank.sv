`timescale 1ns/1ps

//Define eFPGA dimensions
`define V 3
`define H 2

// eFPGA Wrapper Top Module
module eFPGA_blank (
  //Programming Interface
  input wire         prog_nres,
  input wire         prog_clk,
  input wire   [7:0] prog_D,
  input wire         prog_en,
  input wire         prog_apply,
  input wire [2*H:0] prog_s,
  //Register Inputs
  input wire         reg_nres,
  input wire         reg_clk,
  //Module In/Out
  input wire  [62*V+31:0] N_i,
  output wire [62*V+31:0] S_o,
  input wire  [34*V+15:0] S_i,
  output wire [34*V+15:0] N_o,
  input wire  [40*H+31:0] W_i,
  output wire [56*H+31:0] E_o,
  input wire  [16*H+15:0] E_i,
  output wire [16*H+15:0] W_o
);
  
  // Registers
  
  // Wires
  
  // Assigns

  // Instances

  fpga #(.V(V), .H(H)) eFPGA_unit (.prog_nres(prog_nres), .prog_clk(prog_clk),
    .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s(prog_s),
    .reg_nres(reg_nres), .reg_clk(reg_clk),
    .N_i(N_i), .S_o(S_o), .S_i(S_i), .N_o(N_o),
    .W_i(W_i), .E_o(E_o), .E_i(E_i), .W_o(W_o));

  // Processes
  
  //------------------------------- Sequential ------------------------------
  
  //----------------------------- Combinational -----------------------------
  
endmodule