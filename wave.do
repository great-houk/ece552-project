onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/clk
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/rst_n
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/hlt
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/pc
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/f_instruction
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/f_pc_plus2
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_rd
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_rs
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_rt
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_imm
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_alu_op
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_alu_src1
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_alu_src2
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_mem_write_en
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_mem_read_en
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_reg_write_en
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_reg_write_src
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_next_pc
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_opcode_raw
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_rs_raw
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_rt_raw
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_branching
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_pc_plus2
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_halt
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_reg_rs
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/d_reg_rt
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_alu_result
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_flags
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_rd
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_rs
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_rt
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_reg_rt
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_flag_update
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_mem_write_en
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_mem_read_en
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_reg_write_en
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_reg_write_src
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/e_halt
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_mem_addr
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_mem_write_data
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_mem_read_en
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_mem_write_en
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_alu_result
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_rd
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_rs
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_rt
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_reg_write_en
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_reg_write_src
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/m_halt
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/w_reg_write_data
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/w_reg_write_en
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/w_rd
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/stall_decode
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/flush
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/ex_ex_forwarding
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/ex_mem_forwarding
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/mem_mem_forwarding
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/stall_fetch
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/stall_mem
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/instr_data
add wave -noupdate -radix hexadecimal /cpu_tb3/DUT/mem_data
add wave -noupdate {/cpu_tb3/DUT/decode_stage/instr_dff[0]/q}
add wave -noupdate {/cpu_tb3/DUT/decode_stage/instr_dff[0]/d}
add wave -noupdate {/cpu_tb3/DUT/decode_stage/instr_dff[0]/wen}
add wave -noupdate {/cpu_tb3/DUT/decode_stage/instr_dff[0]/clk}
add wave -noupdate {/cpu_tb3/DUT/decode_stage/instr_dff[0]/rst}
add wave -noupdate {/cpu_tb3/DUT/decode_stage/instr_dff[0]/state}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 235
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3510 ps} {5610 ps}
