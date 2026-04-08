`timescale 1ns/1ps

// test of latch memory array
module latch_mem (
  //Programming Input
  input wire       prog_nres,
  input wire       prog_clk,
  input wire [7:0] prog_D,
  input wire       prog_en,
  input wire       prog_shft,
  input wire       prog_s,
  //in/outs
  output wire [15:0] data_out_0,
  output wire [15:0] data_out_1,
  output wire [15:0] data_out_2,
  output wire [15:0] data_out_3,
  output wire [15:0] data_out_4,
  output wire [15:0] data_out_5,
  output wire [15:0] data_out_6,
  output wire [15:0] data_out_7,
  output wire [15:0] data_out_8,
  output wire [15:0] data_out_9,
  output wire [15:0] data_out_10,
  output wire [15:0] data_out_11,
  output wire [15:0] data_out_12,
  output wire [15:0] data_out_13,
  output wire [15:0] data_out_14,
  output wire [15:0] data_out_15
);
  
  // Registers
  reg  [1:0] prog_D_sel;
  reg [15:0] prog_D_line;
  reg [15:0] prog_en_line;

  // Wires
  wire [15:0] en;
  wire [15:0] data;

  // Assigns
  assign en = prog_en ? prog_en_line : '0;
  assign data = prog_D_line;

  // Instances
  genvar x;
  generate
    for(x = 0; x < 16; x++)begin
      latch L0 (.D(data[x]), .E(en[0]), .O(data_out_0[x]));
      latch L1 (.D(data[x]), .E(en[1]), .O(data_out_1[x]));
      latch L2 (.D(data[x]), .E(en[2]), .O(data_out_2[x]));
      latch L3 (.D(data[x]), .E(en[3]), .O(data_out_3[x]));
      latch L4 (.D(data[x]), .E(en[4]), .O(data_out_4[x]));
      latch L5 (.D(data[x]), .E(en[5]), .O(data_out_5[x]));
      latch L6 (.D(data[x]), .E(en[6]), .O(data_out_6[x]));
      latch L7 (.D(data[x]), .E(en[7]), .O(data_out_7[x]));
      latch L8 (.D(data[x]), .E(en[8]), .O(data_out_8[x]));
      latch L9 (.D(data[x]), .E(en[9]), .O(data_out_9[x]));
      latch L10 (.D(data[x]), .E(en[10]), .O(data_out_10[x]));
      latch L11 (.D(data[x]), .E(en[11]), .O(data_out_11[x]));
      latch L12 (.D(data[x]), .E(en[12]), .O(data_out_12[x]));
      latch L13 (.D(data[x]), .E(en[13]), .O(data_out_13[x]));
      latch L14 (.D(data[x]), .E(en[14]), .O(data_out_14[x]));
      latch L15 (.D(data[x]), .E(en[15]), .O(data_out_15[x]));
    end
  endgenerate

  // Processes  
  //------------------------------- Sequential ------------------------------
  always @(posedge prog_clk or negedge prog_nres)
    begin
      if (prog_nres == 0) begin
        prog_D_sel <= 2'b01;
        prog_D_line <= '0;
        prog_en_line <= '0;
      end else begin
        if (prog_en == 0) begin
          prog_D_sel <= {prog_D_sel[0], prog_D_sel[1]};
          if (prog_D_sel[0] == 1)
            prog_D_line[7:0] <= prog_D;
          if (prog_D_sel[1] == 1)
            prog_D_line[15:8] <= prog_D;
        end 
        if (prog_shft == 1) begin
          prog_en_line <= {prog_en_line[14:0], prog_s};
        end
      end
    end
  
endmodule



//Latch
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