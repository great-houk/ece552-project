module full_adder_1bit(A, B, Cin, Sum, Cout);
	input A, B, Cin;
	output Sum, Cout;

	wire half;
	assign half = A ^ B;

	assign Sum = half ^ Cin;
	assign Cout = (half & Cin) | (A & B);
endmodule

module addsub_4bit(A, B, Sum);
	input [3:0] A, B;
	output [3:0] Sum;

	wire [2:0] carry;
	wire carry_out;

	wire [3:0] result;
	full_adder_1bit FAs [3:0] (.A(A), .B(B_mod), .Sum(result), .Cin({carry, 1'b0}), .Cout({carry_out, carry}));

	// Saturate
	wire should_sat;
	assign should_sat = (A[3] == B_mod[3]) && (A[3] != result[3]);
	assign Sum = should_sat ? {A[3] ? 4'b1000 : 4'b0111} : result;
endmodule

module PSA_16bit(A, B, Sum);
	input [15:0] A, B;
	output [15:0] Sum;

	addsub_4bit add0 (.A(A[3:0]), .B(B[3:0]), .Sum(Sum[3:0]));
	addsub_4bit add1 (.A(A[7:4]), .B(B[7:4]), .Sum(Sum[7:4]));
	addsub_4bit add2 (.A(A[11:8]), .B(B[11:8]), .Sum(Sum[11:8]));
	addsub_4bit add3 (.A(A[15:12]), .B(B[15:12]), .Sum(Sum[15:12]));
endmodule