`timescale 1ns/1ps

// test of latch memory array
module latch_mem (
  //Programming Interface
  input wire       prog_nres,
  input wire       prog_clk,
  input wire [7:0] prog_D,
  input wire       prog_en,
  input wire       prog_apply,
  input wire       prog_s_in,
  output wire      prog_s_out,
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

  // Wires
  wire [15:0] en;
  wire [15:0] data;

  // Assigns

  // Instances
  prog #(.D(2), .E(16)) Prog0 (
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
  
endmodule



//configurable programming interface
module prog #(D, E) (
  //Programming Input
  input wire       prog_nres,
  input wire       prog_clk,
  input wire [7:0] prog_D,
  input wire       prog_en,
  input wire       prog_apply,
  input wire       prog_s_in,
  output wire      prog_s_out,
  //Programming Output
  output wire [E-1:0] en,
  output wire [(D*8)-1:0] data
);
  
  // Registers
  reg [D-1:0] prog_D_sel;
  reg [(D*8)-1:0] prog_D_line;
  reg [(D*8)-1:0] prog_D_line_in;
  reg [E-1:0] prog_en_line;
  reg prog_shft;
  reg [1:0] prog_reset;

  // Assigns
  assign prog_s_out = prog_en_line[E-1];

  assign en = (prog_apply || prog_reset != 2'b00) ? prog_en_line : '0;
  assign data = prog_D_line;
  
  genvar x;
  generate
    for(x = 0; x < D; x++)begin
      assign prog_D_line_in[((x+1)*8)-1:(x*8)] = (prog_en & prog_D_sel[x]) ? prog_D : prog_D_line[((x+1)*8)-1:(x*8)];
    end
  endgenerate

  // Processes  
  //------------------------------- Sequential ------------------------------
  always @(posedge prog_clk or negedge prog_nres)
    begin
      if (prog_nres == 0) begin
        prog_D_sel[0] <= 1'b1;
        prog_D_sel[D-1:1] <= '0;
        prog_D_line <= '0;
        prog_en_line <= '0;
        prog_shft <= 1'b1;
        prog_reset <= 2'b01;
      end else begin

        if (prog_reset != 2'b00) begin
          prog_reset <= {prog_reset[0], 1'b0};
          if (prog_reset[0] == 1) begin
            prog_en_line <= '1;
          end else if (prog_reset[1] == 1) begin
            prog_en_line <= '0;
          end

        end else if (prog_en == 1) begin
          prog_shft <= 1'b0;
          prog_D_sel[0] <= prog_D_sel[D-1];
          prog_D_sel[D-1:1] <= prog_D_sel[D-2:0];
          prog_D_line <= prog_D_line_in;
          if (prog_shft == 1) begin
            prog_en_line <= {prog_en_line[E-2:0], prog_s_in};
          end

        end else begin
          prog_shft <= 1'b1;
          if (prog_shft == 1 && prog_en_line[E-1] == 1) begin
            prog_en_line <= '0;
          end
          
        end
      end
    end
  
endmodule
