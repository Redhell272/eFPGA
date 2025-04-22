
// Logic Slice Module of 16x Logic Modules and 12x Logic Switches
module logic_slice (
  //Global Clock/Reset
  input wire 	 	     clk,
  input wire      	 nres,
  //Programming Interface
  input wire  [31:0] prog_i,
  input wire		     prog_shft,
  output wire [31:0] prog_o,
  //Module In/Out
  input wire  [29:0] N_i,
  output wire [29:0] S_o,
  input wire  [17:0] S_i,
  output wire [17:0] N_o,
  input wire  [31:0] W_i,
  output wire  [7:0] E_o
);
  //  Programming Logic
  //set length of programming by number of 32bit regs:
  parameter l=83;
  
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
  logic  [511:0] LUT_prog;
  logic   [31:0] REG_prog;
  logic [1919:0] X_prog;
  logic  [191:0] Y_prog;
  logic   [33:0] LM_prog[15:0];
  logic  [175:0] LS_prog[11:0];
  
  assign REG_prog = (prog_shft == 0) ? prog[16] : 'Z;
  assign Y_prog = (prog_shft == 0) ? {prog[82], prog[81], prog[80], prog[79], prog[78], prog[77]} : 'Z;
  genvar x;
  generate
    for(x = 0; x < 16; x++)begin
      assign LUT_prog[x*32+31:x*32] = (prog_shft == 0) ? prog[x] : 'Z;
    end
    for(x = 0; x < 60; x++)begin
      assign X_prog[32*x+31:32*x] = (prog_shft == 0) ? prog[x+17] : 'Z;
    end
    for(x = 0; x < 16; x++)begin
      assign LM_prog[x] = (prog_shft == 0) ? {REG_prog[x*2+1:x*2], LUT_prog[x*32+31:x*32]} : 'Z;
    end
    for(x = 0; x < 12; x++)begin
      assign LS_prog[x] = (prog_shft == 0) ? {Y_prog[x*16+15:x*16], X_prog[x*160+159:x*160]} : 'Z;
    end
  endgenerate
  
  
  //  Module Logic
  
  // Wires
  
  logic [7:0] Lo[3:0];
  logic [31:0] Li[3:0];
  logic [17:0] wires_U[5:0];
  logic [29:0] wires_D[5:0];

  // Instances
  
  generate
    for(x = 0; x < 4; x++)begin
      logic_module LM0 (.prog(LM_prog[x*4]),   .data_out(Lo[0][x*2+1:x*2]),
                                               .data_in(Li[0][x*8+4:x*8]), .reg_in(Li[0][x*8+5]), .reg_clk(Li[0][x*8+6]), .reg_nres(Li[0][x*8+7]));
      logic_switch LS0 (.prog(LS_prog[x*3]),   .data_in(Li[0][x*8+4:x*8]), .reg_in(Li[0][x*8+5]), .reg_clk(Li[0][x*8+6]), .reg_nres(Li[0][x*8+7]),
                                               .data_out(Lo[1][x*2+1:x*2]), .up_out(wires_U[x][5:0]), .down_in(wires_D[x][9:0]), .up_in(wires_U[x+1][5:0]), .down_out(wires_D[x+1][9:0]));
      logic_module LM1 (.prog(LM_prog[x*4+1]), .data_out(Lo[1][x*2+1:x*2]),
                                               .data_in(Li[1][x*8+4:x*8]), .reg_in(Li[1][x*8+5]), .reg_clk(Li[1][x*8+6]), .reg_nres(Li[1][x*8+7]));
      logic_switch LS1 (.prog(LS_prog[x*3+1]), .data_in(Li[1][x*8+4:x*8]), .reg_in(Li[1][x*8+5]), .reg_clk(Li[1][x*8+6]), .reg_nres(Li[1][x*8+7]),
                                               .data_out(Lo[2][x*2+1:x*2]), .up_out(wires_U[x][11:6]), .down_in(wires_D[x][19:10]), .up_in(wires_U[x+1][11:6]), .down_out(wires_D[x+1][19:10]));
      logic_module LM2 (.prog(LM_prog[x*4+2]), .data_out(Lo[2][x*2+1:x*2]),
                                               .data_in(Li[2][x*8+4:x*8]), .reg_in(Li[2][x*8+5]), .reg_clk(Li[2][x*8+6]), .reg_nres(Li[2][x*8+7]));
      logic_switch LS2 (.prog(LS_prog[x*3+2]), .data_in(Li[2][x*8+4:x*8]), .reg_in(Li[2][x*8+5]), .reg_clk(Li[2][x*8+6]), .reg_nres(Li[2][x*8+7]),
                                               .data_out(Lo[3][x*2+1:x*2]), .up_out(wires_U[x][17:12]), .down_in(wires_D[x][29:20]), .up_in(wires_U[x+1][17:12]), .down_out(wires_D[x+1][29:20]));
      logic_module LM3 (.prog(LM_prog[x*4+3]), .data_out(Lo[3][x*2+1:x*2]),
                                               .data_in(Li[3][x*8+4:x*8]), .reg_in(Li[3][x*8+5]), .reg_clk(Li[3][x*8+6]), .reg_nres(Li[3][x*8+7]));
    end
  endgenerate

  // In/Out Connections
  assign Li[3] = W_i;
  assign E_o = Lo[0];
  assign wires_U[5] = S_i;
  assign N_o = wires_U[0];
  assign wires_D[0] = N_i;
  assign S_o = wires_D[5];

endmodule





