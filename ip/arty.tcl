#
# Parameters
#

set_param general.maxThreads 8

set top    {arty_top}
set part   {xc7a35ticsg324-1L}
set board  {digilentinc.com:arty:part0:1.1}
set debug  0
set ip_dir {output}

set inc_list    {}
set ip_list     {uart.tcl jtag_axilite.tcl}
set file_list   {}
set xdc_list    {}

#
# Project
#

create_project -part $part -force $top
set_property -dict [list \
		    BOARD_PART $board \
		    TARGET_LANGUAGE {Verilog} \
		    DEFAULT_LIB {xil_defaultlib} \
		    IP_REPO_PATHS $ip_dir \
		    ] [current_project]

#
# IP
#

update_ip_catalog -rebuild
foreach f $ip_list { source $f }
foreach f [get_files -all {*.xci}]$ { set_property GENERATE_SYNTH_CHECKPOINT {false} -quiet $f }

generate_target all [get_ips]
synth_ip [get_ips]
