module cache_controller(
	// Inputs
	input clk,
	input rst_n,
	input [15:0] instr_addr,
	input [15:0] mem_addr,
	input mem_read_en,
	input mem_write_en,
	input [15:0] mem_write_data,
	// Outputs
	output instr_invalid,
	output mem_invalid,
	output [15:0] instr_data,
	output [15:0] mem_data
);
	memory1c_instr imem(
		.data_out(instr_data),
		.data_in(16'hX),
		.addr(instr_addr),
		.enable(1'b1),
		.wr(1'b0),
		.clk(clk),
		.rst(~rst_n)
	);

	memory1c memory_read(
		.clk(clk),
		.rst(~rst_n),
		.enable(mem_read_en),
		.addr(mem_addr),
		.wr(mem_write_en),
		.data_in(mem_write_data),
		.data_out(mem_data)
	);

	reg rand_1, rand_2;
	always @(posedge clk or negedge rst_n) begin
		rand_1 <= $random % 2;
		rand_2 <= $random % 2;
	end

	assign instr_invalid = rand_1;
	assign mem_invalid = rand_2;
endmodule