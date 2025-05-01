`default_nettype none

module cache_controller(
	// Inputs
	input wire clk,
	input wire rst_n,
	input wire [15:0] instr_addr,
	input wire [15:0] mem_addr,
	input wire mem_read_en,
	input wire mem_write_en,
	input wire [15:0] mem_write_data,
	// Outputs
	output wire instr_invalid,
	output wire mem_invalid,
	output wire [15:0] instr_data,
	output wire [15:0] mem_data
);
	// Instruction mem
	memory1c_instr instr_mem(
		.clk(clk),
		.rst(~rst_n),
		.addr(instr_addr),
		.enable(1'b1),
		.wr(1'b0),
		.data_in(16'b0),
		.data_out(instr_data)
	);
	assign instr_invalid = 1'b0; // No invalidation for instruction cache

	// D Cache FSM
	wire [2:0] data_read_amount, data_read_amount_next;
	wire [2:0] data_write_amount, data_write_amount_next;
	wire mem_reading;
	wire data_cache_invalid;
	wire [15:0] mem_4c_read;
	wire mem_4c_valid;

	// FSM
	assign mem_reading = (data_read_amount != 3'b0) | data_cache_invalid;
	dff data_read_amount_ff [2:0] (.clk(clk), 
							.rst(~rst_n), 
							.wen(mem_reading), 
							.d(data_read_amount_next), 
							.q(data_read_amount));
	dff data_write_amount_ff [2:0] (.clk(clk),
							.rst(~rst_n), 
							.wen(mem_4c_valid), 
							.d(data_write_amount_next), 
							.q(data_write_amount));
	assign data_read_amount_next = data_read_amount + 1'b1;
	assign data_write_amount_next = data_write_amount + 1'b1;
	

	// 4 Cycle Mem
	memory4c mem_4c(
		.clk(clk),
		.rst(~rst_n),
		.enable(mem_invalid ? mem_reading : mem_write_en),
		.addr(mem_invalid ? {mem_addr[15:4], data_read_amount, 1'b0} : mem_addr),
		.wr(mem_invalid ? 1'b0 : mem_write_en),
		.data_in(mem_write_data),
		.data_out(mem_4c_read),
		.data_valid(mem_4c_valid)
	);

	// D Cache
	d_cache dcache(
		.clk(clk),
		.rst_n(rst_n),
		.addr(mem_invalid ? {mem_addr[15:4], data_write_amount, 1'b0} : mem_addr),
		.data_in(mem_invalid ? mem_4c_read : mem_write_data),
		.read_en(mem_read_en),
		.write_en(mem_invalid ? mem_4c_valid : mem_write_en),
		.data_out(mem_data),
		.invalid(data_cache_invalid)
	);

	assign mem_invalid = mem_reading | mem_4c_valid;
endmodule

`default_nettype wire