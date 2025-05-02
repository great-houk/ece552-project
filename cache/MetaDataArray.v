module MetaDataArray(
	input clk,
	input rst,
	input [7:0] DataIn,
	input Write,
	input [6:0] BlockEnable,
	output [7:0] DataOut
);
	// Memory array
	reg [7:0] mem [0:127]; // 128 Blocks, each 16 words

	// Write operation
	integer i;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// Reset all memory locations to 0
			for (i = 0; i < 128; i = i + 1) begin
				mem[i] <= 8'b0;
			end
		end else if (Write) begin
			// Write data to the specified block and word locations
			mem[BlockEnable] <= DataIn;
		end
	end

	assign DataOut = mem[BlockEnable];
endmodule

