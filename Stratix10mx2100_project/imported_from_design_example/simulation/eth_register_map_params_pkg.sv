// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`ifndef ETH_REGISTER_MAP_PARAMS_PKG__SV
`define ETH_REGISTER_MAP_PARAMS_PKG__SV

// Package defines address of registers
package eth_register_map_params_pkg;
    
    // ******************************************************************************************
    // Base Address (As specified by address decoder) - Byte Addressing / 4
    // ******************************************************************************************
    parameter RD_MGE_RECONFIG_ADDR                              = 32'h00000 / 4;
    parameter RD_CHANNEL_0_BASE_ADDR                            = 32'h10000 / 4;
    parameter RD_CHANNEL_N_OFFSET                               = 32'h10000 / 4;
    parameter RD_CHANNEL_MAC_OFFSET                             = 32'h00000 / 4;
    parameter RD_CHANNEL_PHY_OFFSET                             = 32'h08000 / 4;
    
    // ******************************************************************************************
    // Register Address of MAC - Word Addressing
    // ******************************************************************************************
    // Primary MAC address
    parameter PRIMARY_MAC_ADD_0_ADDR                            = 32'h010;
    parameter PRIMARY_MAC_ADD_1_ADDR                            = 32'h011;
    
    // TX Path Enabled/disabled
    parameter TX_TRANSFER_CONTROL_ADDR                          = 32'h020;
    
    // TX Pad Insertion Control
    parameter TX_PADINS_CONTROL_ADDR                            = 32'h024;
    
    // TX CRC Insertion Control
    parameter TX_CRC_INSERT_CONTROL_ADDR                        = 32'h026;
    
    // TX Address Insertion Control
    parameter TX_ADDRESS_INSERT_CONTROL_ADDR                    = 32'h02A;
    
    // RX Path Enabled/disabled
    parameter RX_TRANSFER_CONTROL_ADDR                          = 32'h0A0;
    
    // Base address for statistics
    parameter TX_STATISTICS_ADDR                                = 32'h140;
    parameter RX_STATISTICS_ADDR                                = 32'h1C0;
    
    // ******************************************************************************************
    // Registers Offset of MAC - Word Addressing
    // ******************************************************************************************
    // ------------------------------------------------------------------------------------------
    // Statistics
    // ------------------------------------------------------------------------------------------
    parameter STATISTICS_framesOK_OFFSET                        = 32'h002;
    parameter STATISTICS_framesErr_OFFSET                       = 32'h004;
    parameter STATISTICS_framesCRCErr_OFFSET                    = 32'h006;
    parameter STATISTICS_octetsOK_OFFSET                        = 32'h008;
    parameter STATISTICS_pauseMACCtrlFrames_OFFSET              = 32'h00A;
    parameter STATISTICS_ifErrors_OFFSET                        = 32'h00C;
    parameter STATISTICS_unicastFramesOK_OFFSET                 = 32'h00E;
    parameter STATISTICS_unicastFramesErr_OFFSET                = 32'h010;
    parameter STATISTICS_multicastFramesOK_OFFSET               = 32'h012;
    parameter STATISTICS_multicastFramesErr_OFFSET              = 32'h014;
    parameter STATISTICS_broadcastFramesOK_OFFSET               = 32'h016;
    parameter STATISTICS_broadcastFramesErr_OFFSET              = 32'h018;
    parameter STATISTICS_etherStatsOctets_OFFSET                = 32'h01A;
    parameter STATISTICS_etherStatsPkts_OFFSET                  = 32'h01C;
    parameter STATISTICS_etherStatsUndersizePkts_OFFSET         = 32'h01E;
    parameter STATISTICS_etherStatsOversizePkts_OFFSET          = 32'h020;
    parameter STATISTICS_etherStatsPkts64Octets_OFFSET          = 32'h022;
    parameter STATISTICS_etherStatsPkts65to127Octets_OFFSET     = 32'h024;
    parameter STATISTICS_etherStatsPkts128to255Octets_OFFSET    = 32'h026;
    parameter STATISTICS_etherStatsPkts256to511Octets_OFFSET    = 32'h028;
    parameter STATISTICS_etherStatsPkts512to1023Octets_OFFSET   = 32'h02A;
    parameter STATISTICS_etherStatPkts1024to1518Octets_OFFSET   = 32'h02C;
    parameter STATISTICS_etherStatsPkts1519toXOctets_OFFSET     = 32'h02E;
    parameter STATISTICS_etherStatsFragments_OFFSET             = 32'h030;
    parameter STATISTICS_etherStatsJabbers_OFFSET               = 32'h032;
    parameter STATISTICS_etherStatsCRCErr_OFFSET                = 32'h034;
    parameter STATISTICS_unicastMACCtrlFrames_OFFSET            = 32'h036;
    parameter STATISTICS_multicastMACCtrlFrames_OFFSET          = 32'h038;
    parameter STATISTICS_broadcastMACCtrlFrames_OFFSET          = 32'h03A;
    
    
    // ******************************************************************************************
    // Registers Address of Reconfig Block
    // ******************************************************************************************
    parameter RCFG_LOGICAL_CHANNEL_NUM_ADDR                     = 32'h0;
    parameter RCFG_CONTROL_ADDR                                 = 32'h1;
    parameter RCFG_STATUS_ADDR                                  = 32'h2;
    
endpackage

`endif
