module detection_unit(
    input wire clk, rst_n,
    input wire branching,
    input wire e_flag_update,
    input wire mem_read_en,
    input wire m_reg_write_en,
    input wire e_reg_write_en,
    input wire w_reg_write_en,
    input wire e_reg_write_src,
    input wire [3:0] d_rs, d_rt,
    input wire [3:0] e_rs, e_rt, e_rd,
    input wire [3:0] m_rs, m_rt, m_rd,
    input wire [3:0] w_rd,
    input wire [2:0] e_flags,
    input wire [2:0] e_ccc,
    output reg stall,
    output reg flush,
    output reg ex_ex_forwarding,
    output reg mem_ex_forwarding,
    output reg mem_mem_forwarding
);
reg is_ld, ex_ex_forward_rs, ex_ex_forward_rt;
reg ex_mem_forwarding_rs, ex_mem_forwarding_rt;

always @(*) begin

    is_ld = mem_read_en & e_reg_write_en & e_reg_write_src;  //Instr in execute read from me, writes to reg 

    //Ex-Ex Forewording
    ex_ex_forward_rs = m_reg_write_en & (m_rd == e_rs) & (m_rd != 4'b0000); //Writing to reg, and not reg R0
    ex_ex_forward_rt = m_reg_write_en & (m_rd == e_rt) & (m_rd != 4'b0000);

    ex_ex_forwarding = ex_ex_forward_rs | ex_ex_forward_rt; //If either of them are true then we need to forward the data


    //Mem-Ex Forewording
    ex_mem_forwarding_rs = w_reg_write_en & (w_rd == e_rs) & (w_rd != 4'b0000); 
    ex_mem_forwarding_rs = w_reg_write_en & (w_rd == e_rt) & (w_rd != 4'b0000);

    mem_ex_forwarding = ex_mem_forwarding_rs | ex_mem_forwarding_rt; 

    //Mem-Mem Forewording
    mem_mem_forwarding = m_reg_write_en & (w_rd == m_rt) & (w_rd != 4'b0000) & is_ld;


    //RAW hazard and ld instr -- need stall
    stall = is_ld & (e_rd == d_rs | e_rd == d_rt) & (e_rd != 4'b0000) | (e_flag_update & branching); 


    //Branching detection
    //Check branch conditions   --check e_flags, if they match the conditions in the machine code then branch --must flush instr in fetch/decode
    case(e_flags)
        3'b000: flush = branching & (e_ccc == 3'b000); //Not equal
        3'b001: flush = branching & (e_ccc == 3'b001); //Equal
        3'b010: flush = branching & (e_ccc == 3'b010); //Greater than
        3'b011: flush = branching & (e_ccc == 3'b011); //Less than
        3'b100: flush = branching & (e_ccc == 3'b100); //Greater than or equal
        3'b101: flush = branching & (e_ccc == 3'b101); //Less than or equal
        3'b110: flush = branching & (e_ccc == 3'b110); //Overflow
        3'b111: flush = 1'b1; //Unconditional branch, will always be taken
        default: flush = 1'b0; //No branch
    endcase


 


end













endmodule