module writeback_stage(
	input clk, rst_n,
	input branch, // Branch signal
	input [2:0] branch_cond, flags, // Flags: NZV
	input [15:0] pc_plus2, alu_result, mem_read,
	input reg_write_src, // 0: ALU, 1: MEM
	output [15:0] next_pc, reg_write_data,
	output branching
);
	// Assign reg write data
	assign reg_write_data = reg_write_src ? mem_read : alu_result;
	// Assign next PC
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

	assign branching = branch & should_branch;
	assign next_pc = branching ? alu_result : pc_plus2;
endmodule