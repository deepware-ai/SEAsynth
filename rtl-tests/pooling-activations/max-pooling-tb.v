`include "max-pooling.v"

module max_pooling_tb;

reg signed [31:0] activation;
wire signed [7:0] max_pool_out;

max_pooling dut
(
    activation, max_pool_out
);
defparam dut.POOLING_NxN = 2;
defparam dut.WIDTH = 8; 

initial
begin
    $dumpfile("./build/rtl-sim/vcd/max-pooling.vcd");
    $dumpvars;
end

initial
begin
    activation = 12;
    #100;
    activation = 44;
    #100;
    activation = 05;
    #100;
end


endmodule

