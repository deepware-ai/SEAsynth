`include "stacked-systolic-array.v"

module stacked_systolic_array_tb;

reg clk, ce;
reg [31:0] ctrl;
reg [3:0] mem_addr;
reg signed [39:0] x_ins;
wire signed [7:0] y_out;

integer i;

stacked_systolic_array dut
    (clk, ce, ctrl, mem_addr, x_ins, y_out);
defparam dut.WIDTH = 8;
defparam dut.ARRAY_COUNT = 3;
defparam dut.CELLS_PER_ARRAY_COUNT = 3;
defparam dut.CELL_MEM_ADDR_WIDTH = 4;
defparam dut.CELL_ROM_BASENAME = "build/raw-mnist-weights-int8/conv2d/cell-weight-";
defparam dut.CELL_ROM_EXTENSION = ".mem";

initial
begin
    $dumpfile("./build/rtl-sim/vcd/stacked-systolic-array.vcd");
    $dumpvars;
end

initial
begin
    clk = 0;
    ce = 1;
    x_ins = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};;
    ctrl = 0;
    mem_addr = 0;
    i = 0;
    #100;
    for (i = 0; i < 64; i = i + 1)
    begin
        /*
             0,  1, 4,  2,  2,  0, 0, 3
             7,  0, 0,  2,  3,  3, 1, 2
             4, 10, 0,  0,  0,  1, 1, 2
             2,  5, 6,  6,  3,  6, 0, 0
            11,  0, 1, 12, 10,  3, 6, 0
             0, 10, 0,  1,  2, 11, 3, 0
             4,  0, 2,  0,  1,  0, 2, 3
             3,  4, 1,  1,  1,  4, 0, 2
        */
        case (i)
        32'd0: x_ins = {8'd11, 8'd2, 8'd4, 8'd7, 8'd0};
        32'd1: x_ins = {8'd0, 8'd5, 8'd10, 8'd0, 8'd1};
        32'd2: x_ins = {8'd1, 8'd6, 8'd0, 8'd0, 8'd4};
        32'd3: x_ins = {8'd12, 8'd6, 8'd0, 8'd2, 8'd2};
        32'd4: x_ins = {8'd10, 8'd3, 8'd0, 8'd3, 8'd2};
        32'd5: x_ins = {8'd3, 8'd6, 8'd1, 8'd3, 8'd0};
        32'd6: x_ins = {8'd6, 8'd0, 8'd1, 8'd1, 8'd0};
        32'd7: x_ins = {8'd0, 8'd0, 8'd2, 8'd2, 8'd3};
        32'd8: x_ins = {8'd0, 8'd11, 8'd2, 8'd4, 8'd7};
        32'd9: x_ins = {8'd10, 8'd0, 8'd5, 8'd10, 8'd0};
        32'd10: x_ins = {8'd0, 8'd1, 8'd6, 8'd0, 8'd0};
        32'd11: x_ins = {8'd1, 8'd12, 8'd6, 8'd0, 8'd2};
        32'd12: x_ins = {8'd2, 8'd10, 8'd3, 8'd0, 8'd3};
        32'd13: x_ins = {8'd11, 8'd3, 8'd6, 8'd1, 8'd3};
        32'd14: x_ins = {8'd3, 8'd6, 8'd0, 8'd1, 8'd1};
        32'd15: x_ins = {8'd0, 8'd0, 8'd0, 8'd2, 8'd2};
        32'd16: x_ins = {8'd4, 8'd0, 8'd11, 8'd2, 8'd4};
        32'd17: x_ins = {8'd0, 8'd10, 8'd0, 8'd5, 8'd10};
        32'd18: x_ins = {8'd2, 8'd0, 8'd1, 8'd6, 8'd0};
        32'd19: x_ins = {8'd0, 8'd1, 8'd12, 8'd6, 8'd0};
        32'd20: x_ins = {8'd1, 8'd2, 8'd10, 8'd3, 8'd0};
        32'd21: x_ins = {8'd0, 8'd11, 8'd3, 8'd6, 8'd1};
        32'd22: x_ins = {8'd2, 8'd3, 8'd6, 8'd0, 8'd1};
        32'd23: x_ins = {8'd3, 8'd0, 8'd0, 8'd0, 8'd2};
        32'd24: x_ins = {8'd3, 8'd4, 8'd0, 8'd11, 8'd2};
        32'd25: x_ins = {8'd4, 8'd0, 8'd10, 8'd0, 8'd5};
        32'd26: x_ins = {8'd1, 8'd2, 8'd0, 8'd1, 8'd6};
        32'd27: x_ins = {8'd1, 8'd0, 8'd1, 8'd12, 8'd6};
        32'd28: x_ins = {8'd1, 8'd1, 8'd2, 8'd10, 8'd3};
        32'd29: x_ins = {8'd4, 8'd0, 8'd11, 8'd3, 8'd6};
        32'd30: x_ins = {8'd0, 8'd2, 8'd3, 8'd6, 8'd0};
        32'd31: x_ins = {8'd2, 8'd3, 8'd0, 8'd0, 8'd0};
        default: x_ins = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
        endcase
        
        clk = ~clk;
        #100;
        clk = ~clk;
        #100;
    end
end

endmodule

