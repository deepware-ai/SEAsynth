`include "mux2-tree.v"

module mux2_tree_tb;

reg [39:0] ins;
reg [3:0] sels;
wire [7:0] out;
integer i;

mux2_tree dut
(
    ins, sels, out
);
defparam dut.WIDTH = 8;
defparam dut.NUM_INPUTS = 5;

// Dump waveform data
initial
begin
    $dumpfile("./build/rtl-sim/vcd/mux2-tree.vcd");
    $dumpvars;
end

initial
begin
    ins = 286;
    for (i = 0; i < 64; i = i + 1)
    begin
        sels = i[3:0];
    end
end

endmodule