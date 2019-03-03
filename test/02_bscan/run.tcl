#
# Setup
#

set dev 0

open_hw
connect_hw_server
open_hw_target -jtag_mode 1
current_hw_device [lindex [get_hw_devices] $dev]
refresh_hw_device [lindex [get_hw_devices] $dev]

run_state_hw_jtag reset ;# can be remoted

#
# Functions
#

proc create_bscan {new_tbl} {
    upvar $new_tbl tbl
    set tbl(BYPASS)    3f
    set tbl(IDCODE)    09
    set tbl(USER4)     23
    set tbl(CFG_OUT)   04
    set tbl(CFG_IN)    05
}

proc test_scan {} {
    create_bscan bs
    
    scan_ir_hw_jtag 6 -tdi $bs(USER4)  ;# start increment counter
    after 1000
    scan_ir_hw_jtag 6 -tdi $bs(BYPASS) ;# stop counter 
    
    return 0
}

proc test_idcode {} {
    create_bscan bs
    
    scan_ir_hw_jtag 6 -tdi $bs(IDCODE)
    set val [scan_dr_hw_jtag 32 -tdi 0]
    scan_ir_hw_jtag 6 -tdi $bs(BYPASS)

    set idcode "0362d093"
    
    if {[string match  $idcode $val]} {
	puts [format "IDCODE  %s" $val]
	return 0
    } else {
	puts [format "IDCODE shoud be $idcode but got %s" $val]
	return 1
    }
}

#
# Regression tests
#

set total_error 0

incr total_error [test_scan]
incr total_error [test_idcode]

puts "==================="
if {$total_error == 0} {
    puts "  PASSED"
} else {
    puts "  FAILED"
}
puts "==================="
exit
