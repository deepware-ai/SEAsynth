`include "full-adder.v"

module carry_save_adder (a, b, c, s, cout);

    // Parameters
    parameter WIDTH = 1;

    // Port connections
    input [WIDTH-1:0] a, b, c;
    output [WIDTH-1:0] s, cout;

genvar gi;
generate
    for (gi = 0; gi < WIDTH; gi = gi + 1)
    begin
        full_adder full_adder_inst
        (
            a[gi], b[gi], c[gi], s[gi], cout[gi]
        );
    end
endgenerate

endmodule

