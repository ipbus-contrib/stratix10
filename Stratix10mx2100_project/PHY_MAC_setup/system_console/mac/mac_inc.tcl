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
source mac/10g_mac_reg_map.tcl

proc CONFIG_MAC_BASIC {macaddr} {
    global MAX_FRAME_LENGTH

    puts "\t Setting up mac with a basic working config"
    SETMAC_PRIMARY_ADDR $macaddr

    # Enable RX CRC/Pad removal and TX CRC insertion
    SETMAC_INSERT_TX_CRC
    SETMAC_STRIP_RX_PADCRC

    SETMAC_RX_MAX_FRAME_LENGTH $MAX_FRAME_LENGTH
    SETMAC_TX_MAX_FRAME_LENGTH $MAX_FRAME_LENGTH

    SETMAC_CLR_STATS
}

proc CONFIG_MAC_BASIC_NO_MOD {macaddr} {
    global MAX_FRAME_LENGTH

    puts "\t Setting up mac with a basic working config"
    SETMAC_PRIMARY_ADDR $macaddr

    # Disable RX CRC/Pad removal and TX CRC insertion
    RESETMAC_INSERT_TX_CRC
    RESETMAC_STRIP_RX_PADCRC

    SETMAC_RX_MAX_FRAME_LENGTH $MAX_FRAME_LENGTH
    SETMAC_TX_MAX_FRAME_LENGTH $MAX_FRAME_LENGTH

    SETMAC_CLR_STATS
}

proc SETMAC_PRIMARY_ADDR {value} {
    global 10GMAC_BASE_ADDR
    global rx_frame_addr0
    global rx_frame_addr1
    set rx_mac_primaddr1 0x[string range $value 0 3]
    puts "\t Setting $rx_mac_primaddr1 into rxmac primary address Reg-1"
    reg_write $10GMAC_BASE_ADDR $rx_frame_addr1 $rx_mac_primaddr1

    set rx_mac_primaddr0 0x[string range $value 4 11]
    puts "\t Setting $rx_mac_primaddr0 into rxmac primary address Reg-0"
    reg_write $10GMAC_BASE_ADDR $rx_frame_addr0 $rx_mac_primaddr0
}

proc SETMAC_INSERT_TX_CRC {} {
    global 10GMAC_BASE_ADDR
    global tx_crcins_control
    puts "\t Enabling: crc insertion in tx mac"
    reg_write $10GMAC_BASE_ADDR $tx_crcins_control 0x00000003
}

proc RESETMAC_INSERT_TX_CRC {} {
    global 10GMAC_BASE_ADDR
    global tx_crcins_control
    puts "\t Disabling: crc insertion in tx mac"
    reg_write $10GMAC_BASE_ADDR $tx_crcins_control 0x00000000
}

proc SETMAC_STRIP_RX_PADCRC {} {
    global 10GMAC_BASE_ADDR
    global rx_padcrc_control
    puts "\t Enabling: pad and crc stripping in rx mac"
    reg_write $10GMAC_BASE_ADDR $rx_padcrc_control 0x00000003
}

proc RESETMAC_STRIP_RX_PADCRC {} {
    global 10GMAC_BASE_ADDR
    global rx_padcrc_control
    puts "\t Disabling: pad and crc stripping in rx mac"
    reg_write $10GMAC_BASE_ADDR $rx_padcrc_control 0x00000000
}

proc CHKMAC_STRIP_RX_PADCRC {} {
    global 10GMAC_BASE_ADDR
    global rx_padcrc_control
    puts "\t rxmac pad-crc stripping setting = "
    reg_read $10GMAC_BASE_ADDR $rx_padcrc_control
}

proc SETMAC_RX_MAX_FRAME_LENGTH {value} {
    global 10GMAC_BASE_ADDR
    global rx_frame_maxlength
    puts "\t Setting $value into rxmac max frame length"
    reg_write $10GMAC_BASE_ADDR $rx_frame_maxlength $value
}

