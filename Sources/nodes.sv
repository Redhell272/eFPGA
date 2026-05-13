`timescale 1ns/1ps

// Matrix of X nodes
module Xnodes #(V, H) (
  //Programming Input
  input wire [H-1:0] D,
  input wire [V-1:0] E,
  //Data Wires
  input wire [V-1:0] V_i,
  output wire [V-1:0] V_o,
  input wire [H-1:0] H_i,
  output wire [H-1:0] H_o
);
  
  // Wires
  logic  [V:0] wiresH[H-1:0];
  logic  [V-1:0] wiresV[H:0];
  
  // Assigns
  genvar x;
  generate
    for(x = 0; x < H; x++)begin
      assign wiresH[x][0] = H_i[x];
      assign H_o[x] = wiresH[x][V];
    end
  endgenerate

  assign wiresV[0] = V_i;
  assign V_o = wiresV[H];

  // Instances
  genvar y;
  generate
    for(x = 0; x < H; x++)begin
      for(y = 0; y < V; y++)begin
        Xnode X0 (.D(D[x]), .E(E[y]), .I1(wiresV[x][y]), .I2(wiresH[x][y]), .O1(wiresV[x+1][y]), .O2(wiresH[x][y+1]));
      end
    end
  endgenerate
  
endmodule


// Horizontal array of Y nodes
module Ynodes_H #(V) (
  //Programming Input
  input wire D,
  input wire [V-1:0] E,
  //Data Wires
  input wire [V-1:0] H_i,
  output wire [V-1:0] H_o
);

  // Instances
  genvar x;
  generate
    for(x = 0; x < V; x++)begin
      Ynode Y0 (.D(D), .E(E[x]), .I(H_i[x]), .O(H_o[x]));
    end
  endgenerate
  
endmodule


// Vertical array of Y nodes
module Ynodes_V #(H) (
  //Programming Input
  input wire [H-1:0] D,
  input wire E,
  //Data Wires
  input wire [H-1:0] V_i,
  output wire [H-1:0] V_o
);

  // Instances
  genvar x;
  generate
    for(x = 0; x < H; x++)begin
      Ynode Y0 (.D(D[x]), .E(E), .I(V_i[x]), .O(V_o[x]));
    end
  endgenerate
  
endmodule


// Array of V nodes
module Vnodes #(V) (
  //Data Wires
  input wire [V-1:0] V_i,
  output wire [V-1:0] V_o
);

  // Instances
  genvar x;
  generate
    for(x = 0; x < V; x++)begin
      Vnode V0 (.I(V_i[x]), .O(V_o[x]));
    end
  endgenerate
  
endmodule



//X
module Xnode (
  //Programming Input
  input wire E,
  input wire D,
  //in/outs
  input wire I1,
  input wire I2,
  output wire O1,
  output wire O2
);

  logic prog;
  latch L0 (.D(D), .E(E), .O(prog));
  pass C0 (.prog(prog), .I1(I1), .I2(I2), .O1(O1), .O2(O2));
  
endmodule

//Y
module Ynode (
  //Programming Input
  input wire E,
  input wire D,
  //in/outs
  input wire I,
  output wire O
);

  logic prog;
  latch L0 (.D(D), .E(E), .O(prog));
  conn C0 (.prog(prog), .I(I), .O(O));
  
endmodule

//V
module Vnode (
  //in/outs
  input wire I,
  output wire O
);

  buffer B0 (.I(I), .O(O));
  
endmodule



// 5LUT from muxes
module LUT5 (
  input wire [31:0] D,
  input wire [4:0] S,
  output wire O
);
  
  logic [15:0] LUT_L1;
  logic [7:0] LUT_L2;
  logic [3:0] LUT_L3;
  logic [1:0] LUT_L4;

  genvar x;
  generate
    for(x = 0; x < 16; x++)begin
      mux ML1 (.S(S[0]), .I0(D[2*x+0]), .I1(D[2*x+1]), .O(LUT_L1[x]));
    end
    for(x = 0; x < 8; x++)begin
      mux ML2 (.S(S[1]), .I0(LUT_L1[2*x+0]), .I1(LUT_L1[2*x+1]), .O(LUT_L2[x]));
    end
    for(x = 0; x < 4; x++)begin
      mux ML3 (.S(S[2]), .I0(LUT_L2[2*x+0]), .I1(LUT_L2[2*x+1]), .O(LUT_L3[x]));
    end
    for(x = 0; x < 2; x++)begin
      mux ML4 (.S(S[3]), .I0(LUT_L3[2*x+0]), .I1(LUT_L3[2*x+1]), .O(LUT_L4[x]));
    end
  endgenerate

  mux ML5 (.S(S[4]), .I0(LUT_L4[0]), .I1(LUT_L4[1]), .O(O));
  
endmodule

// Array of latches
module latches #(L) (
  input wire [L-1:0] D,
  input wire E,
  output wire [L-1:0] O
);

  genvar x;
  generate
    for(x = 0; x < L; x++)begin
      latch L0 (.D(D[x]), .E(E), .O(O[x]));
    end
  endgenerate
  
endmodule

// Array of endpoints
module endpoints #(L) (
  output wire [L-1:0] O
);

  genvar x;
  generate
    for(x = 0; x < L; x++)begin
      endpoint E0 (.O(O[x]));
    end
  endgenerate
  
endmodule
