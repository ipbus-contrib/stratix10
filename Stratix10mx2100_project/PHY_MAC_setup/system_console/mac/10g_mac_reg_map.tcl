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
#                       MAC Register Address Map
#==============================================================================

# TX Packet Transfer
set tx_transfer_control                     0x0080
set tx_transfer_status                      0x0088

# TX Pad Inserter
set tx_padins_control                       0x0090

# TX CRC Inserter
set tx_crcins_control                       0x0098

# TX CRC Inserter
set tx_ipg_10g                              0x00B8

# TX Packet Underflow
set tx_pktunderflow_error_lo                0x00F8
set tx_pktunderflow_error_hi                0x00FC

# TX Preamble Control
set tx_preamble_control                     0x00A0

# TX Pause Frame Control and Generator
set tx_pauseframe_control                   0x0100
set tx_pauseframe_quanta                    0x0108
set tx_pauseframe_enable                    0x0110

# TX PFC Generator
set pfc_pause_quanta_0                      0x0120
set pfc_pause_quanta_1                      0x0124
set pfc_pause_quanta_2                      0x0128
set pfc_pause_quanta_3                      0x012C
set pfc_pause_quanta_4                      0x0130
set pfc_pause_quanta_5                      0x0134
set pfc_pause_quanta_6                      0x0138
set pfc_pause_quanta_7                      0x013C

set pfc_holdoff_quanta_0                    0x0160
set pfc_holdoff_quanta_1                    0x0164
set pfc_holdoff_quanta_2                    0x0168
set pfc_holdoff_quanta_3                    0x016C
set pfc_holdoff_quanta_4                    0x0170
set pfc_holdoff_quanta_5                    0x0174
set pfc_holdoff_quanta_6                    0x0178
set pfc_holdoff_quanta_7                    0x017C

set tx_pfc_priority_enable                  0x0118

# TX Address Inserter
set tx_addrins_control                      0x00A8
set tx_addrins_macaddr0                     0x0040
set tx_addrins_macaddr1                     0x0044

# TX Frame Decoder
set tx_frame_maxlength                      0x00B0

# RX Packet Transfer
set rx_transfer_control                     0x0280
set rx_transfer_status                      0x0288

# RX Pad/CRC Remover
set rx_padcrc_control                       0x0290

# RX CRC Checker
set rx_crccheck_control                     0x0298

# RX Preamble Control
set rx_preamble_inserter_control            0x02A0

# RX Lane Decoder
set rx_lane_decoder_preamble_control        0x02A8

# RX Frame Decoder
set rx_frame_control                        0x02B0
set rx_frame_maxlength                      0x02B8
set rx_frame_addr0                          0x0040
set rx_frame_addr1                          0x0044

set rx_frame_spaddr0_0                      0x02C0
set rx_frame_spaddr0_1                      0x02C4
set rx_frame_spaddr1_0                      0x02C8
set rx_frame_spaddr1_1                      0x02CC
set rx_frame_spaddr2_0                      0x02D0
set rx_frame_spaddr2_1                      0x02D4
set rx_frame_spaddr3_0                      0x02D8
set rx_frame_spaddr3_1                      0x02DC

set rx_pfc_control                          0x0300

# RX Packet Overflow
set rx_pktovrflow_error_lo                  0x03F0
set rx_pktovrflow_error_hi                  0x03F4
set rx_pktovrflow_etherStatsDropEvents_lo   0x03F8
set rx_pktovrflow_etherStatsDropEvents_hi   0x03FC

# 1588
set rx_10g_period_addr                      0x0480;
set rx_10g_adjust_fns_addr                  0x0488;
set rx_10g_adjust_ns_addr                   0x0490;

set rx_1g_period_addr                       0x04A0;
set rx_1g_adjust_fns_addr                   0x04A8;
set rx_1g_adjust_ns_addr                    0x04B0;

set tx_10g_period_addr                      0x0400;
set tx_10g_adjust_fns_addr                  0x0408;
set tx_10g_adjust_ns_addr                   0x040c;

set tx_1g_period_addr                       0x0420;
set tx_1g_adjust_fns_addr                   0x0428;
set tx_1g_adjust_ns_addr                    0x0430;

