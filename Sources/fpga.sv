
// Full FPGA Module
module fpga #(V, H) (
  //Global Clock/Reset
  input wire clk,
  input wire nres,
  //Programming Interface
  input wire            [31:0] prog_i,
  input wire           [H*2:0] prog_shft,
  //Module In/Out
  input wire                   data_en,
  input wire      [(32*H)-1:0] data_in,
  output wire [(32*(H+1))-1:0] data_out
);
  
  // Wires
  
  logic [31:0] prog[H-1:0];
  logic [31:0] data_iCB[H-1:0];
  logic  [7:0] data_iCBV[H-1:0];
  
  logic [(V*62)+31:0] wires_U[2*H:0];
  logic [(V*34)+15:0] wires_D[2*H:0];

  // Instances
  
  genvar x;
  generate
    for(x = 0; x < H; x++)begin
      // Input Logic starting each line
      input_logic IL (.clk(clk), .nres(nres), .prog_i(prog_i), .prog_shft(prog_shft[2*x+1]), .prog_o(prog[x]),
        .data_in(data_in[32*x+31:32*x]), .en(data_en), .data_oCB(data_iCB[x]), .data_oCBV(data_iCBV[x]));
      
      // Crossbar line
      crossbar_line #(.V(V)) CL (.clk(clk), .nres(nres), .prog_i(prog_i), .prog_shft(prog_shft[2*x]),
        .N_i(wires_D[2*x]), .S_o(wires_D[2*x+1]), .S_i(wires_U[2*x+1]), .N_o(wires_U[2*x]), .data_iCB(data_iCB[x]), .data_o(data_out[32*x+31:32*x]));
      
      // Logic line
      logic_line #(.V(V)) LL (.clk(clk), .nres(nres), .prog_i(prog[x]), .prog_shft(prog_shft[2*x+1]),
        .N_i(wires_D[2*x+1]), .S_o(wires_D[2*x+2]), .S_i(wires_U[2*x+2]), .N_o(wires_U[2*x+1]), .data_iCBV(data_iCBV[x]));
    end
  endgenerate
      
  // Last Crossbar line
  crossbar_line #(.V(V)) CLE (.clk(clk), .nres(nres), .prog_i(prog_i), .prog_shft(prog_shft[2*H]),
    .N_i(wires_D[2*H]), .S_o(), .S_i(), .N_o(wires_U[2*H]), .data_iCB(), .data_o(data_out[32*H+31:32*H]));
  
endmodule





// Crossbar FPGA Line
module crossbar_line #(V) (
  //Global Clock/Reset
  input wire clk,
  input wire nres,
  //Programming Interface
  input wire  [31:0] prog_i,
  input wire         prog_shft,
  //Module In/Out
  input wire  [(V*62)+31:0] N_i,
  output wire [(V*62)+31:0] S_o,
  input wire  [(V*34)+15:0] S_i,
  output wire [(V*34)+15:0] N_o,
  input wire  [31:0] data_iCB,
  output wire [31:0] data_o
);
  
  // Wires
  
  logic [31:0] prog[2*V:0];
  logic [31:0] wires_W[2*V:0];
  logic [15:0] wires_E[2*V:0];
  
  // Assigns
  
  assign data_o = wires_W[2*V];
  
  // Instances
  
  crossbar CB0 (.clk(clk), .nres(nres), .prog_i(prog_i), .prog_shft(prog_shft), .prog_o(prog[0]),
    .N_i(N_i[31:0]), .S_o(S_o[31:0]), .S_i(S_i[15:0]), .N_o(N_o[15:0]), .W_i(data_iCB), .E_o(wires_W[0]), .E_i(wires_E[0]), .W_o());
  genvar x;
  generate
    for(x = 0; x < V; x++)begin
      H_crossbar HCB (.clk(clk), .nres(nres), .prog_i(prog[2*x]), .prog_shft(prog_shft), .prog_o(prog[2*x+1]),
        .N_i(N_i[x*62+61:x*62+32]), .S_o(S_o[x*62+61:x*62+32]), .S_i(S_i[x*34+33:x*34+16]), .N_o(N_o[x*34+33:x*34+16]),
        .W_i(wires_W[2*x]), .E_o(wires_W[2*x+1]), .E_i(wires_E[2*x+1]), .W_o(wires_E[2*x]));
      crossbar CB (.clk(clk), .nres(nres), .prog_i(prog[2*x+1]), .prog_shft(prog_shft), .prog_o(prog[2*x+2]),
        .N_i(N_i[x*63+31:x*63+0]), .S_o(S_o[x*63+31:x*63+0]), .S_i(S_i[x*35+15:x*35+0]), .N_o(N_o[x*35+15:x*35+0]),
        .W_i(wires_W[2*x+1]), .E_o(wires_W[2*x+2]), .E_i(wires_E[2*x+2]), .W_o(wires_E[2*x+1]));
    end
  endgenerate
  
endmodule





// Logic FPGA Line
module logic_line #(V) (
  //Global Clock/Reset
  input wire clk,
  input wire nres,
  //Programming Interface
  input wire [31:0] prog_i,
  input wire        prog_shft,
  //Module In/Out
  input wire  [(V*62)+31:0] N_i,
  output wire [(V*62)+31:0] S_o,
  input wire  [(V*34)+15:0] S_i,
  output wire [(V*34)+15:0] N_o,
  input wire  [7:0] data_iCBV
);
  
  // Wires
  
  logic [31:0] prog[2*V:0];
  logic  [7:0] wires_LO[V-1:0];
  logic [31:0] wires_LI[V:0];

  // Instances
  
  V_crossbar VCB0 (.clk(clk), .nres(nres), .prog_i(prog_i), .prog_shft(prog_shft), .prog_o(prog[0]),
    .N_i(N_i[31:0]), .S_o(S_o[31:0]), .S_i(S_i[15:0]), .N_o(N_o[15:0]), .W_i(data_iCBV), .E_o(wires_LI[0]));
  genvar x;
  generate
    for(x = 0; x < V; x++)begin
      logic_slice LS (.clk(clk), .nres(nres), .prog_i(prog[2*x]), .prog_shft(prog_shft), .prog_o(prog[2*x+1]),
        .N_i(N_i[x*62+61:x*62+32]), .S_o(S_o[x*62+61:x*62+32]), .S_i(S_i[x*34+33:x*34+16]), .N_o(N_o[x*34+33:x*34+16]),
        .W_i(wires_LI[x]), .E_o(wires_LO[x]));
      V_crossbar VCB (.clk(clk), .nres(nres), .prog_i(prog[2*x+1]), .prog_shft(prog_shft), .prog_o(prog[2*x+2]),
        .N_i(N_i[x*63+31:x*63+0]), .S_o(S_o[x*63+31:x*63+0]), .S_i(S_i[x*35+15:x*35+0]), .N_o(N_o[x*35+15:x*35+0]),
        .W_i(wires_LO[x]), .E_o(wires_LI[x+1]));
    end
  endgenerate
  
endmodule