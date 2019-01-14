#
# JTAG AXI IO wrapper
#
# - word size is 32bit
# - len does not supported yet

proc mr {addr {len 1}} {
    set ret {}
    for {set i 0} {$i < $len} {incr i} {
	lappend ret [_mr [expr $addr + 4 * $i]]
    }
    return $ret
}

proc _mr {addr} {

    set hex_addr [format "%08x" [expr $addr & ~3]]
    create_hw_axi_txn rd [lindex [get_hw_axis] 0] \
	-address $hex_addr \
	-len 1 \
	-type read
    
    run_hw_axi -quiet rd
    set out [report_hw_axi_txn rd -t x4]
    delete_hw_axi_txn rd
    scan [lindex $out 1] %x ret
    return $ret
}

proc mw {addr data {len 1}} {
    for {set i 0} {$i < $len} {incr i} {
	_mw [expr $addr + 4 * $i] $data
    }
}

proc _mw {addr data} {
    
    set hex_addr [format "%08x" [expr $addr & ~3]]
    set val [format "%08x" [expr $data]]
    
    create_hw_axi_txn wr [lindex [get_hw_axis] 0] \
	-address $hex_addr \
	-len 1 \
	-data $val \
	-type write
    run_hw_axi -quiet wr 
    delete_hw_axi_txn wr
}

proc print_read_value {result addr} {
    upvar $result val

    set i 0
    foreach v $val {
    if {$i%4 == 0} {
        puts -nonewline [format "%08x:" [expr $addr + $i*4]]
    }
    puts -nonewline [format " %08x" $v]
    if {$i%4 == 3} { puts "" }
    incr i
    }
    if {$i%4 != 3} { puts "" }
}

proc md {addr {len 4}} {
    set result [mr $addr $len]
    print_read_value result $addr
}
