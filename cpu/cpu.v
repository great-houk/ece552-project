module cpu(
	input clk, rst_n,
	output hlt,
	output [15:0] pc
);
	//// Five stages of the pipeline
	// Fetch
	fetch_stage fetch_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.next_pc(next_pc),
		// Outputs
		.instruction(instruction),
		.pc(pc),
		.pc_plus2(pc_plus2)
	);
	// Decode
	// Sets control signals (including halt) and reads registers
	decode_stage decode_stage(
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
		// 4 Bit Value
		// 0: src1+src2, 1: src1-src2, 2: src1^src2, 3: src1 << imm[3:0], 4: src1 >> imm[3:0], 5: src1 >>> imm[3:0] (rotate),
		// 8: RED, 9: PADDSB, 10: src1+src2 (no flags), 11: {src1[15:8], imm[7:0]}, 12: {imm[7:0], src1[7:0]}, 13: src1
		.alu_op(alu_op),
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
	// Execute
	// ALU, flag register, and branch addr calculation
	execute_stage execute_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.rs(reg_rs),
		.rt(reg_rt),
		.imm(imm),
		.pc_plus2(pc_plus2),
		.alu_src1(alu_src1),
		.alu_src2(alu_src2),
		.alu_op(alu_op),
		// Outputs
		.alu_result(alu_result),
		.flags(flags) // nzv
	);
	// Memory
	// Read and write to memory
	memory_stage memory_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.addr(alu_result),
		.write_data(reg_rt),
		.mem_write_en(mem_write_en),
		.mem_read_en(mem_read_en),
		// Outputs
		.mem_read(mem_read),
	);
	// Writeback
	// Write to register file, and update PC based on ALU flags
	writeback_stage writeback_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.branch_cond(branch_cond),
		.flags(flags),
		.alu_result(alu_result),
		.mem_read(mem_read),
		.reg_write_src(reg_write_src),

		// Outputs
		.next_pc(next_pc),
		.reg_write_data(reg_write_data),
	);

	// Shared parts of the computer (not in only one stage)
	// Register File
	RegisterFile register_file(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.DstReg(rd),
		.SrcReg1(rs),
		.SrcReg2(rt),
		.DstData(reg_write_data),
		.WriteReg(reg_write_en),
		// Outputs
		.SrcData1(reg_rs),
		.SrcData2(reg_rt)
	);
endmodule