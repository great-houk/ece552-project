module RegisterFile(
	input clk, rst,
	input [3:0] SrcReg1, SrcReg2, DstReg,
	input [15:0] DstData,
	input WriteReg,
	inout [15:0] SrcData1, SrcData2
);
	reg [15:0] regs [15:0];

	integer i;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// Reset all registers to 0
			for (i = 0; i < 16; i = i + 1) begin
				regs[i] <= 16'b0;
			end
		end else if (WriteReg && DstReg != 4'b0000) begin
			// Write data to the destination register if it's not zero
			regs[DstReg] <= DstData;
		end
	end

	assign SrcData1 = (DstReg == SrcReg1 && WriteReg) ? DstData : regs[SrcReg1];
	assign SrcData2 = (DstReg == SrcReg2 && WriteReg) ? DstData : regs[SrcReg2];
endmodule

module RegisterFile_tb();
	reg clk, rst;
	reg [3:0] SrcReg1, SrcReg2, DstReg;
	reg [15:0] DstData;
	reg WriteReg;
	wire [15:0] SrcData1, SrcData2;

	RegisterFile DUT(
		.clk(clk), .rst(rst),
		.SrcReg1(SrcReg1), .SrcReg2(SrcReg2), .DstReg(DstReg),
		.DstData(DstData), .WriteReg(WriteReg),
		.SrcData1(SrcData1), .SrcData2(SrcData2)
	);

	initial begin
		// Initialize signals
		clk = 0;
		rst = 1;
		SrcReg1 = 0;
		SrcReg2 = 0;
		DstReg = 0;
		DstData = 0;
		WriteReg = 0;

		// Reset the RegisterFile
		@(negedge clk);
		rst = 0;

		// Write data to register 1
		@(negedge clk);
		DstReg = 4'b0001;
		DstData = 16'hA5A5;
		WriteReg = 1;
		@(negedge clk);
		WriteReg = 0;

		// Read data from register 1
		@(negedge clk);
		SrcReg1 = 4'b0001;
		@(negedge clk);
		if (SrcData1 !== 16'hA5A5) 
			$display("Test failed: Expected 16'hA5A5, got %h", SrcData1);
		else 
			$display("Test passed: Read 16'hA5A5 from register 1");

		// Write data to register 2
		@(negedge clk);
		DstReg = 4'b0010;
		DstData = 16'h5A5A;
		WriteReg = 1;
		@(negedge clk);
		WriteReg = 0;

		// Read data from register 2
		@(negedge clk);
		SrcReg2 = 4'b0010;
		@(negedge clk);
		if (SrcData2 !== 16'h5A5A) 
			$display("Test failed: Expected 16'h5A5A, got %h", SrcData2);
		else 
			$display("Test passed: Read 16'h5A5A from register 2");

		// Test read+write bypass
		@(negedge clk);
		DstReg = 4'b0011;
		DstData = 16'h3C3C;
		WriteReg = 1;
		SrcReg1 = 4'b0011;
		#1;
		if (SrcData1 !== 16'h3C3C) 
			$display("Test failed: Expected 16'h3C3C, got %h", SrcData1);
		else 
			$display("Test passed: Read+Write bypass working");

		// Finish simulation
		@(negedge clk);
		$stop();
	end

	// Clock generation
	always #5 clk = ~clk;
endmodule

