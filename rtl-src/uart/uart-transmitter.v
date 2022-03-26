module uart_transmitter
(
    input clk,
    input tx_start,
    input [7:0] tx_byte,
    output tx,
    output tx_done
);

// Define uart reciever state items
reg [1:0] state;
localparam [1:0]
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    STOP  = 2'b11;

// Counter used to sample in the middle of a uart bit
// Baud rate of 115200: (50 MHz / 115200) = about 435 clk ticks per uart bit
reg [8:0] sample_counter;
localparam [8:0] BAUD_TICK = 9'd435;

// Reg that holds the recieved uart byte
reg [7:0] tx_byte_buffer;

// Define "done" flag for a sucessful byte transmission
reg tx_done_buffer;

// Define rx reg to connect to the output
reg tx_reg;

// Count number of recieved bits and stop at 1 byte (i.e. 8)
reg [2:0] tx_byte_counter;

initial
begin
    state = IDLE;
    tx_reg <= 1;
    tx_byte_buffer = 0;
    sample_counter = 0;
    tx_done_buffer = 1;
    tx_byte_counter = 0;
end

always@(posedge clk)
begin
    case (state)
    IDLE:
    begin
        tx_byte_buffer <= 0;
        sample_counter <= 0;
        tx_done_buffer <= 1;
        tx_byte_counter <= 0;
        tx_reg <= 1;

        if (tx_start)
        begin
            state <= START;
            tx_byte_buffer <= tx_byte;
            tx_done_buffer <= 0;
        end
    end
    START:
    begin
        tx_reg <= 0;

        // Initially offset by half baud tick to sample the middle of a data bit
        if (sample_counter == BAUD_TICK)
        begin
            state <= DATA;
            sample_counter <= 0;
        end
        else
            sample_counter <= sample_counter + 1;
    end
    DATA:
    begin
        if (sample_counter == BAUD_TICK)
        begin
            // Send out one bit from tx_byte_buffer and increment byte counter
            tx_byte_buffer <= tx_byte_buffer >> 1;
            tx_byte_counter <= tx_byte_counter + 1;
            
            // If 7th bit was recieved
            if (tx_byte_counter == 7)
            begin
                state <= STOP;
                tx_reg <= 1;
                tx_byte_counter <= 0;
            end

            // Clear sample counter
            sample_counter <= 0;
        end
        else
        begin
            tx_reg <= tx_byte_buffer[0];
            sample_counter <= sample_counter + 1;
        end
    end
    STOP:
    begin
        if (sample_counter == BAUD_TICK)
        begin
            // Clear sample counter and go back to IDLE state
            sample_counter <= 0;
            tx_done_buffer <= 1;
            state <= IDLE;
        end
        else
            sample_counter <= sample_counter + 1;
    end
    endcase
end

// Connect module outputs
assign tx = tx_reg;
assign tx_done = tx_done_buffer;

endmodule

