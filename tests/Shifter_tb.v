
module Shifter_tb;

    // 16-bit test signals
    reg [15:0] Shift_In;
    reg [3:0] Shift_Val;
    reg [1:0] Mode;
    wire [15:0] Shift_Out;

    // Instantiate the Shifter module
    Shifter DUT (
        .Shift_Out(Shift_Out),
        .Shift_In(Shift_In),
        .Shift_Val(Shift_Val),
        .Mode(Mode)
    );

    // Task for self-checking test cases
    task check_result;
        input [15:0] expected;
        begin
            #5; // Small delay to stabilize output
            if (Shift_Out !== expected) begin
                $display("TEST FAILED: Mode=%b, Shift_In=%b, Shift_Val=%d, Expected=%b, Got=%b",
                         Mode, Shift_In, Shift_Val, expected, Shift_Out);
            end else begin
                $display("TEST PASSED: Mode=%b, Shift_In=%b, Shift_Val=%d, Result=%b",
                         Mode, Shift_In, Shift_Val, Shift_Out);
            end
        end
    endtask

    // Test process
    initial begin

        // Test 1: Logical Left Shift (SLL)
        Shift_In = 16'b0000_1100_1010_0110; Shift_Val = 4'd3; Mode = 2'b00;
        check_result(16'b0110_0101_0011_0000);

        // Test 2: Arithmetic Right Shift (SRA) with negative number
        Shift_In = 16'b1001_1010_1100_0111; Shift_Val = 4'd2; Mode = 2'b01;
        check_result(16'b1110_0110_1011_0001); // Sign bit should propagate

        // Test 3: Rotate Right (ROR)
        Shift_In = 16'b1100_1010_0110_0001; Shift_Val = 4'd4; Mode = 2'b10;
        check_result(16'b0001_1100_1010_0110);

        // Test 4: Rotate Right (ROR) with 0 shift (no change)
        Shift_In = 16'b1010101010101010; Shift_Val = 4'd0; Mode = 2'b10;
        check_result(16'b1010101010101010); 

        // Test 5: SLL with large shift (should be all zero)
        Shift_In = 16'b0000_1100_1010_0110; Shift_Val = 4'd15; Mode = 2'b00;
        check_result(16'b0000_0000_0000_0000);

        // Test 6: SRA with large shift (should be all sign bits)
        Shift_In = 16'b1001_1010_1100_0111; Shift_Val = 4'd15; Mode = 2'b01;
        check_result(16'b1111_1111_1111_1111);

        // Test 7: ROR with full rotation (should be same as input)
        Shift_In = 16'b1100_1010_0110_0001; Shift_Val = 4'd16; Mode = 2'b10;
        check_result(16'b1100_1010_0110_0001);

        // Test 8: Invalid mode (should return input unchanged)
        Shift_In = 16'b0101_0101_1010_1010; Shift_Val = 4'd4; Mode = 2'b11;
        check_result(16'b0101_0101_1010_1010);

        $display("\nAll tests completed.");
        $finish;
    end

endmodule
