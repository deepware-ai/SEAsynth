`include "full-adder.v"

module full_adder_tb;

reg a, b, cin;
wire s, c;

full_adder dut 
(
    a, b, cin, s, cout
);

initial
begin
    $dumpfile("./build/rtl-sim/vcd/full-adder.vcd");
    $dumpvars;
end

initial
begin
    a = 0;
    b = 0;
    cin = 0;
    #100;
    a = 1;
    b = 0;
    cin = 0;
    #100;
    a = 1;
    b = 0;
    cin = 1;
    #100;
end

endmodule

