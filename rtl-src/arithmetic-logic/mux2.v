module mux2 (in1, in2, sel, out);

    // Parameters
    parameter WIDTH = 1;

    // Port connections
    input [WIDTH-1:0] in1, in2;
    input sel;
    output [WIDTH-1:0] out;

assign out = sel ? (in2) : (in1);

endmodule

