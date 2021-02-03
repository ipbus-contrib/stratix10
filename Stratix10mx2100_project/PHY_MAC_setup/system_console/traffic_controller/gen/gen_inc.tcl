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


#!/usr/bin/tclsh8.4
##==============================================================================
##        Generator Registers Map
##==============================================================================
source traffic_controller/gen/gen_reg_map.tcl
source basic/basic.tcl
source system_base_addr_map.tcl

proc SET_1588_GO_MASTER {} {
    global TRAFFIC_CONTROLLER_BASE_ADDR
    global GO_MASTER
    puts "\t Master 1588 start 1 step operation "
    puts "TRAFFIC_CONTROLLER_BASE_ADDR: $TRAFFIC_CONTROLLER_BASE_ADDR   "
    reg_write $TRAFFIC_CONTROLLER_BASE_ADDR $GO_MASTER 0x00000003
}

proc SET_1588_START_TOD_SYNC {} {
    global TRAFFIC_CONTROLLER_BASE_ADDR
    global START_TOD_SYNC
    puts "\t Start TOD synchronization "
    reg_write $TRAFFIC_CONTROLLER_BASE_ADDR $START_TOD_SYNC 0xFF
}

proc RESET_1588_GO_MASTER {} {
    global TRAFFIC_CONTROLLER_BASE_ADDR
    global GO_MASTER
    puts "\t Reset Master 1588 start 1 step operation "
    reg_write $TRAFFIC_CONTROLLER_BASE_ADDR $GO_MASTER 0x00000000
}

proc RESET_1588_START_TOD_SYNC {} {
    global TRAFFIC_CONTROLLER_BASE_ADDR
    global START_TOD_SYNC
    puts "\t Reset Start TOD synchronization "
    reg_write $TRAFFIC_CONTROLLER_BASE_ADDR $START_TOD_SYNC 0x00000000
}

proc SETGEN_PAYLOADRANDOM {} {
    global GEN_BASE_ADDR
    global GEN_RANDOMPAYLOAD
    puts "\t payload bytes = random bytes .... "
    reg_write $GEN_BASE_ADDR $GEN_RANDOMPAYLOAD 0x00000001
}

proc SETGEN_PAYLOADFIXED {} {
    global GEN_BASE_ADDR
    global GEN_RANDOMPAYLOAD
    puts "\t payload bytes = fixed incremental bytes .... "
    reg_write $GEN_BASE_ADDR $GEN_RANDOMPAYLOAD 0x00000000
}

proc SETGEN_LENGTHRANDOM {} {
    global GEN_BASE_ADDR
    global GEN_RANDOMLENGTH
    puts "\t payload length = variable (random) .... "
    reg_write $GEN_BASE_ADDR $GEN_RANDOMLENGTH 0x00000001
}

proc SETGEN_LENGTHFIXED {} {
    global GEN_BASE_ADDR
    global GEN_RANDOMLENGTH
    puts "\t payload length = fixed .... "
    reg_write $GEN_BASE_ADDR $GEN_RANDOMLENGTH 0x00000000
}

proc SETGEN_PKTLENGTH {value} {
    global GEN_BASE_ADDR
    global GEN_PKTLENGTH
    puts "\t payload length =  $value .... "
    reg_write $GEN_BASE_ADDR $GEN_PKTLENGTH $value
}
proc SETGEN_START {} {
    global GEN_BASE_ADDR
    global GEN_START
    puts "\t burst being injected into device ...."
    reg_write $GEN_BASE_ADDR $GEN_START  0x00000001
}

proc SETGEN_STOP {} {
    global GEN_BASE_ADDR
    global GEN_STOP
    puts "\t burst generation stopped ..."
    reg_write $GEN_BASE_ADDR $GEN_STOP 0x00000001
}

proc SETGEN_NUMPKTS {value} {
    global GEN_BASE_ADDR
    global GEN_NUMPKTS
    puts "\t burst size =  $value ...."
    reg_write $GEN_BASE_ADDR $GEN_NUMPKTS $value
}

proc SETGEN_MACDA {value} {
    global GEN_BASE_ADDR
    global GEN_MACDA0
    global GEN_MACDA1
    set gen_dst_addr1 0x[string range $value 0 3]
    set gen_dst_addr0 0x[string range $value 4 11]
    puts "\t frame destination addres field = $value ...."
    reg_write $GEN_BASE_ADDR $GEN_MACDA1 $gen_dst_addr1
    reg_write $GEN_BASE_ADDR $GEN_MACDA0 $gen_dst_addr0
}

proc SETGEN_MACSA {value} {
    global GEN_BASE_ADDR
    global GEN_MACSA0
    global GEN_MACSA1
    set gen_src_addr1 0x[string range $value 0 3]
    set gen_src_addr0 0x[string range $value 4 11]
    puts "\t frame source addres field = $value ...."
    reg_write $GEN_BASE_ADDR $GEN_MACSA1 $gen_src_addr1
    reg_write $GEN_BASE_ADDR $GEN_MACSA0 $gen_src_addr0
}

proc CONFIG_BURST {burst_type burst_size pkt_type pkt_size } {
    if {$burst_type == "RANDOM"} {SETGEN_LENGTHRANDOM} else {SETGEN_LENGTHFIXED}
    if {$pkt_type == "RANDOM"} {SETGEN_PAYLOADRANDOM} else {SETGEN_PAYLOADFIXED}
    SETGEN_NUMPKTS $burst_size
    SETGEN_PKTLENGTH $pkt_size
}

proc CHKGEN_CONFIG {} {
    
    global GEN_BASE_ADDR
    global GEN_NUMPKTS
    global GEN_RANDOMLENGTH
    global GEN_RANDOMPAYLOAD
    global GEN_START
    global GEN_STOP
    global GEN_MACSA0
    global GEN_MACSA1
    global GEN_MACDA0
    global GEN_MACDA1
    global GEN_TXPKTCNT
    global GEN_RNDSEED0
    global GEN_RNDSEED1
    global GEN_RNDSEED2
    global GEN_PKTLENGTH
    
    puts "\t             ================================================================="
    puts "\t             | GENERATOR CONFIGURATION AND STATUS                             "
    puts "\t             ================================================================="
    puts "\t             | NUM OF FRAMES_CONFIGURED             = [format %u [reg_read $GEN_BASE_ADDR $GEN_NUMPKTS]] "
    puts "\t             | NUM OF FRAMES_TRANSMITTED            = [format %u [reg_read $GEN_BASE_ADDR $GEN_TXPKTCNT]] "
    puts "\t             | FRAME_LENGTH_CONFIGURED              = [format %u [reg_read $GEN_BASE_ADDR $GEN_PKTLENGTH]] "
    puts "\t             | RANDOM_LENGTH_CONFIGURATION          = [format %u [reg_read $GEN_BASE_ADDR $GEN_RANDOMLENGTH]] "
    puts "\t             | RANDOM_PAYLOAD_CONFIGURATION         = [format %u [reg_read $GEN_BASE_ADDR $GEN_RANDOMPAYLOAD]] "
    puts "\t             | FRAME_SOURCE_ADDRESS_CONFIGURED      = [reg_read $GEN_BASE_ADDR $GEN_MACSA1] "
    puts "\t             | FRAME_DESTINATION_ADDRESS_CONFIGURED = [reg_read $GEN_BASE_ADDR $GEN_MACDA1] "
    puts "\t             | Generator Start value                = [reg_read $GEN_BASE_ADDR $GEN_START] "

}

proc PROCESS_GEN {} {
    CHKGEN_CONFIG
}
