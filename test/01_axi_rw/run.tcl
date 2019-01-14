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

proc test_rw {{count 12}} {
    set err 0
    for {set i 0} {$i < $count} {incr i} {
        set input  [expr $i << 24 | $i << 16 | $i << 8 | $i]
        set expect $input
        set addr [expr $i * 4]
        mw $addr $input
        set actual [mr $addr]
        if {$expect != $actual} {
            puts [format "ERROR %08x: actual %08x expect %08x" $addr $actual $expect]
            incr err
        }
    }
    md 0 $count
    return $err
}

proc test_range {} {
    # 16-bit 256MB DDR3 DRAM
    set err 0
    set count 256

    for {set i 0} {$i < $count} {incr i} {
        set input  [expr $i << 24 | $i << 16 | $i << 8 | $i]
	set addr [expr 1024 * 1024 * $i] ;# 1MiB step
        mw $addr $input
    }
    for {set i 0} {$i < $count} {incr i} {
        set expect  [expr $i << 24 | $i << 16 | $i << 8 | $i]
	set addr [expr 1024 * 1024 * $i] ;# 1MiB step
        set actual [mr $addr]
        if {$expect != $actual} {
            puts [format "ERROR %08x: actual %08x expect %08x" $addr $actual $expect]
            incr err
        }
    }
    return $err
}

#
# Regression tests
#

set total_error 0

incr total_error [test_rw 100]
incr total_error [test_range]

puts "==================="
if {$total_error == 0} {
    puts "  PASSED"
} else {
    puts "  FAILED"
}
puts "==================="
exit
