`include "relu.v"

module relu_tb;

reg signed [7:0] relu_in;
wire signed [7:0] relu_out;

relu dut
(
    relu_in,
    relu_out
);

initial
begin
    $dumpfile("./build/rtl-sim/vcd/relu.vcd");
    $dumpvars;
end

integer i;
initial
begin
    relu_in = 0;
    for (i = 0; i < 32; i = i + 1)
    begin
        if (i == 2)
            relu_in = 25;
        if (i == 3)
            relu_in = 100;
        if (i == 4)
            relu_in = -85;
        
        #100;
    end
end

endmodule