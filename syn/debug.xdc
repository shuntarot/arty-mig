create_debug_core u_ila ila

set_property port_width 1 [get_debug_ports u_ila/clk]
connect_debug_port u_ila/clk [get_nets clk]

set probe_list [get_nets r_count_reg*]
set_property port_width [llength $probe_list] [get_debug_ports u_ila/probe0]
connect_debug_port u_ila/probe0 $probe_list

