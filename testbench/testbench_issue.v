`timescale 1ns/1ps

module testbench;
reg clock;
reg reset;
reg [31:0] instruction;

  tomasulo TM(.clock(clock),.reset(reset),.instruction(instruction));

initial 
clock=0;
always#5 clock = ~clock;

initial
begin
  $dumpfile("dumppu.vcd"); $dumpvars(1,TM);	
  reset = 1;
  #5 reset = 0;
  #9.9 instruction = 32'b00000000001100010000001000110011;
           
end
endmodule