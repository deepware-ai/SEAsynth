module full_adder(a, b, cin, s, cout);

    // Port connections
    input a, b, cin;
    output s, cout;

// Sum and carry-out logic
assign s = a ^ b ^ cin;
assign cout = (a & b) | (a & cin) | (b & cin);

endmodule

