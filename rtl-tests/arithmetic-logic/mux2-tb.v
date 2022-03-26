`include "mux2.v"

module mux2_tb;

reg in1, in2, sel;
wire out;

mux2 dut
(
    in1, in2, sel, out
);
defparam dut.WIDTH = 1;

// Dump waveform data
initial
begin
    $dumpfile("./build/rtl-sim/vcd/mux2.vcd");
    $dumpvars;
end

initial
begin
    in1 = 0;
    in2 = 1;
    sel = 0;
    #100;
    sel = 1;
    #100;
end

endmodule

