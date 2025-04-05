module writeback_stage(
	input clk, rst_n,
	input branch, // Branch signal
	input [2:0] branch_cond, flags, // Flags: NZV
	input [15:0] pc_plus2, alu_result, mem_read,
	input reg_write_src, // 0: ALU, 1: MEM
	output [15:0] next_pc, reg_write_data,
	output branching
);
	// Input FFs
	wire branch_ff;
	dff branch_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(branch),
		.q(branch_ff),
		.wen(1'b1)
	);
	wire [2:0] branch_cond_ff;
	dff branch_cond_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(branch_cond),
		.q(branch_cond_ff),
		.wen(1'b1)
	);
	wire [2:0] flags_ff;
	dff flags_dff [2:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(flags),
		.q(flags_ff),
		.wen(1'b1)
	);
	wire [15:0] pc_plus2_ff;
	dff pc_plus2_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(pc_plus2),
		.q(pc_plus2_ff),
		.wen(1'b1)
	);
	wire [15:0] alu_result_ff;
	dff alu_result_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(alu_result),
		.q(alu_result_ff),
		.wen(1'b1)
	);
	wire [15:0] mem_read_ff;
	dff mem_read_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(mem_read),
		.q(mem_read_ff),
		.wen(1'b1)
	);
	wire reg_write_src_ff;
	dff reg_write_src_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(reg_write_src),
		.q(reg_write_src_ff),
		.wen(1'b1)
	);

	// Assign reg write data
	assign reg_write_data = reg_write_src_ff ? mem_read_ff : alu_result_ff;
endmodule