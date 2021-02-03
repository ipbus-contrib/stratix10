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


# Channel Base Address
source system_base_addr_map.tcl

proc SET_CHANNEL_BASE_ADDR {channel_id} {
    global BASE_ADDR_CHANNEL_0
    global BASE_ADDR_CHANNEL_1
    global BASE_ADDR_CHANNEL_2
    global BASE_ADDR_CHANNEL_3
    global BASE_ADDR_CHANNEL_4
    global BASE_ADDR_CHANNEL_5
    global BASE_ADDR_CHANNEL_6
    global BASE_ADDR_CHANNEL_7
    global BASE_ADDR_CHANNEL_8
    global BASE_ADDR_CHANNEL_9
    global BASE_ADDR_CHANNEL_10
    global BASE_ADDR_CHANNEL_11
    
    global BASE_ADDR
    global 10GMAC_BASE_ADDR
    global PHY_IP_BASE_ADDR
    
    global CHANNEL_NUMBER
    
    set CHANNEL_NUMBER $channel_id
    
    if {$channel_id == 0}        {set BASE_ADDR $BASE_ADDR_CHANNEL_0
    } elseif {$channel_id == 1}  {set BASE_ADDR $BASE_ADDR_CHANNEL_1
    } elseif {$channel_id == 2}  {set BASE_ADDR $BASE_ADDR_CHANNEL_2
    } elseif {$channel_id == 3}  {set BASE_ADDR $BASE_ADDR_CHANNEL_3
    } elseif {$channel_id == 4}  {set BASE_ADDR $BASE_ADDR_CHANNEL_4
    } elseif {$channel_id == 5}  {set BASE_ADDR $BASE_ADDR_CHANNEL_5
    } elseif {$channel_id == 6}  {set BASE_ADDR $BASE_ADDR_CHANNEL_6
    } elseif {$channel_id == 7}  {set BASE_ADDR $BASE_ADDR_CHANNEL_7
    } elseif {$channel_id == 8}  {set BASE_ADDR $BASE_ADDR_CHANNEL_8
    } elseif {$channel_id == 9}  {set BASE_ADDR $BASE_ADDR_CHANNEL_9
    } elseif {$channel_id == 10} {set BASE_ADDR $BASE_ADDR_CHANNEL_10
    } elseif {$channel_id == 11} {set BASE_ADDR $BASE_ADDR_CHANNEL_11
    } 
    
    set 10GMAC_BASE_ADDR         [expr {$BASE_ADDR + 0x0000}]
    set PHY_IP_BASE_ADDR         [expr {$BASE_ADDR + 0x8000}]
    
}
