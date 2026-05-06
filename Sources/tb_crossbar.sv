`timescale 1ns/1ps

//Test Logic Switch
module testbench;

  reg prog_nres=0;
  reg prog_clk=0;
  reg [7:0] prog_D='0;
  reg prog_en='0;
  reg prog_apply=0;
  reg prog_s_in=1;
  wire [2:0] prog_s_out;
  reg  [31:0] N_i=32'h87654321;
  reg  [29:0] N_i_H=30'h87654321;
  wire [31:0] S_o;
  wire [31:0] S_o_V;
  wire [29:0] S_o_H;
  reg  [15:0] S_i=16'ha5a5;
  reg  [17:0] S_i_H=18'h5a5a5;
  wire [15:0] N_o;
  wire [15:0] N_o_V;
  wire [17:0] N_o_H;
  reg  [31:0] W_i=32'h0fedcba9;
  reg   [7:0] W_i_L=8'ha5;
  wire [31:0] E_o;
  wire [31:0] E_o_H;
  wire [23:0] E_o_L;
  reg  [15:0] E_i=16'h5a5a;
  wire [15:0] W_o;
  wire [15:0] W_o_H;
  
  // Instantiate Units Under Test
  crossbar CBUT(
    .prog_nres(prog_nres),
    .prog_clk(prog_clk),
    .prog_D(prog_D),
    .prog_en(prog_en),
    .prog_apply(prog_apply),
    .prog_s_in(prog_s_in),
    .prog_s_out(prog_s_out[0]),
    .N_i(N_i),
    .S_o(S_o),
    .S_i(S_i),
    .N_o(N_o),
    .W_i(W_i),
    .E_o(E_o),
    .E_i(E_i),
    .W_o(W_o)
  );

  V_crossbar CBVUT(
    .prog_nres(prog_nres),
    .prog_clk(prog_clk),
    .prog_D(prog_D),
    .prog_en(prog_en),
    .prog_apply(prog_apply),
    .prog_s_in(prog_s_out[0]),
    .prog_s_out(prog_s_out[1]),
    .N_i(N_i),
    .S_o(S_o_V),
    .S_i(S_i),
    .N_o(N_o_V),
    .W_i(W_i_L),
    .E_o(E_o_L)
  );

  H_crossbar CBHUT(
    .prog_nres(prog_nres),
    .prog_clk(prog_clk),
    .prog_D(prog_D),
    .prog_en(prog_en),
    .prog_apply(prog_apply),
    .prog_s_in(prog_s_out[1]),
    .prog_s_out(prog_s_out[2]),
    .N_i(N_i_H),
    .S_o(S_o_H),
    .S_i(S_i_H),
    .N_o(N_o_H),
    .W_i(W_i),
    .E_o(E_o_H),
    .E_i(E_i),
    .W_o(W_o_H)
  );

  task load_prog_CB;
    input [55:0] D;
    begin
      #10 prog_D=D[7:0]; prog_apply=0; prog_en=1;
      #10 prog_D=D[15:8];
      #10 prog_D=D[23:16];
      #10 prog_D=D[31:24];
      #10 prog_D=D[39:32];
      #10 prog_D=D[47:40];
      #10 prog_D=D[55:48];
      #10 prog_apply=1; prog_en=0;  prog_s_in=0;
    end
  endtask

  task load_prog_CBV;
    input [31:0] D;
    begin
      #10 prog_D=D[7:0]; prog_apply=0; prog_en=1;
      #10 prog_D=D[15:8];
      #10 prog_D=D[23:16];
      #10 prog_D=D[31:24];
      #10 prog_apply=1; prog_en=0;
    end
  endtask

  task load_prog_CBH;
    input [55:0] D;
    begin
      #10 prog_D=D[7:0]; prog_apply=0; prog_en=1;
      #10 prog_D=D[15:8];
      #10 prog_D=D[23:16];
      #10 prog_D=D[31:24];
      #10 prog_D=D[39:32];
      #10 prog_D=D[47:40];
      #10 prog_D=D[55:48];
      #10 prog_apply=1; prog_en=0;
    end
  endtask
  
  
  
  initial begin
    // Dump variables for editing
    $dumpfile("dump.vcd");
    $dumpvars();
    
    //Testbench Inputs
    #20 prog_nres=1;
    #40 prog_nres=1;
    
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000001}); //0
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000002}); //1
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000004}); //2
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000008}); //3
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000010}); //4
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000020}); //5
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000040}); //6
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000080}); //7
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000100}); //8
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000200}); //9
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000400}); //10
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00000800}); //11
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00001000}); //12
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00002000}); //13
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00004000}); //14
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00008000}); //15
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00010000}); //16
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00020000}); //17
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00040000}); //18
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00080000}); //19
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00100000}); //20
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00200000}); //21
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00400000}); //22
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h00800000}); //23
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h01000000}); //24
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h02000000}); //25
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h04000000}); //26
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h08000000}); //27
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h10000000}); //28
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h20000000}); //29
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h40000000}); //30
    load_prog_CB({7'h0, 16'h0000,1'h0,32'h80000000}); //31
    load_prog_CB({7'h0, 16'h0000,1'h1,32'h00000000}); //32
    load_prog_CB({7'h0, 16'h0001,1'h0,32'h00000000}); //33
    load_prog_CB({7'h0, 16'h0002,1'h0,32'h00000000}); //34
    load_prog_CB({7'h0, 16'h0004,1'h0,32'h00000000}); //35
    load_prog_CB({7'h0, 16'h0008,1'h0,32'h00000000}); //36
    load_prog_CB({7'h0, 16'h0010,1'h0,32'h00000000}); //37
    load_prog_CB({7'h0, 16'h0020,1'h0,32'h00000000}); //38
    load_prog_CB({7'h0, 16'h0040,1'h0,32'h00000000}); //39
    load_prog_CB({7'h0, 16'h0080,1'h0,32'h00000000}); //40
    load_prog_CB({7'h0, 16'h0100,1'h0,32'h00000000}); //41
    load_prog_CB({7'h0, 16'h0200,1'h0,32'h00000000}); //42
    load_prog_CB({7'h0, 16'h0400,1'h0,32'h00000000}); //43
    load_prog_CB({7'h0, 16'h0800,1'h0,32'h00000000}); //44
    load_prog_CB({7'h0, 16'h1000,1'h0,32'h00000000}); //45
    load_prog_CB({7'h0, 16'h2000,1'h0,32'h00000000}); //46
    load_prog_CB({7'h0, 16'h4000,1'h0,32'h00000000}); //47
    load_prog_CB({7'h0, 16'h8000,1'h0,32'h00000000}); //48

    #10 prog_apply=1; prog_en=1;
    #10 prog_apply=0; prog_en=0;


    load_prog_CBV({8'h01,8'h01,8'h01,8'h01}); //0
    load_prog_CBV({8'h02,8'h02,8'h02,8'h02}); //1
    load_prog_CBV({8'h04,8'h04,8'h04,8'h04}); //2
    load_prog_CBV({8'h08,8'h08,8'h08,8'h08}); //3
    load_prog_CBV({8'h10,8'h10,8'h10,8'h10}); //4
    load_prog_CBV({8'h20,8'h20,8'h20,8'h20}); //5
    load_prog_CBV({8'h40,8'h40,8'h40,8'h40}); //6
    load_prog_CBV({8'h80,8'h80,8'h80,8'h80}); //7

    load_prog_CBV({8'hC0,8'h00,8'h00,8'h00}); //8
    load_prog_CBV({8'h30,8'h00,8'h00,8'h00}); //9
    load_prog_CBV({8'h0C,8'h00,8'h00,8'h00}); //10
    load_prog_CBV({8'h03,8'h00,8'h00,8'h00}); //11
    load_prog_CBV({8'h00,8'hC0,8'h00,8'h00}); //12
    load_prog_CBV({8'h00,8'h30,8'h00,8'h00}); //13
    load_prog_CBV({8'h00,8'h0C,8'h00,8'h00}); //14
    load_prog_CBV({8'h00,8'h03,8'h00,8'h00}); //15
    load_prog_CBV({8'h00,8'h00,8'hC0,8'h00}); //16
    load_prog_CBV({8'h00,8'h00,8'h30,8'h00}); //17
    load_prog_CBV({8'h00,8'h00,8'h0C,8'h00}); //18
    load_prog_CBV({8'h00,8'h00,8'h03,8'h00}); //19
    load_prog_CBV({8'h00,8'h00,8'h00,8'hC0}); //20
    load_prog_CBV({8'h00,8'h00,8'h00,8'h30}); //21
    load_prog_CBV({8'h00,8'h00,8'h00,8'h0C}); //22
    load_prog_CBV({8'h00,8'h00,8'h00,8'h03}); //23

    load_prog_CBV({8'h00,8'h00,8'h00,8'h01}); //24
    load_prog_CBV({8'h00,8'h00,8'h00,8'h02}); //25
    load_prog_CBV({8'h00,8'h00,8'h00,8'h04}); //26
    load_prog_CBV({8'h00,8'h00,8'h00,8'h08}); //27
    load_prog_CBV({8'h00,8'h00,8'h00,8'h10}); //28
    load_prog_CBV({8'h00,8'h00,8'h00,8'h20}); //29
    load_prog_CBV({8'h00,8'h00,8'h00,8'h40}); //30
    load_prog_CBV({8'h00,8'h00,8'h00,8'h80}); //31
    load_prog_CBV({8'h00,8'h00,8'h01,8'h00}); //32
    load_prog_CBV({8'h00,8'h00,8'h02,8'h00}); //33
    load_prog_CBV({8'h00,8'h00,8'h04,8'h00}); //34
    load_prog_CBV({8'h00,8'h00,8'h08,8'h00}); //35
    load_prog_CBV({8'h00,8'h00,8'h10,8'h00}); //36
    load_prog_CBV({8'h00,8'h00,8'h20,8'h00}); //37
    load_prog_CBV({8'h00,8'h00,8'h40,8'h00}); //38
    load_prog_CBV({8'h00,8'h00,8'h80,8'h00}); //39
    load_prog_CBV({8'h00,8'h01,8'h00,8'h00}); //40
    load_prog_CBV({8'h00,8'h02,8'h00,8'h00}); //41
    load_prog_CBV({8'h00,8'h04,8'h00,8'h00}); //42
    load_prog_CBV({8'h00,8'h08,8'h00,8'h00}); //43
    load_prog_CBV({8'h00,8'h10,8'h00,8'h00}); //44
    load_prog_CBV({8'h00,8'h20,8'h00,8'h00}); //45
    load_prog_CBV({8'h00,8'h40,8'h00,8'h00}); //46
    load_prog_CBV({8'h00,8'h80,8'h00,8'h00}); //47
    load_prog_CBV({8'h01,8'h00,8'h00,8'h00}); //48
    load_prog_CBV({8'h02,8'h00,8'h00,8'h00}); //49
    load_prog_CBV({8'h04,8'h00,8'h00,8'h00}); //50
    load_prog_CBV({8'h08,8'h00,8'h00,8'h00}); //51
    load_prog_CBV({8'h10,8'h00,8'h00,8'h00}); //52
    load_prog_CBV({8'h20,8'h00,8'h00,8'h00}); //53
    load_prog_CBV({8'h40,8'h00,8'h00,8'h00}); //54
    load_prog_CBV({8'h80,8'h00,8'h00,8'h00}); //55

    #10 prog_apply=1; prog_en=1;
    #10 prog_apply=0; prog_en=0;
    

    load_prog_CBH({7'h00,16'h0001,1'b0,32'h00000000}); //0
    load_prog_CBH({7'h00,16'h0002,1'b1,32'h00000000}); //1
    load_prog_CBH({7'h00,16'h0004,1'b0,32'h00000000}); //2
    load_prog_CBH({7'h00,16'h0008,1'b1,32'h00000000}); //3
    load_prog_CBH({7'h00,16'h0010,1'b0,32'h00000000}); //4
    load_prog_CBH({7'h00,16'h0020,1'b1,32'h00000000}); //5
    load_prog_CBH({7'h00,16'h0040,1'b0,32'h00000000}); //6
    load_prog_CBH({7'h00,16'h0080,1'b1,32'h00000000}); //7
    load_prog_CBH({7'h00,16'h0100,1'b0,32'h00000000}); //8
    load_prog_CBH({7'h01,16'h0200,1'b1,32'h00000000}); //9
    load_prog_CBH({7'h02,16'h0400,1'b0,32'h00000000}); //10
    load_prog_CBH({7'h04,16'h0800,1'b1,32'h00000000}); //11
    load_prog_CBH({7'h08,16'h1000,1'b0,32'h00000000}); //12
    load_prog_CBH({7'h10,16'h2000,1'b1,32'h00000000}); //13
    load_prog_CBH({7'h20,16'h4000,1'b0,32'h00000000}); //14
    load_prog_CBH({7'h40,16'h8000,1'b1,32'h00000000}); //15

    load_prog_CBH({7'h00,16'h0000,1'b0,32'h00000008}); //16
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h00000004}); //17
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h00000002}); //18
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h00000001}); //19
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h00000080}); //20
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h00000040}); //21
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h00000020}); //22
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h00000010}); //23
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h00000800}); //24
    load_prog_CBH({7'h01,16'h0000,1'b1,32'h00000400}); //25
    load_prog_CBH({7'h02,16'h0000,1'b0,32'h00000200}); //26
    load_prog_CBH({7'h04,16'h0000,1'b1,32'h00000100}); //27
    load_prog_CBH({7'h08,16'h0000,1'b0,32'h00008000}); //28
    load_prog_CBH({7'h10,16'h0000,1'b1,32'h00004000}); //29
    load_prog_CBH({7'h20,16'h0000,1'b0,32'h00002000}); //30
    load_prog_CBH({7'h40,16'h0000,1'b1,32'h00001000}); //31

    load_prog_CBH({7'h00,16'h0000,1'b0,32'h00080000}); //32
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h00040000}); //33
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h00020000}); //34
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h00010000}); //35
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h00800000}); //36
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h00400000}); //37
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h00200000}); //38
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h00100000}); //39
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h08000000}); //40
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h04000000}); //41
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h02000000}); //42
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h01000000}); //43
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h80000000}); //44
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h40000000}); //45
    load_prog_CBH({7'h00,16'h0000,1'b0,32'h20000000}); //46
    load_prog_CBH({7'h00,16'h0000,1'b1,32'h10000000}); //47

    #10 prog_apply=1; prog_en=1;
    #10 prog_apply=0; prog_en=0;
  end
  
  //Clocks
  always
    #5 prog_clk = ~prog_clk;
  
  //Simulation Runtime
  initial
    #12000 $finish;
  
endmodule
