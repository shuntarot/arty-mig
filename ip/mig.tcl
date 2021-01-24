if {![catch {set board_files $env(BOARD_FILES)}]} {
    set mig_prj $board_files/arty/C.0/mig.prj
} else {
    set mig_prj $env(XILINX_VIVADO)/data/boards/board_files/arty/C.0/mig.prj
}

create_ip -vendor xilinx.com -library ip -name mig_7series -module_name mig -dir $ip_dir -force
set_property CONFIG.XML_INPUT_FILE $mig_prj [get_ips mig]
