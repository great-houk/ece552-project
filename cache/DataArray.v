
module DataArray(
	input clk,
	input rst,
	input [15:0] DataIn,
	input Write,
	input [6:0] BlockEnable,
	input [2:0] WordEnable,
	output [15:0] DataOut
);
	// Memory array
	reg [15:0] mem [0:127][0:15]; // 128 Blocks, each 16 words

	// Write operation
	integer i, j;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// Reset all memory locations to 0
			for (i = 0; i < 128; i = i + 1) begin
				for (j = 0; j < 16; j = j + 1) begin
					mem[i][j] <= 16'b0;
				end
			end
		end else if (Write) begin
			// Write data to the specified block and word locations
			mem[BlockEnable][WordEnable] <= DataIn;
		end
	end

	assign DataOut = mem[BlockEnable][WordEnable];
endmodule

