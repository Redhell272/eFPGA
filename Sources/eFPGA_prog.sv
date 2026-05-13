`timescale 1ns/1ps

// eFPGA Module with Programmer
module eFPGA_prog #(V, H, W) (
  //Programming Interface
  input wire              prog_nres,
  input wire              prog_clk,
  input wire              prog_start,
  //Memory Interface
  output wire     [W-1:0] addr,
  input wire       [31:0] dout,
  //Register Inputs
  input wire              reg_nres,
  input wire              reg_clk,
  //Module In/Out
  input wire  [62*V+31:0] N_i,
  output wire [62*V+31:0] S_o,
  input wire  [34*V+15:0] S_i,
  output wire [34*V+15:0] N_o,
  input wire  [40*H+31:0] W_i,
  output wire [56*H+31:0] E_o,
  input wire  [16*H+15:0] E_i,
  output wire [16*H+15:0] W_o
);
  
  // Registers
  reg   [2:0] prog_start_d;
  reg   [1:0] prog_start_RE;

  reg [2*H:0] row_cnt;
  reg [2*V:0] col_cnt;
  reg   [7:0] en_cnt;
  reg   [5:0] data_cnt;

  reg [2*H:0] prog_s_shft;
  reg         prog_s_strobe;

  reg [W-1:0] addr_cnt;
  reg  [31:0] data;
  reg   [1:0] data_sel;
  
  // Wires
  logic   [1:0] state;
  logic   [5:0] data_num;
  logic   [7:0] en_num;

  logic   [7:0] prog_D;
  logic         prog_en;
  logic         prog_apply;
  logic [2*H:0] prog_s;
  
  // Assigns
  assign state = {row_cnt[0], col_cnt[0]};

  assign en_num =   (state == 2'b00) ? 8'h31 :       // CLINE CB State
                    (state == 2'b01) ? 8'h30 :       // CLINE CBH State
                    (state == 2'b10) ? 8'h38 :       // LLINE CBV State
                    (state == 2'b11) ? 8'h46 : '1;   // LLINE LS State

  assign data_num = (state == 2'b00) ? 6'h07 :       // CLINE CB State
                    (state == 2'b01) ? 6'h07 :       // CLINE CBH State
                    (state == 2'b10) ? 6'h04 :       // LLINE CBV State
                    (state == 2'b11) ? 6'h05 : '1;   // LLINE LS State

  assign prog_en = ((data_cnt != data_num) || (en_cnt == en_num - 1)) && en_cnt != en_num;
  assign prog_apply = ((data_cnt == data_num) || (en_cnt == en_num - 1)) && en_cnt != en_num;
  assign prog_s = (prog_s_strobe == 1'b1) ? prog_s_shft : '0;
  assign prog_D = (data_sel == 2'b00) ? data[7:0]   :
                  (data_sel == 2'b01) ? data[15:8]  :
                  (data_sel == 2'b10) ? data[23:16] :
                                        data[31:24] ;

  assign addr = addr_cnt;

  // Instances

  fpga #(.V(V), .H(H)) eFPGA_unit (.prog_nres(prog_nres), .prog_clk(prog_clk),
    .prog_D(prog_D), .prog_en(prog_en), .prog_apply(prog_apply), .prog_s(prog_s),
    .reg_nres(reg_nres), .reg_clk(reg_clk),
    .N_i(N_i), .S_o(S_o), .S_i(S_i), .N_o(N_o),
    .W_i(W_i), .E_o(E_o), .E_i(E_i), .W_o(W_o));

  // Processes
  
  //------------------------------- Sequential ------------------------------

  //Start rising edge detector
  always @(posedge prog_clk or negedge prog_nres)
    begin
      if (prog_nres == 0) begin
        prog_start_d <= 3'b000;
        prog_start_RE <= 2'b00;
      end else begin
        prog_start_d <= {prog_start_d[1:0], prog_start};
        if ((prog_start_d[1] && !prog_start_d[2]) == 1)
          prog_start_RE <= 2'b01;
        else
          prog_start_RE <= {prog_start_RE[0], 1'b0};
      end
    end
  
  //Counters for Sequence
  always @(posedge prog_clk or negedge prog_nres)
    begin
      if (prog_nres == 0) begin
        row_cnt <= 0;
        col_cnt <= 0;
        en_cnt <= 0;
        data_cnt <= 0;
        prog_s_shft <= '0;
        prog_s_strobe <= 0;
      end else begin
        if (row_cnt != 0 || col_cnt != 0 || en_cnt != 0 || data_cnt != 0) begin
          if (data_cnt == data_num) begin
            data_cnt <= 0;
            prog_s_strobe <= 0;
            if (en_cnt == en_num) begin
              en_cnt <= 0;
              if (col_cnt == 2*V) begin
                col_cnt <= 0;
                prog_s_shft <= {prog_s_shft[2*H-1:0], 1'b0};
                prog_s_strobe <= 1;
                if (row_cnt == 2*H) begin
                  row_cnt <= 0;
                end else begin
                  row_cnt <= row_cnt + 1;
                end
              end else begin
                col_cnt <= col_cnt + 1;
              end
            end else begin
              en_cnt <= en_cnt + 1;
            end
          end else if (en_cnt == en_num - 1) begin
            data_cnt <= data_num;
            en_cnt <= en_cnt + 1;
          end else begin
            data_cnt <= data_cnt + 1;
          end
        end else if (prog_start_RE[1] == 1) begin
          data_cnt <= 1;
          prog_s_shft <= {prog_s_shft[2*H-1:0], 1'b1};
          prog_s_strobe <= 1;
        end else begin
          prog_s_strobe <= 1;
        end
      end
    end
  
  //Counters for Data
  always @(posedge prog_clk or negedge prog_nres)
    begin
      if (prog_nres == 0) begin
        addr_cnt <= 0;
        data <= '0;
        data_sel <= 0;
      end else begin
        if (prog_start_RE[0] == 1 && addr_cnt == 0) begin
          data_sel <= 2'b11;
        end else if ((addr_cnt != 0 || data_sel != 2'b00) && (prog_en == 1'b1 && prog_apply == 1'b0)) begin
          data_sel <= data_sel + 1;
          if (data_sel == 2'b11) begin
            addr_cnt <= addr_cnt + 1;
            data <= dout;
          end
        end
      end
    end

  //----------------------------- Combinational -----------------------------
  
endmodule