module Shifter(
    output reg [15:0] Shift_Out, // Shifted output
    input [15:0] Shift_In,       // Input data
    input [3:0] Shift_Val,       // 4-bit shift amount
    input [1:0] Mode             // 2-bit mode selection for 4:1 MUX, changed from our 1-bit mode with a 2:1 mux in the HW
);
//Adjusted to use a case statement instead a ternary, since it looks cleaner. A ternary would still work though
    always @(*) begin
        case (Mode)
            2'b00: Shift_Out = Shift_In << Shift_Val; //SLL: Logical Left Shift
            2'b01: Shift_Out = $signed(Shift_In) >>> Shift_Val; //SRA: Arithmetic Right Shift
            2'b10: Shift_Out = (Shift_In >> Shift_Val) | (Shift_In << (16 - Shift_Val)); //ROR: Rotate Right
            default: Shift_Out = Shift_In; //Edge case
        endcase
    end

endmodule
