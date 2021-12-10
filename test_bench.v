`timescale 1ns/1ns

module testbench;
reg clock;
reg reset;

tomasulo TM(.clock(clock),.reset(reset));

initial 
clock=0;
always#5 clock = ~clock;

initial
begin
  $dumpfile("dumppu.vcd"); $dumpvars(0,TM);	
  reset = 1;
  #5 reset = 0;
  #200 $finish;   
end
endmodule