module memory_stage(
	input clk, rst_n, 
	input [15:0] addr, 
	input [15:0] write_data, 
	input mem_write_en, mem_read_en,
	input [15:0] alu_rslt,
	input [15:0] instruction,
	input [3:0] e_rd, e_rs, e_rt, e_flags,
	input [15:0] instruction_ff, 
	output [15:0] mem_read,
	output [15:0] alu_rslt_out,
	output [3:0] m_rd, m_rs, m_rt, m_flags
);


wire [15:0] mem_alu_ff;
dff mem_alu_ff(
	.clk(clk),
	.rst_n(~rst_n),
	.d(alu_result),
	.q(alu_rslt_out),
	.wen(1'b1)
	);

wire [15:0] pass_through_ff;
dff pass_through_ff(
	.clk(clk),
	.rst_n(~rst_n),
	.d(instruction),
	.q(instruction_ff),
	.wen(1'b1)
	);

	wire [3:0] m_rd, m_rs, m_rd, m_flags;
	dff m_rd(
	.clk(clk),
	.rst_n(~rst_n),
	.d(e_rd),
	.q(m_rd),
	.wen(1'b1)
	);

	dff m_rs(
	.clk(clk),
	.rst_n(~rst_n),
	.d(e_rs),
	.q(m_rs),
	.wen(1'b1)
	);

	dff m_rt(
	.clk(clk),
	.rst_n(~rst_n),
	.d(e_rt),
	.q(m_rt),
	.wen(1'b1)
	);

	dff m_flags(
	.clk(clk),
	.rst_n(~rst_n),
	.d(e_flags),
	.q(m_flags),
	.wen(1'b1)
	);

// Instantiate memory read
memory1c memory_read (
	.clk(clk), 
	.rst(~rst_n), 
	.enable(mem_read_en), 
	.addr(addr), 
	.wr(mem_write_en), 
	.data_in(write_data), 
	.data_out(mem_read)
);
endmodule