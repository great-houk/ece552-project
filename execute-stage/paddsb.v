module full_adder_1bit(A, B, Cin, Sum, Cout);
	input A, B, Cin;
	output Sum, Cout;

	wire half;
	assign half = A ^ B;

	assign Sum = half ^ Cin;
	assign Cout = (half & Cin) | (A & B);
endmodule

module addsub_4bit(Sum, Ovfl, A, B, sub);
	input [3:0] A, B;
	input sub;
	output [3:0] Sum;
	output Ovfl;

	wire [2:0] carry;
	wire carry_out;
	wire [3:0] B_mod;

	assign B_mod = sub ? ~B : B;

	full_adder_1bit FAs [3:0] (.A(A), .B(B_mod), .Sum(Sum), .Cin({carry, sub}), .Cout({carry_out, carry}));

	wire sign_A, sign_B, sign_Sum;
	assign sign_A = A[3];
	assign sign_B = sub ? ~B[3] : B[3];
	assign sign_Sum = Sum[3];
	assign Ovfl = (sign_A & sign_B & ~sign_Sum) | (~sign_A & ~sign_B & sign_Sum);
endmodule

// TODO: Make this saturate instead of overflow
module PSA_16bit(Sum, Error, A, B);
	input [15:0] A, B;
	output [15:0] Sum;
	output Error;

	wire [3:0] errors;

	addsub_4bit add0 (.A(A[3:0]), .B(B[3:0]), .Sum(Sum[3:0]), .Ovfl(errors[0]), .sub(1'b0));
	addsub_4bit add1 (.A(A[7:4]), .B(B[7:4]), .Sum(Sum[7:4]), .Ovfl(errors[1]), .sub(1'b0));
	addsub_4bit add2 (.A(A[11:8]), .B(B[11:8]), .Sum(Sum[11:8]), .Ovfl(errors[2]), .sub(1'b0));
	addsub_4bit add3 (.A(A[15:12]), .B(B[15:12]), .Sum(Sum[15:12]), .Ovfl(errors[3]), .sub(1'b0));

	assign Error = |errors;
endmodule

module PSA_16bit_tb();
	reg [15:0] A, B;
	wire [15:0] Sum;
	wire Error;

	PSA_16bit DUT(.A(A), .B(B), .Sum(Sum), .Error(Error));

	initial begin
		A = 0;
		B = 0;

		// Test addition
		repeat(20) begin
			A = $random;
			B = $random;
			#1;
			if((A[3:0] + B[3:0]) !== Sum[3:0]) begin
				$display("Error in bits 0-3: %d + %d != %d", A[3:0], B[3:0], Sum[3:0]);
				$stop();
			end
			if((A[7:4] + B[7:4]) !== Sum[7:4]) begin
				$display("Error in bits 4-7: %d + %d != %d", A[7:4], B[7:4], Sum[7:4]);
				$stop();
			end
			if((A[11:8] + B[11:8]) !== Sum[11:8]) begin
				$display("Error in bits 8-11: %d + %d != %d", A[11:8], B[11:8], Sum[11:8]);
				$stop();
			end
			if((A[15:12] + B[15:12]) !== Sum[15:12]) begin
				$display("Error in bits 12-15: %d + %d != %d", A[15:12], B[15:12], Sum[15:12]);
				$stop();
			end
		end

		$display("Success!!!");
	end
endmodule