create_clock -name clk -period 10 [get_ports clk]

set_clock_uncertainty 0.5 [get_clocks clk]

set_input_delay -clock clk -max 3.0 [get_ports {start A_in[*] B_in[*] opcode[*]}]

set_output_delay -clock clk -max 3.0 [get_ports {result_out[*] carry zero_flag overflow_flag done}]

set_false_path -from [get_ports reset]

set_driving_cell -lib_cell sky130_fd_sc_hd__buf_1 [get_ports {start reset A_in[*] B_in[*] opcode[*]}]

set_load 0.05 [get_ports {result_out[*] carry zero_flag overflow_flag done}]

