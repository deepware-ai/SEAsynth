`include "activation-memory-unit.v"

module activation_memory_unit_tb;

// Port connections
reg clk;
reg [4:0] en_bus;
reg [4:0] w_addr;
reg [24:0] r_addr;
reg [7:0] data_in;
reg [19:0] data_out_sels;
wire [39:0] data_outs;

activation_memory_unit dut
(
    clk, en_bus, data_out_sels, r_addr, w_addr, data_in, data_outs
);
defparam dut.ADDR_WIDTH = 5;
defparam dut.DATA_WIDTH = 8;
defparam dut.BRAM_COUNT = 5;

// Dump waveform data
initial
begin
    $dumpfile("./build/rtl-sim/vcd/activation-memory-unit.vcd");
    $dumpvars;
end

// Main simulation logic
integer i;
initial
begin
    clk = 0;
    en_bus = 1;
    r_addr = 0;
    w_addr = 0;
    data_in = 0;
    i = 0;
    #100;

    for (i = 0; i < 32; i = i + 1)
    begin
        if ((i%5 == 0) && (i != 0))
            w_addr = w_addr + 1;
        else
            w_addr = w_addr;

        data_in = (i[7:0]+8'd5);

        if (i > 16)
            r_addr = ((i-17)%31);

        #100;
        clk = !clk;
        #100;
        clk = !clk;

        en_bus = {en_bus[3:0], en_bus[4]};
    end
end

endmodule

