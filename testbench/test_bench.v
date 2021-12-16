`timescale 1ns/1ns

module testbench;
reg clock;
reg reset;
//reg [7:0] Data_Memory[0:65536];
//reg [7:0] instruction_memory[0:100];

tomasulo TM(.clock(clock),.reset(reset));

initial 
clock=0;
always#5 clock = ~clock;

initial
begin
  $dumpfile("dumppu.vcd"); $dumpvars(0,TM);
  //$readmemb("memory.mem", Data_Memory);
  reset = 1;
  #5 reset = 0;
  #600 $finish;   
end
endmodule