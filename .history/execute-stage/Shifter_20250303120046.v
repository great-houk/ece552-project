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


module shifter (
    input  [15:0] data_in,   // 16-bit input data
    input  [3:0] shift_val,  // 4-bit shift amount
    input  [1:0] mode,       // Shift mode: 00 = logical left, 01 = logical right, 10 = arithmetic right, 11 = rotate
    output reg [15:0] data_out  // 16-bit shifted output
);
    reg [15:0] stage1, stage2;

    always @(*) begin
        case (mode)
            2'b00: begin  // Logical Left Shift
                case (shift_val[1:0])  // First stage (shift by 0, 1, 2, or 3)
                    2'b00: stage1 = data_in;
                    2'b01: stage1 = {data_in[14:0], 1'b0};
                    2'b10: stage1 = {data_in[13:0], 2'b00};
                    2'b11: stage1 = {data_in[12:0], 3'b000};
                endcase

                case (shift_val[3:2])  // Second stage (shift by 0, 4, 8, or 12)
                    2'b00: stage2 = stage1;
                    2'b01: stage2 = {stage1[11:0], 4'b0000};
                    2'b10: stage2 = {stage1[7:0], 8'b00000000};
                    2'b11: stage2 = 16'b0;
                endcase
            end

            2'b01: begin  // Logical Right Shift
                case (shift_val[1:0])  // First stage (shift by 0, 1, 2, or 3)
                    2'b00: stage1 = data_in;
                    2'b01: stage1 = {1'b0, data_in[15:1]};
                    2'b10: stage1 = {2'b00, data_in[15:2]};
                    2'b11: stage1 = {3'b000, data_in[15:3]};
                endcase

                case (shift_val[3:2])  // Second stage (shift by 0, 4, 8, or 12)
                    2'b00: stage2 = stage1;
                    2'b01: stage2 = {4'b0000, stage1[15:4]};
                    2'b10: stage2 = {8'b00000000, stage1[15:8]};
                    2'b11: stage2 = 16'b0;
                endcase
            end

            2'b10: begin  // Arithmetic Right Shift (preserving sign bit)
                case (shift_val[1:0])  // First stage (shift by 0, 1, 2, or 3)
                    2'b00: stage1 = data_in;
                    2'b01: stage1 = {{1{data_in[15]}}, data_in[15:1]};
                    2'b10: stage1 = {{2{data_in[15]}}, data_in[15:2]};
                    2'b11: stage1 = {{3{data_in[15]}}, data_in[15:3]};
                endcase

                case (shift_val[3:2])  // Second stage (shift by 0, 4, 8, or 12)
                    2'b00: stage2 = stage1;
                    2'b01: stage2 = {{4{data_in[15]}}, stage1[15:4]};
                    2'b10: stage2 = {{8{data_in[15]}}, stage1[15:8]};
                    2'b11: stage2 = {16{data_in[15]}};
                endcase
            end

            2'b11: begin  // Rotate Shift
                case (shift_val[1:0])  // First stage (shift by 0, 1, 2, or 3)
                    2'b00: stage1 = data_in;
                    2'b01: stage1 = {data_in[0], data_in[15:1]};
                    2'b10: stage1 = {data_in[1:0], data_in[15:2]};
                    2'b11: stage1 = {data_in[2:0], data_in[15:3]};
                endcase

                case (shift_val[3:2])  // Second stage (shift by 0, 4, 8, or 12)
                    2'b00: stage2 = stage1;
                    2'b01: stage2 = {stage1[3:0], stage1[15:4]};
                    2'b10: stage2 = {stage1[7:0], stage1[15:8]};
                    2'b11: stage2 = {stage1[11:0], stage1[15:12]};
                endcase
            end

            default: stage2 = data_in;  // Default case (no shift)
        endcase

        data_out = stage2;  // Final output
    end
endmodule

