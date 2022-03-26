module max_compare (compare_a, compare_b, max_val);

    // Parameters
    parameter WIDTH = 8;

    // Port connections
    input signed [WIDTH-1:0] compare_a, compare_b;
    output signed [WIDTH-1:0] max_val;

assign max_val = (compare_a > compare_b) ? (compare_a) : (compare_b);

endmodule

