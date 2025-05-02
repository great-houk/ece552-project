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
	// FSM
	parameter IDLE = 2'b00, INSTR = 2'b01, DATA = 2'b10;
	wire [1:0] state, state_next;
	wire is_miss;
	// 4C Memory
	wire [15:0] mem_4c_addr;
	wire [2:0] read_amount, read_amount_next;
	wire [2:0] write_amount, write_amount_next;
	wire [15:0] mem_4c_out;
	wire mem_4c_read_en;
	wire mem_4c_valid;
	// Caches
	wire data_cache_invalid, instr_cache_invalid;

	// FSM
	dff state_ff [1:0] (.clk(clk), 
						.rst(~rst_n), 
						.wen(1'b1), 
						.d(state_next), 
						.q(state));
	assign state_next = 
		(state == DATA)  & (data_cache_invalid  | mem_4c_valid) ? DATA :
		(state == INSTR) & (instr_cache_invalid | mem_4c_valid) ? INSTR :
		data_cache_invalid  ? DATA :
		instr_cache_invalid ? INSTR :
		IDLE;
	assign is_miss = state_next != IDLE;

	// 4C Memory
	assign mem_4c_read_en = (read_amount != 3'b0) | (is_miss & write_amount == 3'b0);
	dff read_amount_ff [2:0] (.clk(clk), 
							.rst(~rst_n), 
							.wen(mem_4c_read_en), 
							.d(read_amount_next), 
							.q(read_amount));
	dff write_amount_ff [2:0] (.clk(clk),
							.rst(~rst_n), 
							.wen(mem_4c_valid), 
							.d(write_amount_next), 
							.q(write_amount));

	assign read_amount_next = read_amount + 1'b1;
	assign write_amount_next = write_amount + 1'b1;
    
	assign mem_4c_addr = 
		(state_next == IDLE) ? mem_addr :
		(state_next == INSTR) ? {instr_addr[15:4], read_amount, 1'b0} :
		(state_next == DATA) ? {mem_addr[15:4], read_amount, 1'b0} :
		16'hXXXX;
	
	memory4c mem_4c(
		.clk(clk),
		.rst(~rst_n),
		.enable(is_miss ? mem_4c_read_en : mem_write_en),
		.addr(mem_4c_addr),
		.wr(is_miss ? 1'b0 : mem_write_en),
		.data_in(mem_write_data),
		.data_out(mem_4c_out),
		.data_valid(mem_4c_valid)
	);

	// D Cache
	wire data_miss;
	assign data_miss = state_next == DATA;
	assign mem_invalid = data_miss | (state_next == INSTR & mem_write_en);

	cache dcache(
		.clk(clk),
		.rst_n(rst_n),
		.addr(data_miss ? {mem_addr[15:4], write_amount, 1'b0} : mem_addr),
		.data_in(data_miss ? mem_4c_out : mem_write_data),
		.read_en(mem_read_en),
		.write_en(data_miss ? mem_4c_valid : (~mem_invalid & mem_write_en)),
		.write_meta(~mem_invalid & mem_read_en),
		.data_out(mem_data),
		.invalid(data_cache_invalid)
	);

	// I Cache
	assign instr_invalid = state_next == INSTR;

	cache icache(
		.clk(clk),
		.rst_n(rst_n),
		.addr(instr_invalid ? {instr_addr[15:4], write_amount, 1'b0} : instr_addr),
		.data_in(instr_invalid ? mem_4c_out : 16'hXXXX),
		.read_en(1'b1),
		.write_en(instr_invalid ? mem_4c_valid : 1'b0),
		.write_meta(~instr_invalid),
		.data_out(instr_data),
		.invalid(instr_cache_invalid)
	);
endmodule

`default_nettype wire