# TX STATS
set tClearStats                             0x0500
set tframesOK_lo                            0x0508
set tframesOK_hi                            0x050C
set tframesErr_lo                           0x0510
set tframesErr_hi                           0x0514
set tframesCRCErr_lo                        0x0518
set tframesCRCErr_hi                        0x051C
set toctetsOK_lo                            0x0520
set toctetsOK_hi                            0x0524
set tpauseMACCtrlFrames_lo                  0x0528
set tpauseMACCtrlFrames_hi                  0x052C
set tifErrors_lo                            0x0530
set tifErrors_hi                            0x0534
set tunicastFramesOK_lo                     0x0538
set tunicastFramesOK_hi                     0x053C
set tunicastFramesErr_lo                    0x0540
set tunicastFramesErr_hi                    0x0544
set tmulticastFramesOK_lo                   0x0548
set tmulticastFramesOK_hi                   0x054C
set tmulticastFramesErr_lo                  0x0550
set tmulticastFramesErr_hi                  0x0554
set tbroadcastFramesOK_lo                   0x0558
set tbroadcastFramesOK_hi                   0x055C
set tbroadcastFramesErr_lo                  0x0560
set tbroadcastFramesErr_hi                  0x0564
set tetherStatsOctets_lo                    0x0568
set tetherStatsOctets_hi                    0x056C
set tetherStatsPkts_lo                      0x0570
set tetherStatsPkts_hi                      0x0574
set tetherStatsUndersizePkts_lo             0x0578
set tetherStatsUndersizePkts_hi             0x057C
set tetherStatsOversizePkts_lo              0x0580
set tetherStatsOversizePkts_hi              0x0584
set tetherStatsPkts64Octets_lo              0x0588
set tetherStatsPkts64Octets_hi              0x058C
set tetherStatsPkts65to127Octets_lo         0x0590
set tetherStatsPkts65to127Octets_hi         0x0594
set tetherStatsPkts128to255Octets_lo        0x0598
set tetherStatsPkts128to255Octets_hi        0x059C
set tetherStatsPkts256to511Octets_lo        0x05A0
set tetherStatsPkts256to511Octets_hi        0x05A4
set tetherStatsPkts512to1023Octets_lo       0x05A8
set tetherStatsPkts512to1023Octets_hi       0x05AC
set tetherStatPkts1024to1518Octets_lo       0x05B0
set tetherStatPkts1024to1518Octets_hi       0x05B4
set tetherStatsPkts1519toXOctets_lo         0x05B8
set tetherStatsPkts1519toXOctets_hi         0x05Bc
set tetherStatsFragments_lo                 0x05C0
set tetherStatsFragments_hi                 0x05C4
set tetherStatsJabbers_lo                   0x05C8
set tetherStatsJabbers_hi                   0x05CC
set tetherStatsCRCErr_lo                    0x05D0
set tetherStatsCRCErr_hi                    0x05D4
set tunicastMACCtrlFrames_lo                0x05D8
set tunicastMACCtrlFrames_hi                0x05DC
set tmulticastMACCtrlFrames_lo              0x05E0
set tmulticastMACCtrlFrames_hi              0x05E4
set tbroadcastMACCtrlFrames_lo              0x05E8
set tbroadcastMACCtrlFrames_hi              0x05EC

# RX STATS
set ClearStats                              0x0700
set framesOK_lo                             0x0708
set framesOK_hi                             0x070C
set framesErr_lo                            0x0710
set framesErr_hi                            0x0714
set framesCRCErr_lo                         0x0718
set framesCRCErr_hi                         0x071C
set octetsOK_lo                             0x0720
set octetsOK_hi                             0x0724
set pauseMACCtrlFrames_lo                   0x0728
set pauseMACCtrlFrames_hi                   0x072C
set ifErrors_lo                             0x0730
set ifErrors_hi                             0x0734
set unicastFramesOK_lo                      0x0738
set unicastFramesOK_hi                      0x073C
set unicastFramesErr_lo                     0x0740
set unicastFramesErr_hi                     0x0744
set multicastFramesOK_lo                    0x0748
set multicastFramesOK_hi                    0x074C
set multicastFramesErr_lo                   0x0750
set multicastFramesErr_hi                   0x0754
set broadcastFramesOK_lo                    0x0758
set broadcastFramesOK_hi                    0x075C
set broadcastFramesErr_lo                   0x0760
set broadcastFramesErr_hi                   0x0764
set etherStatsOctets_lo                     0x0768
set etherStatsOctets_hi                     0x076C
set etherStatsPkts_lo                       0x0770
set etherStatsPkts_hi                       0x0774
set etherStatsUndersizePkts_lo              0x0778
set etherStatsUndersizePkts_hi              0x077C
set etherStatsOversizePkts_lo               0x0780
set etherStatsOversizePkts_hi               0x0784
set etherStatsPkts64Octets_lo               0x0788
set etherStatsPkts64Octets_hi               0x078C
set etherStatsPkts65to127Octets_lo          0x0790
set etherStatsPkts65to127Octets_hi          0x0794
set etherStatsPkts128to255Octets_lo         0x0798
set etherStatsPkts128to255Octets_hi         0x079C
set etherStatsPkts256to511Octets_lo         0x07A0
set etherStatsPkts256to511Octets_hi         0x07A4
set etherStatsPkts512to1023Octets_lo        0x07A8
set etherStatsPkts512to1023Octets_hi        0x07AC
set etherStatPkts1024to1518Octets_lo        0x07B0
set etherStatPkts1024to1518Octets_hi        0x07B4
set etherStatsPkts1519toXOctets_lo          0x07B8
set etherStatsPkts1519toXOctets_hi          0x07Bc
set etherStatsFragments_lo                  0x07C0
set etherStatsFragments_hi                  0x07C4
set etherStatsJabbers_lo                    0x07C8
set etherStatsJabbers_hi                    0x07CC
set etherStatsCRCErr_lo                     0x07D0
set etherStatsCRCErr_hi                     0x07D4
set unicastMACCtrlFrames_lo                 0x07D8
set unicastMACCtrlFrames_hi                 0x07DC
set multicastMACCtrlFrames_lo               0x07E0
set multicastMACCtrlFrames_hi               0x07E4
set broadcastMACCtrlFrames_lo               0x07E8
set broadcastMACCtrlFrames_hi               0x07EC
