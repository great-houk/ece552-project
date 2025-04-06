
module ReadDecoder_4_16(
	input [3:0] RegId,
	output [15:0] Wordline
);
	Shifter shifter(
		.Shift_Out(Wordline),
		.Shift_In(16'b1),
		.Shift_Val(RegId),
		.Mode(2'b00)
	);
endmodule

module WriteDecoder_4_16(input [3:0] RegId, input WriteReg, output [15:0] Wordline);
	Shifter shifter(
		.Shift_Out(Wordline),
		.Shift_In({15'b0, WriteReg}),
		.Shift_Val(RegId),
		.Mode(2'b00)
	);
endmodule

module BitCell(
	input clk, rst,
	input D, WriteEnable, ReadEnable1, ReadEnable2,
	inout Bitline1, Bitline2
);
	dff ff(.q(Q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));
	assign Bitline1 = ReadEnable1 ? Q : 1'bz;
	assign Bitline2 = ReadEnable2 ? Q : 1'bz;
endmodule

module Register(
	input clk, rst,
	input [15:0] D,
	input WriteReg, ReadEnable1, ReadEnable2,
	inout [15:0] Bitline1, Bitline2
);
	wire [15:0] read1, read2;
	BitCell bitcells [15:0] (clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, read1, read2);
	assign Bitline1 = (WriteReg & ReadEnable1) ? D : read1;
	assign Bitline2 = (WriteReg & ReadEnable2) ? D : read2;
endmodule

module RegisterFile(
	input clk, rst,
	input [3:0] SrcReg1, SrcReg2, DstReg,
	input [15:0] DstData,
	input WriteReg,
	inout [15:0] SrcData1, SrcData2
);
	wire [15:0] read_wordline1, read_wordline2, write_wordline;
	wire [15:0] bitline1, bitline2;

	ReadDecoder_4_16 read_decoder1(SrcReg1, read_wordline1);
	ReadDecoder_4_16 read_decoder2(SrcReg2, read_wordline2);
	WriteDecoder_4_16 write_decoder(DstReg, WriteReg, write_wordline);

	Register regs [15:1] (
		.clk(clk), .rst(rst),
		.D(DstData),
		.WriteReg(write_wordline[15:1]), .ReadEnable1(read_wordline1[15:1]), .ReadEnable2(read_wordline2[15:1]),
		.Bitline1(bitline1), .Bitline2(bitline2)
	);

	assign SrcData1 = read_wordline1[0] ? 16'h0: bitline1;
	assign SrcData2 = read_wordline2[0] ? 16'h0: bitline2;
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

