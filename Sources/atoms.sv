`timescale 1ns/1ps

//Latch module
module latch (
  //in/outs
  input wire D,
  input wire E,
  output wire O
);

  reg i;
  assign O = i;

  always @(E)
    begin
      if (E == 1) 
        i <= D;
    end

endmodule

