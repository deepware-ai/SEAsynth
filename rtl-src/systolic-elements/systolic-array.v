`include "systolic-cell.v"

module systolic_array
    (clk, ce, ctrl, mem_addr, x_in, x_out, y_out);

    // Parameters
    parameter WIDTH = 8;
    parameter CELL_MEM_ADDR_WIDTH = 4;
    parameter CELL_COUNT = 3;
    parameter ARRAY_IDX = 0;
    parameter CELL_ROM_BASENAME = "weights/cell-weights-";
    parameter CELL_ROM_EXTENSION = ".mem";
    localparam ASCII_OFFSET = 8'd48;

    // Port connections
    input clk, ce;
    input [31:0] ctrl;
    input [CELL_MEM_ADDR_WIDTH-1:0] mem_addr;
    input signed [WIDTH-1:0] x_in;
    output signed [WIDTH-1:0] x_out, y_out;

// Internals
wire signed [WIDTH-1:0] y_interconnect [0:CELL_COUNT];
wire signed [WIDTH-1:0] x_interconnect [0:CELL_COUNT];
wire [31:0] ctrl_interconnect [0:CELL_COUNT];
wire [CELL_MEM_ADDR_WIDTH-1:0] mem_addr_interconnect [0:CELL_COUNT];

// Boundary input/output connections of systolic array
assign x_interconnect[0] = x_in;
assign y_interconnect[0] = 0;
assign x_out = x_interconnect[CELL_COUNT];
assign y_out = y_interconnect[CELL_COUNT];
assign ctrl_interconnect[0] = ctrl;
assign mem_addr_interconnect[0] = mem_addr;

// Instantiate the systolic cells
genvar gi, gj;
generate
    for (gi = 0; gi < CELL_COUNT; gi = gi + 1)
    begin
        // This is a shitty hack to cast loop iterator 'gi' to a string to use as the index to the memory files
        if ((gi + (ARRAY_IDX * CELL_COUNT)) < 10) /* Memory files 0 - 9 */
        begin
            systolic_cell systolic_cell_inst
            (
                clk, ce,
                ctrl_interconnect[gi], ctrl_interconnect[gi+1],
                mem_addr_interconnect[gi], mem_addr_interconnect[gi+1],
                y_interconnect[gi], y_interconnect[gi+1],
                x_interconnect[gi], x_interconnect[gi+1]
            );
            defparam systolic_cell_inst.WIDTH = WIDTH;
            defparam systolic_cell_inst.MEM_ADDR_WIDTH = CELL_MEM_ADDR_WIDTH;
            defparam systolic_cell_inst.ROM_FILE = {CELL_ROM_BASENAME, 
                (gi[31:0] + (ARRAY_IDX[31:0] * CELL_COUNT[31:0])) + ASCII_OFFSET, CELL_ROM_EXTENSION};
        end
        else if ((gi + (ARRAY_IDX * CELL_COUNT)) < 100) /* Memory files 10 - 99 */
        begin
            systolic_cell systolic_cell_inst
            (
                clk, ce,
                ctrl_interconnect[gi], ctrl_interconnect[gi+1],
                mem_addr_interconnect[gi], mem_addr_interconnect[gi+1],
                y_interconnect[gi], y_interconnect[gi+1],
                x_interconnect[gi], x_interconnect[gi+1]
            );
            defparam systolic_cell_inst.WIDTH = WIDTH;
            defparam systolic_cell_inst.MEM_ADDR_WIDTH = CELL_MEM_ADDR_WIDTH;
            defparam systolic_cell_inst.ROM_FILE = {CELL_ROM_BASENAME, 
                ((gi[31:0] + (ARRAY_IDX[31:0] * CELL_COUNT[31:0])) / 8'd10) + ASCII_OFFSET, 
                    ((gi[31:0] + (ARRAY_IDX[31:0] * CELL_COUNT[31:0])) % 8'd10) + ASCII_OFFSET, CELL_ROM_EXTENSION};
        end
        else if ((gi + (ARRAY_IDX * CELL_COUNT)) < 1000) /* Memory files 100 - 999 */
        begin
            systolic_cell systolic_cell_inst
            (
                clk, ce,
                ctrl_interconnect[gi], ctrl_interconnect[gi+1],
                mem_addr_interconnect[gi], mem_addr_interconnect[gi+1],
                y_interconnect[gi], y_interconnect[gi+1],
                x_interconnect[gi], x_interconnect[gi+1]
            );
            defparam systolic_cell_inst.WIDTH = WIDTH;
            defparam systolic_cell_inst.MEM_ADDR_WIDTH = CELL_MEM_ADDR_WIDTH;
            defparam systolic_cell_inst.ROM_FILE = {CELL_ROM_BASENAME, 
                ((gi[31:0] + (ARRAY_IDX[31:0] * CELL_COUNT[31:0])) / 8'd100) + ASCII_OFFSET, 
                    (((gi[31:0] + (ARRAY_IDX[31:0] * CELL_COUNT[31:0])) / 8'd10) % 8'd10) + ASCII_OFFSET, 
                        ((gi[31:0] + (ARRAY_IDX[31:0] * CELL_COUNT[31:0])) % 8'd10) + ASCII_OFFSET, CELL_ROM_EXTENSION};
        end
        else /* Memory files 1000 - 9999 */
        begin
            systolic_cell systolic_cell_inst
            (
                clk, ce,
                ctrl_interconnect[gi], ctrl_interconnect[gi+1],
                mem_addr_interconnect[gi], mem_addr_interconnect[gi+1],
                y_interconnect[gi], y_interconnect[gi+1],
                x_interconnect[gi], x_interconnect[gi+1]
            );
            defparam systolic_cell_inst.WIDTH = WIDTH;
            defparam systolic_cell_inst.MEM_ADDR_WIDTH = CELL_MEM_ADDR_WIDTH;
            defparam systolic_cell_inst.ROM_FILE = {CELL_ROM_BASENAME, 
                ((gi[31:0] + (ARRAY_IDX[31:0] * CELL_COUNT[31:0])) / 10'd1000) + ASCII_OFFSET, 
                    (((gi[31:0] + (ARRAY_IDX[31:0] * CELL_COUNT[31:0])) / 8'd100) % 8'd10) + ASCII_OFFSET,
                        (((gi[31:0] + (ARRAY_IDX[31:0] * CELL_COUNT[31:0])) / 8'd10) % 8'd10) + ASCII_OFFSET,
                            ((gi[31:0] + (ARRAY_IDX[31:0] * CELL_COUNT[31:0])) % 8'd10) + ASCII_OFFSET, CELL_ROM_EXTENSION};
        end
    end
endgenerate

endmodule

