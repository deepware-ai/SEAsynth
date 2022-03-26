module fifo (fifo_clk, fifo_we, fifo_re, fifo_in, fifo_almost_full, 
    fifo_full, fifo_almost_empty, fifo_empty, fifo_out);

    parameter WIDTH = 16;
    parameter DEPTH = 256;
    parameter ALMOST_FULL_DEPTH_VAL = 252;
    parameter ALMOST_EMPTY_DEPTH_VAL = 4;
    
    input fifo_clk;
    input fifo_we;
    input fifo_re;
    input signed [WIDTH-1:0] fifo_in;
    output fifo_almost_full;
    output fifo_full;
    output fifo_almost_empty;
    output fifo_empty;
    output signed [WIDTH-1:0] fifo_out;	

// Define log2 function
function integer log2;
    input [31:0] value;
    begin
        value = value -1 ;
        for (log2 = 0; value > 0; log2 = log2 + 1)
        begin
            value = value >> 1;
        end
    end
endfunction

// Create fifo memory along w/ 'head' and 'tail' ptrs
reg signed [WIDTH-1:0] fifo_mem [0:DEPTH-1];
reg [log2(DEPTH)-1:0] fifo_head, fifo_tail;

// Define "Almost-full" counter
reg [log2(DEPTH)-1:0] fifo_count;

// Initially clear values (for simulation)
integer i;
initial
begin
    for (i = 0; i < DEPTH-1; i = i + 1)
    begin
        fifo_mem[i] = 0;
    end
    fifo_head  = 0;
    fifo_tail  = 0;
    fifo_count = 0;
end

// Fifo main logic
always@(posedge fifo_clk)
begin
    // Adjust fifo entry count
    if (fifo_we && fifo_re)
    begin
        fifo_count <= fifo_count + 1;
    end
    else if (!fifo_we && fifo_re)
    begin
        fifo_count <= fifo_count - 1;
    end

    // Adjust fifo tail pointer on write operations
    if (fifo_we && !fifo_full)
    begin
        if (fifo_tail == DEPTH-1)
        begin
            fifo_tail <= 0;
        end
        else
        begin
            fifo_tail <= fifo_tail + 1;
        end
    end

    // Adjust fifo head pointer on read operations
    if (fifo_re && !fifo_empty)
    begin
        if (fifo_head == DEPTH-1)
        begin
            fifo_head <= 0;
        end
        else
        begin
            fifo_head <= fifo_head + 1;
        end
    end

    // Write data into fifo if write-enable is asserted
    if (fifo_we)
    begin
        fifo_mem[fifo_tail] <= fifo_in;
    end
end

// Read value from 'head' of fifo
assign fifo_out = fifo_mem[fifo_head];

// Output 'almost-empty' and 'almost-full' flags
assign fifo_almost_empty = (fifo_count <= ALMOST_EMPTY_DEPTH_VAL) ? 1 : 0;
assign fifo_almost_full = (fifo_count >= ALMOST_FULL_DEPTH_VAL) ? 1 : 0;

// Output 'empty' and 'full' flags
assign fifo_empty = (fifo_count == 0) ? 1 : 0;
assign fifo_full = (fifo_count == DEPTH-1) ? 1 : 0;

endmodule

