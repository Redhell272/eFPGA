
// Synchronization Registers Module
module input_logic (
  //Global Clock/Reset
  input wire clk,
  input wire nres,
  //Programming Interface
  input wire  [31:0] prog_i,
  input wire         prog_shft,
  output wire [31:0] prog_o,
  //Module In/Out
  input wire  [31:0] data_in,
  input wire         en,
  output wire [31:0] data_oCB,
  output wire  [7:0] data_oCBV
);
  //  Programming Logic
  //set length of programming by number of 32bit regs:
  parameter l=7;
  
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
  logic [31:0] clk_prog;
  logic  [1:0] REGS_prog[31:0];
  logic [15:0] LUT4_prog[7:0];
  
  assign clk_prog = (prog_shft == 0) ? prog[0] : 'Z;
  genvar x;
  generate
    for(x = 0; x < 16; x++)begin
      assign REGS_prog[x] = (prog_shft == 0) ? prog[1][x*2+1:x*2] : 'Z;
      assign REGS_prog[x+16] = (prog_shft == 0) ? prog[2][x*2+1:x*2] : 'Z;
    end
    for(x = 0; x < 4; x++)begin
      assign LUT4_prog[x*2] = (prog_shft == 0) ? prog[3+x][15:0] : 'Z;
      assign LUT4_prog[x*2+1] = (prog_shft == 0) ? prog[3+x][31:16] : 'Z;
    end
  endgenerate
  
  
  //  Module Logic
  
  // Wires
  
  logic [31:0] data_bffr;
  logic [31:0] data_en;
  logic [31:0] data_regs;
  logic  [7:0] data_LUTs;
  
  logic        clk_line;
  logic        nres_line;
  
  // Assigns
  
  assign data_oCB = data_regs;
  assign data_oCBV = data_LUTs;

  // Instances
  
  generate
    for(x = 0; x < 32; x++)begin
      Vnode v0 (
        .I(data_in[x]),
        .O(data_bffr[x])
      );
      
      Ynode y0 (
        .prog(en),
        .I(data_bffr[x]),
        .O(data_en[x])
      );
      
      REGS R0 (
        .prog({clk_prog[x], REGS_prog[x]}),
        .reg_clk(clk_line), .reg_nres(nres_line),
        .data_in(data_en[x]),
        .data_out(data_regs[x])
      );
    end
    
    for(x = 0; x < 8; x++)begin
      LUT4 L0 (
        .prog(LUT4_prog[x]),
        .data_in(data_regs[x*4+3:x*4]),
        .data_out(data_LUTs[x])
      );
    end
  endgenerate

  // Processes
  
  //------------------------------- Sequential ------------------------------
  
  //----------------------------- Combinational -----------------------------
  
  //Select clk and nres lines for REGS
  always_comb
    begin
      if (prog_shft == 0) begin
        clk_line <= 1'bZ;
        nres_line <= 1'bZ;
        for (int i = 0; i < 31; i++) begin
          if(clk_prog[i] == 1) begin
            clk_line <= data_en[i];
            nres_line <= data_en[i+1];
          end
        end
        if(clk_prog[31] == 1) begin
          clk_line <= data_en[31];
          nres_line <= data_en[0];
        end
        if(clk_prog == '0) begin
          clk_line <= clk;
          nres_line <= nres;
        end
      end else begin
        clk_line <= clk;
        nres_line <= nres;
      end
    end
  
endmodule





// Synchronization Registers Module
module REGS (
  //Programming Input
  input wire [2:0] prog,
  //Register Inputs
  input wire reg_clk,
  input wire reg_nres,
  //Module In/Out
  input wire data_in,
  output wire data_out
);
  
  // Registers
  
  reg [2:0] REGS;
  
  // Wires
  
  logic REGS_out;

  // Assigns
  
  assign data_out = REGS_out;

  // Instances

  // Processes
  
  //------------------------------- Sequential ------------------------------

  //Registers
  always @(posedge reg_clk or negedge reg_nres)
    begin
      if (reg_nres == 0)
        REGS <= 3'b000;
      else begin
        if (prog[2] == 1) begin
          REGS[0] <= !REGS[0];
          REGS[1] <= REGS[0] ? !REGS[1] : REGS[1];
          REGS[2] <= (REGS[0] && REGS[1]) ? !REGS[2] : REGS[2];
        end else begin
          REGS <= {REGS[1:0], data_in};
        end
      end
    end
  
  //----------------------------- Combinational -----------------------------
  
  //Mux Process
  always @(REGS or prog)
    begin
      case (prog[1:0])
        2'b00 : REGS_out <= data_in;
        2'b01 : REGS_out <= REGS[0];
        2'b10 : REGS_out <= REGS[1];
        2'b11 : REGS_out <= REGS[2];
        default : REGS_out <= 1'bZ;
      endcase
    end
  
endmodule





// 4in-LUT Module
module LUT4 (
  //Programming Input
  input wire [15:0] prog,
  //LUT Module In/Out
  input wire [3:0] data_in,
  output wire data_out
);
  
  // Registers
  
  // Wires
  
  logic LUT_out;

  // Assigns
  
  assign data_out = LUT_out;

  // Instances

  // Processes
  
  //------------------------------- Sequential ------------------------------

  //----------------------------- Combinational -----------------------------
  
  //LUT Process
  always @(data_in or prog)
    begin
      case (data_in)
        4'b0000 : LUT_out <= prog[0];
        4'b0001 : LUT_out <= prog[1];
        4'b0010 : LUT_out <= prog[2];
        4'b0011 : LUT_out <= prog[3];
        4'b0100 : LUT_out <= prog[4];
        4'b0101 : LUT_out <= prog[5];
        4'b0110 : LUT_out <= prog[6];
        4'b0111 : LUT_out <= prog[7];
        4'b1000 : LUT_out <= prog[8];
        4'b1001 : LUT_out <= prog[9];
        4'b1010 : LUT_out <= prog[10];
        4'b1011 : LUT_out <= prog[11];
        4'b1100 : LUT_out <= prog[12];
        4'b1101 : LUT_out <= prog[13];
        4'b1110 : LUT_out <= prog[14];
        4'b1111 : LUT_out <= prog[15];
        default  : LUT_out <= 1'bZ;
      endcase
    end
  
endmodule