proc CHKMAC_RX_MAX_FRAME_LENGTH {} {
    global 10GMAC_BASE_ADDR
    global rx_frame_maxlength
    puts "\t rxmac max frame length = "
    reg_read $10GMAC_BASE_ADDR $rx_frame_maxlength
}

proc SETMAC_TX_MAX_FRAME_LENGTH {value} {
    global 10GMAC_BASE_ADDR
    global tx_frame_maxlength
    puts "\t Setting $value into txmac max frame length"
    reg_write $10GMAC_BASE_ADDR $tx_frame_maxlength $value
}

proc CHKMAC_TX_MAX_FRAME_LENGTH {} {
    global 10GMAC_BASE_ADDR
    global tx_frame_maxlength
    puts "\t txmac max frame length = "
    reg_read $10GMAC_BASE_ADDR $tx_frame_maxlength
}

proc SETMAC_TX_IPG_10G {value} {
    global 10GMAC_BASE_ADDR
    global tx_ipg_10g
    puts "\t Setting $value into txmac 10G IPG"
    reg_write $10GMAC_BASE_ADDR $tx_ipg_10g $value
}

proc CHKMAC_TX_IPG_10G {} {
    global 10GMAC_BASE_ADDR
    global tx_ipg_10g
    puts "\t txmac 10G IPG = "
    reg_read $10GMAC_BASE_ADDR $tx_ipg_10g
}

proc SETMAC_CLR_STATS {} {
    global ClearStats
    global tClearStats
    
    global 10GMAC_BASE_ADDR
    puts "\t Clearing mac stats registers"
    reg_write $10GMAC_BASE_ADDR $tClearStats 0x01
    reg_write $10GMAC_BASE_ADDR $ClearStats 0x01
}

