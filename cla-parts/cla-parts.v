module cla_1bit(
	input a, b, cin,
	output sum, gen, prop
);
	assign sum = a ^ b ^ cin;
	assign gen = a & b;
	assign prop = a | b;
endmodule

module cla_2bit(
	input [1:0] a, b,
	input cin,
	output [1:0] sum,
	output gen, prop
);
	wire gen0, gen1, prop0, prop1, c1;

	cla_1bit cla0 (
		.a(a[0]),
		.b(b[0]),
		.cin(cin),
		.sum(sum[0]),
		.gen(gen0),
		.prop(prop0)
	);

	cla_1bit cla1 (
		.a(a[1]),
		.b(b[1]),
		.cin(c1),
		.sum(sum[1]),
		.gen(gen1),
		.prop(prop1)
	);

	assign c1 = gen0 | (prop0 & cin);
	assign gen = gen1 | (prop1 & gen0);
	assign prop = prop1 & prop0;
endmodule