module memory_stage(input clk, input rst_n, input [15:0] addr, input [15:0] write_data, input mem_write_en, input mem_read_en, output [15:0] mem_read);


//Instantiate instr memory write
memory1c memory_write(.clk(clk), .rst(rst_n), .enable(mem_write_en), .addr(addr), .data_in(write_data), .data_out());

//Instantiate memory read
memory1c memory_read(.clk(clk), .rst(rst_n), .enable(mem_read_en), .addr(addr), .data_in(16'h0000), .data_out(mem_read));


endmodule