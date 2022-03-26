module mac (clk, ce, a, b, c, p);
    
    // Parameters
    parameter WIDTH = 8;
    localparam ACCUM_WIDTH = WIDTH * 2;
    
    // Port connections
    input clk, ce;
    input signed [WIDTH-1:0] a, b;
    input signed [WIDTH-1:0] c;
    output signed [ACCUM_WIDTH-1:0] p;

// Declare regs for intermediate values
reg signed [WIDTH-1:0]  a_reg, b_reg;
reg signed [ACCUM_WIDTH-1:0] mult_reg, adder_out;

initial
begin
    a_reg      = 0;
    b_reg      = 0;
    mult_reg   = 0;
    adder_out  = 0;
end

always @(posedge clk)
begin
	if (ce)
	begin
    	a_reg      <= a;
    	b_reg      <= b;
    	mult_reg   <= a_reg * b_reg;
        adder_out  <= mult_reg + c;
	end
end

// Output accumulation result
assign p = adder_out;

endmodule

