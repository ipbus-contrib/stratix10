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
##        Monitor Registers Map
##==============================================================================
source traffic_controller/mon/mon_reg_map.tcl
source basic/basic.tcl
source system_base_addr_map.tcl

proc CHK_1588_STATUS {} {
    global TRAFFIC_CONTROLLER_BASE_ADDR
    global DELAY_FNS_H
    global DELAY_FNS_L
    global OFFSET_FNS_H
    global OFFSET_FNS_L
    global ERROR
    
    puts "\t delay ns   = [reg_read $TRAFFIC_CONTROLLER_BASE_ADDR $DELAY_FNS_H]"
    puts "\t delay fns  = [reg_read $TRAFFIC_CONTROLLER_BASE_ADDR $DELAY_FNS_L]"
    puts "\t offset ns  = [reg_read $TRAFFIC_CONTROLLER_BASE_ADDR $OFFSET_FNS_H]"
    puts "\t offset fns = [reg_read $TRAFFIC_CONTROLLER_BASE_ADDR $OFFSET_FNS_L]"
    
    set value  [reg_read $TRAFFIC_CONTROLLER_BASE_ADDR $ERROR]
    
    set master_error [expr {$value & 1<<0}]
    if {$master_error == 0x01} {
        puts "\t master error"
    }
    
    set slave_error [expr {$value & 1<<1}]
    if {$slave_error == 0x02} {
        puts "\t slave error"
    }
    
    set master_crc_error [expr {$value & 1<<2}]
    if {$master_crc_error == 0x04} {
        puts "\t master crc error "
    }
    
    set slave_crc_error [expr {$value & 1<<3}]
    if {$slave_crc_error == 0x08} {
        puts "\t slave crc error"
    }
    
}

proc WAIT_OFFSET_DELAY_CAPTURED {} {

    global TRAFFIC_CONTROLLER_BASE_ADDR;
    global CAPT_OFFSET_START
    set start_capture 0
    puts "\t Waiting capturing offset delay ... "
    set test_done 0
    set count 0
    while {$test_done == 0} {
        if {$count == 60} {
            set test_done -1
            puts "\t     -- Break"
        } else {
            set start_capture [reg_read $TRAFFIC_CONTROLLER_BASE_ADDR $CAPT_OFFSET_START]
            
            if {$start_capture == 0x01} {
                set test_done 1
            }
            
            incr count
        }
    }

    puts "\t Start capturing offset delay ... "

}

proc SETMON_STOP {} {
    global MON_BASE_ADDR
    global MON_RXCTRL_STATUS
    puts "\t stoping [user requested] Packet Checker "
    reg_write $MON_BASE_ADDR $MON_RXCTRL_STATUS 0x00000002
}

proc SETMON_RXCNT_RESET {} {
    global MON_BASE_ADDR
    global MON_RXCTRL_STATUS
    puts "\t reseting monitor Packet Counters        "
    reg_write $MON_BASE_ADDR $MON_RXCTRL_STATUS 0x00000001
}

proc SETMON_RXPKTCNT_EXPT {value} {
    global MON_BASE_ADDR
    global MON_RXPKTCNT_EXPT
    puts "\t number of Packets Expected By Monitor = $value "
    reg_write $MON_BASE_ADDR $MON_RXPKTCNT_EXPT $value
}

