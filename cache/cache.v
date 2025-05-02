`default_nettype none

module cache (
	input wire clk, rst_n,
	input wire [15:0] addr,
	input wire [15:0] data_in,
	input wire read_en,
	input wire write_en,
	input wire write_meta,
	output wire [15:0] data_out,
	output wire invalid
);
	wire [4:0] tag;
	wire [127:0] block_enable;
	wire [7:0] word_enable;
	// assign block_enable = 128'b1 << addr[10:4];
	wire [127:0] block_enable_hot;
	one_hot_128 block_shifter (
		.sel(addr[10:4]),
		.one_hot(block_enable_hot));
	assign block_enable = block_enable_hot;

	// assign word_enable = 8'b1 << addr[3:1];
	wire [7:0] word_enable_hot;
	one_hot_8 word_shifter (
		.sel(addr[3:1]),
		.one_hot(word_enable_hot));
	assign word_enable = word_enable_hot;

	assign tag = addr[15:11];

	// Cache Sets
	wire [15:0] set0_out, set1_out;
	DataArray set0(
		.clk(clk), .rst(~rst_n), .DataIn(data_in), .Write(write_en),
		.BlockEnable(block_enable), .WordEnable(word_enable), .DataOut(set0_out)
	);

	DataArray set1(
		.clk(clk), .rst(~rst_n), .DataIn(data_in), .Write(write_en),
		.BlockEnable(block_enable), .WordEnable(word_enable), .DataOut(set1_out)
	);

	// Metadata arrays
	wire [7:0] meta0_in, meta1_in, meta0_out, meta1_out;
	wire set0_valid, set1_valid;
	MetaDataArray set0_meta(
		.clk(clk), .rst(~rst_n), .DataIn(meta0_in), .Write(read_en | write_en),
		.BlockEnable(block_enable), .DataOut(meta0_out)
	);
	assign set0_valid = (meta0_out[7:3] == tag) && meta0_out[1];

	MetaDataArray set1_meta(
		.clk(clk), .rst(~rst_n), .DataIn(meta1_in), .Write(write_meta),
		.BlockEnable(block_enable), .DataOut(meta1_out)
	);
	assign set1_valid = (meta1_out[7:3] == tag) && meta1_out[1];

	// Logic Signals
	assign invalid = ~(set0_valid | set1_valid) & (read_en | write_en);
	wire chosen_set;
	assign chosen_set = (set0_valid | set1_valid) ? set1_valid : meta0_out[0];
	assign meta0_in = (write_en & chosen_set == 1'b0) ? {tag, 2'b01, 1'b1} : {meta0_out[7:1], chosen_set == 1'b0};
	assign meta1_in = (write_en & chosen_set == 1'b1) ? {tag, 2'b01, 1'b1} : {meta1_out[7:1], chosen_set == 1'b1};
	assign data_out = (chosen_set == 1'b0) ? set0_out : set1_out;
endmodule

`default_nettype wire