`include "mux2.v"

module mux2_tree (ins, sels, out);

    // Parameters
    parameter WIDTH = 1;
    parameter NUM_INPUTS = 2;
    localparam MUX_COUNT = NUM_INPUTS-1;
    localparam MUX_BUS_ARRAY_COUNT = NUM_INPUTS + (NUM_INPUTS-1);

    // Port connections
    input [(WIDTH*NUM_INPUTS)-1:0] ins;
    input [MUX_COUNT-1:0] sels;
    output [WIDTH-1:0] out;

// Internals
wire [WIDTH-1:0] mux_bus_array [0:MUX_BUS_ARRAY_COUNT-1];
genvar gi;

// Unpack input 'ins' to the 'mux_bus_array'
generate
    for (gi = 0; gi < NUM_INPUTS; gi = gi + 1)
    begin
        assign mux_bus_array[gi] = ins[(WIDTH*(gi+1))-1:WIDTH*gi];
    end
endgenerate

// Instantiate the 2-1 MUXs
generate
    for (gi = 0; gi < MUX_COUNT; gi = gi + 1)
    begin
        mux2 mux2_inst
        (
            mux_bus_array[gi*2],
            mux_bus_array[(gi*2)+1], 
            sels[gi], 
            mux_bus_array[gi+NUM_INPUTS]
        );
        defparam mux2_inst.WIDTH = WIDTH;
    end
endgenerate

assign out = mux_bus_array[MUX_BUS_ARRAY_COUNT-1];

endmodule

