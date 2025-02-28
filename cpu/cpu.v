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
		.next_pc(pc),
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
		//// Outputs
		// Control Wires
		.reg_write(reg_write),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.mem_to_reg(mem_to_reg),
		.alu_src(alu_src),
		.reg_dst(reg_dst),
		.branch(branch),
		.halt(halt),
		// Registers
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.imm(imm),
		// ALU Control
		.alu_op(alu_op),
	);
	// Execute
	// ALU, flag register, and branch calculation
	execute_stage execute_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.rs1(rs1),
		.rs2(rs2),
		.imm(imm),
		.pc_plus2(pc_plus2),
		.alu_op(alu_op),
		// Outputs
		.alu_result(alu_result),
		.flags(flags)
	);
	// Memory
	// Read and write to memory (sign extending if neccessary)
	memory_stage memory_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.addr(alu_result),
		.data(reg_rt),
		.mem_write(mem_write),
		// Outputs
		.mem_read(mem_read),
	);
	// Writeback
	// Write to register file, and update PC based on ALU flags
	writeback_stage writeback_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		// Other command signals go here
		// Outputs
		.next_pc(next_pc),
		.reg_write_data(reg_write_data),
	);



	// Shared parts of the computer (not in only one stage)
	// Register File
	// Memory
endmodule