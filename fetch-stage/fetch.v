module fetch_stage (
	input clk,
	input rst_n,
	input stall,
	input [15:0] next_pc, // Next PC value
	input branching,
	output [15:0] instruction, // Output instruction
	output [15:0] pc_out, // Output PC value
	output [15:0] pc_plus2 //PC+2 value
);
	// Instruction memory
	memory1c_instr imem(.data_out(instruction), .data_in(16'hX), .addr(pc_out), .enable(en), .wr(write), .clk(clk), .rst(~rst_n));

	// PC register
	wire should_inc;
	assign should_inc = branching | (instruction[15:12] != 4'hF); // Don't change PC on halt if not branching
	dff pc_dff [15:0] (.q(pc_out), .d(next_pc), .wen(should_inc | stall), .clk(clk), .rst(~rst_n));

	// Generate PC+2
	cla_16bit pc_plus2_add(.a(pc_out), .b(16'h2), .cin(1'b0), .sum(pc_plus2), .cout());
endmodule