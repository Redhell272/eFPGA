`timescale 1ns/1ps
//Test Logic Switch
module testbench;

  reg clk=1;
  reg nres=0;
  reg  [31:0] prog_i=32'h00000000;
  reg   [6:0] prog_shft=7'h00;
  reg         data_en=1'b0;
  reg  [95:0] data_in=96'hF0E0D0C0B0A0908070605040;
  wire[127:0] data_out;

  input wire   [31:0] prog_i,
  input wire    [6:0] prog_shft,
  //Module In/Out
  input wire          data_en,
  input wire  [95:0] data_in,
  output wire [127:0] data_out
  
  // Instantiate Units Under Test
  fpga #(.V(2), .H(3)) UUT (
    .clk(clk), 
    .nres(nres), 
    .prog_i(prog_i), 
    .prog_shft(prog_shft),
    .data_en(data_en), 
    .data_in(data_in), 
    .data_out(data_out)
  );
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #20 nres=1;
    
    #25 prog_shft=7'h01;

        prog_i=32'hF0000000;
    #10 prog_i=32'h0F000000;
    #10 prog_i=32'h00F00000;
    #10 prog_i=32'h000F0000;
    #10 prog_i=32'h0000F000;
    #10 prog_i=32'h00000F00;
    #10 prog_i=32'h000000F0;
    #10 prog_i=32'h0000000F;
    
    #10 prog_shft=7'h00;
    #20 prog_shft=7'h02;

        prog_i=32'hF0000000;
    #10 prog_i=32'h0F000000;
    #10 prog_i=32'h00F00000;
    #10 prog_i=32'h000F0000;
    #10 prog_i=32'h0000F000;
    #10 prog_i=32'h00000F00;
    #10 prog_i=32'h000000F0;
    #10 prog_i=32'h0000000F;
    
    #10 prog_shft=7'h00;
    #20 prog_shft=7'h04;

        prog_i=32'hF0000000;
    #10 prog_i=32'h0F000000;
    #10 prog_i=32'h00F00000;
    #10 prog_i=32'h000F0000;
    #10 prog_i=32'h0000F000;
    #10 prog_i=32'h00000F00;
    #10 prog_i=32'h000000F0;
    #10 prog_i=32'h0000000F;
    
    #10 prog_shft=7'h00;
    #20 prog_shft=7'h08;

        prog_i=32'hF0000000;
    #10 prog_i=32'h0F000000;
    #10 prog_i=32'h00F00000;
    #10 prog_i=32'h000F0000;
    #10 prog_i=32'h0000F000;
    #10 prog_i=32'h00000F00;
    #10 prog_i=32'h000000F0;
    #10 prog_i=32'h0000000F;
    
    #10 prog_shft=7'h00;
    #20 prog_shft=7'h10;

        prog_i=32'hF0000000;
    #10 prog_i=32'h0F000000;
    #10 prog_i=32'h00F00000;
    #10 prog_i=32'h000F0000;
    #10 prog_i=32'h0000F000;
    #10 prog_i=32'h00000F00;
    #10 prog_i=32'h000000F0;
    #10 prog_i=32'h0000000F;
    
    #10 prog_shft=7'h00;
    #20 prog_shft=7'h20;

        prog_i=32'hF0000000;
    #10 prog_i=32'h0F000000;
    #10 prog_i=32'h00F00000;
    #10 prog_i=32'h000F0000;
    #10 prog_i=32'h0000F000;
    #10 prog_i=32'h00000F00;
    #10 prog_i=32'h000000F0;
    #10 prog_i=32'h0000000F;
    
    #10 prog_shft=7'h00;
    #20 prog_shft=7'h40;

        prog_i=32'hF0000000;
    #10 prog_i=32'h0F000000;
    #10 prog_i=32'h00F00000;
    #10 prog_i=32'h000F0000;
    #10 prog_i=32'h0000F000;
    #10 prog_i=32'h00000F00;
    #10 prog_i=32'h000000F0;
    #10 prog_i=32'h0000000F;

    #10 prog_shft=0;
    
    #20 data_en=1;
    
    
    
  end
  
  //Clocks
  always
    #5 clk = ~clk;   // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #1000 $finish;
  
endmodule
