module cla_1bit(
	input a, b, cin,
	output sum, gen, prop
);
	assign sum = a ^ b ^ cin;
	assign gen = a & b;
	assign prop = a | b;
endmodule

module cla_4bit(
	input [3:0] a, b,
	input cin,
	output [3:0] sum,
	output cout
);
	wire [3:0] gen, prop;
	wire [3:1] c;

	cla_1bit cla0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .gen(gen[0]), .prop(prop[0]));
	cla_1bit cla1 (.a(a[1]), .b(b[1]), .cin(c[1]), .sum(sum[1]), .gen(gen[1]), .prop(prop[1]));
	cla_1bit cla2 (.a(a[2]), .b(b[2]), .cin(c[2]), .sum(sum[2]), .gen(gen[2]), .prop(prop[2]));
	cla_1bit cla3 (.a(a[3]), .b(b[3]), .cin(c[3]), .sum(sum[3]), .gen(gen[3]), .prop(prop[3]));

	assign c[1] = gen[0] | (prop[0] & cin);
	assign c[2] = gen[1] | (prop[1] & c[1]);
	assign c[3] = gen[2] | (prop[2] & c[2]);
	assign cout = gen[3] | (prop[3] & c[3]);
endmodule

module cla_16bit(
	input [15:0] a, b,
	input cin,
	output [15:0] sum,
	output cout
);
	wire [15:0] gen, prop;
	wire [15:0] c;
	assign c[0] = cin;

	cla_1bit clas [15:0] (
		.a(a),
		.b(b),
		.cin(c),
		.sum(sum),
		.gen(gen),
		.prop(prop)
	);

	assign c[15:1] = gen[14:0] | (prop[14:0] & c[14:0]);
	assign cout = gen[15] | (prop[15] & c[15]);
endmodule