module forwarding_unit(
	input clk, rst_n,
	input [1:0] ex_ex_forwarding,
	input [1:0] ex_mem_forwarding,
	input mem_mem_forwarding,
	input [15:0] m_alu_result,
	input [15:0] w_reg_write_data,
	input [15:0] d_reg_rs, d_reg_rt,
	input [15:0] e_reg_rt,
	output reg [15:0] ex_forward_rs, ex_forward_rt,
	output reg [15:0] mem_forward_rt
);
	always @(*) begin
		// Forwarding logic for execute stage rs
		casex ({ex_ex_forwarding[0], ex_mem_forwarding[0]})
			// No forwarding
			4'b00: ex_forward_rs = d_reg_rs;
			// Forward from EX stage
			4'b1x: ex_forward_rs = m_alu_result;
			// Forward from MEM stage
			4'b01: ex_forward_rs = w_reg_write_data;
			// Error
			default: ex_forward_rs = 'x;
		endcase

		// Forwarding logic for execute stage rt
		casex ({ex_ex_forwarding[1], ex_mem_forwarding[1]})
			// No forwarding
			4'b00: ex_forward_rt = d_reg_rt;
			// Forward from EX stage
			4'b1x: ex_forward_rt = m_alu_result;
			// Forward from MEM stage
			4'b01: ex_forward_rt = w_reg_write_data;
			// Error
			default: ex_forward_rt = 'x;
		endcase

		case (mem_mem_forwarding)
			// No forwarding
			1'b0: mem_forward_rt = e_reg_rt;
			// Forward from MEM stage
			1'b1: mem_forward_rt = w_reg_write_data;
			// Error
			default: mem_forward_rt = 'x;
		endcase
	end
endmodule