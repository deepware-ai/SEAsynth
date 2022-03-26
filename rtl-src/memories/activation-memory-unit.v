`include "ram.v"
`include "mux2-tree.v"

module activation_memory_unit (clk, en_bus, data_out_sels, r_addr, w_addr, data_in, data_outs);

    // Parameters
    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 8;
    parameter BRAM_COUNT = 5;
    localparam DATA_OUT_SELS_WIDTH = BRAM_COUNT-1;

    // Port connections
    input clk;
    input [BRAM_COUNT-1:0] en_bus;
    input [((DATA_OUT_SELS_WIDTH)*BRAM_COUNT)-1:0] data_out_sels;
    input [ADDR_WIDTH-1:0] w_addr;
    input [DATA_WIDTH-1:0] data_in;
    input [(BRAM_COUNT*ADDR_WIDTH)-1:0] r_addr;
    output [(BRAM_COUNT*DATA_WIDTH)-1:0] data_outs;

// Internals
wire [ADDR_WIDTH-1:0] addr_array [0:BRAM_COUNT-1];
wire [(BRAM_COUNT*DATA_WIDTH)-1:0] bram_outs;
wire [DATA_OUT_SELS_WIDTH-1:0] data_out_sels_array [0:BRAM_COUNT-1];
integer i;

// Instantiate BRAMs and mux2 trees
genvar gi;
generate
    for (gi = 0; gi < BRAM_COUNT; gi = gi + 1)
    begin
        // Connect input 'r_addr' sections to 'addr_array'
        assign addr_array[gi] = r_addr[((gi+1)*ADDR_WIDTH)-1:gi*ADDR_WIDTH];

        // Connect input 'data_out_sels' sections to 'data_out_sels_array'
        assign data_out_sels_array[gi] = 
            data_out_sels[((gi+1)*DATA_OUT_SELS_WIDTH)-1:gi*DATA_OUT_SELS_WIDTH];

        ram bram_inst
        (
            clk, en_bus[gi], 
            addr_array[gi], w_addr, 
            data_in,
            bram_outs[((gi+1)*DATA_WIDTH)-1:gi*DATA_WIDTH]
        );
        defparam bram_inst.ADDR_WIDTH = ADDR_WIDTH;
        defparam bram_inst.DATA_WIDTH = DATA_WIDTH;

        mux2_tree mux2_tree_inst
        (
            bram_outs, 
            data_out_sels_array[gi], 
            data_outs[((gi+1)*DATA_WIDTH)-1:gi*DATA_WIDTH]
        );
        defparam mux2_tree_inst.WIDTH = DATA_WIDTH;
        defparam mux2_tree_inst.NUM_INPUTS = BRAM_COUNT;
    end
endgenerate

endmodule

