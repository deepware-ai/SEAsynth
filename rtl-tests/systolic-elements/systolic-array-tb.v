`include "systolic-array.v"

module systolic_array_tb;

reg clk, ce;
reg [31:0] ctrl;
reg [3:0] mem_addr;
reg signed [7:0] x_in;
wire signed [7:0] y_out1, x_out1, y_out2, x_out2;

integer i;

systolic_array dut1
    (clk, ce, ctrl, mem_addr, x_in, x_out1, y_out1);
defparam dut1.WIDTH = 8;
defparam dut1.CELL_COUNT = 3;
defparam dut1.CELL_MEM_ADDR_WIDTH = 4;
defparam dut1.CELL_ROM_BASENAME = "build/raw-mnist-weights-int8/conv2d/cell-weight-";
defparam dut1.CELL_ROM_EXTENSION = ".mem";

systolic_array dut2
    (clk, ce, ctrl, mem_addr, x_in, x_out2, y_out2);
defparam dut2.WIDTH = 8;
defparam dut2.CELL_COUNT = 3;
defparam dut2.CELL_MEM_ADDR_WIDTH = 4;
defparam dut2.CELL_ROM_BASENAME = "build/raw-mnist-weights-int8/conv2d/cell-weight-";
defparam dut2.CELL_ROM_EXTENSION = ".mem";

initial
begin
    $dumpfile("./build/rtl-sim/vcd/systolic-array.vcd");
    $dumpvars;
end

initial
begin
    clk = 0;
    ce = 1;
    x_in = 3;
    ctrl = 0;
    mem_addr = 0;
    i = 0;
    #100;
    for (i = 0; i < 64; i = i + 1)
    begin
        case (i)
        32'd0: x_in = 0;
        32'd1: x_in = 1;
        32'd2: x_in = 0;
        32'd3: x_in = 2;
        32'd4: x_in = 5;
        32'd5: x_in = 0;
        32'd6: x_in = 0;
        32'd7: x_in = 1;
        32'd8: x_in = 2;
        32'd9: x_in = 3;
        32'd10: begin x_in = 4; mem_addr = 0; end
        32'd11: x_in = 10;
        32'd12: x_in = 11;
        32'd13: x_in = 0;
        32'd14: x_in = 0;
        32'd15: x_in = 6;
        default: x_in = 0;
        endcase
        
        mem_addr = (mem_addr + 1) % 12;
        clk = ~clk;
        #100;
        clk = ~clk;
        #100;
    end
end

endmodule

