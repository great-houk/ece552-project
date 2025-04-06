module writeback_stage(
	input clk, rst_n,
	input [15:0] alu_result, mem_read,
	input reg_write_src, // 0: ALU, 1: MEM
	input m_reg_write_en,
	input [3:0] m_rd,
	input m_halt,
	output [15:0] reg_write_data,
	output w_reg_write_en,
	output [3:0] w_rd,
	output halt
);
	// Input FFs
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
	dff reg_write_en_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(m_reg_write_en),
		.q(w_reg_write_en),
		.wen(1'b1)
	);
	dff rd_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(m_rd),
		.q(w_rd),
		.wen(1'b1)
	);
	dff halt_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(m_halt),
		.q(halt),
		.wen(1'b1)
	);

	// Assign reg write data
	assign reg_write_data = reg_write_src_ff ? mem_read_ff : alu_result_ff;
endmodule