module i_cache (
    input clk,
    input rst_n,
    input [15:0] addr,
    input [15:0] data_in,
    input write_en,
    input read_en,
    input write_tag_en,
    input [127:0] ext_block_enable,
    input [7:0] ext_word_enable,
    output [15:0] data_out,
    output hit,
    output miss
);

    wire [3:0] offset = addr[3:0];
    wire [5:0] index = addr[9:4];
    wire [5:0] tag = addr[15:10];
    wire [2:0] word_offset = offset[3:1];
    wire [127:0] block_enable_way0;
    wire [127:0] block_enable_way1;
    wire [7:0] word_enable;
    wire [15:0] data_out_way0;
    wire [15:0] data_out_way1;
    wire [7:0] meta_out_way0;
    wire [7:0] meta_out_way1;

    wire [127:0] read_block_enable_way0;
    wire [127:0] read_block_enable_way1;
    wire [7:0] read_word_enable;
    
    assign read_block_enable_way0 = 1'b1 << {index, 1'b0};
    assign read_block_enable_way1 = 1'b1 << {index, 1'b1};
    assign read_word_enable = 8'b1 << word_offset;

    assign block_enable_way0 = write_en ? ext_block_enable : read_block_enable_way0;
    assign block_enable_way1 = write_en ? ext_block_enable : read_block_enable_way1;
    assign word_enable = write_en ? ext_word_enable : read_word_enable;

    // Data arrays, read-only
    DataArray data_way0(
        .clk(clk), .rst(~rst_n), .DataIn(data_in), .Write(write_en),
        .BlockEnable(block_enable_way0), .WordEnable(word_enable), .DataOut(data_out_way0)
    );

    DataArray data_way1(
        .clk(clk), .rst(~rst_n), .DataIn(data_in), .Write(write_en),
        .BlockEnable(block_enable_way1), .WordEnable(word_enable), .DataOut(data_out_way1)
    );

    // Metadata arrays, read-only unless miss handler updates
    MetaDataArray meta_way0(
        .clk(clk), .rst(~rst_n), .DataIn({1'b1, 1'b0, tag}), .Write(write_tag_en),
        .BlockEnable(block_enable_way0), .DataOut(meta_out_way0)
    );

    MetaDataArray meta_way1(
        .clk(clk), .rst(~rst_n), .DataIn({1'b1, 1'b0, tag}), .Write(write_tag_en),
        .BlockEnable(block_enable_way1), .DataOut(meta_out_way1)
    );

    wire valid_way0 = meta_out_way0[7];
    wire valid_way1 = meta_out_way1[7];
    wire [5:0] tag_way0 = meta_out_way0[5:0];
    wire [5:0] tag_way1 = meta_out_way1[5:0];

    wire hit_way0 = valid_way0 && (tag_way0 == tag);
    wire hit_way1 = valid_way1 && (tag_way1 == tag);
    wire selected_hit = hit_way0 || hit_way1;

    wire [15:0] selected_data = hit_way0 ? data_out_way0 : hit_way1 ? data_out_way1 : 16'hXXXX;

    assign hit = selected_hit;
    assign miss = read_en & ~selected_hit;
    assign data_out = (read_en && selected_hit) ? selected_data : 16'h0000;

endmodule
