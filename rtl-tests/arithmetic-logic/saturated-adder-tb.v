`include "saturated-adder.v"

module saturated_adder_tb;

reg signed [7:0] a, b;
wire signed [7:0] c;

saturated_adder dut
(
    a, b, c
);
defparam dut.WIDTH = 8;

initial
begin
    $dumpfile("./build/rtl-sim/vcd/saturated_adder.vcd");
    $dumpvars;
end

integer i;
initial
begin
    a = 120;
    b = -12;
    #100;
end

endmodule