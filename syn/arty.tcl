#
# Parameters
#

set_param general.maxThreads 8

set top    {arty_top}
set part   {xc7a35ticsg324-1L}
set board  {digilentinc.com:arty:part0:1.1}
set debug  0
set output {output}

set inc_list    {}
set ip_dir      {../ip/output}
set file_list   {../rtl/arty_top.sv ../rtl/cmn.sv}
set xdc_list    {arty.xdc}

#
# Project
#

set_part $part

#
# IP
#

read_ip [glob -directory $ip_dir [file join * {*.xci}]]

#
# Read files
#

# set_property INCLUDE_DIRS $inc_list [current_fileset]

foreach f $file_list { read_verilog -sv $f }
foreach f $xdc_list  { read_xdc $f }

#
# Synthesis
#

synth_design -top $top -part $part -flatten_hierarchy none -directive Default

#
# Chipscope
#
if {$debug} {
    read_xdc debug.xdc
    implement_debug_core [get_debug_cores]
}

#
# Implementation
#

opt_design
place_design
phys_opt_design
route_design

#
# Report
#

report_datasheet                 -file $output/datasheet.txt
report_io                        -file $output/io.rpt
report_clocks                    -file $output/clock.rpt
report_timing_summary            -file $output/timing.rpt -max_paths 10
report_utilization -hierarchical -file $output/util.rpt
report_clock_utilization         -file $output/util.rpt -append
report_ram_utilization           -file $output/util.rpt -append -detail
report_high_fanout_nets          -file $output/fanout.rpt -timing -load_types -max_nets 25
report_drc                       -file $output/drc.rpt

#
# Output
#

write_checkpoint   -force $output/$top
write_bitstream    -force $output/$top
write_debug_probes -force $output/$top
