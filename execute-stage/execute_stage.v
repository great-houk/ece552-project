module execute_stage(
	// Inputs
	input clk, rst_n,
	input [15:0] reg_rs, reg_rt, imm, pc_plus2,
	input alu_src1, alu_src2,
	input [3:0] alu_op,
	// Outputs
	output [15:0] alu_result,
	output [2:0] flags // nzv
);
	// Assign sources
	wire [15:0] alu_src1_data, alu_src2_data;
	assign alu_src1_data = alu_src1 ? pc_plus2 : reg_rs;
	assign alu_src2_data = alu_src2 ? imm : reg_rt;

	// Calculate possible ALU results
	wire [15:0] adder_res, adder_sat;
	wire adder_cout, should_sat;
	cla_16bit cla(
		.a(alu_src1_data),
		.b(alu_op[0] ? (alu_src2_data) : (~alu_src2_data)),
		.cin(alu_op[0]),
		.sum(adder_res),
		.cout(adder_cout)
	);
	assign should_sat = (alu_src1_data[15] == (alu_src2_data[15] ^ alu_op[0])) && (alu_src1_data[15] != adder_res[15]);
	assign adder_sat = should_sat ? (adder_res[15] ? 16'h7FFF : 16'h8000) : adder_res;

	// Calculate ALU result
	always(*) begin
		// 0: src1+src2, 1: src1-src2, 2: src1^src2, 3: src1 << imm[3:0], 4: src1 >> imm[3:0], 5: src1 >>> imm[3:0] (rotate),
		// 8: RED, 9: PADDSB, 10: src1+src2 (no flags), 11: {src1[15:8], imm[7:0]}, 12: {imm[7:0], src1[7:0]}, 13: src1
		case (alu_op)

			default: alu_result = 16'hXXXX;
		endcase
	end
endmodule