module detection_unit(
    input wire clk, rst_n,
    input wire [3:0] alu_op,
    input wire branching,
    input wire [2:0] e_flags,
    input wire [2:0] e_ccc,
    output reg stall_sig
);
reg is_branch;
always @(*) begin

    case (alu_op) 
        4'b1100: is_branch = 1'b1;
        4'b1101: is_branch = 1'b1;  //Was a branching instr 
        default: is_branch = 1'b0; //Stays 0
    endcase

    //Check branch conditions   --check e_flags, if they match the conditions in the machine code then branch
    case(e_flags)
        3'b000: stall_sig = is_branch & (e_ccc == 3'b000); //Not equal
        3'b001: stall_sig = is_branch & (e_ccc == 3'b001); //Equal
        3'b010: stall_sig = is_branch & (e_ccc == 3'b010); //Greater than
        3'b011: stall_sig = is_branch & (e_ccc == 3'b011); //Less than
        3'b100: stall_sig = is_branch & (e_ccc == 3'b100); //Greater than or equal
        3'b101: stall_sig = is_branch & (e_ccc == 3'b101); //Less than or equal
        3'b110: stall_sig = is_branch & (e_ccc == 3'b110); //Overflow
        3'b111: stall_sig = 1'b1; //Unconditional branch, will always be taken
        default: stall_sig = 1'b0; //No branch
    endcase


end













endmodule