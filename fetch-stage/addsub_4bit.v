module addsub_4bit(Sum, Ovfl, A, B, sub);

input [3:0] A;
input [3:0] B; //Input values
input sub; // add-sub indicator
output [3:0] Sum; //sum output
output Ovfl; //To indicate overflow

wire [3:0] B_prime;
wire [3:0] carry;
wire[3:0] sub_bits;

assign sub_bits = (sub) ? (4'b1111):(4'b0000);

xor xor_gates[3:0](B_prime, B, sub_bits);
xor (Ovfl, carry[2], carry[3]);


FA iFA0(.A(A[0]), .B(B_prime[0]), .Cin(sub), .S(Sum[0]), .Cout(carry[0]));
FA iFA1(.A(A[1]), .B(B_prime[1]), .Cin(carry[0]), .S(Sum[1]), .Cout(carry[1]));
FA iFA2(.A(A[2]), .B(B_prime[2]), .Cin(carry[1]), .S(Sum[2]), .Cout(carry[2]));
FA iFA3(.A(A[3]), .B(B_prime[3]), .Cin(carry[2]), .S(Sum[3]), .Cout(carry[3]));



endmodule