create_ip -name axi_uartlite -vendor xilinx.com -library ip -version 2.0 -module_name uart -dir $ip_dir -force
set_property -dict [list CONFIG.C_BAUDRATE {115200}] [get_ips uart]
