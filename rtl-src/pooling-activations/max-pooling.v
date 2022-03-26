`include "max-compare.v"

module max_pooling (activations, max_pool_out);

    // Parameters
    parameter POOLING_NxN = 2;
    parameter WIDTH = 8;
    localparam KERNEL_SIZE = POOLING_NxN * POOLING_NxN;
    localparam MAX_VAL_UNITS = KERNEL_SIZE - 1;
    localparam MAX_VAL_ARRAY_COUNT = (MAX_VAL_UNITS * 2) + 1;

    // Port connections
    input signed [(WIDTH*KERNEL_SIZE)-1:0] activations;
    output signed [WIDTH-1:0] max_pool_out;

// Internals
wire [WIDTH-1:0] max_val_array [0:MAX_VAL_ARRAY_COUNT-1];
genvar gi;

// Unpack input 'activations' to the 'max_val_array'
generate
    for (gi = 0; gi < KERNEL_SIZE; gi = gi + 1)
    begin
        if (gi == 0)
        begin
            assign max_val_array[gi] = activations[((gi+1)*WIDTH)-1:(gi*WIDTH)];
        end
        else
        begin
            assign max_val_array[(gi*2)-1] = activations[((gi+1)*WIDTH)-1:(gi*WIDTH)];
        end
    end
endgenerate

// Instantiate max compare units
generate
    for (gi = 0; gi < MAX_VAL_UNITS; gi = gi + 1)
    begin
        max_compare max_compare_inst
        (
            max_val_array[gi*2], 
            max_val_array[(gi*2)+1], 
            max_val_array[(gi*2)+2]
        );
        defparam max_compare_inst.WIDTH = WIDTH;
    end
endgenerate

assign max_pool_out = max_val_array[MAX_VAL_ARRAY_COUNT-1];

endmodule

