`include "signed-divider.v"

module signed_divider_tb;

reg signed [7:0] Ain, Bin;
reg clk, start;
wire DivWait, writeResultSig;
wire signed [7:0] result;
wire signed [15:0] remainder;

signed_divider dut
(
    Ain,Bin,
    clk,start,
    DivWait,writeResultSig,
    result,
    remainder
);
defparam dut.WIDTH = 8;

initial
begin
    $dumpfile("./build/rtl-sim/vcd/signed-divider.vcd");
    $dumpvars;
end

integer i;
initial
begin
    clk = 0;
    start = 0;
    Ain = 90;
    Bin = 40;
    for (i = 0; i < 200; i = i + 1)
    begin
        if (i == 2)
            start = 1;
        else
            start = 0;
        
        #100;
        clk = !clk;
        #100;
        clk = !clk;
    end
end

endmodule
