`timescale 1ns/1ps

// eFPGA Wrapper Top Module
module eFPGA_blank (
  //Global Clock/Reset
  input wire clk,
  input wire nres,
  //Programming Interface
  input wire   [31:0] prog_i,
  input wire    [4:0] prog_shft,
  //Module In/Out
  input wire          data_en,
  input wire  [63:0] data_in,
  output wire [95:0] data_out
);
  
  // Registers
  
  // Wires
  
  // Assigns

  // Instances

  fpga #(.V(2), .H(2)) eFPGA_unit (.clk(clk), .nres(nres), .prog_i(prog_i), .prog_shft(prog_shft),
    .data_en(data_en), .data_in(data_in), .data_out(data_out));

  // Processes
  
  //------------------------------- Sequential ------------------------------
  
  //----------------------------- Combinational -----------------------------
  
endmodule