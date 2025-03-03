module decode_stage(
		input wire clk, rst_n,
		input wire [15:0] instruction,
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
		// Branch Control signals
		output reg [2:0] branch_cond,
		output reg branch,
		// Halt signal
		output reg halt
	);


	wire [3:0] opcode;
	assign opcode = instruction[15:12];

	always @(*) begin
		// Default values
		rd = instruction[11:8];
		rs = instruction[7:4];
		rt = instruction[3:0];
		imm = {{12{instruction[3]}}, instruction[3:0]}; // Sign extend 4 bit imm

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
				imm = {{11{instruction[3]}}, instruction[3:0], 1'b0}; // 4 bit imm << 1
				reg_write_en = 1;
				reg_write_src = 1;
				mem_read_en = 1;
			end
			4'b1001: begin // SW
				rt = instruction[11:8];
				alu_op = 4'd10;
				alu_src1 = 0;
				alu_src2 = 1;
				imm = {{11{instruction[3]}}, instruction[3:0], 1'b0}; // 4 bit imm << 1
				mem_write_en = 1;
			end
			4'b1010: begin // LLB
				alu_op = 4'd11;
				alu_src1 = 0;
				alu_src2 = 1;
				imm = {8'b0, instruction[7:0]}; // Zero-extend
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b1011: begin // LHB 
				alu_op = 4'd12;
				alu_src1 = 0;
				alu_src2 = 1;
				imm = {8'b0, instruction[7:0]}; // Zero-extend
				reg_write_en = 1;
				reg_write_src = 0;
			end
			4'b1100: begin // B
				alu_op = 4'd10; // Add no flags
				alu_src1 = 1; // Use PC+2
				alu_src2 = 1; // Use IMM for calculation
				imm = {{6{instruction[8]}}, instruction[8:0], 1'b0}; // 9 bit imm << 1
				branch_cond = instruction[11:9];
				branch = 1;
			end
			4'b1101: begin // BR
				alu_op = 4'd10; // Add no flags
				alu_src1 = 1; // Use PC+2
				alu_src2 = 0; // Use RS
				branch_cond = instruction[11:9];
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
		endcase
	end

endmodule