proc CHKMAC_RXSTATS {} {
    global 10GMAC_BASE_ADDR
    
    global framesOK_lo
    global framesErr_lo
    global framesCRCErr_lo
    global octetsOK_lo
    global pauseMACCtrlFrames_lo
    global ifErrors_lo
    global unicastFramesOK_lo
    global unicastFramesErr_lo
    global multicastFramesOK_lo
    global multicastFramesErr_lo
    global broadcastFramesOK_lo
    global broadcastFramesErr_lo
    global etherStatsOctets_lo
    global etherStatsPkts_lo
    global etherStatsUndersizePkts_lo
    global etherStatsOversizePkts_lo
    global etherStatsPkts64Octets_lo
    global etherStatsPkts65to127Octets_lo
    global etherStatsPkts128to255Octets_lo
    global etherStatsPkts256to511Octets_lo
    global etherStatsPkts512to1023Octets_lo
    global etherStatPkts1024to1518Octets_lo
    global etherStatsPkts1519toXOctets_lo
    global etherStatsFragments_lo
    global etherStatsJabbers_lo
    global etherStatsCRCErr_lo
    global unicastMACCtrlFrames_lo
    global multicastMACCtrlFrames_lo
    global broadcastMACCtrlFrames_lo
    
    puts "\t     ======================================================================"
    puts "\t     |  MAC RX STATS REGISTER CHECK                                        "
    puts "\t     ======================================================================"
    puts "\t     |# FRAMES_RECEIVED_WITH_ERROR               = [format %u [reg_read $10GMAC_BASE_ADDR $framesErr_lo                      ]]"
    puts "\t     |# UNICAST_FRAMES_WITH_ERROR                = [format %u [reg_read $10GMAC_BASE_ADDR $unicastFramesErr_lo               ]]"
    puts "\t     |# MULTICAST_FRAMES_RECEIVED_WITH_ERROR     = [format %u [reg_read $10GMAC_BASE_ADDR $multicastFramesErr_lo             ]]"
    puts "\t     |# BRDCAST_FRAMES_WITH_ERROR                = [format %u [reg_read $10GMAC_BASE_ADDR $broadcastFramesErr_lo             ]]"
    puts "\t     |# FRAMES_RECEIVED_WITH_ONLY_CRCERROR       = [format %u [reg_read $10GMAC_BASE_ADDR $framesCRCErr_lo                   ]]"
    puts "\t     |# VALID_LENGTH_FRAMES_WITH_CRC_ERROR       = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatsCRCErr_lo               ]]"
    puts "\t     |# JABBER_FRAMES                            = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatsJabbers_lo              ]]"
    puts "\t     |# FRAGMENTED_FRAMES                        = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatsFragments_lo            ]]"
    puts "\t     |# INVALID_FRAMES_RECEIVED                  = [format %u [reg_read $10GMAC_BASE_ADDR $ifErrors_lo                       ]]"
    
    puts "\t     |# FRAMES_RECEIVED_GOOD                     = [format %u [reg_read $10GMAC_BASE_ADDR $framesOK_lo                       ]]"
    puts "\t     |# PAUSE_FRAMES_RECEIVED                    = [format %u [reg_read $10GMAC_BASE_ADDR $pauseMACCtrlFrames_lo             ]]"
    puts "\t     |# UNICAST_CONTROL_FRAMES                   = [format %u [reg_read $10GMAC_BASE_ADDR $unicastMACCtrlFrames_lo           ]]"
    puts "\t     |# MULTICAST_CONTROL_FRAMES                 = [format %u [reg_read $10GMAC_BASE_ADDR $multicastMACCtrlFrames_lo         ]]"
    puts "\t     |# UNICAST_FRAMES_RECEIVED_GOOD             = [format %u [reg_read $10GMAC_BASE_ADDR $unicastFramesOK_lo                ]]"
    puts "\t     |# MULTICAST_FRAMES_RECEIVED_GOOD           = [format %u [reg_read $10GMAC_BASE_ADDR $multicastFramesOK_lo              ]]"
    puts "\t     |# BRDCAST_FRAMES_GOOD                      = [format %u [reg_read $10GMAC_BASE_ADDR $broadcastFramesOK_lo              ]]"
    puts "\t     |# DATA_AND_PADDING_OCTETS_RECEIVED_GOOD    = [format %u [reg_read $10GMAC_BASE_ADDR $octetsOK_lo                       ]]"
    
    puts "\t     |# COMPREHENSICE_OCTETS_RECEIVED            = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatsOctets_lo               ]]"
    puts "\t     |# FRAMES_WITH_SIZE_64_BYTES                = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatsPkts64Octets_lo         ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_64AND127_BYTES       = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatsPkts65to127Octets_lo    ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_128AND255_BYTES      = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatsPkts128to255Octets_lo   ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_256AND511_BYTES      = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatsPkts256to511Octets_lo   ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_512AND1K_BYTES       = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatsPkts512to1023Octets_lo  ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_1KND1518_BYTES       = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatPkts1024to1518Octets_lo  ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_ABOVE1519_BYTES      = [format %u [reg_read $10GMAC_BASE_ADDR $etherStatsPkts1519toXOctets_lo    ]]"
    
}

