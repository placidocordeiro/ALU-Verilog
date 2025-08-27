module display_controller #(parameter N=5) (
    input wire [N-1:0] num,
    input wire negative,
    output wire [6:0] seg_unidade,
    output wire [6:0] seg_dezena,
    output wire [6:0] seg_sinal
);

    wire [3:0] dez_bcd, uni_bcd;
    
    // Conversion to BCD
    wire [4:0] abs_num = negative ? -num : num;
    assign dez_bcd = (abs_num >= 10) ? 4'd1 : 4'd0;
    assign uni_bcd = (abs_num >= 10) ? abs_num - 10 : abs_num;
    
    // Decoders
    decoder_7seg u_dec_uni (.bcd(uni_bcd), .seg(seg_unidade));
    decoder_7seg u_dec_dez (.bcd(dez_bcd), .seg(seg_dezena));
    
    // Signal display (-)
    assign seg_sinal = negative ? 7'b0111111 : 7'b1111111;
endmodule
