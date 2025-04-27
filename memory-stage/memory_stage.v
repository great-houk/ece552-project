module memory_stage(
	// Inputs
	input clk, rst_n, stall,
	input [15:0] addr, 
	input [15:0] write_data, 
	input e_mem_write_en, e_mem_read_en,
	input [15:0] w_reg_write_data,
	input mem_mem_forwarding,
	// Passthrough
	input [15:0] e_alu_rslt,
	input [3:0] e_rd, e_rs, e_rt,
	input e_reg_write_en, e_reg_write_src,
	input e_halt,
	// Outputs
	output [15:0] m_mem_addr,
	output [15:0] m_mem_write_data,
	output m_mem_read_en, m_mem_write_en,
	// Passthrough
	input [15:0] m_alu_rslt,
	input [3:0] m_rd, m_rs, m_rt,
	input m_reg_write_en, m_reg_write_src,
	input m_halt
);
	// Input FFs
	wire [15:0] mem_forward;
	wire [15:0] addr_ff, write_data_ff;
	dff addr_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(addr),
		.q(addr_ff),
		.wen(~stall)
	);
	dff write_data_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(stall ? mem_forward : write_data),
		.q(write_data_ff),
		.wen(1'b1)
	);
	wire mem_write_en_ff, mem_read_en_ff;
	dff mem_write_en_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(e_mem_write_en),
		.q(mem_write_en_ff),
		.wen(~stall)
	);
	dff mem_read_en_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(e_mem_read_en),
		.q(mem_read_en_ff),
		.wen(~stall)
	);

	// Passthrough FFs
	dff rd_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(e_rd),
		.q(m_rd),
		.wen(~stall)
	);
	dff rs_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(e_rs),
		.q(m_rs),
		.wen(~stall)
	);
	dff rt_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(e_rt),
		.q(m_rt),
		.wen(~stall)
	);
	dff alu_rslt_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(e_alu_rslt),
		.q(m_alu_rslt),
		.wen(~stall)
	);
	wire reg_write_en_ff, halt_ff;
	dff reg_write_en_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(e_reg_write_en),
		.q(reg_write_en_ff),
		.wen(~stall)
	);
	dff reg_write_src_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(e_reg_write_src),
		.q(m_reg_write_src),
		.wen(~stall)
	);
	dff halt_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(e_halt),
		.q(halt_ff),
		.wen(~stall)
	);

	// Stalling outputs
	assign m_reg_write_en = stall ? 1'b0 : reg_write_en_ff;
	assign m_halt = stall ? 1'b0 : halt_ff;

	// Mem-mem forwarding
	assign mem_forward = mem_mem_forwarding ? w_reg_write_data : write_data_ff;

	// Output memory signals
	assign m_mem_addr = addr_ff;
	assign m_mem_write_data = mem_forward;
	assign m_mem_read_en = mem_read_en_ff;
	assign m_mem_write_en = mem_write_en_ff;
endmodule