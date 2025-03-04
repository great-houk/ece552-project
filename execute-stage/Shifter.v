module Shifter (
	output reg [15:0] Shift_Out, // 16-bit shifted output
	input  [15:0] Shift_In, // 16-bit input data
	input  [3:0] Shift_Val, // 4-bit shift amount
	input  [1:0] Mode // Shift Mode: 00 = logical left, 01 = arithmetic right, 10 = rotate
);
	reg [15:0] stage1;

	always @(*) begin
		case (Mode)
			2'b00: begin  // Logical Left Shift
				case (Shift_Val[1:0])  // First stage (shift by 0, 1, 2, or 3)
					2'b00: stage1 = Shift_In;
					2'b01: stage1 = {Shift_In[14:0], 1'b0};
					2'b10: stage1 = {Shift_In[13:0], 2'b00};
					2'b11: stage1 = {Shift_In[12:0], 3'b000};
					default: stage1 = 16'hXXXX;  // Default case (error)
				endcase

				case (Shift_Val[3:2])  // Second stage (shift by 0, 4, 8, or 12)
					2'b00: ShiftOut = stage1;
					2'b01: ShiftOut = {stage1[11:0], 4'h0};
					2'b10: ShiftOut = {stage1[7:0], 8'h0};
					2'b11: ShiftOut = {stage1[3:0], 12'h0};
					default: ShiftOut = 16'hXXXX;  // Default case (error)
				endcase
			end

			2'b01: begin  // Arithmetic Right Shift (preserving sign bit)
				case (Shift_Val[1:0])  // First stage (shift by 0, 1, 2, or 3)
					2'b00: stage1 = Shift_In;
					2'b01: stage1 = {{1{Shift_In[15]}}, Shift_In[15:1]};
					2'b10: stage1 = {{2{Shift_In[15]}}, Shift_In[15:2]};
					2'b11: stage1 = {{3{Shift_In[15]}}, Shift_In[15:3]};
					default: stage1 = 16'hXXXX;  // Default case (error)
				endcase

				case (Shift_Val[3:2])  // Second stage (shift by 0, 4, 8, or 12)
					2'b00: ShiftOut = stage1;
					2'b01: ShiftOut = {{4{Shift_In[15]}}, stage1[15:4]};
					2'b10: ShiftOut = {{8{Shift_In[15]}}, stage1[15:8]};
					2'b11: ShiftOut = {{12{Shift_In[15]}}, stage1[15:12]};
					default: ShiftOut = 16'hXXXX;  // Default case (error)
				endcase
			end

			2'b10: begin  // Rotate Shift
				case (Shift_Val[1:0])  // First stage (shift by 0, 1, 2, or 3)
					2'b00: stage1 = Shift_In;
					2'b01: stage1 = {Shift_In[0], Shift_In[15:1]};
					2'b10: stage1 = {Shift_In[1:0], Shift_In[15:2]};
					2'b11: stage1 = {Shift_In[2:0], Shift_In[15:3]};
					default: stage1 = 16'hXXXX;  // Default case (error)
				endcase

				case (Shift_Val[3:2])  // Second stage (shift by 0, 4, 8, or 12)
					2'b00: ShiftOut = stage1;
					2'b01: ShiftOut = {stage1[3:0], stage1[15:4]};
					2'b10: ShiftOut = {stage1[7:0], stage1[15:8]};
					2'b11: ShiftOut = {stage1[11:0], stage1[15:12]};
					default: ShiftOut = 16'hXXXX;  // Default case (error)
				endcase
			end

			default: ShiftOut = 16'hXXXX;  // Default case (error)
		endcase
	end
endmodule

