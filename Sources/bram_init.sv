`timescale 1ns/1ps
// Initializing Block RAM from external data file
// Binary data
// File: rams_init_file.v

module rams_init_file #(addrW) (clk, we, addr, din, dout);
input clk;
input we;
input [addrW-1:0] addr;
input [31:0] din;
output [31:0] dout;

reg [31:0] ram [0:(2**addrW)-1];
reg [31:0] dout;

initial begin
$readmemb("rams_init_file.data",ram);
end

always @(posedge clk)
begin
if (we)
ram[addr] <= din;
dout <= ram[addr];
end
endmodule

