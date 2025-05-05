`timescale 1ns/1ps
//Test Logic Switch
module testbench;

  reg clk=1;
  reg reset=1;
  reg prog_btn=1'b0;
  reg  [15:0] SW=16'hF971;
  wire [15:0] led;
  
  // Instantiate Units Under Test
  eFPGA UUT (
    .clk(clk),
    .reset(reset),
    .prog_btn(prog_btn),
    .SW(SW),
    .led(led)
  );
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #20 reset=0;
    
    #50 prog_btn=1;
    #30 prog_btn=0;
    #20000;
    
    #10000 SW=16'h7ABC;
    
    #10000 SW=16'h3C3C;
    
    #10000 SW=16'h15a5;
    
    #10000 SW=16'h0108;
    
    #20000;
    #30 prog_btn=1;
    #20 prog_btn=0;
    #50 SW=16'h0000;
    #20000;
    
          SW=16'h8000;
    #5000 SW=16'h0000;
    #10000;
    
         SW=16'h0001;
    #300 SW=16'h8001;
    #300 SW=16'h0002;
    #300 SW=16'h8002;
    #300 SW=16'h0004;
    #300 SW=16'h8004;
    #300 SW=16'h0008;
    #300 SW=16'h8008;
    #300 SW=16'h0010;
    #300 SW=16'h8010;
    #300 SW=16'h0020;
    #300 SW=16'h8020;
    #300 SW=16'h0040;
    #300 SW=16'h8040;
    #300 SW=16'h0080;
    #300 SW=16'h8080;
    #300 SW=16'h0000;
    #10000;
    
          SW=16'h0001;
    #5000 SW=16'h8001;
    #5000 SW=16'h007F;
    #2000;
    
         SW=16'h0001;
    #300 SW=16'h0003;
    #300 SW=16'h0007;
    #300 SW=16'h000f;
    #300 SW=16'h001f;
    #300 SW=16'h003f;
    #300 SW=16'h007f;
    #300 SW=16'h0000;
    #10000;
    
          SW=16'h0009;
    #5000 SW=16'h8009;
    #5000 SW=16'h0006;
    #10000;
    
          SW=16'h007F;
    #5000 SW=16'h807F;
    #5000 SW=16'h0010;
    #10000;
    
    #20000;
    #30 prog_btn=1;
    #20 prog_btn=0;
    #50 SW=16'h0000;
    #20000;
    
  end
  
  //Clocks
  always
    #5 clk = ~clk;   // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #8000000 $finish;
  
endmodule
