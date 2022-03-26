module rom (clk, en, addr, data);

    // Parameter
    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 8;
    parameter ROM_FILE = "rom_values.mem";

    // Port connections
    input clk, en;
    input [ADDR_WIDTH-1:0] addr;
    output reg [DATA_WIDTH-1:0] data;

// Memory unit
reg [DATA_WIDTH-1:0] memory [0:(2**ADDR_WIDTH)-1];

// Load .mem file values into "synchronous ROM"
initial $readmemh(ROM_FILE, memory);

// Init values (for simulation purposes)
initial
begin
    data = 0;
end

// Read from ROM logic
always@(posedge clk)
begin
    if (en)
    begin
        data <= memory[addr];
    end
end

endmodule

