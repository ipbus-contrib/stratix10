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


source system_base_addr_map.tcl
source channel_setting.tcl
source basic/basic.tcl
source mac/mac_inc.tcl
source rcfg/mge_rcfg_inc.tcl
source traffic_controller/traffic_controller.tcl

proc CONFIG_TRAFFIC_CONTROL {burst_size} {

    global MAC_SRC_ADDRESS
    global MAC_DST_ADDRESS
    global BURST_TYPE
    global PACKET_TYPE
    global PACKET_SIZE

    CONFIG_TRAFFIC $BURST_TYPE $burst_size $PACKET_TYPE $PACKET_SIZE $MAC_SRC_ADDRESS $MAC_DST_ADDRESS

}
