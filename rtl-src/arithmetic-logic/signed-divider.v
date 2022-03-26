module signed_divider 
    (Ain, Bin, clk, start, DivWait, writeResultSig, result, remainder);
    
    parameter WIDTH = 8;
    localparam IDLE = 3'd0;
    localparam SUBDIV = 3'd1;
    localparam SHIFTQUO = 3'd2;
    localparam SHIFTDIV = 3'd3;
    localparam DONE = 3'd4;
    input [WIDTH-1:0]Ain,Bin;
    input clk,start;
    output DivWait,writeResultSig;
    output [WIDTH-1:0]result;
    output [(WIDTH*2)-1:0]remainder;

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

reg [(WIDTH*2)-1:0]Divisor,DivisorNext,Remainder,RemainderNext;
reg [WIDTH-1:0]Quotient,QuotientNext;
reg [2:0]state,stateNext;
reg [log2(WIDTH*2)-1:0]counter,counterNext;
reg DivWaitReg,DivWaitRegNext;
reg writeResult,writeResultNext;
reg DivisorSign,RemainderSign;

wire [WIDTH-1:0] zero_pad;
assign zero_pad = 0; 

initial
begin
    Divisor = 0;
    Remainder = 0;
    Quotient = 0;
    DivisorNext = 0;
    RemainderNext = 0;
    QuotientNext = 0;
    DivWaitReg = 0;
    DivWaitRegNext = 0;
    writeResult = 0;
    writeResultNext = 0;
    counter = 0;
    counterNext = 0;
    state = 0;
    stateNext = 0;
end

always@(posedge clk)
begin
    Divisor <= DivisorNext;
    Remainder <= RemainderNext;
    Quotient <= QuotientNext;
    DivWaitReg <= DivWaitRegNext;
    writeResult <= writeResultNext;
    counter <= counterNext;
    state <= stateNext;
end

always@*
begin
    DivisorNext = Divisor;
    RemainderNext = Remainder;
    QuotientNext = Quotient;
    DivWaitRegNext = DivWaitReg;
    writeResultNext = writeResult;
    counterNext = counter;
    stateNext = state;

    case(state)
    IDLE:
    begin
        if(start)
        begin 
            DivisorNext = {Bin,zero_pad};
            RemainderNext = Ain;
            DivWaitRegNext = 1;
            counterNext = (WIDTH+1);
            DivisorSign = Bin[WIDTH-1];
            RemainderSign = Ain[WIDTH-1];

            if(RemainderSign == 1)
                RemainderNext[WIDTH-1:0] = ~RemainderNext[WIDTH-1:0] + 1;
            if(DivisorSign == 1)
                DivisorNext = ~DivisorNext + 1;

            stateNext = SUBDIV;
        end
        else
        begin
            stateNext = IDLE;
            DivWaitRegNext = 0;
            writeResultNext = 0;
        end
    end

    SUBDIV:
    begin
        RemainderNext = RemainderNext - DivisorNext;
        stateNext = SHIFTQUO;
    end

    SHIFTQUO:
    begin
        if(RemainderNext[(WIDTH*2)-1] == 0)
        begin
            QuotientNext = {QuotientNext[(WIDTH-2):0],1'b1};
            stateNext = SHIFTDIV;
        end
        else
        begin
            RemainderNext = RemainderNext + DivisorNext;
            QuotientNext = {QuotientNext[(WIDTH-2):0],1'b0};
            stateNext = SHIFTDIV;
        end
    end

    SHIFTDIV:
    begin
        DivisorNext = DivisorNext >> 1'b1;
        counterNext = counterNext - 1;

        if(counterNext == 0)
            stateNext = DONE;

        else
            stateNext = SUBDIV;
    end

    DONE:
    begin
        if(DivisorSign != RemainderSign)
        begin
            QuotientNext = ~QuotientNext + 1;
        end
            writeResultNext = 1;
            DivWaitRegNext = 0;
            stateNext = IDLE;
    end
    endcase
end

assign result = Quotient;
assign remainder = Remainder;
assign writeResultSig = writeResult;
assign DivWait = DivWaitReg;

endmodule

