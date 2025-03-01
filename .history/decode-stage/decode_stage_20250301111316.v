module decode_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.instruction(instruction),
		// Outputs
		// Register file read data
		.rd(rd), // Bits 11-8
		.rs(rs), // Bits 7-4
		.rt(rt), // Bits 3-0 (except SW, when it's 11-8)
		// Immediate value
		.imm(imm), // 16 bit value, depends on opcode
		// ALU Control signals
		.alu_op(alu_op), // 4 bit value, look at execute_stage.v for more info
		.alu_src1(alu_src1), // 0: RS, 1: PC+2
		.alu_src2(alu_src2), // 0: RT, 1: IMM
		// Memory Control signals
		.mem_write_en(mem_write_en),
		.mem_read_en(mem_read_en),
		// Register File Control signals
		.reg_write_en(reg_write_en),
		.reg_write_src(reg_write_src), // 0: ALU, 1: MEM
		// Branch Control signals
		.branch_cond(branch_cond),
		// Halt signal
		.halt(halt)
	);