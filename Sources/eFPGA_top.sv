// eFPGA Wrapper Top Module
module eFPGA (
  //Global Clock/Reset
  input wire clk,
  input wire nres,
  //Programming Interface
  input wire   [31:0] prog_i,
  input wire    [6:0] prog_shft,
  //Module In/Out
  input wire          data_en,
  input wire   [95:0] data_in,
  output wire [127:0] data_out
);
  
  // Registers
  
  // Wires
  
  // Assigns

  // Instances

  fpga #(.V(2), .H(3)) eFPGA (.clk(clk), .nres(nres), .prog_i(prog_i), .prog_shft(prog_shft),
    .data_en(data_en), .data_in(data_in), .data_out(data_out));

  // Processes
  
  //------------------------------- Sequential ------------------------------
  
  //----------------------------- Combinational -----------------------------
  
endmodule