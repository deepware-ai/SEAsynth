`include "mac.v"
`include "rom.v"

module systolic_cell 
    (clk, ce, ctrl_in, ctrl_out, mem_addr_in, mem_addr_out, y_in, y_out, x_in, x_out);

    // Parameters
    parameter WIDTH = 8;
    parameter MEM_ADDR_WIDTH = 4;
    parameter ROM_FILE = "weights/cell-weights.mem";
    localparam ACCUM_WIDTH = WIDTH * 2;
    localparam SATURATED_MAX = (1 << WIDTH - 1) - 1;
    localparam SATURATED_MIN = -(1 << WIDTH - 1);

    // Port connections
    input clk, ce;
    input [31:0] ctrl_in; 
    input [MEM_ADDR_WIDTH-1:0] mem_addr_in;
    input signed [WIDTH-1:0] y_in, x_in;
    output signed [WIDTH-1:0] y_out, x_out;
    output [31:0] ctrl_out; 
    output [MEM_ADDR_WIDTH-1:0] mem_addr_out;

// Internals
wire signed [ACCUM_WIDTH-1:0] mac_out;
wire signed [WIDTH-1:0] kernel_weight;
reg [31:0] ctrl_reg;
reg [MEM_ADDR_WIDTH-1:0] mem_addr_reg;
reg signed [WIDTH-1:0] x_in_reg1, x_in_reg2;

// Instantiate a MAC-unit
mac mac_inst
(
    clk, ce, 
    x_in, kernel_weight, y_in, 
    mac_out
);
defparam mac_inst.WIDTH = WIDTH;

// Instantiate ROM unit
rom cell_memory
(
    clk, 1'b1,
    mem_addr_reg, 
    kernel_weight
);
defparam cell_memory.ADDR_WIDTH = MEM_ADDR_WIDTH;
defparam cell_memory.DATA_WIDTH = WIDTH;
defparam cell_memory.ROM_FILE = ROM_FILE;

// Init values (for simulation purposes)
initial
begin
    mem_addr_reg = 0;
    ctrl_reg = 0;
    x_in_reg1 = 0;
    x_in_reg2 = 0;
end

// Cell dataflow pipeline logic
always@ (posedge clk)
begin
    if (ce)
    begin
        mem_addr_reg <= mem_addr_in;
        ctrl_reg <= ctrl_in;
        x_in_reg1 <= x_in;
        x_in_reg2 <= x_in_reg1;
    end
end

// Saturate/clamp the MAC's output value to max/min range
assign y_out = 
    /* if */ (mac_out >= SATURATED_MAX) ? (SATURATED_MAX) : 
        /* else if*/ (mac_out <= SATURATED_MIN) ? (SATURATED_MIN) : 
            /* else */ (mac_out[WIDTH-1:0]);

// Pass x_out to next systolic cell
assign x_out = x_in_reg2;

// Pass ctrl and mem_addr to next cell
assign ctrl_out = ctrl_reg;
assign mem_addr_out = mem_addr_reg;

endmodule

