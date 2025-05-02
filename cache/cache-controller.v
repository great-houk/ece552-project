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

    // I-cache signals
    wire i_cache_hit, i_cache_miss;
    wire i_write_cache, i_write_tag;
    wire [127:0] i_block_enable;
    wire [7:0] i_word_enable;
    wire [15:0] i_cache_data_in;
    
    // Instantiating instruction cache with write capability
    i_cache instr_cache(
        .clk(clk),
        .rst_n(rst_n),
        .addr(instr_addr),
        .data_in(i_cache_data_in),         // Connect data input
        .read_en(1'b1),                    // I-cache always reads
        .write_en(i_write_cache),          // Connect write enable
        .write_tag_en(i_write_tag),        // Connect tag write enable
        .ext_block_enable(i_block_enable), // Connect block enable
        .ext_word_enable(i_word_enable),   // Connect word enable
        .data_out(instr_data),
        .hit(i_cache_hit),
        .miss(i_cache_miss)
    );

    // I-cache FSM signals
    parameter IDLE = 3'b000, REQUEST = 3'b001, WAIT_DATA = 3'b010, UPDATE_CACHE = 3'b011, DONE = 3'b100;
    wire [2:0] i_state, i_state_next;
    wire [2:0] i_word_count, i_word_count_next;
    wire i_word_count_en;
    wire [15:0] i_addr_reg;
    wire i_addr_reg_en;
    wire [15:0] i_data_buffer [7:0];
    wire [7:0] i_data_buffer_wen;
    wire [15:0] i_curr_mem_addr;
    wire [15:0] i_mem_data_out;
    wire i_data_valid;
    wire i_enable_mem_read;
    wire [2:0] i_write_word_count, i_write_word_count_next;
    wire i_write_word_count_en;

    // I-cache state register
    dff i_state_ff [2:0] (
        .clk(clk), 
        .rst(~rst_n), 
        .wen(1'b1), 
        .d(i_state_next), 
        .q(i_state)
    );

    dff i_word_count_ff [2:0] (
        .clk(clk), 
        .rst(~rst_n), 
        .wen(i_word_count_en), 
        .d(i_word_count_next), 
        .q(i_word_count)
    );

    // Keep memory read enabled during WAIT_DATA state
    assign i_enable_mem_read = (i_state == REQUEST) || (i_state == WAIT_DATA);
    
    // Store original address when miss occurs
    assign i_addr_reg_en = (i_state == IDLE) & i_cache_miss;

    dff i_addr_reg_ff [15:0] (
        .clk(clk),
        .rst(~rst_n), 
        .wen(i_addr_reg_en), 
        .d(instr_addr),     
        .q(i_addr_reg)
    );

    // Data buffer to store memory responses
    dff i_data_buffer_ff0 [15:0] (.clk(clk), .rst(~rst_n), .wen(i_data_buffer_wen[0]), .d(i_mem_data_out), .q(i_data_buffer[0]));
    dff i_data_buffer_ff1 [15:0] (.clk(clk), .rst(~rst_n), .wen(i_data_buffer_wen[1]), .d(i_mem_data_out), .q(i_data_buffer[1]));
    dff i_data_buffer_ff2 [15:0] (.clk(clk), .rst(~rst_n), .wen(i_data_buffer_wen[2]), .d(i_mem_data_out), .q(i_data_buffer[2]));
    dff i_data_buffer_ff3 [15:0] (.clk(clk), .rst(~rst_n), .wen(i_data_buffer_wen[3]), .d(i_mem_data_out), .q(i_data_buffer[3]));
    dff i_data_buffer_ff4 [15:0] (.clk(clk), .rst(~rst_n), .wen(i_data_buffer_wen[4]), .d(i_mem_data_out), .q(i_data_buffer[4]));
    dff i_data_buffer_ff5 [15:0] (.clk(clk), .rst(~rst_n), .wen(i_data_buffer_wen[5]), .d(i_mem_data_out), .q(i_data_buffer[5]));
    dff i_data_buffer_ff6 [15:0] (.clk(clk), .rst(~rst_n), .wen(i_data_buffer_wen[6]), .d(i_mem_data_out), .q(i_data_buffer[6]));
    dff i_data_buffer_ff7 [15:0] (.clk(clk), .rst(~rst_n), .wen(i_data_buffer_wen[7]), .d(i_mem_data_out), .q(i_data_buffer[7]));

    dff i_write_word_ff [2:0] (
        .clk(clk),
        .rst(~rst_n),
        .wen(i_write_word_count_en),
        .d(i_write_word_count_next),
        .q(i_write_word_count)
    );

    // Calculate memory address based on cache block offset
    assign i_curr_mem_addr = {i_addr_reg[15:3], i_word_count};

    // Memory instance for instructions
    memory4c i_memory_read(
        .clk(clk),
        .rst(~rst_n),
        .enable(i_enable_mem_read),
        .addr(i_curr_mem_addr),
        .wr(1'b0),    // Always reading (i-cache is read-only)
        .data_in(16'h0),
        .data_out(i_mem_data_out),
        .data_valid(i_data_valid)
    );

    // State machine transitions for miss handling
    assign i_state_next = 
        (i_state == IDLE && i_cache_miss) ? REQUEST :
        (i_state == REQUEST) ? WAIT_DATA :
        (i_state == WAIT_DATA && !i_data_valid) ? WAIT_DATA : // Stay in WAIT_DATA until data is valid
        (i_state == WAIT_DATA && i_data_valid) ? UPDATE_CACHE :
        (i_state == UPDATE_CACHE && i_word_count < 3'b111) ? REQUEST :
        (i_state == UPDATE_CACHE && i_word_count == 3'b111) ? DONE :
        (i_state == DONE && i_write_word_count == 3'b111) ? IDLE :
        i_state;

    // Word counter control
    assign i_word_count_en = ((i_state == IDLE) & i_cache_miss) | (i_state == UPDATE_CACHE);
    assign i_word_count_next = (i_state == IDLE) ? 3'b000 : 
                              (i_state == UPDATE_CACHE) ? (i_word_count + 1'b1) : i_word_count;

    // Data buffer write enable signals - capture data when data_valid is high
    assign i_data_buffer_wen[0] = (i_state == WAIT_DATA) & i_data_valid & (i_word_count == 3'b000);
    assign i_data_buffer_wen[1] = (i_state == WAIT_DATA) & i_data_valid & (i_word_count == 3'b001);
    assign i_data_buffer_wen[2] = (i_state == WAIT_DATA) & i_data_valid & (i_word_count == 3'b010);
    assign i_data_buffer_wen[3] = (i_state == WAIT_DATA) & i_data_valid & (i_word_count == 3'b011);
    assign i_data_buffer_wen[4] = (i_state == WAIT_DATA) & i_data_valid & (i_word_count == 3'b100);
    assign i_data_buffer_wen[5] = (i_state == WAIT_DATA) & i_data_valid & (i_word_count == 3'b101);
    assign i_data_buffer_wen[6] = (i_state == WAIT_DATA) & i_data_valid & (i_word_count == 3'b110);
    assign i_data_buffer_wen[7] = (i_state == WAIT_DATA) & i_data_valid & (i_word_count == 3'b111);

    // Write word counter control
    assign i_write_word_count_en = (i_state == DONE);
    assign i_write_word_count_next = (i_state == UPDATE_CACHE && i_word_count == 3'b111) ? 3'b000 :
                                  (i_state == DONE) ? (i_write_word_count + 1'b1) : i_write_word_count;

    // Select data to write to cache
    assign i_cache_data_in =
        (i_write_word_count == 3'b000) ? i_data_buffer[0] :
        (i_write_word_count == 3'b001) ? i_data_buffer[1] :
        (i_write_word_count == 3'b010) ? i_data_buffer[2] :
        (i_write_word_count == 3'b011) ? i_data_buffer[3] :
        (i_write_word_count == 3'b100) ? i_data_buffer[4] :
        (i_write_word_count == 3'b101) ? i_data_buffer[5] :
        (i_write_word_count == 3'b110) ? i_data_buffer[6] :
                                      i_data_buffer[7];

    // Control signals for cache update
    assign i_write_cache = (i_state == DONE);
    assign i_write_tag = (i_state == DONE) & (i_write_word_count == 3'b111);

    // Determine way select based on address
    wire way_select = i_addr_reg[0];
    
    // Generate block enable signals for way selection
    assign i_block_enable = (i_write_cache) ? 
                           (way_select ? 
                             (1 << {i_addr_reg[9:4], 1'b1}) : // Way 1
                             (1 << {i_addr_reg[9:4], 1'b0})   // Way 0
                           ) : 128'b0;
                           
    // Generate word enable signals for the specific word being written
    assign i_word_enable = (i_write_cache) ? (1 << i_write_word_count) : 8'b0;
    
    // Indicate when instruction cache is handling a miss (stall)
    assign instr_invalid = (i_state != IDLE);

	//d_mem
	memory1c memory_read(
		.clk(clk),
		.rst(~rst_n),
		.enable(mem_read_en),
		.addr(mem_addr),
		.wr(mem_write_en),
		.data_in(mem_write_data),
		.data_out(mem_data)
	);
    
	assign mem_invalid = 1'b0;

endmodule