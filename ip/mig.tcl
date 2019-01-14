create_ip -vendor xilinx.com -library ip -name mig_7series -module_name mig -dir $ip_dir -force
set_property CONFIG.XML_INPUT_FILE $env(XILINX_VIVADO)/data/boards/board_files/arty/C.0/mig.prj [get_ips mig]
