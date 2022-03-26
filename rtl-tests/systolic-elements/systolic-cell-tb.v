`include "systolic-cell.v"

module systolic_cell_tb; 

reg clk, ce;
reg [31:0] ctrl_in;
reg [3:0] mem_addr_in;
reg signed [7:0] y_in, x_in;
wire signed [7:0] y_out, x_out;
wire [31:0] ctrl_out;
wire [3:0] mem_addr_out;

integer i;

systolic_cell dut 
    (clk, ce, ctrl_in, ctrl_out, mem_addr_in, mem_addr_out, y_in, y_out, x_in, x_out);
defparam dut.WIDTH = 8;
defparam dut.MEM_ADDR_WIDTH = 4;
defparam dut.ROM_FILE = "build/raw-mnist-weights-int8/conv2d/cell-weight-0.mem";

initial
begin
    $dumpfile("./build/rtl-sim/vcd/systolic-cell.vcd");
    $dumpvars;
end

initial
begin
    clk = 0;
    ce = 1;
    x_in = 15;
    y_in = 3;
    ctrl_in = 0;
    mem_addr_in = 0;
    i = 0;
    #100;
    for (i = 0; i < 32; i = i + 1)
    begin
        clk = ~clk;
        #100;
        clk = ~clk;
        #100;
    end
end

endmodule

