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
source phy/phy_ip_reg_map.tcl

# Serial loopback mode is used for internal testing only
proc SETPHY_SERIAL_LLPBK {} {
    global PHY_IP_BASE_ADDR
    global PHY_CONTROL_REG
    global PHY_SERIAL_LOOPBACK
    puts "\t Enabling serial PMA Loopback (local)"
    reg_write $PHY_IP_BASE_ADDR $PHY_CONTROL_REG [expr (1 << $PHY_SERIAL_LOOPBACK)]
}

proc RESETPHY_SERIAL_LLPBK {} {
    global PHY_IP_BASE_ADDR
    global PHY_CONTROL_REG
    global PHY_SERIAL_LOOPBACK
    puts "\t Disabling serial PMA Loopback (local)"
    reg_write $PHY_IP_BASE_ADDR $PHY_CONTROL_REG [expr (0 << $PHY_SERIAL_LOOPBACK)]
}

# Clause 37 Auto-Negotiation
proc SETPHY_CL_37_AN {} {
    global PHY_IP_BASE_ADDR
    global PHY_CONTROL_REG
    puts "\t Enabling Clause 37 Auto-Negotiation"
    reg_write $PHY_IP_BASE_ADDR $PHY_CONTROL_REG 0x1140
}

proc RESETPHY_CL_37_AN {} {
    global PHY_IP_BASE_ADDR
    global PHY_CONTROL_REG
    puts "\t Disabling Clause 37 Auto-Negotiation"
    reg_write $PHY_IP_BASE_ADDR $PHY_CONTROL_REG 0x0140
}

proc SETPHY_CL_37_AN_RESTART {} {
    global PHY_IP_BASE_ADDR
    global PHY_CONTROL_REG
    puts "\t Enabling Clause 37 Auto-Negotiation Restart"
    reg_write $PHY_IP_BASE_ADDR $PHY_CONTROL_REG 0x1340
}

proc SETPHY_AN_DEV_ABILITY {value} {
    global PHY_IP_BASE_ADDR
    global PHY_DEV_ABILITY_REG
    puts "\t Setting $value into dev_ability"
    reg_write $PHY_IP_BASE_ADDR $PHY_DEV_ABILITY_REG $value
}

# PHY Status
proc CHKPHY_STATUS {} {
    global PHY_IP_BASE_ADDR
    global PHY_CONTROL_REG
    global PHY_STATUS_REG
    global PHY_ID_0_REG
    global PHY_ID_1_REG
    global PHY_DEV_ABILITY_REG
    global PHY_PARTNER_ABILITY_REG
    global PHY_AN_EXPANSION_REG
    
    puts "\t PHY Controls    = 0x[format %X [reg_read $PHY_IP_BASE_ADDR $PHY_CONTROL_REG]]"
    puts "\t PHY Status      = 0x[format %X [reg_read $PHY_IP_BASE_ADDR $PHY_STATUS_REG]]"
    puts "\t PHY ID 0        = 0x[format %X [reg_read $PHY_IP_BASE_ADDR $PHY_ID_0_REG]]"
    puts "\t PHY ID 1        = 0x[format %X [reg_read $PHY_IP_BASE_ADDR $PHY_ID_1_REG]]"
    puts "\t Dev Ability     = 0x[format %X [reg_read $PHY_IP_BASE_ADDR $PHY_DEV_ABILITY_REG]]"
    puts "\t Partner Ability = 0x[format %X [reg_read $PHY_IP_BASE_ADDR $PHY_PARTNER_ABILITY_REG]]"
    puts "\t AN Expansion    = 0x[format %X [reg_read $PHY_IP_BASE_ADDR $PHY_AN_EXPANSION_REG]]"
}
