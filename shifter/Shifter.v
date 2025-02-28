module Shifter(
    output reg [15:0] Shift_Out, // Shifted output
    input [15:0] Shift_In,       // Input data
    input [3:0] Shift_Val,       // 4-bit shift amount
    input [1:0] Mode             // 2-bit mode selection for 4:1 MUX, changed from our 1-bit mode with a 2:1 mux in the HW
);
reg[15:0] in_progress_shift_1, in_progress_shift_2, in_progress_shift_3;
//Adjusted to use a case statement instead a ternary, since it looks cleaner. A ternary would still work though
    always @(*) begin
        case (Mode)
            2'b00: begin //SLL: Logical Left Shift
                in_progress_shift_1 = Shift_Val[0] ? {Shift_In[14:0], 1'b0} : Shift_In; //1 bit shift left
                in_progress_shift_2 = Shift_Val[1] ? {in_progress_shift_1[13:0], 2'b0} : in_progress_shift_1; //2 bit shift left
                in_progress_shift_3 = Shift_Val[2] ? {in_progress_shift_2[11:0], 4'b0} : in_progress_shift_2; //4 bit shift left
                Shift_Out = Shift_Val[3] ? {in_progress_shift_3[7:0], 8'b0} : in_progress_shift_3; //8 bit shift left
            end
            2'b01: begin //SRA: Arithmetic Right Shift
                in_progress_shift_1 = Shift_Val[0] ? {Shift_In[15], Shift_In[15:1]} : Shift_In; //1 bit shift right
                in_progress_shift_2 = Shift_Val[1] ? {{2{Shift_In[15]}}, in_progress_shift_1[15:2]} : in_progress_shift_1; //2 bit shift right
                in_progress_shift_3 = Shift_Val[2] ? {{4{Shift_In[15]}}, in_progress_shift_2[15:4]}  : in_progress_shift_2; //4 bit shift right
                Shift_Out = Shift_Val[3] ? {{8{Shift_In[15]}}, in_progress_shift_3[15:8]} : in_progress_shift_3; //8 bit shift right
            end
            2'b10: begin //ROR: Rotate Right
                in_progress_shift_1 = Shift_Val[0] ? {Shift_In[1], Shift_In[15:1]} : Shift_In; //1 bit rotate right
                in_progress_shift_2 = Shift_Val[1] ? {{in_progress_shift_1[1:0]}, in_progress_shift_1[15:2]} : in_progress_shift_1; //2 bit rotate right
                in_progress_shift_3 = Shift_Val[2] ? {in_progress_shift_2[3:0], in_progress_shift_2[15:4]}  : in_progress_shift_2; //4 bit rotate right
                Shift_Out = Shift_Val[3] ? {in_progress_shift_3[7:0], in_progress_shift_3[15:8]} : in_progress_shift_3; //8 bit rotate right
            end
            default: Shift_Out = Shift_In; //Edge case
        endcase
    end

endmodule

