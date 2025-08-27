module top_module #(parameter N=5) (
    input wire clk,
    input wire [N-1:0] a, b,
    input wire [2:0] op,
    output wire [6:0] seg,
    output wire dp,
    output wire [3:0] an,
    output wire status_led,
    output wire overflow_led
);

    // Internal connections
    wire [N-1:0] result;
    wire sign, overflow, status;
    wire [6:0] seg_unidade, seg_dezena, seg_sinal;
    
    // ALU instance
    ALU #(.N(N)) u_alu (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .sign(sign),
        .overflow(overflow),
        .status(status)
    );
    
    // Display controller instance
    display_controller #(.N(N)) u_display (
        .num(result),
        .negative(sign),
        .seg_unidade(seg_unidade),
        .seg_dezena(seg_dezena), 
        .seg_sinal(seg_sinal)
    );
    
    // Clock divider for display multiplexing
    reg [19:0] counter;
    always @(posedge clk) counter <= counter + 1;
    wire [1:0] sel = counter[19:18];

    // Anode control with multiplexing
    assign an = (sel == 2'b00) ? 4'b1110 : // Display 0 active (units)
                (sel == 2'b01) ? 4'b1101 : // Display 1 active (tens)
                (sel == 2'b10) ? 4'b1011 : // Display 2 active (sign)
                4'b1111;                   // Display 3 off

    // Multiplexer for the segments
    assign seg = (sel == 2'b00) ? seg_unidade :
                 (sel == 2'b01) ? seg_dezena :
                 (sel == 2'b10) ? seg_sinal :
                 7'b1111111;
    
    // LEDs
    assign status_led = status;
    assign overflow_led = overflow;
    
    // Decimal point always off
    assign dp = 1'b1;
endmodule
