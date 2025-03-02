module fetch_tb();
logic clk;
logic rst_n;
logic [15:0] next_pc;
logic [15:0] instruction;
logic [15:0] pc_out;
logic [15:0] pc_plus2;

fetch_stage(.clk(clk), .rst_n(rst_n), .next_pc(next_pc), .instruction(instruction), .pc_out(pc_out), .pc_plus2(pc_plus2));


initial begin
	


end


endmodule