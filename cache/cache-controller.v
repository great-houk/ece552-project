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
/*
    //D-cache Internal signals
    wire data_valid;
    wire enable, enable_mem_read, cache_write_en, addr_reg_en, data_out_en;
    wire write_cache, write_tag;
    wire [2:0] state, state_next;
    wire [127:0] block_enable;
    wire [7:0] word_enable;
	wire [2:0] write_word_count, write_word_count_next;
    wire write_word_count_en;
	wire [15:0] addr_reg;
	wire [2:0] word_count, word_count_next;
    wire word_count_en;
	wire [15:0] data_buffer [7:0];    
    wire [7:0] data_buffer_wen;
    wire [15:0] curr_mem_addr;
    wire [15:0] mem_data_out;
	wire [15:0] cache_data_in;
	*/

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
	wire i_write_cache, i_write_tag;
	wire [127:0] i_block_enable;
	wire [7:0] i_word_enable;
	wire [15:0] i_cache_data_in;

	// I-cache state register
	dff i_state_ff [2:0] (.clk(clk), 
						.rst(~rst_n), 
						.wen(1'b1), 
						.d(i_state_next), 
						.q(i_state));

	
	dff i_word_count_ff [2:0] (.clk(clk), 
							.rst(~rst_n), 
							.wen(i_word_count_en), 
							.d(i_word_count_next), 
							.q(i_word_count));

	
	dff i_addr_reg_ff [15:0] (.clk(clk),
							.rst(~rst_n), 
							.wen(i_addr_reg_en), 
							.d(instr_addr),     
							.q(i_addr_reg));

	
	dff i_data_buffer_ff0 [15:0] (.clk(clk),.rst(~rst_n),.wen(i_data_buffer_wen[0]),.d(i_mem_data_out),.q(i_data_buffer[0]));
	dff i_data_buffer_ff1 [15:0] (.clk(clk),.rst(~rst_n),.wen(i_data_buffer_wen[1]),.d(i_mem_data_out),.q(i_data_buffer[1]));
	dff i_data_buffer_ff2 [15:0] (.clk(clk),.rst(~rst_n),.wen(i_data_buffer_wen[2]),.d(i_mem_data_out),.q(i_data_buffer[2]));
	dff i_data_buffer_ff3 [15:0] (.clk(clk),.rst(~rst_n),.wen(i_data_buffer_wen[3]),.d(i_mem_data_out),.q(i_data_buffer[3]));
	dff i_data_buffer_ff4 [15:0] (.clk(clk),.rst(~rst_n),.wen(i_data_buffer_wen[4]),.d(i_mem_data_out),.q(i_data_buffer[4]));
	dff i_data_buffer_ff5 [15:0] (.clk(clk),.rst(~rst_n),.wen(i_data_buffer_wen[5]),.d(i_mem_data_out),.q(i_data_buffer[5]));
	dff i_data_buffer_ff6 [15:0] (.clk(clk),.rst(~rst_n),.wen(i_data_buffer_wen[6]),.d(i_mem_data_out),.q(i_data_buffer[6]));
	dff i_data_buffer_ff7 [15:0] (.clk(clk),.rst(~rst_n),.wen(i_data_buffer_wen[7]),.d(i_mem_data_out),.q(i_data_buffer[7]));

	
	dff i_write_word_ff [2:0] (.clk(clk),
							.rst(~rst_n),
							.wen(i_write_word_count_en),
							.d(i_write_word_count_next),
							.q(i_write_word_count));

	
	assign i_curr_mem_addr = {i_addr_reg[15:3], i_word_count};

	
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

	
	assign i_state_next = (i_state == IDLE && instr_invalid) ? REQUEST :
						(i_state == REQUEST) ? WAIT_DATA :
						(i_state == WAIT_DATA && i_data_valid) ? UPDATE_CACHE :
						(i_state == UPDATE_CACHE && i_word_count < 3'b111) ? REQUEST :
						(i_state == UPDATE_CACHE && i_word_count == 3'b111) ? DONE :
						(i_state == DONE && i_write_word_count == 3'b111) ? IDLE :
						i_state;

	
	assign i_enable_mem_read = (i_state == REQUEST);
	assign i_addr_reg_en = (i_state == IDLE) & instr_invalid;

	assign i_word_count_en = ((i_state == IDLE) & instr_invalid) | (i_state == UPDATE_CACHE);
	assign i_word_count_next = (i_state == IDLE) ? 3'b000 : 
							(i_state == UPDATE_CACHE) ? (i_word_count + 1'b1) : i_word_count;

	
	assign i_data_buffer_wen[0] = (i_state == UPDATE_CACHE) & i_data_valid & (i_word_count == 3'b000);
	assign i_data_buffer_wen[1] = (i_state == UPDATE_CACHE) & i_data_valid & (i_word_count == 3'b001);
	assign i_data_buffer_wen[2] = (i_state == UPDATE_CACHE) & i_data_valid & (i_word_count == 3'b010);
	assign i_data_buffer_wen[3] = (i_state == UPDATE_CACHE) & i_data_valid & (i_word_count == 3'b011);
	assign i_data_buffer_wen[4] = (i_state == UPDATE_CACHE) & i_data_valid & (i_word_count == 3'b100);
	assign i_data_buffer_wen[5] = (i_state == UPDATE_CACHE) & i_data_valid & (i_word_count == 3'b101);
	assign i_data_buffer_wen[6] = (i_state == UPDATE_CACHE) & i_data_valid & (i_word_count == 3'b110);
	assign i_data_buffer_wen[7] = (i_state == UPDATE_CACHE) & i_data_valid & (i_word_count == 3'b111);

	
	assign i_write_word_count_en = (i_state == DONE);
	assign i_write_word_count_next = (i_state == UPDATE_CACHE && i_word_count == 3'b111) ? 3'b000 :
								(i_state == DONE) ? (i_write_word_count + 1'b1) : i_write_word_count;

	
	assign i_cache_data_in = (i_write_word_count == 3'b000) ? i_data_buffer[0] :
							(i_write_word_count == 3'b001) ? i_data_buffer[1] :
							(i_write_word_count == 3'b010) ? i_data_buffer[2] :
							(i_write_word_count == 3'b011) ? i_data_buffer[3] :
							(i_write_word_count == 3'b100) ? i_data_buffer[4] :
							(i_write_word_count == 3'b101) ? i_data_buffer[5] :
							(i_write_word_count == 3'b110) ? i_data_buffer[6] :
														i_data_buffer[7];

	
	assign i_write_cache = (i_state == DONE);
	assign i_write_tag = (i_state == DONE) & (i_write_word_count == 3'b111);

	
	assign i_block_enable = i_write_cache ? (1 << i_addr_reg[9:3]) : 128'b0;
	assign i_word_enable = i_write_cache ? (1 << i_write_word_count) : 8'b0;

	
	DataArray i_data_array(
		.clk(clk), 
		.rst(~rst_n), 
		.DataIn(i_cache_data_in),  
		.Write(i_write_cache), 
		.BlockEnable(i_block_enable), 
		.WordEnable(i_word_enable), 
		.DataOut(instr_data)
	);

	
	MetaDataArray i_tag_array(
		.clk(clk), 
		.rst(~rst_n), 
		.DataIn({i_addr_reg[15:10], 1'b1, 1'b0}),  
		.Write(i_write_tag), 
		.BlockEnable(i_block_enable), 
		.DataOut()  // Not used for write
	);
	
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




///////////////////////////////////////////////////

/*
	//D-cache FSM
    dff state_ff [2:0] (.clk(clk), 
                      .rst(~rst_n), 
                      .wen(1'b1), 
                      .d(state_next), 
                      .q(state));

  
    

    dff word_count_ff [2:0] (.clk(clk), 
                          .rst(~rst_n), 
                          .wen(word_count_en), 
                          .d(word_count_next), 
                          .q(word_count));

 
    

    dff addr_reg_ff [15:0] (.clk(clk),     //keeps track of addr so can see if it is grabbing it multiple times
                          .rst(~rst_n), 
                          .wen(addr_reg_en), 
                          .d(mem_addr),     
                          .q(addr_reg));


    

    dff data_buffer_ff0 [15:0] (.clk(clk),.rst(~rst_n),.wen(data_buffer_wen[0]),.d(mem_data_out),.q(data_buffer[0]));
    dff data_buffer_ff1 [15:0] (.clk(clk),.rst(~rst_n),.wen(data_buffer_wen[1]),.d(mem_data_out),.q(data_buffer[1]));
    dff data_buffer_ff2 [15:0] (.clk(clk),.rst(~rst_n),.wen(data_buffer_wen[2]),.d(mem_data_out),.q(data_buffer[2]));
    dff data_buffer_ff3 [15:0] (.clk(clk),.rst(~rst_n),.wen(data_buffer_wen[3]),.d(mem_data_out),.q(data_buffer[3]));
    dff data_buffer_ff4 [15:0] (.clk(clk),.rst(~rst_n),.wen(data_buffer_wen[4]),.d(mem_data_out),.q(data_buffer[4]));
    dff data_buffer_ff5 [15:0] (.clk(clk),.rst(~rst_n),.wen(data_buffer_wen[5]),.d(mem_data_out),.q(data_buffer[5]));
    dff data_buffer_ff6 [15:0] (.clk(clk),.rst(~rst_n),.wen(data_buffer_wen[6]),.d(mem_data_out),.q(data_buffer[6]));
    dff data_buffer_ff7 [15:0] (.clk(clk),.rst(~rst_n),.wen(data_buffer_wen[7]),.d(mem_data_out),.q(data_buffer[7]));

    

    
  
    assign curr_mem_addr = {addr_reg[15:3], word_count};   

    memory4c memory_read(
        .clk(clk),
        .rst(~rst_n),
        .enable(enable_mem_read),
        .addr(curr_mem_addr),
        .wr(1'b0),    // Always reading during miss handling
        .data_in(16'h0),
        .data_out(mem_data_out),
        .data_valid(data_valid)
    );

 
    assign state_next = (state == IDLE && miss) ? REQUEST :                       
                      (state == REQUEST) ? WAIT_DATA :                            // Issue memory request
                      (state == WAIT_DATA && data_valid) ? UPDATE_CACHE :        
                      (state == UPDATE_CACHE && word_count < 3'b111) ? REQUEST :  
                      (state == UPDATE_CACHE && word_count == 3'b111) ? DONE :    // All words received
                      (state == DONE && write_word_count == 3'b111) ? IDLE :      
                      state;


    assign enable_mem_read = (state == REQUEST); 
    assign addr_reg_en = (state == IDLE) & miss;  

    assign word_count_en = ((state == IDLE) & miss) | (state == UPDATE_CACHE);
    assign word_count_next = (state == IDLE) ? 3'b000 : 
                           (state == UPDATE_CACHE) ? (word_count + 1'b1) : word_count;


    assign data_buffer_wen[0] = (state == UPDATE_CACHE) & data_valid & (word_count == 3'b000);
    assign data_buffer_wen[1] = (state == UPDATE_CACHE) & data_valid & (word_count == 3'b001);
    assign data_buffer_wen[2] = (state == UPDATE_CACHE) & data_valid & (word_count == 3'b010);
    assign data_buffer_wen[3] = (state == UPDATE_CACHE) & data_valid & (word_count == 3'b011);
    assign data_buffer_wen[4] = (state == UPDATE_CACHE) & data_valid & (word_count == 3'b100);
    assign data_buffer_wen[5] = (state == UPDATE_CACHE) & data_valid & (word_count == 3'b101);
    assign data_buffer_wen[6] = (state == UPDATE_CACHE) & data_valid & (word_count == 3'b110);
    assign data_buffer_wen[7] = (state == UPDATE_CACHE) & data_valid & (word_count == 3'b111);




    dff write_word_ff [2:0] (.clk(clk),
                           .rst(~rst_n),
                           .wen(write_word_count_en),
                           .d(write_word_count_next),
                           .q(write_word_count));

    assign write_word_count_en = (state == DONE);
    assign write_word_count_next = (state == UPDATE_CACHE && word_count == 3'b111) ? 3'b000 :
                                 (state == DONE) ? (write_word_count + 1'b1) : write_word_count;

    
    
    assign cache_data_in = (write_word_count == 3'b000) ? data_buffer[0] :
                          (write_word_count == 3'b001) ? data_buffer[1] :
                          (write_word_count == 3'b010) ? data_buffer[2] :
                          (write_word_count == 3'b011) ? data_buffer[3] :
                          (write_word_count == 3'b100) ? data_buffer[4] :
                          (write_word_count == 3'b101) ? data_buffer[5] :
                          (write_word_count == 3'b110) ? data_buffer[6] :
                                                      data_buffer[7];

   
    assign write_cache = (state == DONE);                 
    assign write_tag = (state == DONE) & (write_word_count == 3'b111); 


    assign block_enable = write_cache ? (1 << addr_reg[9:3]) : 128'b0;
    assign word_enable = write_cache ? (1 << write_word_count) : 8'b0;  // One-hot for current word

   
    DataArray data_array(
        .clk(clk), 
        .rst(~rst_n), 
        .DataIn(cache_data_in),  
        .Write(write_cache), 
        .BlockEnable(block_enable), 
        .WordEnable(word_enable), 
        .DataOut(mem_data)
    );

   
    MetaDataArray tag_array(
        .clk(clk), 
        .rst(~rst_n), 
        .DataIn({addr_reg[15:10], 1'b1, 1'b0}),  
        .Write(write_tag), 
        .BlockEnable(block_enable), 
        .DataOut()  // Not used for write
    );
	assign mem_invalid = (state != IDLE);
    */
    
	assign mem_invalid = 1'b0;

endmodule