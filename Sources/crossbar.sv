
// General Crossbar Module
module crossbar (
  //Global Clock/Reset
  input wire 	 	 clk,
  input wire      	 nres,
  //Programming Interface
  input wire  [31:0] prog_i,
  input wire		 prog_shft,
  output wire [31:0] prog_o,
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
  //set length of programming by number of 32bit regs:
  parameter l=75;
  
  reg [31:0] prog[l-1:0];
  assign prog_o = prog[l-1];

  //Shifting Registers
  integer i;
  always @(posedge clk or negedge nres)
    begin
      if (nres == 0) begin
        for (i = 0; i < l; i++) begin
          prog[i] <= 32'h00000000;
        end
      end else begin
        if (prog_shft == 1) begin
          prog[0] <= prog_i;
          for (i = 1; i < l; i++) begin
            prog[i] <= prog[i-1];
          end
        end
      end
    end
  
  //Fetch Programming Regions from Shifting Registers
  logic  [511:0] X_prog_NW;
  logic [1023:0] X_prog_NE;
  logic  [255:0] X_prog_SW;
  logic  [511:0] X_prog_SE;
  logic   [15:0] Y_prog_N;
  logic   [15:0] Y_prog_W;
  logic   [31:0] Y_prog_S;
  logic   [31:0] Y_prog_E;
  
  assign Y_prog_N = (prog_shft == 0) ? prog[0][15:0] : 'Z;
  assign Y_prog_W = (prog_shft == 0) ? prog[0][31:16] : 'Z;
  assign Y_prog_S = (prog_shft == 0) ? prog[1] : 'Z;
  assign Y_prog_E = (prog_shft == 0) ? prog[2] : 'Z;
  genvar x;
  generate
    for(x = 0; x < 16; x++)begin
      assign X_prog_NW[32*x+31:32*x] = (prog_shft == 0) ? prog[3+x] : 'Z;
    end
    for(x = 0; x < 32; x++)begin
      assign X_prog_NE[32*x+31:32*x] = (prog_shft == 0) ? prog[19+x] : 'Z;
    end
    for(x = 0; x < 8; x++)begin
      assign X_prog_SW[32*x+31:32*x] = (prog_shft == 0) ? prog[51+x] : 'Z;
    end
    for(x = 0; x < 16; x++)begin
      assign X_prog_SE[32*x+31:32*x] = (prog_shft == 0) ? prog[59+x] : 'Z;
    end
  endgenerate
  
  
  //  Module Logic
  
  // Wires
  
  logic [15:0] Y_N[1:0];
  logic [15:0] Y_W[1:0];
  logic [31:0] Y_S[1:0];
  logic [31:0] Y_E[1:0];

  // Instances
  
  Ynodes #(.V(16)) Y_N0 (.prog(Y_prog_N), .V_i(Y_N[0]), .V_o(Y_N[1]));
  Ynodes #(.V(16)) Y_W0 (.prog(Y_prog_W), .V_i(Y_W[0]), .V_o(Y_W[1]));
  Ynodes #(.V(32)) Y_S0 (.prog(Y_prog_S), .V_i(Y_S[0]), .V_o(Y_S[1]));
  Ynodes #(.V(32)) Y_E0 (.prog(Y_prog_E), .V_i(Y_E[0]), .V_o(Y_E[1]));

  Xnodes #(.V(16), .H(32)) X_NW (.prog(X_prog_NW), .V_i(Y_N[1]), .V_o(N_o), .H_i(W_i), .H_o(Y_E[0]));
  Xnodes #(.V(32), .H(32)) X_NE (.prog(X_prog_NE), .V_i(N_i), .V_o(Y_S[0]), .H_i(Y_E[1]), .H_o(E_o));
  Xnodes #(.V(16), .H(16)) X_SW (.prog(X_prog_SW), .V_i(S_i), .V_o(Y_N[0]), .H_i(Y_W[1]), .H_o(W_o));
  Xnodes #(.V(32), .H(16)) X_SE (.prog(X_prog_SE), .V_i(Y_S[1]), .V_o(S_o), .H_i(E_i), .H_o(Y_W[0]));

endmodule





// Logic V Crossbar Module
module V_crossbar (
  //Global Clock/Reset
  input wire clk,
  input wire nres,
  //Programming Interface
  input wire  [31:0] prog_i,
  input wire		 prog_shft,
  output wire [31:0] prog_o,
  //Module In/Out
  input wire  [31:0] N_i,
  output wire [31:0] S_o,
  input wire  [15:0] S_i,
  output wire [15:0] N_o,
  input wire   [7:0] W_i,
  output wire [31:0] E_o
);
  //  Programming Logic
  //set length of programming by number of 32bit regs:
  parameter l=68;
  
  reg [31:0] prog[l-1:0];
  assign prog_o = prog[l-1];

  //Shifting Registers
  integer i;
  always @(posedge clk or negedge nres)
    begin
      if (nres == 0) begin
        for (i = 0; i < l; i++) begin
          prog[i] <= 32'h00000000;
        end
      end else begin
        if (prog_shft == 1) begin
          prog[0] <= prog_i;
          for (i = 1; i < l; i++) begin
            prog[i] <= prog[i-1];
          end
        end
      end
    end
  
  //Fetch Programming Regions from Shifting Registers
  logic   [31:0] X_prog_LO_N[3:0];
  logic   [63:0] X_prog_LO_S[3:0];
  logic   [63:0] X_prog_LO_D[3:0];
  logic  [127:0] X_prog_LI_N[3:0];
  logic  [255:0] X_prog_LI_S[3:0];
  
  genvar x;
  generate
    for(x = 0; x < 4; x++)begin
      assign X_prog_LO_N[x] = (prog_shft == 0) ? prog[0+x*17] : 'Z;
      assign X_prog_LO_S[x] = (prog_shft == 0) ? {prog[2+x*17], prog[1+x*17]} : 'Z;
      assign X_prog_LO_D[x] = (prog_shft == 0) ? {prog[4+x*17], prog[3+x*17]} : 'Z;
      assign X_prog_LI_N[x] = (prog_shft == 0) ? {prog[8+x*17], prog[7+x*17], prog[6+x*17], prog[5+x*17]} : 'Z;
      assign X_prog_LI_S[x] = (prog_shft == 0) ? {prog[16+x*17], prog[15+x*17], prog[14+x*17], prog[13+x*17], prog[12+x*17], prog[11+x*17], prog[10+x*17], prog[9+x*17]} : 'Z;
    end
  endgenerate
  
  
  //  Module Logic
  
  // Wires
  
  logic  [1:0] LD_B[3:0];
  logic  [7:0] LO_D[3:0];
  logic [15:0] LO_N[8:0];
  logic  [7:0] LO_B[3:0];
  logic [31:0] LO_S[8:0];

  // Instances
  
  Vnodes #(.V(16)) V_N0 (.V_i(S_i), .V_o(LO_N[8]));
  assign N_o = LO_N[0];

  Vnodes #(.V(32)) V_S0 (.V_i(N_i), .V_o(LO_S[0]));
  assign S_o = LO_S[8];

  generate
    for(x = 0; x < 4; x++)begin
      Xnodes #(.V(16), .H(2)) X_LO_N (.prog(X_prog_LO_N[x]), .V_i(LO_N[2*x+1]), .V_o(LO_N[2*x]), .H_i(W_i[2*x+1:2*x]), .H_o(LD_B[x]));
      Xnodes #(.V(32), .H(2)) X_LO_S (.prog(X_prog_LO_S[x]), .V_i(LO_S[2*x]), .V_o(LO_S[2*x+1]), .H_i(LD_B[x]), .H_o());
      Xnodes #(.V(8), .H(8)) X_LO_D (.prog(X_prog_LO_D[x]), .V_i(W_i), .V_o(), .H_i('0), .H_o(LO_D[x]));
      Xnodes #(.V(16), .H(8)) X_LI_N (.prog(X_prog_LI_N[x]), .V_i(LO_N[2*x+2]), .V_o(LO_N[2*x+1]), .H_i(LO_D[x]), .H_o(LO_B[x]));
      Xnodes #(.V(32), .H(8)) X_LI_S (.prog(X_prog_LI_S[x]), .V_i(LO_S[2*x+1]), .V_o(LO_S[2*x+2]), .H_i(LO_B[x]), .H_o(E_o[8*x+7:8*x]));
    end
  endgenerate

endmodule





// Logic H Crossbar Module
module H_crossbar (
  //Global Clock/Reset
  input wire clk,
  input wire nres,
  //Programming Interface
  input wire  [31:0] prog_i,
  input wire		 prog_shft,
  output wire [31:0] prog_o,
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
  //set length of programming by number of 32bit regs:
  parameter l=76;
  
  reg [31:0] prog[l-1:0];
  assign prog_o = prog[l-1];

  //Shifting Registers
  integer i;
  always @(posedge clk or negedge nres)
    begin
      if (nres == 0) begin
        for (i = 0; i < l; i++) begin
          prog[i] <= 32'h00000000;
        end
      end else begin
        if (prog_shft == 1) begin
          prog[0] <= prog_i;
          for (i = 1; i < l; i++) begin
            prog[i] <= prog[i-1];
          end
        end
      end
    end
  
  //Fetch Programming Regions from Shifting Registers
  logic   [79:0] X_prog_LB;
  logic   [15:0] Y_prog[2:0];
  logic  [511:0] X_prog_W[2:0];
  logic  [255:0] X_prog_E[2:0];
  logic  [319:0] X_prog_Wd[2:0];
  logic  [192:0] X_prog_Wu[2:0];
  logic  [159:0] X_prog_Ed[2:0];
  logic   [95:0] X_prog_Eu[2:0];
  
  assign X_prog_LB = (prog_shft == 0) ? {prog[2][15:0], prog[1], prog[0]} : 'Z;
  assign Y_prog[0] = (prog_shft == 0) ? prog[2][31:16] : 'Z;
  assign Y_prog[1] = (prog_shft == 0) ? prog[3][15:0] : 'Z;
  assign Y_prog[2] = (prog_shft == 0) ? prog[3][31:16] : 'Z;
  genvar x,y;
  generate
    for(x = 0; x < 3; x++)begin
      for(y = 0; y < 8; y++)begin
        assign X_prog_W[x][y*64+31:y*64] = (prog_shft == 0) ? prog[4+y+x*24] : 'Z;
        assign X_prog_W[x][y*64+63:y*64+32] = (prog_shft == 0) ? prog[12+y+x*24] : 'Z;
        assign X_prog_E[x][y*32+31:y*32] = (prog_shft == 0) ? prog[20+y+x*24] : 'Z;
      end
      for(y = 0; y < 16; y++)begin
        assign X_prog_Wd[x][y*20+9:y*20] = (prog_shft == 0) ? X_prog_W[x][y*32+9:y*32] : 'Z;
        assign X_prog_Wu[x][y*12+5:y*12] = (prog_shft == 0) ? X_prog_W[x][y*32+15:y*32+10] : 'Z;
        assign X_prog_Wd[x][y*20+19:y*20+10] = (prog_shft == 0) ? X_prog_W[x][y*32+25:y*32+16] : 'Z;
        assign X_prog_Wu[x][y*12+11:y*12+6] = (prog_shft == 0) ? X_prog_W[x][y*32+31:y*32+26] : 'Z;
        assign X_prog_Ed[x][y*10+9:y*10] = (prog_shft == 0) ? X_prog_E[x][y*16+9:y*16] : 'Z;
        assign X_prog_Eu[x][y*6+5:y*6] = (prog_shft == 0) ? X_prog_E[x][y*16+15:y*16+10] : 'Z;
      end
    end
  endgenerate
  
  
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

  generate
    for(x = 0; x < 3; x++)begin
      Xnodes #(.V(10), .H(32)) X_Ni (.prog(X_prog_Wd[x]), .V_i(Ni[x]), .V_o(XNi[x]), .H_i(wires_E[2*x+1]), .H_o(wires_E[2*x]));
      Xnodes #(.V(6), .H(32)) X_No (.prog(X_prog_Wu[x]), .V_i(XNo[x]), .V_o(No[x]), .H_i(wires_E[2*x+2]), .H_o(wires_E[2*x+1]));
      Ynodes #(.V(10)) Y_S (.prog(Y_prog[x][9:0]), .V_i(XNi[x]), .V_o(XSo[x]));
      Ynodes #(.V(6)) Y_N (.prog(Y_prog[x][15:10]), .V_i(XSi[x]), .V_o(XNo[x]));
      Xnodes #(.V(10), .H(16)) X_So (.prog(X_prog_Ed[x]), .V_i(XSo[x]),  .V_o(So[x]),  .H_i(wires_W[2*x]),  .H_o(wires_W[2*x+1]));
      Xnodes #(.V(6), .H(16)) X_Si (.prog(X_prog_Eu[x]), .V_i(Si[x]), .V_o(XSi[x]), .H_i(wires_W[2*x+1]), .H_o(wires_W[2*x+2]));
    end
  endgenerate
  
  assign So[3] = So[0];
  Xnodes #(.V(10), .H(4)) X_LB0 (.prog(X_prog_LB[39:0]), .V_i(So[1]), .V_o(So[4]), .H_i(S_i[3:0]), .H_o());
  Xnodes #(.V(10), .H(4)) X_LB1 (.prog(X_prog_LB[79:40]), .V_i(So[2]), .V_o(So[5]), .H_i(S_i[9:6]), .H_o());

endmodule
