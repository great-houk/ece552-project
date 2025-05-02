module execute_stage(
	// Inputs
	input clk, rst_n, stall,
	input [15:0] reg_rs, reg_rt, imm, pc_plus2,
	input alu_src1, alu_src2,
	input [3:0] alu_op,
	input [15:0] m_alu_result, w_reg_write_data,
	input [1:0] ex_ex_forwarding, ex_mem_forwarding,
	// Passthrough
	input [3:0] d_rd, d_rs, d_rt,
	input d_mem_write_en, d_mem_read_en,
	input d_reg_write_en, d_reg_write_src,
	input [15:0] d_pc_plus2,
	input d_halt,
	// Outputs
	output reg [15:0] alu_result,
	output [2:0] flags, // nzv
	output flag_update,
	// Passthrough
	output [3:0] e_rd, e_rs, e_rt,
	output [15:0] e_reg_rt,
	output e_mem_write_en, e_mem_read_en,
	output e_reg_write_en, e_reg_write_src,
	output e_halt
);
	// Input dffs
	wire [15:0] reg_rs_forward, reg_rt_forward;
	wire [15:0] reg_rs_ff, reg_rt_ff, imm_ff, pc_plus2_ff;
	dff reg_rs_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(stall ? reg_rs_forward : reg_rs),
		.q(reg_rs_ff),
		.wen(1'b1)
	);
	dff reg_rt_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(stall ? reg_rt_forward : reg_rt),
		.q(reg_rt_ff),
		.wen(1'b1)
	);
	dff imm_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(imm),
		.q(imm_ff),
		.wen(~stall)
	);
	dff pc_plus2_dff [15:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(pc_plus2),
		.q(pc_plus2_ff),
		.wen(~stall)
	);
	wire alu_src1_ff, alu_src2_ff;
	dff alu_src1_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(alu_src1),
		.q(alu_src1_ff),
		.wen(~stall)
	);
	dff alu_src2_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(alu_src2),
		.q(alu_src2_ff),
		.wen(~stall)
	);
	wire [3:0] alu_op_ff;
	dff alu_op_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(alu_op),
		.q(alu_op_ff),
		.wen(~stall)
	);

	// Forwarding
	assign reg_rs_forward = 
		ex_ex_forwarding[0] ? m_alu_result :
		ex_mem_forwarding[0] ? w_reg_write_data :
		reg_rs_ff;
	assign reg_rt_forward =
		ex_ex_forwarding[1] ? m_alu_result :
		ex_mem_forwarding[1] ? w_reg_write_data :
		reg_rt_ff;

	// Passthrough dffs
	dff rs_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(d_rs),
		.q(e_rs),
		.wen(~stall)
	);
	dff rt_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(d_rt),
		.q(e_rt),
		.wen(~stall)
	);
	dff rd_dff [3:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(d_rd),
		.q(e_rd),
		.wen(~stall)
	);
	assign e_reg_rt = reg_rt_forward; // Pass through reg_rt with forwarding
	dff mem_write_en_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(d_mem_write_en),
		.q(e_mem_write_en),
		.wen(~stall)
	);
	dff mem_read_en_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(d_mem_read_en),
		.q(e_mem_read_en),
		.wen(~stall)
	);
	dff reg_write_en_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(d_reg_write_en),
		.q(e_reg_write_en),
		.wen(~stall)
	);
	dff reg_write_src_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(d_reg_write_src),
		.q(e_reg_write_src),
		.wen(~stall)
	);
	dff halt_dff (
		.clk(clk),
		.rst(~rst_n),
		.d(d_halt),
		.q(e_halt),
		.wen(~stall)
	);

	// Assign sources
	wire [15:0] alu_src1_data, alu_src2_data;
	assign alu_src1_data = alu_src1_ff ? pc_plus2_ff : reg_rs_forward;
	assign alu_src2_data = alu_src2_ff ? imm_ff : reg_rt_forward;

	// Calculate possible ALU results
	// Add/sub
	wire [15:0] adder_res, adder_sat;
	wire adder_cout, should_sat;
	// cla_16bit cla(
	// 	.a(alu_src1_data),
	// 	.b(alu_op_ff[0] ? (~alu_src2_data) : (alu_src2_data)),
	// 	.cin(alu_op_ff[0]),
	// 	.sum(adder_res),
	// 	.cout(adder_cout)
	// );
	assign adder_cout = alu_src1_data + (alu_op_ff[0] ? (~alu_src2_data) : (alu_src2_data)) + alu_op_ff[0];

	assign should_sat = (alu_src1_data[15] == (alu_src2_data[15] ^ alu_op_ff[0])) && (alu_src1_data[15] != adder_res[15]);
	assign adder_sat = should_sat ? (adder_res[15] ? 16'h7FFF : 16'h8000) : adder_res;

	// Shifter
	// wire [15:0] shifter_res;
	// Shifter shifter(
	// 	.Shift_Out(shifter_res),
	// 	.Shift_In(alu_src1_data),
	// 	.Shift_Val(alu_src2_data[3:0]),
	// 	.Mode(alu_op_ff[1:0])
	// );
	//This is a more complicated implementation of the shifter, but SHOULD decrease area(I think)
	wire [15:0] shift_left_result;
	wire [15:0] shift_arith_result;
	wire [15:0] shift_rotate_result;
	wire [15:0] shifter_res;

	wire [3:0] shift_amt = alu_src2_data[3:0];  // 4-bit shift amount

	// Logical Left Shift
	assign shift_left_result = alu_src1_data << shift_amt;

	// Arithmetic Right Shift (preserve sign bit)
	assign shift_arith_result = $signed(alu_src1_data) >>> shift_amt;

	// Rotate Right (custom implementation)
	assign shift_rotate_result = (alu_src1_data >> shift_amt) | (alu_src1_data << (16 - shift_amt));

	// Shifter result selected by Mode (ternary)
	assign shifter_res = (alu_op_ff[1:0] == 2'b00) ? shift_left_result :
						(alu_op_ff[1:0] == 2'b01) ? shift_arith_result :
						(alu_op_ff[1:0] == 2'b10) ? shift_rotate_result :
						16'hXXXX;

	// Reduce
	wire [15:0] reduction_res;
	reduction_unit reduction_unit(
		.rs(alu_src1_data),
		.rt(alu_src2_data),
		.rd(reduction_res)
	);

	// Parallel Adder
	// wire [15:0] psa_adder_res;
	// PSA_16bit PSA(
	// 	.A(alu_src1_data),
	// 	.B(alu_src2_data),
	// 	.Sum(psa_adder_res)
	// );
	assign psa_adder_res[3:0]   = alu_src1_data[3:0]   + alu_src2_data[3:0];
	assign psa_adder_res[7:4]   = alu_src1_data[7:4]   + alu_src2_data[7:4];
	assign psa_adder_res[11:8]  = alu_src1_data[11:8]  + alu_src2_data[11:8];
	assign psa_adder_res[15:12] = alu_src1_data[15:12] + alu_src2_data[15:12];

	// Calculate ALU result
	always @(*) begin
		// 0: src1+src2, 1: src1-src2, 2: src1^src2, 4: src1 << imm[3:0], 5: src1 >> imm[3:0], 6: src1 >>> imm[3:0] (rotate),
		// 8: RED, 9: PADDSB, 10: src1+src2 (no flags), 11: {src1[15:8], imm[7:0]}, 12: {imm[7:0], src1[7:0]}, 13: src1
		case (alu_op_ff)
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
	assign new_flags = alu_op_ff[3] ? flags : (alu_op_ff[2:1] == 2'h0 ? potential_flags : {flags[2], potential_flags[1], flags[0]});
	assign flag_update = ~alu_op_ff[3];

	dff flags_dff [2:0] (
		.clk(clk),
		.rst(~rst_n),
		.d(new_flags),
		.q(flags),
		.wen(~stall)
	);
endmodule