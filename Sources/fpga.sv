`timescale 1ns/1ps

// Full FPGA Module
module fpga #(V, H) (
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
  
  // Wires
  
  logic [34*V+15:0] wires_U[2*H:0];
  logic [62*V+31:0] wires_D[2*H:0];

  // Assigns
  
  assign wires_D[0] = N_i;
  assign N_o = wires_U[0];

  // Instances
  
  genvar x;
  generate
    for(x = 0; x < H; x++)begin
      // Crossbar line
      crossbar_line #(.V(V)) CL (.prog_nres(prog_nres), .prog_clk(prog_clk), .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s_in(prog_s[2*x]),
        .N_i(wires_D[2*x]), .S_o(wires_D[2*x+1]), .S_i(wires_U[2*x+1]), .N_o(wires_U[2*x]),
        .W_i(W_i[40*x+31:40*x]), .E_o(E_o[56*x+31:56*x]), .E_i(E_i[16*x+15:16*x]), .W_o(W_o[16*x+15:16*x]));
      
      // Logic line
      logic_line #(.V(V)) LL (.prog_nres(prog_nres), .prog_clk(prog_clk), .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s_in(prog_s[2*x+1]),
        .reg_nres(reg_nres), .reg_clk(reg_clk),
        .N_i(wires_D[2*x+1]), .S_o(wires_D[2*x+2]), .S_i(wires_U[2*x+2]), .N_o(wires_U[2*x+1]),
        .W_i(W_i[40*x+39:40*x+32]), .E_o(E_o[56*x+55:56*x+32]));
    end
  endgenerate
      
  // Last Crossbar line
  crossbar_line #(.V(V)) CLE (.prog_nres(prog_nres), .prog_clk(prog_clk), .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s_in(prog_s[2*H]),
    .N_i(wires_D[2*H]), .S_o(S_o), .S_i(S_i), .N_o(wires_U[2*H]),
    .W_i(W_i[40*H+31:40*H]), .E_o(E_o[56*H+31:56*H]), .E_i(E_i[16*H+15:16*H]), .W_o(W_o[16*H+15:16*H]));
  
endmodule





// Crossbar FPGA Line
module crossbar_line #(V) (
  //Programming Interface
  input wire         prog_nres,
  input wire         prog_clk,
  input wire   [7:0] prog_D,
  input wire         prog_en,
  input wire         prog_apply,
  input wire         prog_s_in,
  //Module In/Out
  input wire  [(V*62)+31:0] N_i,
  output wire [(V*62)+31:0] S_o,
  input wire  [(V*34)+15:0] S_i,
  output wire [(V*34)+15:0] N_o,
  input wire  [31:0] W_i,
  output wire [31:0] E_o,
  input wire  [15:0] E_i,
  output wire [15:0] W_o
);
  
  // Wires
  
  logic [2*V:0] prog_s;
  logic [31:0] wires_W[2*V:0];
  logic [15:0] wires_E[2*V:0];
  
  // Assigns
  
  assign wires_E[2*V] = E_i;
  assign E_o = wires_W[2*V];
  
  // Instances
  
  crossbar CB0 (.prog_nres(prog_nres), .prog_clk(prog_clk), .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s_in(prog_s_in), .prog_s_out(prog_s[0]),
    .N_i(N_i[(V*62)+31:(V*62)]), .S_o(S_o[(V*62)+31:(V*62)]), .S_i(S_i[(V*34)+15:(V*34)]), .N_o(N_o[(V*34)+15:(V*34)]), .W_i(W_i), .E_o(wires_W[0]), .E_i(wires_E[0]), .W_o(W_o));
  genvar x;
  generate
    for(x = 0; x < V; x++)begin
      H_crossbar HCB (.prog_nres(prog_nres), .prog_clk(prog_clk), .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s_in(prog_s[2*x]), .prog_s_out(prog_s[2*x+1]),
        .N_i(N_i[x*62+61:x*62+32]), .S_o(S_o[x*62+61:x*62+32]), .S_i(S_i[x*34+33:x*34+16]), .N_o(N_o[x*34+33:x*34+16]),
        .W_i(wires_W[2*x]), .E_o(wires_W[2*x+1]), .E_i(wires_E[2*x+1]), .W_o(wires_E[2*x]));
      crossbar CB (.prog_nres(prog_nres), .prog_clk(prog_clk), .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s_in(prog_s[2*x+1]), .prog_s_out(prog_s[2*x+2]),
        .N_i(N_i[x*62+31:x*62+0]), .S_o(S_o[x*62+31:x*62+0]), .S_i(S_i[x*34+15:x*34+0]), .N_o(N_o[x*34+15:x*34+0]),
        .W_i(wires_W[2*x+1]), .E_o(wires_W[2*x+2]), .E_i(wires_E[2*x+2]), .W_o(wires_E[2*x+1]));
    end
  endgenerate
  
endmodule





// Logic FPGA Line
module logic_line #(V) (
  //Programming Interface
  input wire         prog_nres,
  input wire         prog_clk,
  input wire   [7:0] prog_D,
  input wire         prog_en,
  input wire         prog_apply,
  input wire         prog_s_in,
  //Register Inputs
  input wire         reg_nres,
  input wire         reg_clk,
  //Module In/Out
  input wire  [(V*62)+31:0] N_i,
  output wire [(V*62)+31:0] S_o,
  input wire  [(V*34)+15:0] S_i,
  output wire [(V*34)+15:0] N_o,
  input wire          [7:0] W_i,
  output wire        [23:0] E_o
);
  
  // Wires
  
  logic [2*V:0] prog_s;
  logic  [7:0] wires_LO[V-1:0];
  logic [23:0] wires_LI[V:0];
  
  // Assigns
  
  assign E_o = wires_LI[V];

  // Instances
  
  V_crossbar VCB0 (.prog_nres(prog_nres), .prog_clk(prog_clk), .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s_in(prog_s_in), .prog_s_out(prog_s[0]),
    .N_i(N_i[(V*62)+31:(V*62)]), .S_o(S_o[(V*62)+31:(V*62)]), .S_i(S_i[(V*34)+15:(V*34)]), .N_o(N_o[(V*34)+15:(V*34)]), .W_i(W_i), .E_o(wires_LI[0]));
  genvar x;
  generate
    for(x = 0; x < V; x++)begin
      logic_slice LS (.prog_nres(prog_nres), .prog_clk(prog_clk), .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s_in(prog_s[2*x+0]), .prog_s_out(prog_s[2*x+1]),
        .reg_nres(reg_nres), .reg_clk(reg_clk),
        .N_i(N_i[x*62+61:x*62+32]), .S_o(S_o[x*62+61:x*62+32]), .S_i(S_i[x*34+33:x*34+16]), .N_o(N_o[x*34+33:x*34+16]),
        .W_i(wires_LI[x]), .E_o(wires_LO[x]));
      V_crossbar VCB (.prog_nres(prog_nres), .prog_clk(prog_clk), .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s_in(prog_s[2*x+1]), .prog_s_out(prog_s[2*x+2]),
        .N_i(N_i[x*62+31:x*62+0]), .S_o(S_o[x*62+31:x*62+0]), .S_i(S_i[x*34+15:x*34+0]), .N_o(N_o[x*34+15:x*34+0]),
        .W_i(wires_LO[x]), .E_o(wires_LI[x+1]));
    end
  endgenerate
  
endmodule