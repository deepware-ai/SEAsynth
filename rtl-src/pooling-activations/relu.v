module relu (relu_in, relu_out);

    // Parameters
    parameter WIDTH = 8;

    // Port connections
    input signed [WIDTH-1:0] relu_in;
    output reg signed [WIDTH-1:0] relu_out;

always@*
begin
    if(relu_in < 0)
    begin
        relu_out = 0;
    end
    else
    begin
        relu_out = relu_in;
    end
end

endmodule

