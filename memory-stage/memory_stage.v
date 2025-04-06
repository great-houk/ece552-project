module memory_stage(
	// Inputs
	input clk, rst_n,
	input [15:0] addr, 
	input [15:0] write_data, 
	input mem_write_en, mem_read_en,
	// Passthrough
	input [15:0] e_alu_rslt,
	input [3:0] e_rd, e_rs, e_rt,
	input e_reg_write_en, e_reg_write_src,
	input e_halt,
	// Outputs
	output [15:0] mem_read,
	// Passthrough
	input [15:0] m_alu_rslt,
	input [3:0] m_rd, m_rs, m_rt,
	input m_reg_write_en, m_reg_write_src,
	input m_halt
);
	// Input FFs
	wire [15:0] addr_ff, write_data_ff;
	dff addr_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(addr),
		.q(addr_ff),
		.wen(1'b1)
	);
	dff write_data_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(write_data),
		.q(write_data_ff),
		.wen(1'b1)
	);
	wire mem_write_en_ff, mem_read_en_ff;
	dff mem_write_en_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(mem_write_en),
		.q(mem_write_en_ff),
		.wen(1'b1)
	);
	dff mem_read_en_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(mem_read_en),
		.q(mem_read_en_ff),
		.wen(1'b1)
	);

	// Passthrough FFs
	dff rd_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(e_rd),
		.q(m_rd),
		.wen(1'b1)
	);
	dff rs_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(e_rs),
		.q(m_rs),
		.wen(1'b1)
	);
	dff rt_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(e_rt),
		.q(m_rt),
		.wen(1'b1)
	);
	dff alu_rslt_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(e_alu_rslt),
		.q(m_alu_rslt),
		.wen(1'b1)
	);
	dff reg_write_en_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(e_reg_write_en),
		.q(m_reg_write_en),
		.wen(1'b1)
	);
	dff reg_write_src_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(e_reg_write_src),
		.q(m_reg_write_src),
		.wen(1'b1)
	);
	dff halt_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(e_halt),
		.q(m_halt),
		.wen(1'b1)
	);

	// Instantiate memory read
	memory1c memory_read(
		.clk(clk),
		.rst(~rst_n),
		.enable(mem_read_en_ff),
		.addr(addr_ff),
		.wr(mem_write_en_ff),
		.data_in(write_data_ff),
		.data_out(mem_read)
	);
endmodule