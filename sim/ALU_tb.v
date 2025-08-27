`timescale 1ns / 1ps

module ALU_tb;
    parameter N = 5;
    parameter TEST_COUNT = 8;
    
    // Inputs
    reg [N-1:0] a;
    reg [N-1:0] b;
    reg [2:0] op;
    
    // Outputs
    wire [N-1:0] result;
    wire sign;
    wire overflow;
    wire status;
    
    // Instantiate the Unit Under Test (UUT)
    ALU #(.N(N)) uut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .sign(sign),
        .overflow(overflow),
        .status(status)
    );
    
    // Test cases
    reg [N-1:0] test_a [0:TEST_COUNT-1];
    reg [N-1:0] test_b [0:TEST_COUNT-1];
    reg [2:0] test_op [0:TEST_COUNT-1];
    reg [N-1:0] expected_result [0:TEST_COUNT-1];
    reg expected_sign [0:TEST_COUNT-1];
    reg expected_overflow [0:TEST_COUNT-1];
    reg expected_status [0:TEST_COUNT-1];
    
    integer i;
    integer errors = 0;
    
    initial begin        
        // Test 0: ADDITION (-5 + 3 = -2)
        test_a[0] = 5'b11011; // -5
        test_b[0] = 5'b00011; // +3
        test_op[0] = 3'b000;
        expected_result[0] = 5'b11110; // -2
        expected_sign[0] = 1'b1;
        expected_overflow[0] = 1'b0;
        
        // Test 1: SUBTRACTION (7 - 3 = 4)
        test_a[1] = 5'b00111; // +7
        test_b[1] = 5'b00011; // +3
        test_op[1] = 3'b001;
        expected_result[1] = 5'b00100; // +4
        expected_sign[1] = 1'b0;
        expected_overflow[1] = 1'b0;
        
        // Test 2: MAX(max(-3, 2) = 2)
        test_a[2] = 5'b11101; // -3
        test_b[2] = 5'b00010; // +2
        test_op[2] = 3'b010;
        expected_result[2] = 5'b00010; // +2
        expected_sign[2] = 1'b0;
        
        // Test 3: COMPARISON (-4 <= 1 = TRUE)
        test_a[3] = 5'b11100; // -4
        test_b[3] = 5'b00001; // +1
        test_op[3] = 3'b011;
        expected_result[3] = 5'b00001; // 1 (true)
        expected_status[3] = 1'b1;
        
        // Test 4: AVERAGE ((-4 + 2)/2 = -1)
        test_a[4] = 5'b11100; // -4
        test_b[4] = 5'b00010; // +2
        test_op[4] = 3'b100;
        expected_result[4] = 5'b11111; // -1
        expected_sign[4] = 1'b1;
        
        // Test 5: SQUARE (-3² = 9)
        test_a[5] = 5'b11101; // -3
        test_b[5] = 5'b00000; // don't care
        test_op[5] = 3'b101;
        expected_result[5] = 5'b01001; // +9
        expected_sign[5] = 1'b0;
        
        // Test 6: ABSOLUTE (|-6| = 6)
        test_a[6] = 5'b11010; // -6
        test_b[6] = 5'b00000; // don't care
        test_op[6] = 3'b110;
        expected_result[6] = 5'b00110; // +6
        expected_sign[6] = 1'b0;
        
        // Test 7: RIGHT SHIFT (-4 >> 1 = -2)
        test_a[7] = 5'b11100; // -4
        test_b[7] = 5'b00001; // shift by 1
        test_op[7] = 3'b111;
        expected_result[7] = 5'b11110; // -2
        expected_sign[7] = 1'b1;
        
        // Run all tests
        for (i = 0; i < TEST_COUNT; i = i + 1) begin
            a = test_a[i];
            b = test_b[i];
            op = test_op[i];
            #20; // Wait for propagation
            
            // Check all outputs for each test
            if (result !== expected_result[i]) begin
                $display("Error test %d: result %b (%d), expected %b (%d)", 
                         i, result, $signed(result), expected_result[i], $signed(expected_result[i]));
                errors = errors + 1;
            end
            
            if (sign !== expected_sign[i]) begin
                $display("Error test %d: sign %b, expected %b", i, sign, expected_sign[i]);
                errors = errors + 1;
            end
            
            // Check overflow only for arithmetic operations
            if ((op == 3'b000 || op == 3'b001) && (overflow !== expected_overflow[i])) begin
                $display("Error test %d: overflow %b, expected %b", i, overflow, expected_overflow[i]);
                errors = errors + 1;
            end
            
            // Check status only for comparison
            if (op == 3'b011 && (status !== expected_status[i])) begin
                $display("Error test %d: status %b, expected %b", i, status, expected_status[i]);
                errors = errors + 1;
            end
        end
        
        // Summary
        if (errors == 0)
            $display("All %d tests passed!", TEST_COUNT);
        else
            $display("%d tests failed", errors);
        
        $finish;
    end
endmodule
