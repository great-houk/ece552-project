`default_nettype none

module cpu(
	input wire clk, rst_n,
	output wire hlt,
	output wire [15:0] pc
);
	//// Connections
	// Fetch
	wire [15:0] instruction, pc_plus2;
	// Decode
	wire [3:0] rd, rs, rt;
	wire [15:0] imm;
	wire [3:0] alu_op;
	wire alu_src1, alu_src2;
	wire mem_write_en, mem_read_en;
	wire reg_write_en, reg_write_src;
	wire [2:0] branch_cond;
	wire branch;
	// Execute
	wire [15:0] alu_result;
	wire [2:0] flags; // nzv
	// Memory
	wire [15:0] mem_read;
	// Writeback
	wire [15:0] next_pc, reg_write_data;
	// Register File
	wire [15:0] reg_rs, reg_rt;

	//// Five stages of the pipeline
	// Fetch
	fetch_stage fetch_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.next_pc(next_pc),
		// Outputs
		.instruction(instruction),
		.pc_out(pc),
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
		.branch(branch),
		.branch_cond(branch_cond),
		// Halt signal
		.halt(hlt)
	);
	// Execute
	// ALU, flag register, and branch addr calculation
	execute_stage execute_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.reg_rs(reg_rs),
		.reg_rt(reg_rt),
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
		.rst(!rst_n),
		.addr(alu_result),
		.write_data(reg_rt),
		.mem_write_en(mem_write_en),
		.mem_read_en(mem_read_en),
		// Outputs
		.mem_read(mem_read)
	);
	// Writeback
	// Write to register file, and update PC based on ALU flags
	writeback_stage writeback_stage(
		// Inputs
		.clk(clk),
		.rst_n(rst_n),
		.branch(branch),
		.branch_cond(branch_cond),
		.flags(flags),
		.pc_plus2(pc_plus2),
		.alu_result(alu_result),
		.mem_read(mem_read),
		.reg_write_src(reg_write_src),
		// Outputs
		.next_pc(next_pc),
		.reg_write_data(reg_write_data)
	);

	// Shared parts of the computer (not in only one stage)
	// Register File
	RegisterFile register_file(
		// Inputs
		.clk(clk),
		.rst(!rst_n),
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

`default_nettype wire