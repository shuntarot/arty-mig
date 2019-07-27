#
# Setup
#

set dev 0
set bit "../../syn/output/arty_top.bit"
set ltx "../../syn/output/arty_top.ltx"

open_hw
connect_hw_server
open_hw_target
current_hw_device [lindex [get_hw_devices] $dev]
set_property PROGRAM.FILE ${bit} [lindex [get_hw_devices] $dev]
set_property FULL_PROBES.FILE ${ltx} [lindex [get_hw_devices] $dev]
refresh_hw_device [lindex [get_hw_devices] $dev]

#
# Functions
#

source io.tcl

proc test_hello {{msg " Hello World! "}} {
    set err 0

	set uart(rx)   0x0
	set uart(tx)   0x4
	set uart(stat) 0x8
	set uart(ctrl) 0xC

	md $uart(stat) 1
	
	for {set i 0} {$i < [string length $msg]} {incr i} {
		binary scan [string index $msg $i] c x
		mw $uart(tx) $x
	}
	
	md $uart(stat) 1
	
    return $err
}

#
# Regression tests
#

set total_error 0

incr total_error [test_hello "Hello World!"]

puts "==================="
if {$total_error == 0} {
    puts "  PASSED"
} else {
    puts "  FAILED"
}
puts "==================="
exit
