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
##        Generator Registers Map
##==============================================================================
source traffic_controller/gen/gen_inc.tcl
source traffic_controller/mon/mon_inc.tcl
source traffic_controller/avalonstloopback/avalon_st_loopback_inc.tcl

proc CONFIG_TRAFFIC {bursttype burstsize pkttype pktsize macsaddr macdaddr} {
    
    puts "\n"
    puts "\t ==================================================================================== "
    puts "\t        B E G I N     C O N F I G U R A T I O N                                       "
    puts "\t ==================================================================================== "
    
    CONFIG_BURST $bursttype $burstsize $pkttype $pktsize
    SETGEN_MACSA $macsaddr
    SETGEN_MACDA $macdaddr
    
    set exp_pkts [format "%#x" [expr $burstsize - 0]]
    SETMON_RXCNT_RESET
    SETMON_RXPKTCNT_EXPT $exp_pkts
}

proc SELECT_1588_TRAFFIC_CONTROLLER {} {
    global TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR
    
    puts "\t Select 1588 traffic controller "
    reg_write $TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR 0x0 0x00000000
}

proc SELECT_STD_ETHERNET_TRAFFIC_CONTROLLER {} {
    global TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR

    puts "\t Select std ethernet traffic controller "
    reg_write $TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR 0x0 0x00000001
}

proc SET_TRAFFIC_CONTROLLER_STD_CHANNEL_BASE_ADDR {channel_id} {
    global TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_0
    global TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_1
    global TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_2
    global TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_3
    global TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_4
    global TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_5
    global TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_6
    global TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_7
    global TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_8
    global TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_9
    
    global TRAFFIC_CONTROLLER_BASE_ADDR
    global AVALON_ST_LOOPBACK_BASE_ADDR
    global GEN_BASE_ADDR
    global MON_BASE_ADDR
    
    if {$channel_id == 0} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_0
    } elseif {$channel_id == 1} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_1
    } elseif {$channel_id == 2} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_2
    } elseif {$channel_id == 3} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_3
    } elseif {$channel_id == 4} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_4
    } elseif {$channel_id == 5} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_5
    } elseif {$channel_id == 6} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_6
    } elseif {$channel_id == 7} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_7
    } elseif {$channel_id == 8} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_8
    } elseif {$channel_id == 9} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_BASE_ADDR_CHANNEL_9
    }
    
    set GEN_BASE_ADDR                [expr {$TRAFFIC_CONTROLLER_BASE_ADDR +  0x0000}]
    set MON_BASE_ADDR                [expr {$TRAFFIC_CONTROLLER_BASE_ADDR +  0x0400}]
    set AVALON_ST_LOOPBACK_BASE_ADDR [expr {$TRAFFIC_CONTROLLER_BASE_ADDR +  0x0800}]
}

proc SET_TRAFFIC_CONTROLLER_1588_CHANNEL_BASE_ADDR {channel_id} {
    
    global TRAFFIC_CONTROLLER_1588_BASE_ADDR_0
    global TRAFFIC_CONTROLLER_1588_BASE_ADDR_1
    global TRAFFIC_CONTROLLER_1588_BASE_ADDR_2
    global TRAFFIC_CONTROLLER_1588_BASE_ADDR_3
    global TRAFFIC_CONTROLLER_1588_BASE_ADDR_4
    
    global TRAFFIC_CONTROLLER_BASE_ADDR
    
    if {$channel_id == 0} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_1588_BASE_ADDR_0
    } elseif {$channel_id == 1} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_1588_BASE_ADDR_1
    } elseif {$channel_id == 2} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_1588_BASE_ADDR_2
    } elseif {$channel_id == 3} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_1588_BASE_ADDR_3
    } elseif {$channel_id == 4} {
        set TRAFFIC_CONTROLLER_BASE_ADDR $TRAFFIC_CONTROLLER_1588_BASE_ADDR_4
    }
}

proc SET_TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR {channel_id} {
    
    global TRAFFIC_CONTROLLER_SELECTOR_0
    global TRAFFIC_CONTROLLER_SELECTOR_1
    global TRAFFIC_CONTROLLER_SELECTOR_2
    global TRAFFIC_CONTROLLER_SELECTOR_3
    global TRAFFIC_CONTROLLER_SELECTOR_4
    
    global TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR
    
    if {$channel_id == 0} {
        set TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR $TRAFFIC_CONTROLLER_SELECTOR_0
    } elseif {$channel_id == 1} {
        set TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR $TRAFFIC_CONTROLLER_SELECTOR_1
    } elseif {$channel_id == 2} {
        set TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR $TRAFFIC_CONTROLLER_SELECTOR_2
    } elseif {$channel_id == 3} {
        set TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR $TRAFFIC_CONTROLLER_SELECTOR_3
    } elseif {$channel_id == 4} {
        set TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR $TRAFFIC_CONTROLLER_SELECTOR_4
    }
}
