 module detection_unit(
	// Inputs
	input clk,
	input rst_n,
	input e_reg_write_en,
	input e_reg_write_src,
	input e_flag_update,
	input m_reg_write_en,
	input m_reg_write_src,
	input w_reg_write_en,
	input [3:0] d_opcode,
	input d_branching,
	input [3:0] d_rs, d_rt,
	input [3:0] e_rd, e_rs, e_rt,
	input [3:0] m_rd, m_rt,
	input [3:0] w_rd,
	// Outputs
	output stall, flush,
	output [1:0] ex_ex_forwarding,
	output [1:0] ex_mem_forwarding,
	output mem_mem_forwarding
);
	// Stall signal
	wire branch;
	assign branch = (d_opcode == 4'b1100) | (d_opcode == 4'b1101);
	assign stall = (e_flag_update & branch) | 
		(e_reg_write_src & e_reg_write_en & (e_rd == d_rs | e_rd == d_rt) & (e_rd != 4'b0000));
	
	// Flush signal
	assign flush = d_branching;

	// Forwarding signals
	wire ex_ex, ex_mem;

	// EX-EX Forwarding
	assign ex_ex = m_reg_write_en & (m_reg_write_src == 1'b0) & (e_rd != 4'b0000);
	assign ex_ex_forwarding = {
		ex_ex & m_rd == e_rt,
		ex_ex & m_rd == e_rs
	};

	// EX-MEM Forwarding
	assign ex_mem = w_reg_write_en & (w_rd != 4'b0000);
	assign ex_mem_forwarding = {
		ex_mem & w_rd == e_rt,
		ex_mem & w_rd == e_rs
	};

	// MEM-MEM Forwarding
	assign mem_mem_forwarding = w_reg_write_en & (w_rd != 4'b0000) & (w_rd == m_rt);
endmodule