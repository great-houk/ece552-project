`timescale 1ns / 1ps

module cla_parts_tb();

	// Inputs
	reg [15:0] a;
	reg [15:0] b;
	reg cin;

	// Outputs
	wire [15:0] sum;
	wire cout;

	cla_16bit DUT (
		.a(a),
		.b(b),
		.cin(cin),
		.sum(sum),
		.cout(cout)
	);

	initial begin
		// Initialize Inputs
		a = 0;
		b = 0;
		cin = 0;

		// Add stimulus here
		// Test case 1
		a = 16'h0001; b = 16'h0001; cin = 0;
		#10;
		if (sum !== 16'h0002 || cout !== 0) $display("Test case 1 failed");

		// Test case 2
		a = 16'hFFFF; b = 16'h0001; cin = 0;
		#10;
		if (sum !== 16'h0000 || cout !== 1) $display("Test case 2 failed");

		// Test case 3
		a = 16'hAAAA; b = 16'h5555; cin = 0;
		#10;
		if (sum !== 16'hFFFF || cout !== 0) $display("Test case 3 failed");

		// Test case 4
		a = 16'h8000; b = 16'h8000; cin = 1;
		#10;
		if (sum !== 16'h0001 || cout !== 1) $display("Test case 4 failed");

		// Test case 5
		a = 16'h1234; b = 16'h5678; cin = 1;
		#10;
		if (sum !== 16'h68AD || cout !== 0) $display("Test case 5 failed");

		// Finish simulation
		$display("Success!!!!");
		$stop();
	end
endmodule