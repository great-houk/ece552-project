module fetch_stage (
    input  clk,               
    input  rst_n,             
    input  [15:0] next_pc,    // Next PC value
    output [15:0] instruction,// Output instruction
    output [15:0] pc_out,      // Output PC value
	output [15:0] pc_plus2	   //PC+2 value
);

//Take instruction from instr memory and pass it to the output
//Increment the pc counter

wire en;
wire write;
parameter [15:0] increment = 16'h0002;
wire ovfl_p2;
wire [15:0] sl2;
wire [15:0] temp_pc_plus2; 

//Instantiate defaults
assign en = 1;
assign write = 0;
assign pc_out = next_pc;
//Instatiate instruction memory
memory1c imem(.data_out(instruction), .data_in(16'h0000), .addr(next_pc), .enable(en), .wr(write), .clk(clk), .rst(rst_n));

//Create PC + 2
cla_16bit pc_plus2_add(.a(next_pc[15:0]), .b(increment), .cin(1'b0), .sum(temp_pc_plus2), .cout(ovfl_p2));

//Overflow handling
assign pc_plus2 = (ovfl_p2) ? (16'h0000):(temp_pc_plus2);



endmodule