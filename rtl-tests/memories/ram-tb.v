`include "ram.v"

module ram_tb;

reg clk, en;
reg [4:0] r_addr, w_addr;
reg [7:0] data_in; 
wire [7:0] data_out;
integer i;

ram dut 
(
    clk, en, r_addr, w_addr, data_in, data_out
);
defparam dut.ADDR_WIDTH = 5;
defparam dut.DATA_WIDTH = 8;

// Dump waveform data
initial
begin
    $dumpfile("./build/rtl-sim/vcd/ram.vcd");
    $dumpvars;
end

initial
begin
    en = 1;
    clk = 0;
    r_addr = 0;
    w_addr = 0;
    data_in = 45;
    for (i = 0; i < 64; i = i + 1)
    begin
        if (((i%4) == 0) && i != 0)
            w_addr = w_addr + 1;

        data_in = i;
        r_addr = i;
        clk = ~clk;
        #100;
        clk = ~clk;
        #100;
    end
end

endmodule