proc CHKMAC_TXSTATS {} {
    global 10GMAC_BASE_ADDR
    
    global tframesOK_lo
    global tframesErr_lo
    global tframesCRCErr_lo
    global toctetsOK_lo
    global tpauseMACCtrlFrames_lo
    global tifErrors_lo
    global tunicastFramesOK_lo
    global tunicastFramesErr_lo
    global tmulticastFramesOK_lo
    global tmulticastFramesErr_lo
    global tbroadcastFramesOK_lo
    global tbroadcastFramesErr_lo
    global tetherStatsOctets_lo
    global tetherStatsPkts_lo
    global tetherStatsUndersizePkts_lo
    global tetherStatsOversizePkts_lo
    global tetherStatsPkts64Octets_lo
    global tetherStatsPkts65to127Octets_lo
    global tetherStatsPkts128to255Octets_lo
    global tetherStatsPkts256to511Octets_lo
    global tetherStatsPkts512to1023Octets_lo
    global tetherStatPkts1024to1518Octets_lo
    global tetherStatsPkts1519toXOctets_lo
    global tetherStatsFragments_lo
    global tetherStatsJabbers_lo
    global tetherStatsCRCErr_lo
    global tunicastMACCtrlFrames_lo
    global tmulticastMACCtrlFrames_lo
    global tbroadcastMACCtrlFrames_lo
    
    puts "\t     ======================================================================"
    puts "\t     |  MAC TX STATS REGISTER CHECK                                        "
    puts "\t     ======================================================================"
    puts "\t     |# FRAMES_RECEIVED_WITH_ERROR               = [format %u [reg_read $10GMAC_BASE_ADDR $tframesErr_lo                     ]]"
    puts "\t     |# UNICAST_FRAMES_WITH_ERROR                = [format %u [reg_read $10GMAC_BASE_ADDR $tunicastFramesErr_lo              ]]"
    puts "\t     |# MULTICAST_FRAMES_RECEIVED_WITH_ERROR     = [format %u [reg_read $10GMAC_BASE_ADDR $tmulticastFramesErr_lo            ]]"
    puts "\t     |# BRDCAST_FRAMES_WITH_ERROR                = [format %u [reg_read $10GMAC_BASE_ADDR $tbroadcastFramesErr_lo            ]]"
    puts "\t     |# FRAMES_RECEIVED_WITH_ONLY_CRCERROR       = [format %u [reg_read $10GMAC_BASE_ADDR $tframesCRCErr_lo                  ]]"
    puts "\t     |# VALID_LENGTH_FRAMES_WITH_CRC_ERROR       = [format %u [reg_read $10GMAC_BASE_ADDR $tetherStatsCRCErr_lo              ]]"
    puts "\t     |# JABBER_FRAMES                            = [format %u [reg_read $10GMAC_BASE_ADDR $tetherStatsJabbers_lo             ]]"
    puts "\t     |# FRAGMENTED_FRAMES                        = [format %u [reg_read $10GMAC_BASE_ADDR $tetherStatsFragments_lo           ]]"
    puts "\t     |# INVALID_FRAMES_RECEIVED                  = [format %u [reg_read $10GMAC_BASE_ADDR $tifErrors_lo                      ]]"
    
    puts "\t     |# FRAMES_RECEIVED_GOOD                     = [format %u [reg_read $10GMAC_BASE_ADDR $tframesOK_lo                      ]]"
    puts "\t     |# PAUSE_FRAMES_RECEIVED                    = [format %u [reg_read $10GMAC_BASE_ADDR $tpauseMACCtrlFrames_lo            ]]"
    puts "\t     |# UNICAST_CONTROL_FRAMES                   = [format %u [reg_read $10GMAC_BASE_ADDR $tunicastMACCtrlFrames_lo          ]]"
    puts "\t     |# MULTICAST_CONTROL_FRAMES                 = [format %u [reg_read $10GMAC_BASE_ADDR $tmulticastMACCtrlFrames_lo        ]]"
    puts "\t     |# UNICAST_FRAMES_RECEIVED_GOOD             = [format %u [reg_read $10GMAC_BASE_ADDR $tunicastFramesOK_lo               ]]"
    puts "\t     |# MULTICAST_FRAMES_RECEIVED_GOOD           = [format %u [reg_read $10GMAC_BASE_ADDR $tmulticastFramesOK_lo             ]]"
    puts "\t     |# BRDCAST_FRAMES_GOOD                      = [format %u [reg_read $10GMAC_BASE_ADDR $tbroadcastFramesOK_lo             ]]"
    puts "\t     |# DATA_AND_PADDING_OCTETS_RECEIVED_GOOD    = [format %u [reg_read $10GMAC_BASE_ADDR $toctetsOK_lo                      ]]"
    
    puts "\t     |# COMPREHENSICE_OCTETS_RECEIVED            = [format %u [reg_read $10GMAC_BASE_ADDR $tetherStatsOctets_lo              ]]"
    puts "\t     |# FRAMES_WITH_SIZE_64_BYTES                = [format %u [reg_read $10GMAC_BASE_ADDR $tetherStatsPkts64Octets_lo        ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_64AND127_BYTES       = [format %u [reg_read $10GMAC_BASE_ADDR $tetherStatsPkts65to127Octets_lo   ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_128AND255_BYTES      = [format %u [reg_read $10GMAC_BASE_ADDR $tetherStatsPkts128to255Octets_lo  ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_256AND511_BYTES      = [format %u [reg_read $10GMAC_BASE_ADDR $tetherStatsPkts256to511Octets_lo  ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_512AND1K_BYTES       = [format %u [reg_read $10GMAC_BASE_ADDR $tetherStatsPkts512to1023Octets_lo ]]"
    puts "\t     |# FRAMES_BETWEEN_SIZE_1KND1518_BYTES       = [format %u [reg_read $10GMAC_BASE_ADDR $tetherStatPkts1024to1518Octets_lo ]]"
    
}

