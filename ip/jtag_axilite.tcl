create_ip -name jtag_axi -vendor xilinx.com -library ip -module_name jtag_axilite -dir $ip_dir -force
set_property -dict [list CONFIG.PROTOCOL {2}] [get_ips jtag_axilite]
