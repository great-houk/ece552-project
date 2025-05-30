module fetch_stage (
	input clk, rst_n, stall,
	input [15:0] next_pc, // Next PC value
	input branching,
	input [15:0] instr_data,
	output [15:0] instruction, // Output instruction
	output [15:0] pc_out, // Output PC value
	output [15:0] pc_plus2 //PC+2 value
);
	// Instruction memory
	assign instruction = stall ? 16'hE000 : instr_data;

	// PC register
	wire should_inc;
	// Don't change PC on stall or halt if not branching
	assign should_inc = branching | ~((instruction[15:12] == 4'hF) | stall);
	dff pc_dff [15:0] (.q(pc_out), .d(next_pc), .wen(should_inc), .clk(clk), .rst(~rst_n));

	// Generate PC+2
	cla_16bit pc_plus2_add(.a(pc_out), .b(16'h2), .cin(1'b0), .sum(pc_plus2), .cout());
endmodule