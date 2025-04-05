`default_nettype none

module cpu(
	input wire clk, rst_n,
	output wire hlt,
	output wire [15:0] pc
);
	//// Connections
	// Fetch outputs
	wire [15:0] f_instruction, f_pc_plus2;
	// Decode outputs
	wire [3:0] d_rd, d_rs, d_rt;
	wire [15:0] d_imm;
	wire [3:0] d_alu_op;
	wire d_alu_src1, d_alu_src2;
	wire d_mem_write_en, d_mem_read_en;
	wire d_reg_write_en, d_reg_write_src;
	wire d_branch;
	wire [15:0] d_next_pc;
	wire [15:0] d_pc_plus2;
	// Register File outputs
	wire [15:0] d_reg_rs, d_reg_rt;
	// Execute outputs
	wire [15:0] e_alu_result;
	wire [2:0] e_flags; // nzv
	wire [3:0] e_rd, e_rs, e_rt;
	wire [15:0] e_reg_rt;
	wire e_mem_write_en, e_mem_read_en;
	wire e_reg_write_en, e_reg_write_src;
	// Memory outputs
	wire [15:0] m_mem_read;
	wire [15:0] m_alu_result;
	wire [3:0] m_rd, m_rs, m_rt;
	wire m_reg_write_en, m_reg_write_src;
	// Writeback outputs
	wire [15:0] w_reg_write_data;
	wire w_reg_write_en;
	wire [3:0] w_rd;
	wire stall;
	//// Five stages of the pipeline
	// Fetch
	fetch_stage fetch_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.stall(stall),
		.next_pc(d_next_pc),
		.branching(d_branch),
		// Outputs
		.instruction(f_instruction),
		.pc_out(pc),
		.pc_plus2(f_pc_plus2)
	);
	// Decode
	// Sets control signals (including halt) and reads registers
	decode_stage decode_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.stall(stall),
		.instruction(f_instruction),
		.pc_plus2(f_pc_plus2),
		.reg_rs(d_reg_rs),
		// Outputs
		// Register file read data
		.rd(d_rd), // Bits 11-8
		.rs(d_rs), // Bits 7-4
		.rt(d_rt), // Bits 3-0 (except SW, when it's 11-8)
		// Immediate value
		.imm(d_imm), // 16 bit value, depends on opcode
		// ALU Control signals
		.alu_op(d_alu_op), // 4 bit value, look at execute_stage.v for more info
		.alu_src1(d_alu_src1), // 0: RS, 1: PC+2
		.alu_src2(d_alu_src2), // 0: RT, 1: IMM
		// Memory Control signals
		.mem_write_en(d_mem_write_en),
		.mem_read_en(d_mem_read_en),
		// Register File Control signals
		.reg_write_en(d_reg_write_en),
		.reg_write_src(d_reg_write_src), // 0: ALU, 1: MEM
		// Branch logic signals
		.branch(d_branch),
		.next_pc(d_next_pc),
		// Halt signal
		.halt(hlt),
		// Passthrough
		.d_pc_plus2(d_pc_plus2)
	);

	//Detection_unit
	detection_unit detection_unit(
		//Inputs
		.curr_rs(d_rs),
		.curr_rt(d_rt),
		.e_rd(e_rd),
		.m_rd(m_rd),
		.alu_op(d_alu_op),
		.branch(),

	);


	// Execute
	// ALU, flag register, and branch addr calculation
	execute_stage execute_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.reg_rs(d_reg_rs),
		.reg_rt(d_reg_rt),
		.imm(d_imm),
		.pc_plus2(d_pc_plus2),
		.alu_src1(d_alu_src1),
		.alu_src2(d_alu_src2),
		.alu_op(d_alu_op),
		// Passthrough
		.d_rd(d_rd),
		.d_rs(d_rs),
		.d_rt(d_rt),
		.d_reg_rt(d_reg_rt),
		.d_mem_write_en(d_mem_write_en),
		.d_mem_read_en(d_mem_read_en),
		.d_reg_write_en(d_reg_write_en),
		.d_reg_write_src(d_reg_write_src),
		.d_pc_plus2(d_pc_plus2),
		// Outputs
		.alu_result(e_alu_result),
		.flags(e_flags), // nzv
		// Passthrough
		.e_rd(e_rd),
		.e_rs(e_rs),
		.e_rt(e_rt),
		.e_reg_rt(e_reg_rt),
		.e_mem_write_en(e_mem_write_en),
		.e_mem_read_en(e_mem_read_en),
		.e_reg_write_en(e_reg_write_en),
		.e_reg_write_src(e_reg_write_src)
	);
	// Memory
	// Read and write to memory
	memory_stage memory_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.addr(e_alu_result),
		.write_data(e_reg_rt),
		.mem_write_en(e_mem_write_en),
		.mem_read_en(e_mem_read_en),
		//Passthrough
		.e_rd(e_rd),
		.e_rs(e_rs),
		.e_rt(e_rt),
		.e_alu_rslt(e_alu_result),
		.e_reg_write_en(e_reg_write_en),
		.e_reg_write_src(e_reg_write_src),
		// Outputs
		.mem_read(m_mem_read),
		// Passthrough
		.m_rd(m_rd),
		.m_rs(m_rs),
		.m_rt(m_rt),
		.m_alu_rslt(m_alu_result),
		.m_reg_write_en(m_reg_write_en),
		.m_reg_write_src(m_reg_write_src)
	);
	// Writeback
	// Write to register file, and update PC based on ALU flags
	writeback_stage writeback_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.alu_result(m_alu_result),
		.mem_read(m_mem_read),
		.reg_write_src(m_reg_write_src),
		// Passthrough
		.m_reg_write_en(m_reg_write_en),
		.m_rd(m_rd),
		// Outputs
		.reg_write_data(w_reg_write_data),
		// Passthrough
		.w_reg_write_en(w_reg_write_en),
		.w_rd(w_rd)
	);

	// Shared parts of the computer (not in only one stage)
	// Register File
	RegisterFile register_file(
		// Inputs
		.clk(clk),
		.rst(~rst_n),
		.DstReg(w_rd),
		.SrcReg1(d_rs),
		.SrcReg2(d_rt),
		.DstData(w_reg_write_data),
		.WriteReg(w_reg_write_en),
		// Outputs
		.SrcData1(d_reg_rs),
		.SrcData2(d_reg_rt)
	);
endmodule

`default_nettype wire