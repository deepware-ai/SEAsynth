module btn_debounce(raw_input, clk, btn_pulse);

    // Parameters
    parameter COUNTER_VAL = 28'h3D0900;

    // Port connections
    input raw_input, clk;
    output btn_pulse;

// Create 3 D Flip Flops
reg d1, d2, d3;

// Create clock-divider counter
reg [27:0]counter;

// Create slow-clock D Flip Flop
reg slow_clk;

always@(posedge clk)
begin
    if (counter == COUNTER_VAL)
    begin
        counter <= 28'd0;
        slow_clk <= ~slow_clk;
    end
    else
    begin
        counter <= counter + 1'b1;
    end
end

always@(posedge slow_clk)
begin
    d1 <= raw_input;
    d2 <= d1;
    d3 <= d2;
end

// Cleaned-up one-shot button press output (rising-edge detect)
assign btn_pulse = d2 && !d3;

endmodule