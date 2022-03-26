module saturated_adder (a, b, c);

    parameter  WIDTH = 8;
    localparam SATURATED_MAX = (1 << WIDTH - 1) - 1;
    localparam SATURATED_MIN = -(1 << WIDTH - 1);
    input signed [WIDTH-1:0] a, b; 
    output signed [WIDTH-1:0] c;

reg signed [WIDTH:0] adder_tmp;

initial
begin
    adder_tmp = 0;
end

always@*
begin
    adder_tmp = a + b;
end

assign c = (adder_tmp >= SATURATED_MAX) ? (SATURATED_MAX) : 
    (adder_tmp <= SATURATED_MIN) ? (SATURATED_MIN) : 
        (adder_tmp);

endmodule

