
// Matrix of X nodes
module Xnodes #(V, H) (
  //Programming Input
  input wire [(V*H)-1:0] prog,
  //Data Wires
  input wire [V-1:0] V_i,
  output wire [V-1:0] V_o,
  input wire [H-1:0] H_i,
  output wire [H-1:0] H_o
);
  
  // Wires
  
  logic  [V-1:0] X_prog[H-1:0];
  
  logic  [V:0] wiresH[H-1:0];
  logic  [V-1:0] wiresV[H:0];
  
  // Assigns
  
  genvar x;
  generate
    for(x = 0; x < H; x++)begin
      assign X_prog[x] = prog[((V*H)-1)-V*x:(V*H)-V-V*x];
      
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
        //assign wiresV[x+1][y] = wiresV[x][y]; assign wiresH[x][y+1] = wiresH[x][y];
        XnodeNW X0 (.prog(X_prog[x][y]), .N(wiresV[x][y]), .E(wiresH[x][y+1]), .S(wiresV[x+1][y]), .W(wiresH[x][y]));
      end
    end
  endgenerate
  
endmodule


// Array of Y nodes
module Ynodes #(V) (
  //Programming Input
  input wire [V-1:0] prog,
  //Data Wires
  input wire [V-1:0] V_i,
  output wire [V-1:0] V_o
);

  // Instances
  
  genvar x;
  generate
    for(x = 0; x < V; x++)begin
      Ynode Y0 (.prog(prog[x]), .I(V_i[x]), .O(V_o[x]));
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



//X in N/W
module XnodeNW (
  //Programming Input
  input wire prog,
  //in/outs
  input wire N,
  input wire W,
  output wire S,
  output wire E
);

  assign E = prog ? N || W : W;
  assign S = prog ? W || N : N;
  
endmodule

//X in N/E
module XnodeNE (
  //Programming Input
  input wire prog,
  //in/outs
  input wire N,
  input wire E,
  output wire S,
  output wire W
);

  assign W = prog ? N || E : E;
  assign S = prog ? E || N : N;
  
endmodule

//X in S/W
module XnodeSW (
  //Programming Input
  input wire prog,
  //in/outs
  input wire S,
  input wire W,
  output wire N,
  output wire E
);

  assign E = prog ? S || W : W;
  assign N = prog ? W || S : S;
  
endmodule

//X in S/E
module XnodeSE (
  //Programming Input
  input wire prog,
  //in/outs
  input wire S,
  input wire E,
  output wire N,
  output wire W
);

  assign W = prog ? S || E : E;
  assign N = prog ? E || S : S;
  
endmodule

//Y
module Ynode (
  //Programming Input
  input wire prog,
  //in/outs
  input wire I,
  output wire O
);

  assign O = prog ? I : 1'b0;
  
endmodule

//V
module Vnode (
  //in/outs
  input wire I,
  output wire O
);

  assign O = I;
  
endmodule