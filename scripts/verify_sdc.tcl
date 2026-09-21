read_lef /home/fayiz/vlsi/pdk/sky130hd/lef/sky130_fd_sc_hd.tlef
read_lef /home/fayiz/vlsi/pdk/sky130hd/lef/sky130_fd_sc_hd_merged.lef
read_liberty /home/fayiz/vlsi/pdk/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog synthesis/Top_netlist.v
link_design Top
read_sdc constraints/top.sdc
report_clock_properties
check_setup -verbose
report_checks -path_delay max

