create_ip -vendor xilinx.com -library ip -name clk_wiz -module_name mmcm -dir $ip_dir -force
set_property -dict [list \
	CONFIG.PRIMITIVE {MMCM} \
	CONFIG.RESET_TYPE {ACTIVE_LOW} \
	CONFIG.CLKOUT1_USED {true} \
        CONFIG.CLKOUT2_USED {true} \
        CONFIG.CLKOUT3_USED {true} \
	CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {166.000} \
        CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} \
        CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {25.000} \
	] [get_ips mmcm]
