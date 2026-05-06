`timescale 1ns/1ps

// General Crossbar Module
module crossbar (
  //Programming Interface
  input wire         prog_nres,
  input wire         prog_clk,
  input wire   [7:0] prog_D,
  input wire         prog_en,
  input wire         prog_apply,
  input wire         prog_s_in,
  output wire        prog_s_out,
  //Module In/Out
  input wire  [31:0] N_i,
  output wire [31:0] S_o,
  input wire  [15:0] S_i,
  output wire [15:0] N_o,
  input wire  [31:0] W_i,
  output wire [31:0] E_o,
  input wire  [15:0] E_i,
  output wire [15:0] W_o
);
  //  Programming Logic
  wire [48:0] en;
  wire [55:0] data;
  prog #(.D(7), .E(49)) Prog0 (
    .prog_nres(prog_nres),
    .prog_clk(prog_clk),
    .prog_D(prog_D),
    .prog_en(prog_en),
    .prog_apply(prog_apply),
    .prog_s_in(prog_s_in),
    .prog_s_out(prog_s_out),
    .en(en),
    .data(data)
  );

  
  //  Module Logic
  
  // Wires
  
  logic [15:0] Y_N[1:0];
  logic [15:0] Y_W[1:0];
  logic [31:0] Y_S[1:0];
  logic [31:0] Y_E[1:0];

  // Instances
  
  Xnodes #(.V(16), .H(32)) X_NW (.D(data[31:0]), .E(en[15:0]), .V_i(Y_N[1]), .V_o(N_o), .H_i(W_i), .H_o(Y_E[0]));
  Ynodes_V #(.H(32))       Y_E0 (.D(data[31:0]), .E(en[16]), .V_i(Y_E[0]), .V_o(Y_E[1]));
  Xnodes #(.V(32), .H(32)) X_NE (.D(data[31:0]), .E(en[48:17]), .V_i(N_i), .V_o(Y_S[0]), .H_i(Y_E[1]), .H_o(E_o));

  Ynodes_H #(.V(16))       Y_N0 (.D(data[32]), .E(en[15:0]), .H_i(Y_N[0]), .H_o(Y_N[1]));
  Ynodes_H #(.V(32))       Y_S0 (.D(data[32]), .E(en[48:17]), .H_i(Y_S[0]), .H_o(Y_S[1]));

  Xnodes #(.V(16), .H(16)) X_SW (.D(data[48:33]), .E(en[15:0]), .V_i(S_i), .V_o(Y_N[0]), .H_i(Y_W[1]), .H_o(W_o));
  Ynodes_V #(.H(16))       Y_W0 (.D(data[48:33]), .E(en[16]), .V_i(Y_W[0]), .V_o(Y_W[1]));
  Xnodes #(.V(32), .H(16)) X_SE (.D(data[48:33]), .E(en[48:17]), .V_i(Y_S[1]), .V_o(S_o), .H_i(E_i), .H_o(Y_W[0]));

endmodule





// Logic V Crossbar Module
module V_crossbar (
  //Programming Interface
  input wire         prog_nres,
  input wire         prog_clk,
  input wire   [7:0] prog_D,
  input wire         prog_en,
  input wire         prog_apply,
  input wire         prog_s_in,
  output wire        prog_s_out,
  //Module In/Out
  input wire  [31:0] N_i,
  output wire [31:0] S_o,
  input wire  [15:0] S_i,
  output wire [15:0] N_o,
  input wire   [7:0] W_i,
  output wire [23:0] E_o
);
  //  Programming Logic
  wire [55:0] en;
  wire [31:0] data;
  prog #(.D(4), .E(56)) Prog0 (
    .prog_nres(prog_nres),
    .prog_clk(prog_clk),
    .prog_D(prog_D),
    .prog_en(prog_en),
    .prog_apply(prog_apply),
    .prog_s_in(prog_s_in),
    .prog_s_out(prog_s_out),
    .en(en),
    .data(data)
  );
  
  
  //  Module Logic
  
  // Wires
  
  logic  [1:0] LD_B[3:0];
  logic  [5:0] LO_D[3:0];
  logic [15:0] LO_N[8:0];
  logic  [5:0] LO_B[3:0];
  logic [31:0] LO_S[8:0];

  // Instances
  
  Vnodes #(.V(16)) V_N0 (.V_i(S_i), .V_o(LO_N[8]));
  assign N_o = LO_N[0];

  Vnodes #(.V(32)) V_S0 (.V_i(N_i), .V_o(LO_S[0]));
  assign S_o = LO_S[8];

  genvar x;
  generate
    for(x = 0; x < 4; x++)begin
      Xnodes #(.V(16), .H(2)) X_LO_N (.D(data[8*x+1:8*x+0]), .E(en[23:8]),  .V_i(LO_N[2*x+1]), .V_o(LO_N[2*x]), .H_i(W_i[2*x+1:2*x]), .H_o(LD_B[x]));
      Xnodes #(.V(32), .H(2)) X_LO_S (.D(data[8*x+1:8*x+0]), .E(en[55:24]), .V_i(LO_S[2*x]),   .V_o(LO_S[2*x+1]), .H_i(LD_B[x]), .H_o());
      Xnodes #(.V(8),  .H(6)) X_LO_D (.D(data[8*x+7:8*x+2]), .E(en[7:0]),   .V_i(W_i), .V_o(), .H_i('0), .H_o(LO_D[x]));
      Xnodes #(.V(16), .H(6)) X_LI_N (.D(data[8*x+7:8*x+2]), .E(en[23:8]),  .V_i(LO_N[2*x+2]), .V_o(LO_N[2*x+1]), .H_i(LO_D[x]), .H_o(LO_B[x]));
      Xnodes #(.V(32), .H(6)) X_LI_S (.D(data[8*x+7:8*x+2]), .E(en[55:24]), .V_i(LO_S[2*x+1]), .V_o(LO_S[2*x+2]), .H_i(LO_B[x]), .H_o(E_o[6*x+5:6*x]));
    end
  endgenerate

endmodule





// Logic H Crossbar Module
module H_crossbar (
  //Programming Interface
  input wire         prog_nres,
  input wire         prog_clk,
  input wire   [7:0] prog_D,
  input wire         prog_en,
  input wire         prog_apply,
  input wire         prog_s_in,
  output wire        prog_s_out,
  //Module In/Out
  input wire  [29:0] N_i,
  output wire [29:0] S_o,
  input wire  [17:0] S_i,
  output wire [17:0] N_o,
  input wire  [31:0] W_i,
  output wire [31:0] E_o,
  input wire  [15:0] E_i,
  output wire [15:0] W_o
);
  //  Programming Logic
  wire [47:0] en;
  wire [55:0] data;
  prog #(.D(7), .E(48)) Prog0 (
    .prog_nres(prog_nres),
    .prog_clk(prog_clk),
    .prog_D(prog_D),
    .prog_en(prog_en),
    .prog_apply(prog_apply),
    .prog_s_in(prog_s_in),
    .prog_s_out(prog_s_out),
    .en(en),
    .data(data)
  );
  
  
  //  Module Logic
  
  // Wires
  
  logic [5:0] No[2:0];
  logic [9:0] Ni[2:0];
  logic [5:0] XNo[2:0];
  logic [9:0] XNi[2:0];
  logic [9:0] XSo[2:0];
  logic [5:0] XSi[2:0];
  logic [9:0] So[5:0];
  logic [5:0] Si[2:0];

  logic [15:0] wires_W[6:0];
  logic [31:0] wires_E[6:0];

  // Instances
  
  Vnodes #(.V(30)) V_Ni (.V_i(N_i), .V_o({Ni[2], Ni[1], Ni[0]}));
  Vnodes #(.V(18)) V_No (.V_i({No[2], No[1], No[0]}), .V_o(N_o));
  Vnodes #(.V(18)) V_Si (.V_i(S_i), .V_o({Si[2], Si[1], Si[0]}));
  Vnodes #(.V(30)) V_So (.V_i({So[5], So[4], So[3]}), .V_o(S_o));
  
  assign wires_W[0] = E_i;
  assign W_o = wires_W[6];
  assign wires_E[6] = W_i;
  assign E_o = wires_E[0];

  genvar x;
  generate
    for(x = 0; x < 3; x++)begin
      Xnodes #(.V(6),  .H(32)) X_No (.D(data[31:0]), .E(en[16*x+5:16*x+0]), .V_i(XNo[x]), .V_o(No[x]), .H_i(wires_E[2*x+2]), .H_o(wires_E[2*x+1]));
      Xnodes #(.V(10), .H(32)) X_Ni (.D(data[31:0]), .E(en[16*x+15:16*x+6]), .V_i(Ni[x]), .V_o(XNi[x]), .H_i(wires_E[2*x+1]), .H_o(wires_E[2*x]));
      Ynodes_H #(.V(6))        Y_N  (.D(data[32]), .E(en[16*x+5:16*x+0]), .H_i(XSi[x]), .H_o(XNo[x]));
      Ynodes_H #(.V(10))       Y_S  (.D(data[32]), .E(en[16*x+15:16*x+6]), .H_i(XNi[x]), .H_o(XSo[x]));
      Xnodes #(.V(6),  .H(16)) X_Si (.D(data[48:33]), .E(en[16*x+5:16*x+0]), .V_i(Si[x]), .V_o(XSi[x]), .H_i(wires_W[2*x+1]), .H_o(wires_W[2*x+2]));
      Xnodes #(.V(10), .H(16)) X_So (.D(data[48:33]), .E(en[16*x+15:16*x+6]), .V_i(XSo[x]),  .V_o(So[x]),  .H_i(wires_W[2*x]),  .H_o(wires_W[2*x+1]));
    end
  endgenerate
  
  assign So[3] = So[0];
  Xnodes #(.V(10), .H(6)) X_LB0 (.D(data[54:49]), .E(en[15:6]), .V_i(So[1]), .V_o(So[4]), .H_i(S_i[5:0]), .H_o());
  Xnodes #(.V(10), .H(6)) X_LB1 (.D(data[54:49]), .E(en[31:22]), .V_i(So[2]), .V_o(So[5]), .H_i(S_i[11:6]), .H_o());

endmodule