proc CHKMON_STATUS {} {
    global MON_BASE_ADDR
    global MON_RXBYTECNT_LO32
    global MON_RXBYTECNT_HI32
    global MON_RXCYCLCNT_LO32
    global MON_RXCYCLCNT_HI32
    global MON_RXCTRL_STATUS
    global MON_RXPKTCNT_GOOD
    global MON_RXPKTCNT_BAD
    global LOBYTES
    global HIBYTES
    global LOWCYCLES
    global HICYCLES
    global SUMBYTES
    global SUMCYCLES
    
    #set LOBYTES   [format %u [reg_read $MON_BASE_ADDR $MON_RXBYTECNT_LO32]]
    #set HIBYTES   [format %u [reg_read $MON_BASE_ADDR $MON_RXBYTECNT_HI32]]
    #set LOCYCLES  [format %u [reg_read $MON_BASE_ADDR $MON_RXCYCLCNT_LO32]]
    #set HICYCLES  [format %u [reg_read $MON_BASE_ADDR $MON_RXCYCLCNT_HI32]]
    #set SUMBYTES  [format %u [expr ((4294967295*$HIBYTES) + $LOBYTES)]]
    #set SUMBYTES  [format %u [expr ((4294967295 * $HIBYTES) + $LOBYTES)]]
    
    set LOBYTES   [format %u [reg_read $MON_BASE_ADDR $MON_RXBYTECNT_LO32]]
    set HIBYTES   [format %u [reg_read $MON_BASE_ADDR $MON_RXBYTECNT_HI32]]
    set LOCYCLES  [format %u [reg_read $MON_BASE_ADDR $MON_RXCYCLCNT_LO32]]
    set HICYCLES  [format %u [reg_read $MON_BASE_ADDR $MON_RXCYCLCNT_HI32]]
    
    set SUMBYTES  [format %u  [expr { 4294967295*$HIBYTES + $LOBYTES}]]
    set SUMCYCLES [format %u  [expr { 4294967295*$HICYCLES + $LOCYCLES}]]
    set THRUPUT   [format %2.2f [expr {1.25*$SUMBYTES/$SUMCYCLES}]]
    
    puts "\t _________________________________________________________________________________________________________________________\n"
    puts "\t     -- (MONITOR) GOOD PKTS RECEIVED     = [format %u [reg_read $MON_BASE_ADDR $MON_RXPKTCNT_GOOD]]"
    puts "\t     -- (MONITOR) BAD PKTS RECEIVED      = [format %u [reg_read $MON_BASE_ADDR $MON_RXPKTCNT_BAD]] "
    puts "\t     -- (MONITOR) BYTES RECEIVED         = $SUMBYTES "
    puts "\t     -- (MONITOR) CYCLES USED            = $SUMCYCLES "
    puts "\t     -- (MONITOR) THROUGHPUT CALCULATED  = $THRUPUT Gbps"
    puts "\t     -- (MONITOR) RXBYTECNT_LO32         = [format %u [reg_read $MON_BASE_ADDR $MON_RXBYTECNT_LO32]]"
    puts "\t     -- (MONITOR) RXBYTECNT_HI32         = [format %u [reg_read $MON_BASE_ADDR $MON_RXBYTECNT_HI32]]"
    puts "\t     -- (MONITOR) RXCYCLCNT_LO32         = [format %u [reg_read $MON_BASE_ADDR $MON_RXCYCLCNT_LO32]]"
    puts "\t     -- (MONITOR) RXCYCLCNT_HI32         = [format %u [reg_read $MON_BASE_ADDR $MON_RXCYCLCNT_HI32]]"
    puts "\t _________________________________________________________________________________________________________________________\n"
    
}

proc PROCESS_MON {} {
    CHKMON_STATUS
}

proc CHKMON_DONE {} {
    global MON_BASE_ADDR
    global MON_RXBYTECNT_LO32
    global MON_RXBYTECNT_HI32
    global MON_RXCYCLCNT_LO32
    global MON_RXCYCLCNT_HI32
    global MON_RXCTRL_STATUS
    global MON_RXPKTCNT_GOOD
    global MON_RXPKTCNT_BAD
    global LOBYTES
    global HIBYTES
    global LOWCYCLES
    global HICYCLES
    global SUMBYTES
    global SUMCYCLES
    set rx_status 0
    set test_done 0
    set total_pkts_rcv -1
    
    puts "\t     -- MONITOR processing frames received .....\n\n"
    while {$test_done == 0} {
        after 8000
        set rx_status [reg_read $MON_BASE_ADDR $MON_RXCTRL_STATUS]
        set test_done [expr $rx_status & 0x4]
        set previous_total_pkts_rcv $total_pkts_rcv
        
        set good_pkts [format %u [reg_read $MON_BASE_ADDR $MON_RXPKTCNT_GOOD]]
        set bad_pkts [format %u [reg_read $MON_BASE_ADDR $MON_RXPKTCNT_BAD]]
        set total_pkts_rcv [expr $good_pkts + $bad_pkts]]
        puts "\t     -- MONITOR Received  Packet#   $total_pkts_rcv \n"
        
        if {$previous_total_pkts_rcv == $total_pkts_rcv} {
            set test_done -1
            puts "\t     -- Break : No furtuer packet is being generated or received "
        }
    }
    
    if {$test_done == 0x4} {
        puts "\t     -- DONE! - monitor received all expected sum of packets ..... \n"
    } elseif {$total_pkts_rcv == 0} {
        puts "\t     -- WARNING! - monitor unable to receive any packet ..... \n"
    } else {
        puts "\t     -- WARNING! - monitor unable to receive all expected sum of packets ..... \n"
    }
    
}
