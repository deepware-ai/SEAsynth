`include "rom.v"

module rom_tb;

reg clk, en;
reg [3:0] addr;
wire [31:0] data;
integer i;

rom dut 
(
    clk, en, addr, data
);
defparam dut.ADDR_WIDTH = 4;
defparam dut.DATA_WIDTH = 32;
defparam dut.ROM_FILE = "build/raw-mnist-weights-int8/conv2d/cell-weight-0.mem";

// Dump waveform data
initial
begin
    $dumpfile("./build/rtl-sim/vcd/rom.vcd");
    $dumpvars;
end

initial
begin
    for (i = 0; i < 64; i = i + 1)
    begin
        en = 1;
        addr = i % 32;

        clk = 0;
        #100;
        clk = 1;
        #100;
    end
end

endmodule

