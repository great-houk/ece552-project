module decode_stage(
	input wire clk, rst_n, stall,
	input wire [15:0] instruction,
	input wire [15:0] pc_plus2,
	input wire [2:0] flags, // NZV
	input wire [15:0] reg_rs,
	// Outputs
	// Register file read data
	output reg [3:0] rd,  // Bits 11-8
	output reg [3:0] rs,  // Bits 7-4
	output reg [3:0] rt,  // Bits 3-0 (except SW, when it's 11-8)
	output reg [15:0] imm, // Immediate value

	// ALU Control signals
	output reg [3:0] alu_op,  // ALU operation
	output reg alu_src1,	  // 0: RS, 1: PC+2
	output reg alu_src2,	  // 0: RT, 1: IMM

	// Memory Control signals
	output reg mem_write_en,
	output reg mem_read_en,
	// Register File Control signals
	output reg reg_write_en,
	output reg reg_write_src, // 0: ALU, 1: MEM
	// Branch Control signal
	output reg branch,
	output [15:0] next_pc,
	// Halt signal
	output reg halt,
	// Passthrough
	output [15:0] d_pc_plus2,
	output branching
);
	// Input FFs
	wire [15:0] instruction_ff;
	dff instr_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(instruction),
		.q(instruction_ff),
		.wen(stall)
	);

	// Passthrough FFs
	dff pc_plus2_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(f_pc_plus2),
		.q(d_pc_plus2),
		.wen(stall)
	);

	// Decode instruction
	wire [3:0] opcode;
	reg [2:0] branch_cond;
	assign opcode = instruction_ff[15:12];

	always @(*) begin
		// Default values
		rd = instruction_ff[11:8];
		rs = instruction_ff[7:4];
		rt = instruction_ff[3:0];
		imm = {{12{instruction_ff[3]}}, instruction_ff[3:0]}; // Sign extend 4 bit imm

		alu_op = 'x;
		alu_src1 = 'x;
		alu_src2 = 'x;

		mem_write_en = 1'b0;
		mem_read_en = 1'b0;

		reg_write_en = 1'b0;
		reg_write_src = 'x;

		branch = 1'b0;
		branch_cond = 'x;

		halt = 1'b0;

		case (opcode)
			4'b0000: begin // ADD
				alu_op = 4'd0;
				alu_src1 = 0;
				alu_src2 = 0;
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b0001: begin // SUB
				alu_op = 4'd1;
				alu_src1 = 0;
				alu_src2 = 0;
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b0010: begin // XOR
				alu_op = 4'd2;
				alu_src1 = 0;
				alu_src2 = 0;
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b0011: begin // RED
				alu_op = 4'd8;
				alu_src1 = 0;
				alu_src2 = 0;
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b0100: begin // SLL
				alu_op = 4'd4;
				alu_src1 = 0;
				alu_src2 = 1;
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b0101: begin // SRA
				alu_op = 4'd5;
				alu_src1 = 0;
				alu_src2 = 1;
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b0110: begin // ROR
				alu_op = 4'd6;
				alu_src1 = 0;
				alu_src2 = 1;
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b0111: begin // PADDSB
				alu_op = 4'd9;
				alu_src1 = 0;
				alu_src2 = 0;
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b1000: begin // LW 
				alu_op = 4'd10;
				alu_src1 = 0;
				alu_src2 = 1;
				imm = {{11{instruction_ff[3]}}, instruction_ff[3:0], 1'b0}; // 4 bit imm << 1
				reg_write_en = 1;
				reg_write_src = 1;
				mem_read_en = 1;
			end
			4'b1001: begin // SW
				rt = instruction_ff[11:8];
				alu_op = 4'd10;
				alu_src1 = 0;
				alu_src2 = 1;
				imm = {{11{instruction_ff[3]}}, instruction_ff[3:0], 1'b0}; // 4 bit imm << 1
				mem_write_en = 1;
				mem_read_en = 1;//different
			end
			4'b1010: begin // LLB
				rs = instruction_ff[11:8];
				alu_op = 4'd11;
				alu_src1 = 0;
				alu_src2 = 1;
				imm = {8'b0, instruction_ff[7:0]}; // Zero-extend
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b1011: begin // LHB 
				rs = instruction_ff[11:8];
				alu_op = 4'd12;
				alu_src1 = 0;
				alu_src2 = 1;
				imm = {8'b0, instruction_ff[7:0]}; // Zero-extend
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b1100: begin // B
				alu_op = 4'd10; // Add no flags
				alu_src1 = 1; // Use PC+2
				alu_src2 = 1; // Use IMM for calculation
				imm = {{6{instruction_ff[8]}}, instruction_ff[8:0], 1'b0}; // 9 bit imm << 1
				branch_cond = instruction_ff[11:9];
				branch = 1;
			end
			4'b1101: begin // BR
				alu_op = 4'd13; // Pass RS
				alu_src1 = 0;
				branch_cond = instruction_ff[11:9];
				branch = 1;
			end
			4'b1110: begin // PCS
				alu_op = 4'd13;
				alu_src1 = 1;
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b1111: begin // HLT
				halt = 1;
			end
			default: begin
				// Invalid opcode
				rd = 'x;
				rs = 'x;
				rt = 'x;
				imm = 'x;
				alu_op = 'x;
				alu_src1 = 'x;
				alu_src2 = 'x;
				mem_write_en = 'x;
				mem_read_en = 'x;
				reg_write_en = 'x;
				reg_write_src = 'x;
				branch = 'x;
				branch_cond = 'x;
				halt = 'x;
			end
		endcase
	end

	// Branch logic
	reg should_branch;
	wire greater_than;
	assign greater_than = (flags[2] == flags[1]) && (flags[2] == 1'b0);
	// Check if branch condition is met
	always @* begin
		case(branch_cond)
			3'b000: should_branch = flags[1] == 1'b0;							// Not Equal (Z = 0)
			3'b001: should_branch = flags[1] == 1'b1;							// Equal (Z = 1)
			3'b010: should_branch = greater_than;								// Greater Than (Z = N = 0)
			3'b011: should_branch = flags[2] == 1'b1;							// Less Than (N = 1)
			3'b100: should_branch = (flags[1] == 1'b1) | greater_than;			// Greater Than or Equal (Z = 1 or Z = N = 0)
			3'b101: should_branch = (flags[2] == 1'b1) | (flags[1] == 1'b1);	// Less Than or Equal (N = 1 or Z = 1)
			3'b110: should_branch = flags[0] == 1'b1;							// Overflow (V = 1)
			3'b111: should_branch = 1'b1;										// Unconditional
			default: should_branch = 1'bx;										// Default case (error)
		endcase
	end

	// Calculate next PC
	wire [15:0] pc_plus_imm;
	cla_16bit pc_plus_imm_adder (
		.a(pc_plus2_ff),
		.b(imm),
		.cin(1'b0),
		.sum(pc_plus_imm)
	);

	assign branching = branch & should_branch;
	assign next_pc = branching ? (opcode[0] ? reg_rs : pc_plus_imm) : pc_plus2_ff;
endmodule