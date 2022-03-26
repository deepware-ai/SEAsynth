`include "mac.v"

module mac_tb;

reg clk, ce;
reg signed [7:0] a, b;
reg signed [7:0] c;
wire signed [15:0] p;

integer i;

mac dut 
(
    clk, ce, a, b, c, p
);
defparam dut.WIDTH = 8;

initial
begin
    $dumpfile("./build/rtl-sim/vcd/mac.vcd");
    $dumpvars;
end

initial
begin
    clk = 0;
    ce = 1;
    a = 15;
    b = -3;
    c = 3;
    i = 0;
    #100;
    for (i = 0; i < 32; i = i + 1)
    begin
        clk = ~clk;
        #100;
        clk = ~clk;
        #100;
    end
end

endmodule

