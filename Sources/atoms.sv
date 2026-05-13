`timescale 1ns/1ps

//Register
module register (
  input wire clk,
  input wire nres,
  input wire nres_prog,
  input wire D,
  output wire O
);
  reg Reg;
  assign O = Reg;

  always @(posedge clk or negedge nres)
    begin
      if (nres == 0)
        Reg <= nres_prog;
      else
        Reg <= D;
    end
  
endmodule



//Latch
module latch (
  input wire D,
  input wire E,
  output wire O
);

  reg i;
  assign O = i;

  always @(E, D)
    begin
      if (E == 1) 
        i <= D;
    end

endmodule



//Mux
module mux (
  input wire S,
  input wire I0,
  input wire I1,
  output wire O
);

  assign O = S ? I1 : I0;
  
endmodule



//Passgate
module pass (
  input wire prog,
  input wire I1,
  input wire I2,
  output wire O1,
  output wire O2
);

  logic val;
  assign val = I1 || I2;

  assign O1 = prog ? val : I1;
  assign O2 = prog ? val : I2;
  
endmodule



//Connector
module conn (
  input wire prog,
  input wire I,
  output wire O
);

  logic e;
  endpoint E0 (.O(e));

  assign O = prog ? I : e;
  
endmodule



//Buffer
module buffer (
  input wire I,
  output wire O
);

  assign O = I;
  
endmodule



//Endpoint
module endpoint (
  output wire O
);

  assign O = 1'b0;
  
endmodule
