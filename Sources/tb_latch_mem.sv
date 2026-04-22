`timescale 1ns/1ps

//Test Node
module testbench;
  
  
  reg prog_nres=0;
  reg prog_clk=0;
  reg [7:0] prog_D='0;
  reg prog_en=0;
  reg prog_apply=0;
  reg prog_s_in=1;
  wire prog_s_out;
  wire [15:0] data_out_0;
  wire [15:0] data_out_1;
  wire [15:0] data_out_2;
  wire [15:0] data_out_3;
  wire [15:0] data_out_4;
  wire [15:0] data_out_5;
  wire [15:0] data_out_6;
  wire [15:0] data_out_7;
  wire [15:0] data_out_8;
  wire [15:0] data_out_9;
  wire [15:0] data_out_10;
  wire [15:0] data_out_11;
  wire [15:0] data_out_12;
  wire [15:0] data_out_13;
  wire [15:0] data_out_14;
  wire [15:0] data_out_15;
  
  // Instantiate Unit Under Test
  latch_mem DUT(
    .prog_nres(prog_nres),
    .prog_clk(prog_clk),
    .prog_D(prog_D),
    .prog_en(prog_en),
    .prog_apply(prog_apply),
    .prog_s_in(prog_s_in),
    .prog_s_out(prog_s_out),
    .data_out_0(data_out_0),
    .data_out_1(data_out_1),
    .data_out_2(data_out_2),
    .data_out_3(data_out_3),
    .data_out_4(data_out_4),
    .data_out_5(data_out_5),
    .data_out_6(data_out_6),
    .data_out_7(data_out_7),
    .data_out_8(data_out_8),
    .data_out_9(data_out_9),
    .data_out_10(data_out_10),
    .data_out_11(data_out_11),
    .data_out_12(data_out_12),
    .data_out_13(data_out_13),
    .data_out_14(data_out_14),
    .data_out_15(data_out_15));

  task load_prog;
    input [15:0] D;
    begin
      #10 prog_D=D[7:0]; prog_apply=0; prog_en=1; 
      #10 prog_D=D[15:8];
      #10 prog_apply=1; prog_en=0;  prog_s_in=0;
    end
  endtask 


  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #20 prog_nres=1;

    load_prog(16'hAA55); //0
    load_prog(16'hBB44); //1
    load_prog(16'hCC33); //2
    load_prog(16'hEE22); //3
    load_prog(16'hFF11); //4
    load_prog(16'h0000); //5
    load_prog(16'h1001); //6
    load_prog(16'h2002); //7
    load_prog(16'h4004); //8
    load_prog(16'h8008); //9
    load_prog(16'h0110); //10
    load_prog(16'h0220); //11
    load_prog(16'h0440); //12
    load_prog(16'h0880); //13
    load_prog(16'hF00F); //14
    load_prog(16'hFFFF); //15

    load_prog(16'h000F);
    load_prog(16'h00F0);
    load_prog(16'h0F00);
    load_prog(16'hF000);
    
    #10 prog_apply=0;
  end

  //Clocks
  always
    #5 prog_clk = ~prog_clk;
  
  //Simulation Runtime
  initial
    #640 $finish;
  
endmodule
