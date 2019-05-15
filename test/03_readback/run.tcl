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

# import xapp1230 scripts
source readback.tcl
script_setup

proc create_bscan {new_tbl} {
    upvar $new_tbl tbl
    set tbl(BYPASS)    3f
    set tbl(IDCODE)    09
    set tbl(USER4)     23
    set tbl(CFG_OUT)   04
    set tbl(CFG_IN)    05
}

proc create_cfg {new_tbl} {
    upvar $new_tbl tbl
    set tbl(crc)      0
    set tbl(far)      1
    set tbl(fdri)     2
    set tbl(fdro)     3
    set tbl(cmd)      4
    set tbl(ctl0)     5
    set tbl(mask)     6
    set tbl(stat)     7
    set tbl(lout)     8
    set tbl(cor0)     9
    set tbl(mfwr)     a
    set tbl(cbc)      b
    set tbl(idcode)   c
    set tbl(axss)     d
    set tbl(cor1)     e
    set tbl(wbstar)   f
    set tbl(timer)   10
    set tbl(bootsts) 11
    set tbl(ctl1)    12
    set tbl(bspi)    13
}

# == type1 ==
# [31:29] header    001: type1
# [28:27] opcode    00:noop, 01:read, 10:write, 11:reserved
# [26:13] reg addr  00001:FAR, 00111:STAT, 01100:IDCODE
# [12:11] reserved
# [10:0]  word count
proc create_t1 {op addr {count 1}} {
    set tmp 001

    # puts [format "t1: %s %s %s" $op $addr $count]

    if {[string match $op "r"]} {
        append tmp 01
    } elseif {[string match $op "w"]} {
        append tmp 10
    } else {
        append tmp 00 ;# noop
    }

    append tmp [conv2bin 14 $addr]
    append tmp 00
    append tmp [conv2bin 11 $count]
    return [conv2hex 32 $tmp]
}

# == type2 ==
# [31:29] header    010: type2
# [28:27] opcode    00:noop, 01:read, 10:write, 11:reserved
# [26:0]  word count
proc create_t2 {op {count 1}} {
    set tmp 010

    if {[string match $op "r"]} {
        append tmp 01
    } elseif {[string match $op "w"]} {
        append tmp 10
    } else {
        append tmp 00 ;# noop
    }

    append tmp [conv2bin 27 $count]
    return [conv2hex 32 $tmp]
}

proc test_idcode {} {
    puts "Test IDCODE read via CFG_OUT"
    create_bscan bs
    create_cfg cr

    scan_ir_hw_jtag 6 -tdi $bs(CFG_IN)

    set    tmp ffffffff ;# dummy
    append tmp aa995566 ;# sync
    append tmp 20000000 ;# noop
    append tmp [create_t1 "r" $cr(idcode) 1] ;# idcode read
    append tmp 20000000 ;# noop
    append tmp 20000000 ;# noop

    scan_dr_hw_jtag [expr 6 * 32] -tdi [revHexData $tmp]

    scan_ir_hw_jtag 6 -tdi $bs(CFG_OUT)
    set val [scan_dr_hw_jtag 32 -tdi 0]
    set val [revHexData $val]

    set idcode "0362d093"

    if {[string match -nocase $idcode $val]} {
        puts [format "IDCODE  %s" $val]
        return 0
    } else {
        puts [format "IDCODE shoud be $idcode but got %s" $val]
        return 1
    }
}

# device  config     config frame    config   config
#         bitstrea   frames length   array    overhead
#         length            in words size in  in
#                                    words    words
#
# xcku040 128055264   32530 123      4001190  537   # (* (+ (* 32530 123) 537) 32) => 128055264
# xcvu440 1031731104 262110 123     32239530 2067   # (* (+ (* 262110 123) 2067) 32) => 1031731104
# xc7a35t 17536096

proc test_readback {} {
    puts "Test readback capture"
    create_bscan bs
    create_cfg cr
    set noop 20000000
    set num_words [expr (262110 + 1) * 123 + 10]

    # readback capture
    scan_ir_hw_jtag 6 -tdi $bs(CFG_IN)

    set    tmp ffffffff ;# dummy
    append tmp aa995566 ;# sync
    append tmp $noop
    append tmp [create_t1 "w" $cr(cmd) 1]
    append tmp [format "%08x" 0]
    append tmp [create_t1 "w" $cr(mask) 1]
    append tmp [format "%08x" [expr 1 << 23]]
    append tmp [create_t1 "w" $cr(ctl1) 1]
    append tmp [format "%08x" [expr 1 << 23]]
    append tmp $noop
    append tmp $noop
    append tmp $noop
    append tmp $noop
    append tmp $noop
    append tmp $noop
    append tmp $noop
    append tmp $noop
    append tmp [create_t1 "w" $cr(far) 1]
    append tmp [format "%08x" 0]
    append tmp [create_t1 "w" $cr(cmd) 1]
    append tmp [format "%08x" 4] ;# RCFG
    append tmp [create_t1 "w" $cr(fdro) 0]
    append tmp [create_t2 "w" [format "%x" $num_words]]
    append tmp $noop

    puts $tmp
    scan_dr_hw_jtag [expr 24 * 32] -tdi [revHexData $tmp]

    scan_ir_hw_jtag 6 -tdi $bs(CFG_OUT)
    set val [scan_dr_hw_jtag 32 -tdi 0]

    # revert CTL1
    scan_ir_hw_jtag 6 -tdi $bs(CFG_IN)
    scan_dr_hw_jtag 1000 -tdi 0

    return 0
}

proc count_up {{ms 1000}} {
    create_bscan bs
    
    scan_ir_hw_jtag 6 -tdi $bs(USER4)  ;# start increment counter
    after $ms
    scan_ir_hw_jtag 6 -tdi $bs(BYPASS) ;# stop counter 
}

#
# Regression tests
#

set total_error 0

# incr total_error [test_idcode]

rdbk_jtag "out.rdbk" 4455 1

puts "==================="
if {$total_error == 0} {
    puts "  PASSED"
} else {
    puts "  FAILED"
}
puts "==================="
exit
