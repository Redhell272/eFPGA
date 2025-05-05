`timescale 1ns/1ps

// eFPGA Wrapper Top Module
module eFPGA (
  //Global Clock/Reset
  input wire clk,
  input wire reset,
  //Board In/Outputs
  input wire prog_btn,
  input wire [15:0] SW,
  output wire [15:0] led
);
  
  // Registers
  reg   [1:0] state;
  reg  [10:0] addr_cnt;
  reg   [9:0] row_cnt;
  reg   [2:0] prog_shft;
  reg   [2:0] prog_shft_d;
  reg   [2:0] data_en_d;

  reg   [1:0] btn_d;
  reg         btn_RE;
  
  // Wires
  logic        clock;
  logic [31:0] dout;
  logic        data_en;
  logic [31:0] data_in;
  logic [63:0] data_out;
  
  // Assigns
  assign data_en = state[1];
  
  assign data_in = {'0, SW, !reset, clock};
  assign led = data_out[63:48];

  // Instances
  
  clk_wiz_0 clock_wizard (.clk_in1(clk), .clk_out1(clock), .reset(reset), .locked());

  rams_init_file #(.addrW(11)) bram (.clk(clk), .we('0), .addr(addr_cnt), .din('0), .dout(dout));

  fpga #(.V(1), .H(1)) eFPGA_unit (.clk(clk), .nres(!reset), .prog_i(dout), .prog_shft(prog_shft_d),
    .data_en(data_en_d[2]), .data_in(data_in), .data_out(data_out));

  // Processes
  
  //------------------------------- Sequential ------------------------------
  
  //prog_shft and en delay line
  always @(posedge clk or posedge reset)
    begin
      if (reset == 1) begin
        prog_shft_d <= '0;
        data_en_d <= 3'b000;
      end else begin
        prog_shft_d <= prog_shft;
        data_en_d <= {data_en_d[1:0], data_en};
      end
    end

  //Button rising edge detector
  always @(posedge clk or posedge reset)
    begin
      if (reset == 1) begin
        btn_d <= 2'b00;
        btn_RE <= 1'b0;
      end else begin
        btn_d <= {btn_d[0], prog_btn};
        if ((btn_d[0] && !btn_d[1]) == 1)
          btn_RE <= 1;
        else
          btn_RE <= 0;
      end
    end

  //Finite state machine
  always @(posedge clk or posedge reset)
    begin
      if (reset == 1) begin
        state <= 2'b00;
      end else begin
        // Idle State
        if (state == 2'b00) begin
          if (btn_RE == 1)
            state <= 2'b01;
          else
            state <= 2'b00;
        
        // Program State
        end else if (state == 2'b01) begin
          if (row_cnt == 225 && prog_shft[2] == 1)
            state <= 2'b10;
          else
            state <= 2'b01;
        
        // FPGA State
        end else if (state == 2'b10) begin
          if (btn_RE == 1)
            state <= 2'b01;
          else
            state <= 2'b10;
          
        // Invalid State
        end else if (state == 2'b11) begin
          state <= 2'b00;
        end
      end
    end
  
  //Counters and program shifter (Datapath)
  always @(posedge clk or posedge reset)
    begin
      if (reset == 1) begin
        addr_cnt <= '0;
        row_cnt <= '0;
        prog_shft <= '0;
      end else begin
        if (state[0] == 1) begin
          if (addr_cnt == 1356)
            addr_cnt <= '0;
          else
            addr_cnt <= addr_cnt + 1;
          if (row_cnt == 225) begin
            row_cnt <= '0;
            prog_shft <= {prog_shft[1:0], 1'b0};
          end else begin
            row_cnt <= row_cnt + 1;
          end

        end else if (state[0] == 0 && btn_RE == 1) begin
          if (addr_cnt == 1356)
            addr_cnt <= 1;
          else
            addr_cnt <= addr_cnt + 1;
          row_cnt <= row_cnt + 1;
          prog_shft <= 3'h1;
        end
      end
    end

  //----------------------------- Combinational -----------------------------
  
endmodule