proc CHKMAC_CONFIG {} {
    global 10GMAC_BASE_ADDR
    
    global tx_addrins_control
    global tx_addrins_macaddr0
    global tx_addrins_macaddr1
    
    global rx_padcrc_control
    
    global rx_frame_addr0
    global rx_frame_addr1
    global rx_frame_maxlength
    
    global rx_frame_spaddr0_0
    global rx_frame_spaddr0_1
    global rx_frame_spaddr1_0
    global rx_frame_spaddr1_1
    global rx_frame_spaddr2_1
    global rx_frame_spaddr2_0
    global rx_frame_spaddr3_0
    global rx_frame_spaddr3_1
    
    puts "\t     =========================================================================="
    puts "\t     | MAC CONFIGURATION DUMP                           "
    puts "\t     =========================================================================="
    puts "\t     |# MAC TX SADDR INSERTION CTRL   = [reg_read $10GMAC_BASE_ADDR $tx_addrins_control]"
    puts "\t     |# TX MAC SOURCE ADDRESS         = [reg_read $10GMAC_BASE_ADDR $tx_addrins_macaddr1]"
    puts "\t     |#                                 [reg_read $10GMAC_BASE_ADDR $tx_addrins_macaddr0]"
    puts "\t     |# RX PAD/CRC SRIPPING           = [reg_read $10GMAC_BASE_ADDR $rx_padcrc_control]"
    puts "\t     |# PRIMARY MAC ADDRESS-1         = [reg_read $10GMAC_BASE_ADDR $rx_frame_addr1]"
    puts "\t     |# PRIMARY MAC ADDRESS-0         = [reg_read $10GMAC_BASE_ADDR $rx_frame_addr0]"
    puts "\t     |# MAX FRAME LENGTH              = [reg_read $10GMAC_BASE_ADDR $rx_frame_maxlength]"
    puts "\t     |# SUPPLIMENTARY ADDRESS-0       = [reg_read $10GMAC_BASE_ADDR $rx_frame_spaddr0_1]"
    puts "\t     |#                                 [reg_read $10GMAC_BASE_ADDR $rx_frame_spaddr0_0]"
    puts "\t     |# SUPPLIMENTARY ADDRESS-1       = [reg_read $10GMAC_BASE_ADDR $rx_frame_spaddr1_1]"
    puts "\t     |#                                 [reg_read $10GMAC_BASE_ADDR $rx_frame_spaddr1_0]"
    puts "\t     |# SUPPLIMENTARY ADDRESS-2       = [reg_read $10GMAC_BASE_ADDR $rx_frame_spaddr2_1]"
    puts "\t     |#                                 [reg_read $10GMAC_BASE_ADDR $rx_frame_spaddr2_0]"
    puts "\t     |# SUPPLIMENTARY ADDRESS-3       = [reg_read $10GMAC_BASE_ADDR $rx_frame_spaddr3_1]"
    puts "\t     |#                                 [reg_read $10GMAC_BASE_ADDR $rx_frame_spaddr3_0]"
    
}
