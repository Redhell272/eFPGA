`timescale 1ns/1ps

//Test Logic Module
module testbench;

  reg clk=1;
  reg[175:0] prog=176'h00000000000000000000000000000000000000000000;
  wire reg_in;
  wire reg_clk;
  wire reg_nres;
  reg[1:0] data_out=2'b00;
  wire[4:0] data_in;
  wire[5:0] up_out;
  reg[9:0] down_in=10'h000;
  reg[5:0] up_in=6'h00;
  wire[9:0] down_out;
  
  // Instantiate Unit Under Test
  logic_switch UUT(
    .prog(prog),
    .reg_in(reg_in),
    .reg_clk(reg_clk),
    .reg_nres(reg_nres),
    .data_out(data_out),
    .data_in(data_in),
    .up_out(up_out),
    .down_in(down_in),
    .up_in(up_in),
    .down_out(down_out));
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs

    //Test Y nodes
    #20 prog=176'hFFFF0000000000000000000000000000000000000000;
    #10 up_in=6'h33; down_in=10'h0CC;
    #10 up_in=6'h0C; down_in=10'h333;
    #10 up_in=6'h00; down_in=10'h000;

    //Test data_out nodes
    #10 prog=176'hFFFFAAAA969600000000000000000000000000000000;
    #10 data_out=2'b01;
    #10 data_out=2'b10;
    #10 data_out=2'b00;

    //Test data_out nodes
    #10 prog=176'h00005555696900000000000000000000000000000000;
    #10 data_out=2'b01;
    #10 data_out=2'b10;
    #10 data_out=2'b00;

    //Test data_out nodes wo. verticals
    #10 prog=176'hFFFF0000969600000000000000000000000000000000;
    #10 data_out=2'b01;
    #10 data_out=2'b10;
    #10 data_out=2'b00;

    //Test X nodes matrix with data_out 1
    #10 prog=176'hFFFF0000696980804040202010100808040402020101;
    #10 data_out=2'b01;
    #10 data_out=2'b10;
    #10 data_out=2'b00;

    //Test X nodes matrix with data_out 2
    #10 prog=176'hFFFF0000696901018080404020201010080804040202;
    #10 data_out=2'b01;
    #10 data_out=2'b10;
    #10 data_out=2'b00;

    //Test X nodes matrix with data_out 3
    #10 prog=176'hFFFF0000696902020101808040402020101008080404;
    #10 data_out=2'b01;
    #10 data_out=2'b10;
    #10 data_out=2'b00;

    //Test X nodes matrix with verticals
    #10 prog=176'hFFFF0000000080804040202010100808040402020101;
    #10 up_in=6'h55; down_in=10'h555;
    #10 up_in=6'hAA; down_in=10'hAAA;
    #10 up_in=6'h00; down_in=10'h000;
    
  end
  
  //Clocks
  always
    #5 clk = ~clk;   // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #400 $finish;
  
endmodule
