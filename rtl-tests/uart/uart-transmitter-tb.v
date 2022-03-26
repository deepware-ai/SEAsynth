`include "uart-transmitter.v"

module uart_transmitter_tb;

reg clk;
reg tx_start;
reg [7:0] tx_byte;
wire tx;
wire tx_done;

uart_transmitter dut
(
    clk,
    tx_start,
    tx_byte,
    tx,
    tx_done
);

initial
begin
    $dumpfile("./build/rtl-sim/vcd/uart-transmitter.vcd");
    $dumpvars;
end

integer i;
initial
begin
    clk = 0;
    tx_start = 0;
    tx_byte = 65;

    for (i = 0; i < 10500; i = i + 1)
    begin
        if (i == 500)
            tx_start = 1;
        else
            tx_start = 0;
        
        clk = ~clk; 
        #100;
    end
end

endmodule
