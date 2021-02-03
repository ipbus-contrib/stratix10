# (C) 2001-2019 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


##==============================================================================
##		Generator Registers Map
##==============================================================================  
source traffic_controller/avalonstloopback/avalon_st_loopback_reg_map.tcl
source basic/basic.tcl
source system_base_addr_map.tcl

proc SET_AVALON_ST_LOOPBACK_ENA {} { 
    global AVALON_ST_LOOPBACK_BASE_ADDR
    global AVALON_ST_LOOPBACK_ENA
    puts "\t Enable Avalon ST Loopback"
    reg_write $AVALON_ST_LOOPBACK_BASE_ADDR $AVALON_ST_LOOPBACK_ENA 0x00000001  
}

proc RESET_AVALON_ST_LOOPBACK_ENA {} { 
    global AVALON_ST_LOOPBACK_BASE_ADDR
    global AVALON_ST_LOOPBACK_ENA
    puts "\t Disable Avalon ST Loopback"
    reg_write $AVALON_ST_LOOPBACK_BASE_ADDR $AVALON_ST_LOOPBACK_ENA 0x00000000  
}
