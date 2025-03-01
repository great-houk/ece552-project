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
        output reg alu_src1,      // 0: RS, 1: PC+2
        output reg alu_src2,      // 0: RT, 1: IMM

		// Memory Control signals
		output reg mem_write_en,
        output reg mem_read_en,
		// Register File Control signals
		output reg reg_write_en,
        output reg reg_write_src, // 0: ALU, 1: MEM
		// Branch Control signals
		output reg branch_cond,
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
        imm = {{8{instruction[7]}}, instruction[7:0]}; // Sign-extend 8-bit immediate
        alu_op = 4'b0000;
        alu_src1 = 0;
        alu_src2 = 0;
        mem_write_en = 0;
        mem_read_en = 0;
        reg_write_en = 0;
        reg_write_src = 0;
        branch_cond = 0;
        halt = 0;

        case (opcode)
            4'b0000: begin // ADD
                alu_op = 4'b0000;
                reg_write_en = 1;
            end
            4'b0001: begin // SUB
                alu_op = 4'b0001;
                reg_write_en = 1;
            end
            4'b0010: begin // XOR
                alu_op = 4'b0010;
                reg_write_en = 1;
            end
            4'b0011: begin // RED
                alu_op = 4'b0011;
                reg_write_en = 1;
            end
            4'b0100: begin // SLL
                alu_op = 4'b0100;
                reg_write_en = 1;
            end
            4'b0101: begin // SRA
                alu_op = 4'b0101;
                reg_write_en = 1;
            end
            4'b0110: begin // ROR
                alu_op = 4'b0110;
                reg_write_en = 1;
            end
            4'b0111: begin // PADDSB
                alu_op = 4'b0111;
                reg_write_en = 1;
            end
            4'b1000: begin // LW 
                mem_read_en = 1;
                reg_write_en = 1;
                reg_write_src = 1;
                alu_src2 = 1; // Use IMM for address calculation
            end
            4'b1001: begin // SW
                mem_write_en = 1;
                rt = instruction[11:8]; // Special case: rt comes from bits 11-8
                alu_src2 = 1; // Use IMM for address calculation
            end
            4'b1010: begin // LLB
                reg_write_en = 1;
                imm = {8'b0, instruction[7:0]}; // Zero-extend
            end
            4'b1011: begin // LHB 
                reg_write_en = 1;
                imm = {instruction[7:0], 8'b0}; // Shift left
            end
            4'b1100: begin // B
                branch_cond = 1;
                alu_src1 = 1; // Use PC+2
                alu_src2 = 1; // Use IMM for calculation
            end
            4'b1101: begin // BR
                branch_cond = 1;
                alu_op = 4'b1101; // Branch evaluation
            end
            4'b1110: begin // PCS
                alu_op = 4'b1110;
            end
            4'b1111: begin // HLT (Halt)
                halt = 1;
            end
        endcase
    end

endmodule