// 5in-LUT Module with a register
module logic_module (
  //Programming Input
  input wire [33:0] prog,
  //Register Inputs
  input wire reg_in,
  input wire reg_clk,
  input wire reg_nres,
  //LUT Module In/Out
  input wire [4:0] data_in,
  output wire [1:0] data_out
);
  
  // Registers
  
  reg Reg;
  
  // Wires
  
  logic [31:0] LUT_prog;
  logic reg_prog;
  logic rst_prog;
  
  logic LUT_out;

  // Assigns
  
  assign LUT_prog = prog[31:0];
  assign reg_prog = prog[32];
  assign rst_prog = prog[33];
  
  assign data_out = {LUT_out, Reg};

  // Instances

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
  input wire [175:0] prog,
  //Register Inputs
  output wire reg_in,
  output wire reg_clk,
  output wire reg_nres,
  //Logic Module In/Out
  input wire [1:0] data_out,
  output wire [4:0] data_in,
  //Interconnect Wires
  output wire [5:0] up_out,
  input wire [9:0] down_in,
  input wire [5:0] up_in,
  output wire [9:0] down_out
);
  
  // Registers
  
  // Wires
  
  logic  [5:0] y_prog_up;
  logic  [9:0] y_prog_down;
  logic  [1:0] out_prog_up[1:0];
  logic  [5:0] out_prog_down[1:0];
  logic  [1:0] out_prog_right[7:0];
  logic  [5:0] in_prog_up[7:0];
  logic  [9:0] in_prog_down[7:0];
  
  logic  [5:0] y_up;
  logic  [9:0] y_down;
  logic  [7:0] out_thr[1:0];
  logic  [7:0] out_H[2:0];
  
  logic  [18:0] wiresH[7:0];
  logic  [15:0] wiresV[8:0];
  
  // Assigns
  
  assign y_prog_up = prog[175:170];
  assign y_prog_down = prog[169:160];
  genvar x;
  generate
    for(x = 0; x < 2; x++)begin
      assign out_prog_up[x] = prog[159-2*x:158-2*x];
      assign out_prog_down[x] = prog[155-6*x:150-6*x];
    end
    for(x = 0; x < 8; x++)begin
      
      assign out_prog_right[x] = prog[143-2*x:142-2*x];
      assign in_prog_up[x] = prog[127-16*x:122-16*x];
      assign in_prog_down[x] = prog[121-16*x:112-16*x];
    end
  endgenerate
  
  //Connect wires with different labels and in/outputs
  assign wiresV[0][9:0] = down_in;
  assign up_out = wiresV[0][15:10];
  assign wiresV[8][15:10] = {y_up[5:2], out_H[0][7:6]};
  assign out_H[0][5:0] = wiresV[8][9:4];

  assign out_H[2][7:6] = y_up[1:0];
  assign y_down[9:4] = out_H[2][5:0];
  assign y_down[3:0] = wiresV[8][3:0];
  
  assign data_in = {wiresH[4][0], wiresH[3][0], wiresH[2][0], wiresH[1][0], wiresH[0][0]};
  assign reg_in = wiresH[5][0];
  assign reg_clk = wiresH[6][0];
  assign reg_nres = wiresH[7][0];

  assign wiresH[0][18] = 1'b0;
  assign wiresH[1][18] = 1'b0;
  assign wiresH[2][18] = 1'b0;
  assign wiresH[3][18] = 1'b0;
  assign wiresH[4][18] = 1'b0;
  assign wiresH[5][18] = 1'b0;
  assign wiresH[6][18] = 1'b0;
  assign wiresH[7][18] = 1'b0;

  // Instances
  
  genvar y;
  generate
    //Y Up
    for(x = 0; x < 6; x++)begin
      Ynode Yu0 (.prog(y_prog_up[x]), .I(up_in[x]), .O(y_up[x]));
    end
    //Y down
    for(x = 0; x < 10; x++)begin
      Ynode Yd0 (.prog(y_prog_down[x]), .I(y_down[x]), .O(down_out[x]));
    end
    for(x = 0; x < 2; x++)begin
      //Out Short
      XnodeSW XoU0 (.prog(out_prog_up[x][0]), .N(out_H[x][7]), .E(out_thr[x][0]), .S(out_H[x+1][7]), .W(data_out[x]));
      XnodeSW XoU1 (.prog(out_prog_up[x][1]), .N(out_H[x][6]), .E(out_thr[x][1]), .S(out_H[x+1][6]), .W(out_thr[x][0]));
      for(y = 0; y < 6; y++)begin
        XnodeNW XoD0 (.prog(out_prog_down[x][y]), .N(out_H[x][5-y]), .E(out_thr[x][y+2]), .S(out_H[x+1][5-y]), .W(out_thr[x][y+1]));
      end
      //Out Direct
      for(y = 0; y < 8; y++)begin
        XnodeSW XoR0 (.prog(out_prog_right[y][x]), .N(), .E(wiresH[y][x+16]), .S(data_out[x]), .W(wiresH[y][x+17]));
      end
    end
    for(x = 0; x < 8; x++)begin
      //In Down
      for(y = 0; y < 10; y++)begin
        XnodeNW XiD0 (.prog(in_prog_down[x][y]), .N(wiresV[x][y]), .E(wiresH[x][y]), .S(wiresV[x+1][y]), .W(wiresH[x][y+1]));
      end
      //In Up
      for(y = 0; y < 6; y++)begin
        XnodeSW XiU0 (.prog(in_prog_up[x][y]), .N(wiresV[x][y+10]), .E(wiresH[x][y+10]), .S(wiresV[x+1][y+10]), .W(wiresH[x][y+11]));
      end
    end
  endgenerate

  // Processes
  
  //------------------------------- Sequential ------------------------------

  //----------------------------- Combinational -----------------------------
  
endmodule