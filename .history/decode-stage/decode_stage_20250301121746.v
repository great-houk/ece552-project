module decode_stage(
		input wire clk, rst_n,
        input wire [15:0] instruction,
		// Outputs
		// Register file read data
		output reg [3:0] rd,  // Bits 11-8
        output reg [3:0] rs,  // Bits 7-4
        output reg [3:0] rt,  // Bits 3-0 (except SW, when it's 11-8)
     output reg [15:0] imm, // Immediate value
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


endmodule