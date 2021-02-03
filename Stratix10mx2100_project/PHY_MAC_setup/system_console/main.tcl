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


#==============================================================================
#        Main Reference Design Test CLI
#==============================================================================  

source basic/basic.tcl
source system_base_addr_map.tcl
source test_functions.tcl
source mac/mac_inc.tcl
source phy/phy_ip_inc.tcl
source test_parameter/parameter.tcl
source traffic_controller/traffic_controller.tcl
source channel_setting.tcl

# Test with external tester, loopback from Avalon-ST RX to Avalon-ST TX
proc TEST_ST_LB {channel speed} {
    
    global MAC_DST_ADDRESS
    
    puts "\t CONFIGURE CHANNEL $channel"
    SET_CHANNEL_BASE_ADDR $channel
    
    # Configure PHY speed
    if {$speed == "10G"} {
        SETPHY_SPEED_10G
    } elseif {$speed == "1G"} {
        SETPHY_SPEED_1G
    } else {
        SETPHY_SPEED_2P5G
    }
    
    # Configure MAC
    #CONFIG_MAC_BASIC_NO_MOD $MAC_DST_ADDRESS
    CONFIG_MAC_BASIC $MAC_DST_ADDRESS
    #
    ## Configure Traffic Controller
    #SET_TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR [expr $channel/2]
    #SELECT_STD_ETHERNET_TRAFFIC_CONTROLLER
    #SET_TRAFFIC_CONTROLLER_STD_CHANNEL_BASE_ADDR $channel
    #SET_AVALON_ST_LOOPBACK_ENA
    
    # External tester should send packets to the DUT and expect packets loopback to the tester
    
}

# Test with internal packet generator and monitor, loopback from serial TX to serial RX
proc TEST_EXT_LB {channel speed burst_size} {
    
    global MAC_DST_ADDRESS
    
    puts "\t CONFIGURE CHANNEL $channel"
    SET_CHANNEL_BASE_ADDR $channel
    
    # Configure PHY speed
    if {$speed == "10G"} {
        SETPHY_SPEED_10G
    } elseif {$speed == "1G"} {
        SETPHY_SPEED_1G
    } else {
        SETPHY_SPEED_2P5G
    }
    
    # Configure MAC
    #CONFIG_MAC_BASIC $MAC_DST_ADDRESS
    
    # Configure Traffic Controller
    #selector base address channel id = channel id /2
    #for example if channel id = 2, this wil be set 1
    #if channel id = 3, this will be set to 3/2 = 1
    #SET_TRAFFIC_CONTROLLER_SELECTOR_BASE_ADDR [expr $channel/2]  
    #SELECT_STD_ETHERNET_TRAFFIC_CONTROLLER
    #SET_TRAFFIC_CONTROLLER_STD_CHANNEL_BASE_ADDR $channel
    #RESET_AVALON_ST_LOOPBACK_ENA
    #
    #CONFIG_TRAFFIC_CONTROL $burst_size
    #
    #SETGEN_START
    #after 200
    #CHKMON_DONE
    #CHKMON_STATUS
    #CHKMAC_TXSTATS
    #CHKMAC_RXSTATS
}
