module ram (clk, en, r_addr, w_addr, data_in, data_out);

    // Parameter
    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 8;

    // Port connections
    input clk, en;
    input [ADDR_WIDTH-1:0] r_addr, w_addr;
    input [DATA_WIDTH-1:0] data_in; 
    output [DATA_WIDTH-1:0] data_out;

// Memory unit
reg [DATA_WIDTH-1:0] memory [0:(2**ADDR_WIDTH)-1];
integer i;

// Init values (for simulation purposes)
initial
begin
    for (i = 0; i < 2**ADDR_WIDTH; i = i + 1)
    begin
        memory[i] = 0;
    end
end

// Sychronous write
always@(posedge clk)
begin
    if (en)
    begin
        memory[w_addr] <= data_in;
    end
end

// Asynchronous read
assign data_out = memory[r_addr];

endmodule

