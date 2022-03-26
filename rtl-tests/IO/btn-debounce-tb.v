`include "btn-debounce.v"

module btn_debounce_tb;

reg raw_input, clk;
wire btn_pulse;
integer i;

btn_debounce dut
(
    raw_input, clk, btn_pulse
);

// Dump waveform data
initial
begin
    $dumpfile("./build/rtl-sim/vcd/btn-debounce.vcd");
    $dumpvars;
end

initial
begin
    for (i = 0; i < 64; i = i + 1)
    begin
        if (i == 16)
            raw_input = 1;
        else
            raw_input = 0;
        
        clk = 0;
        #100;
        clk = 1;
        #100;
    end
end


endmodule

