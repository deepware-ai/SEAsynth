`include "max-compare.v"

module max_compare_tb;

reg signed [7:0] compare_a, compare_b;
wire signed [7:0] max_val;

max_compare dut
(
    compare_a, 
    compare_b, 
    max_val
);
defparam dut.WIDTH = 8; 

initial
begin
    $dumpfile("./build/rtl-sim/vcd/max-compare.vcd");
    $dumpvars;
end

integer i;
initial
begin
    compare_a = -12;
    compare_b = 124;
    #100;
end


endmodule

