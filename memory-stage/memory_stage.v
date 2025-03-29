module memory_stage(
	input clk, rst_n, 
	input [15:0] addr, 
	input [15:0] write_data, 
	input mem_write_en, mem_read_en, 
	output [15:0] mem_read
);
// Instantiate memory read
memory1c memory_read (
	.clk(clk), 
	.rst(~rst_n), 
	.enable(mem_read_en), 
	.addr(addr), 
	.wr(mem_write_en), 
	.data_in(write_data), 
	.data_out(mem_read)
);
endmodule