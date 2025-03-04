module memory_stage(input clk, input rst, input [15:0] addr, input [15:0] write_data, input mem_write_en, input mem_read_en, output [15:0] mem_read);


//Instantiate memory read
memory1c memory_read(.clk(clk), .rst(rst), .enable(mem_read_en), .addr(addr), .wr(mem_read_en), .data_in(write_data), .data_out(mem_read));


endmodule