create_ip -name jtag_axi -vendor xilinx.com -library ip -module_name jtag_axi -dir $ip_dir -force
set_property -dict [list CONFIG.M_AXI_DATA_WIDTH {32} CONFIG.M_AXI_ID_WIDTH {4}] [get_ips jtag_axi]
