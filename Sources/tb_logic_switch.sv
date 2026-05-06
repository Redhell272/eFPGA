`timescale 1ns/1ps

//Test Logic switch
module testbench;

  reg [11:0] D='0;
  reg [17:0] E='0;
  reg[1:0] data_out=2'b00;
  wire[5:0] data_in;
  wire[5:0] up_out;
  reg[9:0] down_in=10'h000;
  reg[5:0] up_in=6'h00;
  wire[9:0] down_out;
  
  // Instantiate Unit Under Test
  logic_switch UUT(
    .D(D),
    .E(E),
    .data_out(data_out),
    .data_in(data_in),
    .up_out(up_out),
    .down_in(down_in),
    .up_in(up_in),
    .down_out(down_out));

  task load_prog;
    input [155:0] prog; //{20'h00000, 10'h000, 60'h000000000000000, 36'h000000000, 6'h00, 12'h000, 12'h000}
    begin
      #10 E = 18'h00000;
      #10 D = {3'h0, prog[5:0] ,3'h0};
      #10 E = 18'h00001;
      #10 E = 18'h00000;
      #10 D = {3'h0, prog[11:6] ,3'h0};
      #10 E = 18'h00002;

      #10 E = 18'h00000;
      #10 D = {3'h0, prog[35:30], prog[24], prog[18], prog[12]};
      #10 E = 18'h00004;
      #10 E = 18'h00000;
      #10 D = {3'h0, prog[41:36], prog[25], prog[19], prog[13]};
      #10 E = 18'h00008;
      #10 E = 18'h00000;
      #10 D = {3'h0, prog[47:42], prog[26], prog[20], prog[14]};
      #10 E = 18'h00010;
      #10 E = 18'h00000;
      #10 D = {3'h0, prog[53:48], prog[27], prog[21], prog[15]};
      #10 E = 18'h00020;
      #10 E = 18'h00000;
      #10 D = {3'h0, prog[59:54], prog[28], prog[22], prog[16]};
      #10 E = 18'h00040;
      #10 E = 18'h00000;
      #10 D = {3'h0, prog[65:60], prog[29], prog[23], prog[17]};
      #10 E = 18'h00080;

      #10 E = 18'h00000;
      #10 D = {prog[146], prog[136], prog[126], prog[71:66], 3'h0};
      #10 E = 18'h00100;
      #10 E = 18'h00000;
      #10 D = {prog[147], prog[137], prog[127], prog[77:72], 3'h0};
      #10 E = 18'h00200;
      #10 E = 18'h00000;
      #10 D = {prog[148], prog[138], prog[128], prog[83:78], 3'h0};
      #10 E = 18'h00400;
      #10 E = 18'h00000;
      #10 D = {prog[149], prog[139], prog[129], prog[89:84], 3'h0};
      #10 E = 18'h00800;
      #10 E = 18'h00000;
      #10 D = {prog[150], prog[140], prog[130], prog[95:90], 3'h0};
      #10 E = 18'h01000;
      #10 E = 18'h00000;
      #10 D = {prog[151], prog[141], prog[131], prog[101:96], 3'h0};
      #10 E = 18'h02000;
      #10 E = 18'h00000;
      #10 D = {prog[152], prog[142], prog[132], prog[107:102], 3'h0};
      #10 E = 18'h04000;
      #10 E = 18'h00000;
      #10 D = {prog[153], prog[143], prog[133], prog[113:108], 3'h0};
      #10 E = 18'h08000;
      #10 E = 18'h00000;
      #10 D = {prog[154], prog[144], prog[134], prog[119:114], 3'h0};
      #10 E = 18'h10000;
      #10 E = 18'h00000;
      #10 D = {prog[155], prog[145], prog[135], prog[125:120], 3'h0};
      #10 E = 18'h20000;


      #10 E = '0;
      #10 D = '0;
    end
  endtask 
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs

    //Test Y nodes
    #400 load_prog({20'h00000, 10'hA5A, 60'h000000000000000, 36'h000000000, 6'h5A, 12'h000, 12'h000});
    #200 up_in=6'h33; down_in=10'hCCC;
    #200 up_in=6'hCC; down_in=10'h333;
    #200 up_in=6'h00; down_in=10'h000;

    //Test data_out nodes
    #400 load_prog({20'h00000, 10'h000, 60'h000000000000000, 36'h000000000, 6'h00, 12'h000, 12'h333});
    #200 data_out=2'b01;
    #200 data_out=2'b10;
    #200 data_out=2'b00;

    //Test data_out nodes
    #400 load_prog({20'h00000, 10'h000, 60'h000000000000000, 36'h000000000, 6'h00, 12'h000, 12'hCCC});
    #200 data_out=2'b01;
    #200 data_out=2'b10;
    #200 data_out=2'b00;

    //Test data_out verticals
    #400 load_prog({20'hCCCCC, 10'h000, 60'h000000000000000, 36'h000000000, 6'h00, 12'h333, 12'h000});
    #200 data_out=2'b01;
    #200 data_out=2'b10;
    #200 data_out=2'b00;

    //Test X nodes matrix
    #400 load_prog({20'h00000, 10'h000, 60'hAAAAAAAAAAAAAAA, 36'h555555555, 6'h00, 12'h000, 12'h000});
    #200 up_in=6'hFF; down_in=10'h000;
    #200 up_in=6'h00; down_in=10'hFFF;
    #200 up_in=6'h00; down_in=10'h000;
    
  end
  
  //Simulation Runtime
  initial
    #8000 $finish;
  
endmodule
