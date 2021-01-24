#
# Parameters
#

if {![catch {set board_files $env(BOARD_FILES)}]} {
    set_param board.repoPaths $board_files
}
set_param general.maxThreads 8

set top    {arty_top}
set part   {xc7a35ticsg324-1L}
set board  {digilentinc.com:arty:part0:1.1}
set ip_dir {output}

set inc_list    {}
set ip_list     {mmcm.tcl mig.tcl jtag_axi.tcl}
set file_list   {}
set xdc_list    {}

#
# Project
#

set_part $part

#
# IP
#

update_ip_catalog -rebuild
foreach f $ip_list { source $f }
foreach f [get_files -all {*.xci}]$ { set_property GENERATE_SYNTH_CHECKPOINT {false} -quiet $f }

generate_target all [get_ips]
synth_ip [get_ips]
