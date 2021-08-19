// Clock Module 
`timescale 1ps/1ps
module clock(output clk);
    reg Clock = 1;
    assign clk = Clock;
    always begin
        #500;
        Clock = !Clock;
    end
endmodule