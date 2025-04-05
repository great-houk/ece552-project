module detection_unit(
    input [3:0] curr_rs, curr_rt,
    input [3:0] e_rd, m_rd,
    input [3:0] alu_op,
    output stall_sig
);
//Mainly used for checking branching and and stalling if the branch is taken --so have to look at which instructions modify the flags 

//if flags in execute stage match flags for alu operation, use case statement


wire temp;
// assign temp = 










endmodule