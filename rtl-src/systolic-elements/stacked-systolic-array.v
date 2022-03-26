`include "systolic-array.v"
`include "saturated-adder.v"

module stacked_systolic_array
    (clk, ce, ctrl, mem_addr, x_ins, y_out);

    // Parameters
    parameter WIDTH = 8;
    parameter ARRAY_COUNT = 3;
    parameter CELLS_PER_ARRAY_COUNT = 3;
    parameter CELL_MEM_ADDR_WIDTH = 4;
    parameter CELL_ROM_BASENAME = "weights/cell-weights-";
    parameter CELL_ROM_EXTENSION = ".mem";
    localparam X_INS_BUS_WIDTH = WIDTH * ARRAY_COUNT;
    localparam Y_OUTS_BUS_WIDTH = X_INS_BUS_WIDTH;
    localparam ADDER_TREE_BUS_COUNT = ARRAY_COUNT + (ARRAY_COUNT-2);

    // Port connections
    input clk, ce;
    input [31:0] ctrl;
    input [CELL_MEM_ADDR_WIDTH-1:0] mem_addr;
    input signed [X_INS_BUS_WIDTH-1:0] x_ins;
    output signed [Y_OUTS_BUS_WIDTH-1:0] y_out;

// Internals
wire signed [WIDTH-1:0] x_ins_array [0:ARRAY_COUNT-1];
wire signed [WIDTH-1:0] systolic_array_y_outs [0:ARRAY_COUNT-1];

// Instantiate the systolic arrays and saturated adders for output adder tree
genvar gi;
generate
    for (gi = 0; gi < ARRAY_COUNT; gi = gi + 1)
    begin
        systolic_array systolic_array_inst
        (
            clk, ce, 
            ctrl, mem_addr, 
            x_ins_array[gi], /* x_out not needed */, 
            systolic_array_y_outs[gi]
        );
        defparam systolic_array_inst.WIDTH = WIDTH;
        defparam systolic_array_inst.CELL_MEM_ADDR_WIDTH = CELL_MEM_ADDR_WIDTH;
        defparam systolic_array_inst.CELL_COUNT = CELLS_PER_ARRAY_COUNT;
        defparam systolic_array_inst.ARRAY_IDX = gi;
        defparam systolic_array_inst.CELL_ROM_BASENAME = CELL_ROM_BASENAME;
        defparam systolic_array_inst.CELL_ROM_EXTENSION = CELL_ROM_EXTENSION;

        // Assign x_ins and y_outs
        assign x_ins_array[gi] = x_ins[((gi+1)*WIDTH)-1:gi*WIDTH];
        assign y_out[((gi+1)*WIDTH)-1:gi*WIDTH] = systolic_array_y_outs[gi];
    end
endgenerate

endmodule

