module writeback_stage(
	input clk, rst_n,
	input branch, // Branch signal
	input [2:0] branch_cond, flags, // Flags: NZV
	input [15:0] pc_plus2, alu_result, mem_read,
	input reg_write_src, // 0: ALU, 1: MEM
	output [15:0] next_pc, reg_write_data,
	output branching
);
	// Input FFs
	wire branch_ff;
	dff branch_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(branch),
		.q(branch_ff),
		.wen(1'b1)
	);
	wire [2:0] branch_cond_ff;
	dff branch_cond_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(branch_cond),
		.q(branch_cond_ff),
		.wen(1'b1)
	);
	wire [2:0] flags_ff;
	dff flags_dff [2:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(flags),
		.q(flags_ff),
		.wen(1'b1)
	);
	wire [15:0] pc_plus2_ff;
	dff pc_plus2_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(pc_plus2),
		.q(pc_plus2_ff),
		.wen(1'b1)
	);
	wire [15:0] alu_result_ff;
	dff alu_result_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(alu_result),
		.q(alu_result_ff),
		.wen(1'b1)
	);
	wire [15:0] mem_read_ff;
	dff mem_read_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(mem_read),
		.q(mem_read_ff),
		.wen(1'b1)
	);
	wire reg_write_src_ff;
	dff reg_write_src_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(reg_write_src),
		.q(reg_write_src_ff),
		.wen(1'b1)
	);

	// Assign reg write data
	assign reg_write_data = reg_write_src_ff ? mem_read_ff : alu_result_ff;
	// Assign next PC
	reg should_branch;
	wire greater_than;
	assign greater_than = (flags_ff[2] == flags_ff[1]) && (flags_ff[2] == 1'b0);

	


	// Check if branch condition is met
	always @* begin
		case(branch_cond_ff)
			3'b000: should_branch = flags_ff[1] == 1'b0;							// Not Equal (Z = 0)
			3'b001: should_branch = flags_ff[1] == 1'b1;							// Equal (Z = 1)
			3'b010: should_branch = greater_than;								// Greater Than (Z = N = 0)
			3'b011: should_branch = flags_ff[2] == 1'b1;							// Less Than (N = 1)
			3'b100: should_branch = (flags_ff[1] == 1'b1) | greater_than;			// Greater Than or Equal (Z = 1 or Z = N = 0)
			3'b101: should_branch = (flags_ff[2] == 1'b1) | (flags_ff[1] == 1'b1);	// Less Than or Equal (N = 1 or Z = 1)
			3'b110: should_branch = flags_ff[0] == 1'b1;							// Overflow (V = 1)
			3'b111: should_branch = 1'b1;										// Unconditional
			default: should_branch = 1'bx;										// Default case (error)
		endcase
	end

	assign branching = branch_ff & should_branch;
	assign next_pc = branching ? alu_result_ff : pc_plus2_ff;
endmodule