module cpu_tb3();
  

	wire [15:0] PC;
	wire [15:0] Inst;			  /* This should be the 15 bits of the FF that
											 stores instructions fetched from instruction memory
										 */
	wire		  RegWrite;		 /* Whether register file is being written to */
	wire [3:0]  WriteRegister;  /* What register is written */
	wire [15:0] WriteData;		/* Data */
	wire		  MemWrite;		 /* Similar as above but for memory */
	wire		  MemRead;
	wire [15:0] MemAddress;
	wire [15:0] MemDataIn;	/* Read from Memory */
	wire [15:0] MemDataOut;	/* Written to Memory */
	wire		  DCacheMiss;
	wire		  ICacheMiss;
	wire		  DCacheReq;
	wire		  ICacheReq;

	wire		  Halt;			/* Halt executed and in Memory or writeback stage */
		  
	integer	  inst_count;
	integer	  cycle_count;

	integer	  trace_file;
	integer	  sim_log_file;


	integer	  DCacheHit_count;
	integer	  ICacheHit_count;
	integer	  DCacheReq_count;
	integer	  ICacheReq_count;


	reg clk; /* Clock input */
	reg rst_n; /* (Active low) Reset input */

	  

	cpu DUT(.clk(clk), .rst_n(rst_n), .pc(PC), .hlt(Halt)); /* Instantiate your processor */
	






	/* Setup */
	initial begin
		$display("Hello world...simulation starting");
		$display("See verilogsim.plog and verilogsim.ptrace for output");
		inst_count = 0;
		DCacheHit_count = 0;
		ICacheHit_count = 0;
		DCacheReq_count = 0;
		ICacheReq_count = 0;

		trace_file = $fopen("verilogsim.ptrace");
		sim_log_file = $fopen("verilogsim.plog");
		
	end





  /* Clock and Reset */
// Clock period is 100 time units, and reset length
// to 201 time units (two rising edges of clock).

	initial begin
		$dumpvars;
		cycle_count = 0;
		rst_n = 0; /* Intial reset state */
		clk = 1;
		#201 rst_n = 1; // delay until slightly after two clock periods
	 end

	 always #50 begin	// delay 1/2 clock period each time thru loop
		clk = ~clk;
	 end
	
	 always @(posedge clk) begin
	 	cycle_count = cycle_count + 1;
	if (cycle_count > 100000) begin
		$display("hmm....more than 100000 cycles of simulation...error?\n");
		$stop;
	end
	 end








  /* Stats */
	always @ (posedge clk) begin
		if (rst_n) begin
			if (Halt || RegWrite || MemWrite) begin
				inst_count = inst_count + 1;
			end
	 if (DCacheMiss) begin
				DCacheHit_count = DCacheHit_count - 1;
			end	
	 if (ICacheMiss) begin
				ICacheHit_count = ICacheHit_count - 1;
	 end	 
	 if (DCacheReq) begin
				DCacheReq_count = DCacheReq_count + 1;
				DCacheHit_count = DCacheHit_count + 1;
			end	
	 if (ICacheReq) begin
				ICacheReq_count = ICacheReq_count + 1;
				ICacheHit_count = ICacheHit_count + 1;
	 end 

			$fdisplay(sim_log_file, "SIMLOG:: Cycle %d PC: %8x I: %8x R: %d %3d %8x M: %d %d %8x %8x %8x",
						cycle_count,
						PC,
						Inst,
						RegWrite,
						WriteRegister,
						WriteData,
						MemRead,
						MemWrite,
						MemAddress,
						MemDataIn,
		  MemDataOut);
			if (RegWrite) begin
				$fdisplay(trace_file,"REG: %d VALUE: 0x%04x",
							 WriteRegister,
							 WriteData );				
			end
			if (MemRead) begin
				$fdisplay(trace_file,"LOAD: ADDR: 0x%04x VALUE: 0x%04x",
							 MemAddress, MemDataOut );
			end

			if (MemWrite) begin
				$fdisplay(trace_file,"STORE: ADDR: 0x%04x VALUE: 0x%04x",
							 MemAddress, MemDataIn  );
			end
			if (Halt) begin
				$fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
				$fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", cycle_count);
				$fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);
				$fdisplay(sim_log_file, "SIMLOG:: dcachehit_count %d\n", DCacheHit_count);
				$fdisplay(sim_log_file, "SIMLOG:: icachehit_count %d\n", ICacheHit_count);
				$fdisplay(sim_log_file, "SIMLOG:: dcachereq_count %d\n", DCacheReq_count);
				$fdisplay(sim_log_file, "SIMLOG:: icachereq_count %d\n", ICacheReq_count);


				$fclose(trace_file);
				$fclose(sim_log_file);
		 #5;
				$stop;
			end 
		end
		
	end
	/* Assign internal signals to top level wires
		The internal module names and signal names will vary depending
		on your naming convention and your design */

	// Edit the example below. You must change the signal
	// names on the right hand side
	
	//Instruction fetched in the current cycle
	assign Inst = DUT.f_instruction;
	
	// Is register file being written to in this cycle, one bit signal (1 means yes, 0 means no)
	assign RegWrite = DUT.w_reg_write_en;
  
	// If above is true, this should hold the name of the register being written to. (4 bit signal)
	assign WriteRegister = DUT.w_rd;
	
	// If above is true, this should hold the Data being written to the register. (16 bits)
	assign WriteData = DUT.w_reg_write_data;
	
	// Is memory being read from, in this cycle. one bit signal (1 means yes, 0 means no)
	assign MemRead = DUT.m_mem_read_en & ~DUT.m_mem_write_en & ~DUT.stall_mem;
	
	// Is memory being written to, in this cycle (1 bit signal)
	assign MemWrite = DUT.m_mem_write_en & ~DUT.stall_mem;
	
	// If there's a memory access this cycle, this should hold the address to access memory with (for both reads and writes to memory, 16 bits)
	assign MemAddress = DUT.m_mem_addr;
	
	// If there's a memory write in this cycle, this is the Data being written to memory (16 bits)
	assign MemDataIn = DUT.m_mem_write_data;
	
	// If there's a memory read in this cycle, this is the data being read out of memory (16 bits)
	assign MemDataOut = DUT.mem_data;

	// Signal indicating a valid instruction read request to cache
	assign ICacheReq = DUT.fetch_stage.should_inc;
	
	// Signal indicating a valid instruction cache hit
	assign ICacheMiss =
		DUT.cache_controller.read_amount == 3'b0 &&
		DUT.cache_controller.write_amount == 3'b0 &&
		DUT.cache_controller.state_next == 2'h1;

	// Signal indicating a valid instruction data read or write request to cache
	assign DCacheReq = (DUT.m_mem_read_en | DUT.m_mem_write_en) & ~DUT.stall_mem;
	
	// Signal indicating a valid data cache miss
	assign DCacheMiss =
		DUT.cache_controller.read_amount == 3'b0 &&
		DUT.cache_controller.write_amount == 3'b0 &&
		DUT.cache_controller.state_next == 2'h2;

	/* Add anything else you want here */
endmodule
