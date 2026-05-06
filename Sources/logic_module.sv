`timescale 1ns/1ps

// Logic Slice Module of 16x Logic Modules and 12x Logic Switches
module logic_slice (
  //Programming Interface
  input wire         prog_nres,
  input wire         prog_clk,
  input wire   [7:0] prog_D,
  input wire         prog_en,
  input wire         prog_apply,
  input wire         prog_s_in,
  output wire        prog_s_out,
  //Register Inputs
  input wire         reg_nres,
  input wire         reg_clk,
  //Module In/Out
  input wire  [29:0] N_i,
  output wire [29:0] S_o,
  input wire  [17:0] S_i,
  output wire [17:0] N_o,
  input wire  [23:0] W_i,
  output wire  [7:0] E_o
);
  //  Programming Logic
  wire [69:0] en;
  wire [39:0] data;
  prog #(.D(5), .E(70)) Prog0 (
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
  
  logic [7:0] Lo[3:0];
  logic [23:0] Li[3:0];
  logic [17:0] wires_U[4:0];
  logic [29:0] wires_D[4:0];

  // Instances
  
  genvar x;
  generate
    for(x = 0; x < 4; x++)begin
      logic_module LM0 (.D(data[x*9+11:x*9+3]), .E(en[3:0]),   .data_out(Lo[0][x*2+1:x*2]), .data_in(Li[0][x*6+4:x*6]), .reg_in(Li[0][x*6+5]), .reg_nres(reg_nres), .reg_clk(reg_clk));
      logic_switch LS0 (.D(data[x*9+11:x*9+0]), .E(en[21:4]),   .data_in(Li[0][x*6+5:x*6]), .data_out(Lo[1][x*2+1:x*2]), .up_out(wires_U[x][5:0]), .down_in(wires_D[x][9:0]), .up_in(wires_U[x+1][5:0]), .down_out(wires_D[x+1][9:0]));
      logic_module LM1 (.D(data[x*9+11:x*9+3]), .E(en[25:22]), .data_out(Lo[1][x*2+1:x*2]), .data_in(Li[1][x*6+4:x*6]), .reg_in(Li[1][x*6+5]), .reg_nres(reg_nres), .reg_clk(reg_clk));
      logic_switch LS1 (.D(data[x*9+11:x*9+0]), .E(en[43:26]),  .data_in(Li[1][x*6+5:x*6]), .data_out(Lo[2][x*2+1:x*2]), .up_out(wires_U[x][11:6]), .down_in(wires_D[x][19:10]), .up_in(wires_U[x+1][11:6]), .down_out(wires_D[x+1][19:10]));
      logic_module LM2 (.D(data[x*9+11:x*9+3]), .E(en[47:44]), .data_out(Lo[2][x*2+1:x*2]), .data_in(Li[2][x*6+4:x*6]), .reg_in(Li[2][x*6+5]), .reg_nres(reg_nres), .reg_clk(reg_clk));
      logic_switch LS2 (.D(data[x*9+11:x*9+0]), .E(en[65:48]),  .data_in(Li[2][x*6+5:x*6]), .data_out(Lo[3][x*2+1:x*2]), .up_out(wires_U[x][17:12]), .down_in(wires_D[x][29:20]), .up_in(wires_U[x+1][17:12]), .down_out(wires_D[x+1][29:20]));
      logic_module LM3 (.D(data[x*9+11:x*9+3]), .E(en[69:66]), .data_out(Lo[3][x*2+1:x*2]), .data_in(Li[3][x*6+4:x*6]), .reg_in(Li[3][x*6+5]), .reg_nres(reg_nres), .reg_clk(reg_clk));
    end
  endgenerate

  // In/Out Connections
  assign Li[3] = W_i;
  assign E_o = Lo[0];
  assign wires_U[4] = S_i;
  assign N_o = wires_U[0];
  assign wires_D[0] = N_i;
  assign S_o = wires_D[4];

endmodule





// 5in-LUT Module with a register
module logic_module (
  //Programming Input
  input wire [8:0] D,
  input wire [3:0] E,
  //Register Inputs
  input wire reg_nres,
  input wire reg_clk,
  input wire reg_in,
  //LUT Module In/Out
  input wire [4:0] data_in,
  output wire [1:0] data_out
);
  
  // Registers
  
  reg Reg;
  
  // Wires

  logic [8:0] latch_O0;
  logic [8:0] latch_O1;
  logic [7:0] latch_O2;
  logic [7:0] latch_O3;
  
  logic [31:0] LUT_prog;
  logic reg_prog;
  logic rst_prog;
  
  logic LUT_out;

  // Assigns
  
  assign LUT_prog = {latch_O3, latch_O2, latch_O1[7:0], latch_O0[7:0]};
  assign reg_prog = latch_O0[8];
  assign rst_prog = latch_O1[8];
  
  assign data_out = {LUT_out, Reg};

  // Instances
  latches #(.L(9)) L0 (.D(D[8:0]), .E(E[0]), .O(latch_O0));
  latches #(.L(9)) L1 (.D(D[8:0]), .E(E[1]), .O(latch_O1));
  latches #(.L(8)) L2 (.D(D[7:0]), .E(E[2]), .O(latch_O2));
  latches #(.L(8)) L3 (.D(D[7:0]), .E(E[3]), .O(latch_O3));
  // Processes
  
  //------------------------------- Sequential ------------------------------
 
  //LUT Register
  always @(posedge reg_clk or negedge reg_nres)
    begin
      if (reg_nres == 0)
        Reg <= rst_prog;
      else
        Reg <= reg_prog ? reg_in : LUT_out;
    end

  //----------------------------- Combinational -----------------------------
  
  //LUT Process
  always @(data_in or LUT_prog)
    begin
      case (data_in)
        5'b00000 : LUT_out <= LUT_prog[0];
        5'b00001 : LUT_out <= LUT_prog[1];
        5'b00010 : LUT_out <= LUT_prog[2];
        5'b00011 : LUT_out <= LUT_prog[3];
        5'b00100 : LUT_out <= LUT_prog[4];
        5'b00101 : LUT_out <= LUT_prog[5];
        5'b00110 : LUT_out <= LUT_prog[6];
        5'b00111 : LUT_out <= LUT_prog[7];
        5'b01000 : LUT_out <= LUT_prog[8];
        5'b01001 : LUT_out <= LUT_prog[9];
        5'b01010 : LUT_out <= LUT_prog[10];
        5'b01011 : LUT_out <= LUT_prog[11];
        5'b01100 : LUT_out <= LUT_prog[12];
        5'b01101 : LUT_out <= LUT_prog[13];
        5'b01110 : LUT_out <= LUT_prog[14];
        5'b01111 : LUT_out <= LUT_prog[15];
        5'b10000 : LUT_out <= LUT_prog[16];
        5'b10001 : LUT_out <= LUT_prog[17];
        5'b10010 : LUT_out <= LUT_prog[18];
        5'b10011 : LUT_out <= LUT_prog[19];
        5'b10100 : LUT_out <= LUT_prog[20];
        5'b10101 : LUT_out <= LUT_prog[21];
        5'b10110 : LUT_out <= LUT_prog[22];
        5'b10111 : LUT_out <= LUT_prog[23];
        5'b11000 : LUT_out <= LUT_prog[24];
        5'b11001 : LUT_out <= LUT_prog[25];
        5'b11010 : LUT_out <= LUT_prog[26];
        5'b11011 : LUT_out <= LUT_prog[27];
        5'b11100 : LUT_out <= LUT_prog[28];
        5'b11101 : LUT_out <= LUT_prog[29];
        5'b11110 : LUT_out <= LUT_prog[30];
        5'b11111 : LUT_out <= LUT_prog[31];
        default  : LUT_out <= 5'bZZZZZ;
      endcase
    end
  
endmodule





// Switch Module to place between Logic Modules
module logic_switch (
  //Programming Input
  input wire [11:0] D,
  input wire [17:0] E,
  //Logic Module In/Out
  input wire [1:0] data_out,
  output wire [5:0] data_in,
  //Interconnect Wires
  output wire [5:0] up_out,
  input wire [9:0] down_in,
  input wire [5:0] up_in,
  output wire [9:0] down_out
);
  
  // Wires
  logic [5:0] D_F;
  logic [5:0] X_W[4:0];
  logic [5:0] Y_N[1:0];
  logic [9:0] Y_S[1:0];
  
  // Flip wires around X_U0 block to keep all connections grid aligned
  genvar x;
  generate
    for(x = 0; x < 6; x++) begin
      assign D_F[x] = D[8-x];
      assign X_W[2][x] = X_W[1][5-x];
      assign X_W[4][x] = X_W[3][5-x];
    end
  endgenerate

  // Instances
  endpoints #(.L(6))       EP0 (.O(X_W[0]));
  Xnodes #(.V(2), .H(6))  X_L0 (.D(D[8:3]), .E(E[1:0]),       .V_i(data_out), .V_o(),  .H_i(X_W[0]), .H_o(X_W[1]));

  Xnodes #(.V(6), .H(2))  X_U0 (.D({D[0], D[1]}), .E(E[7:2]), .V_i(Y_N[1]), .V_o(up_out), .H_i({data_out[0], data_out[1]}), .H_o());
  Ynodes_H #(.V(6))       Y_U0 (.D(D[2]), .E(E[7:2]),         .H_i(Y_N[0]), .H_o(Y_N[1]));
  Xnodes #(.V(6), .H(6))  X_U1 (.D(D_F), .E(E[7:2]),          .V_i(up_in), .V_o(Y_N[0]), .H_i(X_W[2]), .H_o(X_W[3]));

  Xnodes #(.V(10), .H(6)) X_D1 (.D(D[8:3]), .E(E[17:8]),      .V_i(down_in), .V_o(Y_S[0]), .H_i(X_W[4]), .H_o(data_in));
  Ynodes_H #(.V(10))      Y_D0 (.D(D[9]), .E(E[17:8]),        .H_i(Y_S[0]), .H_o(Y_S[1]));
  Xnodes #(.V(10), .H(2)) X_D0 (.D(D[11:10]), .E(E[17:8]),    .V_i(Y_S[1]), .V_o(down_out), .H_i(data_out), .H_o());
  
endmodule