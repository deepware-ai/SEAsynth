`include "fifo.v"

module fifo_tb;

reg fifo_clk;
reg fifo_we;
reg fifo_re;
reg signed [15:0] fifo_in;
wire fifo_almost_full;
wire fifo_full;
wire fifo_almost_empty;
wire fifo_empty;
wire signed [15:0] fifo_out;	

// Instantiate and override parameter values
fifo dut
(
    fifo_clk,
    fifo_we,
    fifo_re,
    fifo_in,
    fifo_almost_full,
    fifo_full,
    fifo_almost_empty,
    fifo_empty,
    fifo_out
);
defparam dut.WIDTH = 16;
defparam dut.DEPTH = 256;
defparam dut.ALMOST_FULL_DEPTH_VAL = 252;
defparam dut.ALMOST_EMPTY_DEPTH_VAL = 4;

// Dump waveform data
initial
begin
    $dumpfile("./build/rtl-sim/vcd/fifo.vcd");
    $dumpvars;
end

// Main simulation logic
integer i;
initial
begin
    fifo_clk = 0;
    fifo_we = 0;
    fifo_re = 0;
    fifo_in = 0;

    for (i = 0; i < 1000; i = i + 1)
    begin
        if (i == 1)
            fifo_in = 129;
        else if (i == 2)
            fifo_in = 45;
        
        if (i > 0 && i < 3)
            fifo_we = 1;
        else
            fifo_we = 0;

        if (i >= 5 && i <= 6)
            fifo_re = 1;
        else
            fifo_re = 0;

        #100;
        fifo_clk = !fifo_clk;
        #100;
        fifo_clk = !fifo_clk;
    end
end

endmodule