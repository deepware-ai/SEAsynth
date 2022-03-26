`include "carry-save-adder.v"

module carry_save_adder_tb;

reg [7:0] a, b, c;
wire [7:0] s, cout;

carry_save_adder dut
(
    a, b, c, s, cout
);
defparam dut.WIDTH = 8;

initial
begin
    $dumpfile("./build/rtl-sim/vcd/carry-save-adder.vcd");
    $dumpvars;
end

initial
begin
    a = 12;
    b = 33;
    c = 1;
    #100;
    a = 1;
    b = 23;
    c = 0;
    #100;
    a = 1;
    b = 0;
    c = 7;
    #100;
end

endmodule

