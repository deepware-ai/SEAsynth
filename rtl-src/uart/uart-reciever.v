module uart_reciever
(
    input clk,
    input rx,
    output rx_done,
    output [7:0] rx_byte
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
reg [7:0] rx_byte_buffer;

// Define "done" flag for a sucessful byte reception
reg rx_done_buffer;

// Count number of recieved bits and stop at 1 byte (i.e. 8)
reg [2:0]rx_byte_counter;

initial
begin
    state = IDLE;
    rx_byte_buffer = 0;
    sample_counter = 0;
    rx_done_buffer = 1;
    rx_byte_counter = 0;
end

always@(posedge clk)
begin
    case (state)
    IDLE:
    begin
        rx_byte_buffer <= 0;
        sample_counter <= 0;
        rx_done_buffer <= 1;
        rx_byte_counter <= 0;

        if (!rx)
            state <= START;
    end
    START:
    begin
        // Initially offset by half baud tick to sample the middle of a data bit
        if (sample_counter == BAUD_TICK / 2)
        begin
            if (!rx)
            begin
                state <= DATA;
                rx_done_buffer <= 0;
                sample_counter <= 0;
            end
            else
                state <= IDLE;
        end
        else
            sample_counter <= sample_counter + 1;
    end
    DATA:
    begin
        if (sample_counter == BAUD_TICK)
        begin
            // Shift-in input rx into rx byte buffer and increment byte counter
            rx_byte_buffer <= {rx, rx_byte_buffer[7:1]};
            rx_byte_counter <= rx_byte_counter + 1;
            
            // If 7th bit was recieved
            if (rx_byte_counter == 7)
            begin
                state <= STOP;
                rx_byte_counter <= 0;
            end

            // Clear sample counter
            sample_counter <= 0;
        end
        else
            sample_counter <= sample_counter + 1;
    end
    STOP:
    begin
        if (sample_counter == BAUD_TICK)
        begin
            if (rx)
            begin
                rx_done_buffer <= 1;
            end

            // Clear sample counter and go back to IDLE state
            sample_counter <= 0;
            state <= IDLE;
        end
        else
            sample_counter <= sample_counter + 1;
    end
    endcase
end

// Connect module outputs
assign rx_done = rx_done_buffer;
assign rx_byte = rx_byte_buffer;

endmodule

