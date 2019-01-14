#
# Parameters
#

set dev 0
set bit "output/arty_top.bit"

#
# Program
#

open_hw
connect_hw_server
open_hw_target

current_hw_device [lindex [get_hw_devices] $dev]
set_property PROGRAM.FILE ${bit} [lindex [get_hw_devices] $dev]

program_hw_devices [lindex [get_hw_devices] $dev]
# verify_hw_devices [lindex [get_hw_devices] $dev]

quit
