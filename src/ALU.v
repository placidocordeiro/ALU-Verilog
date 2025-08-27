module ALU #(parameter N=5) (
    input [N-1:0] a, b,
    input [2:0] op,
    output reg [N-1:0] result,
    output reg sign,
    output reg overflow,
    output reg status
);

    wire [N-1:0] sum_out, sub_out, max_out, shift_out, square_out, abs_out;
    wire [N:0] avg_out; // Average needs 1 extra bit
    wire le_out;

    // Operations
    assign sum_out = a + b;
    assign sub_out = a - b;
    assign max_out = ($signed(a) > $signed(b)) ? a : b;
    assign le_out = ($signed(a) <= $signed(b));
    assign avg_out = ($signed({a[N-1], a}) + $signed({b[N-1], b})) >>> 1; // Sign extension
    assign square_out = a * a;
    assign abs_out = a[N-1] ? -a : a;
    assign shift_out = a >>> b;

    always @(*) begin
        // Default values
        {result, sign, overflow, status} = 0;

        case (op)
            3'b000: begin // Add
                result = sum_out;
                {overflow, sign} = {(a[N-1] == b[N-1]) && (sum_out[N-1] != a[N-1]), sum_out[N-1]};
            end
            3'b001: begin // Sub
                result = sub_out;
                {overflow, sign} = {(a[N-1] != b[N-1]) && (sub_out[N-1] != a[N-1]), sub_out[N-1]};
            end
            3'b010: begin // Max
                result = max_out;
                sign = max_out[N-1];
            end
            3'b011: begin // a <= b
                result = { {N-1{1'b0}}, le_out };
                status = le_out;
            end
            3'b100: begin // (a+b)/2
                result = avg_out[N-1:0];
                sign = avg_out[N-1];
            end
            3'b101: begin // a^2
                result = square_out;
                sign = square_out[N-1];
            end
            3'b110: begin // |a|
                result = abs_out;
                sign = 1'b0;
            end
            3'b111: begin // a >> b
                result = shift_out;
                sign = shift_out[N-1];
            end
        endcase
    end
endmodule
