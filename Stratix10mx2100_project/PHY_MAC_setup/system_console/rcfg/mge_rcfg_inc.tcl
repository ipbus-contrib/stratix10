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


source basic/basic.tcl
source system_base_addr_map.tcl
source rcfg/mge_rcfg_reg_map.tcl

proc SETPHY_SPEED_10G {} {
    
    global RCFG_BASE_ADDR
    global MGE_RCFG_LOGICAL_CHANNEL_NUMBER
    global MGE_RCFG_CONTROL
    global MIF_SELECT
    global RECONFIG_START
    global CHANNEL_NUMBER
    
    puts "\t Configure to 10G"
    
    set speed 3
    
    reg_write $RCFG_BASE_ADDR $MGE_RCFG_LOGICAL_CHANNEL_NUMBER $CHANNEL_NUMBER
    reg_write $RCFG_BASE_ADDR $MGE_RCFG_CONTROL [expr ((1 << $RECONFIG_START) | ($speed << $MIF_SELECT))]
    
}

proc SETPHY_SPEED_2P5G {} {
    
    global RCFG_BASE_ADDR
    global MGE_RCFG_LOGICAL_CHANNEL_NUMBER
    global MGE_RCFG_CONTROL
    global MIF_SELECT
    global RECONFIG_START
    global CHANNEL_NUMBER
    
    puts "\t Configure to 2.5G"
    
    set speed 1
    
    reg_write $RCFG_BASE_ADDR $MGE_RCFG_LOGICAL_CHANNEL_NUMBER $CHANNEL_NUMBER
    reg_write $RCFG_BASE_ADDR $MGE_RCFG_CONTROL [expr ((1 << $RECONFIG_START) | ($speed << $MIF_SELECT))]
    
}

proc SETPHY_SPEED_1G {} {
    
    global RCFG_BASE_ADDR
    global MGE_RCFG_LOGICAL_CHANNEL_NUMBER
    global MGE_RCFG_CONTROL
    global MIF_SELECT
    global RECONFIG_START
    global CHANNEL_NUMBER
    
    puts "\t Configure to 1G"
    
    set speed 0
    
    reg_write $RCFG_BASE_ADDR $MGE_RCFG_LOGICAL_CHANNEL_NUMBER $CHANNEL_NUMBER
    reg_write $RCFG_BASE_ADDR $MGE_RCFG_CONTROL [expr ((1 << $RECONFIG_START) | ($speed << $MIF_SELECT))]
    
}
