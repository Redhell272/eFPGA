`timescale 1ns/1ps

//Test Logic Slice
module tb;


  reg prog_nres=0;
  reg prog_clk=0;
  reg [7:0] prog_D='0;
  reg prog_en='0;
  reg prog_apply=0;
  reg prog_s_in=1;
  wire prog_s_out;
  reg reg_nres=0;
  reg reg_clk=0;
  reg  [29:0] N_i=30'ha5a5a5a5;
  wire [29:0] S_o;
  reg  [17:0] S_i=18'h5a5a5;
  wire [17:0] N_o;
  reg  [23:0] W_i=24'h000000;
  wire  [7:0] E_o;
  
  // Instantiate Units Under Test
  logic_slice UUT(
    .prog_nres(prog_nres),
    .prog_clk(prog_clk),
    .prog_D(prog_D),
    .prog_en(prog_en),
    .prog_apply(prog_apply),
    .prog_s_in(prog_s_in),
    .prog_s_out(prog_s_out),
    .reg_nres(reg_nres),
    .reg_clk(reg_clk),
    .N_i(N_i),
    .S_o(S_o),
    .S_i(S_i),
    .N_o(N_o),
    .W_i(W_i),
    .E_o(E_o)
  );

  task load_prog_LS;
    input [39:0] D;
    begin
      #10 prog_D=D[7:0]; prog_apply=0; prog_en=1;
      #10 prog_D=D[15:8];
      #10 prog_D=D[23:16];
      #10 prog_D=D[31:24];
      #10 prog_D=D[39:32];
      #10 prog_apply=1; prog_en=0;  prog_s_in=0;
    end
  endtask
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #20 prog_nres=1;
    #40 prog_nres=1;
    #20 reg_nres=1;
    
    load_prog_LS({40'h0000000000}); //0
    load_prog_LS({40'h0000000000}); //1
    load_prog_LS({40'h0000000000}); //2
    load_prog_LS({40'h0000000000}); //3
    load_prog_LS({40'h0000000000}); //4
    load_prog_LS({40'h0000000000}); //5
    load_prog_LS({40'h0020100804}); //6
    load_prog_LS({40'h0020100804}); //7
    load_prog_LS({40'h0020100804}); //8
    load_prog_LS({40'h0020100804}); //9
    load_prog_LS({40'h0020100804}); //10
    load_prog_LS({40'h0020100804}); //11
    load_prog_LS({40'h1008040200}); //12
    load_prog_LS({40'h1008040200}); //13
    load_prog_LS({40'h1008040200}); //14
    load_prog_LS({40'h1008040200}); //15
    load_prog_LS({40'h1008040200}); //16
    load_prog_LS({40'h1008040200}); //17
    load_prog_LS({40'h1008040200}); //18
    load_prog_LS({40'h1008040200}); //19
    load_prog_LS({40'h1008040200}); //20
    load_prog_LS({40'h1008040200}); //21
    load_prog_LS({40'h0000000000}); //22
    load_prog_LS({40'h0000000000}); //23
    load_prog_LS({40'h0000000000}); //24
    load_prog_LS({40'h0000000000}); //25
    load_prog_LS({40'h0000000000}); //26
    load_prog_LS({40'h0000000000}); //27
    load_prog_LS({40'h0020100804}); //28
    load_prog_LS({40'h0020100804}); //29
    load_prog_LS({40'h0020100804}); //30
    load_prog_LS({40'h0020100804}); //31
    load_prog_LS({40'h0020100804}); //32
    load_prog_LS({40'h0020100804}); //33
    load_prog_LS({40'h1008040200}); //34
    load_prog_LS({40'h1008040200}); //35
    load_prog_LS({40'h1008040200}); //36
    load_prog_LS({40'h1008040200}); //37
    load_prog_LS({40'h1008040200}); //38
    load_prog_LS({40'h1008040200}); //39
    load_prog_LS({40'h1008040200}); //40
    load_prog_LS({40'h1008040200}); //41
    load_prog_LS({40'h1008040200}); //42
    load_prog_LS({40'h1008040200}); //43
    load_prog_LS({40'h0000000000}); //44
    load_prog_LS({40'h0000000000}); //45
    load_prog_LS({40'h0000000000}); //46
    load_prog_LS({40'h0000000000}); //47
    load_prog_LS({40'h0000000000}); //48
    load_prog_LS({40'h0000000000}); //49
    load_prog_LS({40'h0020100804}); //50
    load_prog_LS({40'h0020100804}); //51
    load_prog_LS({40'h0020100804}); //52
    load_prog_LS({40'h0020100804}); //53
    load_prog_LS({40'h0020100804}); //54
    load_prog_LS({40'h0020100804}); //55
    load_prog_LS({40'h1008040200}); //56
    load_prog_LS({40'h1008040200}); //57
    load_prog_LS({40'h1008040200}); //58
    load_prog_LS({40'h1008040200}); //59
    load_prog_LS({40'h1008040200}); //60
    load_prog_LS({40'h1008040200}); //61
    load_prog_LS({40'h1008040200}); //62
    load_prog_LS({40'h1008040200}); //63
    load_prog_LS({40'h1008040200}); //64
    load_prog_LS({40'h1008040200}); //65
    load_prog_LS({40'h0000000000}); //66
    load_prog_LS({40'h0000000000}); //67
    load_prog_LS({40'h0000000000}); //68
    load_prog_LS({40'h0000000000}); //69

    #10 prog_apply=0;

    #400 N_i=30'h00300C03;
    #400 N_i=30'h00F03C0F;
    #400 N_i=30'h00300C03;
    #400 N_i=30'h00F03C0F;
    #400 N_i=30'h00300C03;
    #400 N_i=30'h00F03C0F;
    #400 N_i=30'h00000000;
    
    
    
  end
  
  //Clocks
  always
    #5 prog_clk = ~prog_clk;   // 100 Mhz clock

  always
    #5 reg_clk = ~reg_clk;   // 100 Mhz clock
  
  //Simulation Runtime
  initial
    #8000 $finish;
  
endmodule
