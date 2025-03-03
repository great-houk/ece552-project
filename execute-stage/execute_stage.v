module execute_stage(
	// Inputs
	input clk, rst_n,
	input [15:0] reg_rs, reg_rt, imm, pc_plus2,
	input alu_src1, alu_src2,
	input [3:0] alu_op,
	// Outputs
	output reg [15:0] alu_result,
	output [2:0] flags // nzv
);
	// Assign sources
	wire [15:0] alu_src1_data, alu_src2_data;
	assign alu_src1_data = alu_src1 ? pc_plus2 : reg_rs;
	assign alu_src2_data = alu_src2 ? imm : reg_rt;

	// Calculate possible ALU results
	// Add/sub
	wire [15:0] adder_res, adder_sat;
	wire adder_cout, should_sat;
	cla_16bit cla(
		.a(alu_src1_data),
		.b(alu_op[0] ? (~alu_src2_data) : (alu_src2_data)),
		.cin(alu_op[0]),
		.sum(adder_res),
		.cout(adder_cout)
	);
	assign should_sat = (alu_src1_data[15] == (alu_src2_data[15] ^ alu_op[0])) && (alu_src1_data[15] != adder_res[15]);
	assign adder_sat = should_sat ? (adder_res[15] ? 16'h7FFF : 16'h8000) : adder_res;

	// Shifter
	wire [15:0] shifter_res;
	Shifter shifter(
		.Shift_Out(shifter_res),
		.Shift_In(alu_src1_data),
		.Shift_Val(alu_src2_data[3:0]),
		.Mode(alu_op[1:0])
	);

	// Reduce
	wire [15:0] reduction_res;
	reduction_unit reduction_unit(
		.rs(alu_src1_data),
		.rt(alu_src2_data),
		.rd(reduction_res)
	);

	// Parallel Adder
	wire [15:0] psa_adder_res;
	PSA_16bit PSA(
		.A(alu_src1_data),
		.B(alu_src2_data),
		.Sum(psa_adder_res)
	);

	// Calculate ALU result
	always @(*) begin
		// 0: src1+src2, 1: src1-src2, 2: src1^src2, 4: src1 << imm[3:0], 5: src1 >> imm[3:0], 6: src1 >>> imm[3:0] (rotate),
		// 8: RED, 9: PADDSB, 10: src1+src2 (no flags), 11: {src1[15:8], imm[7:0]}, 12: {imm[7:0], src1[7:0]}, 13: src1
		case (alu_op)
			4'h0: alu_result = adder_res; // src1+src2
			4'h1: alu_result = adder_sat; // src1-src2
			4'h2: alu_result = alu_src1_data ^ alu_src2_data; // src1^src2
			4'h4: alu_result = shifter_res; // src1 << imm[3:0]
			4'h5: alu_result = shifter_res; // src1 >> imm[3:0]
			4'h6: alu_result = shifter_res; // src1 >>> imm[3:0] (rotate)
			4'h8: alu_result = reduction_res; // RED
			4'h9: alu_result = psa_adder_res; // PADDSB
			4'hA: alu_result = adder_res; // src1+src2 (no flags)
			4'hB: alu_result = {alu_src1_data[15:8], alu_src2_data[7:0]}; // {src1[15:8], imm[7:0]}
			4'hC: alu_result = {alu_src2_data[7:0], alu_src1_data[7:0]}; // {imm[7:0], src1[7:0]}
			4'hD: alu_result = alu_src1_data; // src1
			default: alu_result = 16'hXXXX;
		endcase
	end

	// Set flags
	wire [2:0] potential_flags, new_flags;
	assign potential_flags = {alu_result[15], alu_result == 16'h0, should_sat};
	assign new_flags = alu_op[3] ? flags : (alu_op[2:1] == 2'h0 ? potential_flags : {flags[2], potential_flags[1], flags[0]});

	dff flags_dff [2:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(new_flags),
		.q(flags),
		.wen(1'b1)
	);

endmodule