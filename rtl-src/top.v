`include "activation-memory-unit.v"
`include "stacked-systolic-array.v"
`include "saturated-adder"
`include "max-pooling.v"
`include "relu.v"
`include "mux2.v"

module top (clk, ce);

    // Port connections
    input clk, ce;

// General systolic wires
wire [23:0] x_ins_bus;
wire [31:0] cell_ctrl;
wire [4:0] cell_mem_addr; 

// 3x3 stacked systolic array wires
wire [23:0] ssa_3_3_y_out;
wire [7:0] ssa_3_3_csa_s_out, ssa_3_3_csa_c_out, ssa_3_3_y_out_sum;

// 3x1 stacked systolic array wires
wire [23:0] ssa_3_1_y_out;
wire [7:0] ssa_3_1_csa_s_out, ssa_3_1_csa_c_out, ssa_3_1_y_out_sum;

// Mux wires
wire [7:0] ssa_3_3_ssa_3_1_mux_out;
wire ssa_3_3_ssa_3_1_mux_sel;
wire relu_bypass_mux_sel;
wire [7:0] relu_bypass_mux_mux_out;
wire ssa_max_pooling_mux_mux_sel;
wire [7:0] ssa_max_pooling_mux_mux_out;

// Max pooling wires
wire [7:0] max_pooling_out;

// ReLU wires
wire [7:0] relu_out;

// Activation mem wires
wire [7:0] fully_connected_adder_out;
wire [7:0] convolved_output;
wire [7:0] activation_mem_in;
wire [19:0] data_out_sels;
wire [4:0] activation_mem_r_addr, activation_mem_w_addr;
wire [4:0] activation_mem_en_bus;

wire fc_accum_out_sce_outs_mux_sel;
wire relu_bypass_mux_sel, max_pooling_conv_out_mux_sel;

// -------------------------------------------------------- //

// Instantiate a 3x3 stacked systolic array
stacked_systolic_array ssa_3_3_inst
(
    clk, ce, cell_ctrl, cell_mem_addr, x_ins_bus, ssa_3_3_y_out
);
defparam ssa_3_3_inst.WIDTH = 8;
defparam ssa_3_3_inst.ARRAY_COUNT = 3;
defparam ssa_3_3_inst.CELLS_PER_ARRAY_COUNT = 3;
defparam ssa_3_3_inst.CELL_MEM_ADDR_WIDTH = 5;
defparam ssa_3_3_inst.CELL_ROM_BASENAME = "build/raw-mnist-weights/kernels-3x3/cell-weight-";
defparam ssa_3_3_inst.CELL_ROM_EXTENSION = ".mem";

// -------------------------------------------------------- //

carry_save_adder ssa_3_3_csa_inst
(
    ssa_3_3_y_out[23:16], ssa_3_3_y_out[15:8], ssa_3_3_y_out[7:0], 
    ssa_3_3_csa_s_out, ssa_3_3_csa_c_out
);
defparam ssa_3_3_csa_inst.WIDTH = 8;

// -------------------------------------------------------- //

saturated_adder ssa_3_3_sat_adder_inst 
(
    ssa_3_3_csa_s_out, {ssa_3_3_csa_c_out[6:0],1'b0}, 
    ssa_3_3_y_out_sum
);
defparam ssa_3_3_sat_adder_inst.WIDTH = 8;

// -------------------------------------------------------- //

// Instantiate a 3x1 stacked systolic array
stacked_systolic_array ssa_3_1_inst
(
    clk, ce, cell_ctrl, cell_mem_addr, x_ins_bus[23:0], ssa_3_1_y_out
);
defparam ssa_3_1_inst.WIDTH = 8;
defparam ssa_3_1_inst.ARRAY_COUNT = 3;
defparam ssa_3_1_inst.CELLS_PER_ARRAY_COUNT = 1;
defparam ssa_3_1_inst.CELL_MEM_ADDR_WIDTH = 5;
defparam ssa_3_1_inst.CELL_ROM_BASENAME = "build/raw-mnist-weights/kernels-3x3/cell-weight-";
defparam ssa_3_1_inst.CELL_ROM_EXTENSION = ".mem";

// -------------------------------------------------------- //

carry_save_adder ssa_3_1_csa_inst
(
    ssa_3_1_y_out[23:16], ssa_3_1_y_out[15:8], ssa_3_1_y_out[7:0], 
    ssa_3_1_csa_s_out, ssa_3_1_csa_c_out
);
defparam ssa_3_1_csa_inst.WIDTH = 8;

// -------------------------------------------------------- //

saturated_adder ssa_3_1_sat_adder_inst  
(
    ssa_3_1_csa_s_out, {ssa_3_1_csa_c_out[6:0],1'b0},
    ssa_3_1_y_out_sum
);
defparam ssa_3_1_sat_adder_inst .WIDTH = 8;

// -------------------------------------------------------- //

// Instantiate ReLU unit
relu relu_inst
(
    ssa_3_3_ssa_3_1_mux_out, relu_out
);
defparam relu_inst.WIDTH = 8;

// -------------------------------------------------------- //

// Instantiate max-pooling (2x2) unit
max_pooling max_pooling_inst 
(
    x_ins_bus[23:0], 
    max_pooling_out
);
defparam max_pooling_inst.POOLING_NxN = 1;
defparam max_pooling_inst.WIDTH = 8;

// -------------------------------------------------------- //

// Instantiate activation memory // TODO: Update the fields
activation_memory_unit amu_inst
(
    clk, activation_mem_en_bus,
    data_out_sels,
    activation_mem_r_addr, activation_mem_w_addr, 
    ssa_max_pooling_mux_mux_out, x_ins_bus
);
defparam  amu_inst.ADDR_WIDTH = 5;
defparam  amu_inst.DATA_WIDTH = 8;
defparam  amu_inst.BRAM_COUNT = 3;

// -------------------------------------------------------- //

// TODO: Instantiate the AXI I/O streams (Data-in, Data-out, Status-out)
// ...

// -------------------------------------------------------- //

// TODO: Instantiate the Control unit
// ...

// -------------------------------------------------------- //

// Instantiate mux2 modules
mux2 ssa_3_3_ssa_3_1_mux
(
    ssa_3_3_y_out_sum,
    ssa_3_1_y_out_sum,
    ssa_3_3_ssa_3_1_mux_sel,
    ssa_3_3_ssa_3_1_mux_out
);
defparam ssa_3_3_ssa_3_1_mux.WIDTH = 8;

// -------------------------------------------------------- //

// Instantiate mux2 modules
mux2 ssa_max_pooling_mux
(
    max_pooling_out,
    relu_bypass_mux_mux_out,
    ssa_max_pooling_mux_mux_sel,
    ssa_max_pooling_mux_mux_out
);
defparam ssa_max_pooling_mux.WIDTH = 8;

// -------------------------------------------------------- //

// Instantiate mux2 modules
mux2 relu_bypass_mux
(
    relu_out,
    ssa_3_3_ssa_3_1_mux_out,
    relu_bypass_mux_sel,
    relu_bypass_mux_mux_out
);
defparam relu_bypass_mux.WIDTH = 8;

// -------------------------------------------------------- //

endmodule

