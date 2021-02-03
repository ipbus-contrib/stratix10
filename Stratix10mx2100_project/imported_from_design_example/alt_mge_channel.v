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


`timescale 1 ps / 1 ps

module alt_mge_channel (
    // CSR Clock
    input               csr_clk,
    
    // MAC User Clock
    input               mac_clk,
    
    // Reset
    input               reset,
    input               tx_digitalreset,
    input               rx_digitalreset,
    input               tx_analogreset,
    input               rx_analogreset,
    
    // reset STAT
    output              tx_analogreset_stat,
    output              rx_analogreset_stat,
    output              tx_digitalreset_stat,
    output              rx_digitalreset_stat,
    
    // MAC CSR
    input       [9:0]   csr_mac_address,
    input               csr_mac_read,
    input               csr_mac_write,
    input       [31:0]  csr_mac_writedata,
    output      [31:0]  csr_mac_readdata,
    output              csr_mac_waitrequest,
    
    // MAC TX User Frame
    input               avalon_st_tx_valid,
    output              avalon_st_tx_ready,
    input               avalon_st_tx_startofpacket,
    input               avalon_st_tx_endofpacket,
    input       [31:0]  avalon_st_tx_data,
    input       [1:0]   avalon_st_tx_empty,
    input               avalon_st_tx_error,
    
    // MAC RX User Frame
    output              avalon_st_rx_valid,
    input               avalon_st_rx_ready,
    output              avalon_st_rx_startofpacket,
    output              avalon_st_rx_endofpacket,
    output      [31:0]  avalon_st_rx_data,
    output       [1:0]  avalon_st_rx_empty,
    output       [5:0]  avalon_st_rx_error,
    
    // MAC TX Frame Status
    output              avalon_st_txstatus_valid,
    output      [39:0]  avalon_st_txstatus_data,
    output       [6:0]  avalon_st_txstatus_error,
    
    // MAC RX Frame Status
    output              avalon_st_rxstatus_valid,
    output      [39:0]  avalon_st_rxstatus_data,
    output       [6:0]  avalon_st_rxstatus_error,
    
    // MAC TX Pause Frame Generation Command
    input        [1:0]  avalon_st_pause_data,
    
    // PHY CSR
    input        [4:0]  csr_phy_address,
    input               csr_phy_read,
    input               csr_phy_write,
    input       [15:0]  csr_phy_writedata,
    output      [15:0]  csr_phy_readdata,
    output              csr_phy_waitrequest,
    
    // PHY Operating Mode from Reconfig Block
    input        [1:0]  xcvr_mode,
    
    // PHY Status
    output              led_link,
    output              led_char_err,
    output              led_disp_err,
    output              led_an,
    
    // Transceiver Serial Interface
    input        [1:0]  tx_serial_clk,
    input               rx_cdr_refclk,
    output              rx_pma_clkout,
    output              tx_serial_data,
    input               rx_serial_data,
    
    // Transceiver Status
    output              rx_is_lockedtodata,
    output              tx_cal_busy,
    output              rx_cal_busy,
    
    // Transceiver Reconfiguration
    input               reconfig_clk,
    input               reconfig_reset,
    input        [9:0]  reconfig_address,
    input               reconfig_read,
    input               reconfig_write,
    input       [31:0]  reconfig_writedata,
    output      [31:0]  reconfig_readdata,
    output              reconfig_waitrequest
    
);
    
    // GMII Clock from PHY to MAC
    wire        gmii16b_tx_clk;
    wire        gmii16b_rx_clk;
    
    // GMII TX from MAC to PHY
    wire  [1:0] gmii16b_tx_en;
    wire [15:0] gmii16b_tx_d;
    wire  [1:0] gmii16b_tx_err;
    
    // GMII RX from PHY to MAC
    wire  [1:0] gmii16b_rx_dv;
    wire [15:0] gmii16b_rx_d;
    wire  [1:0] gmii16b_rx_err;
    
    // PHY Operating Speed to MAC
    wire  [2:0] operating_speed;

    MAC_layer_low mac (
        // CSR Clock
        .csr_clk                        (csr_clk),
        
        // MAC User Clock
        .tx_156_25_clk                  (mac_clk),
        .rx_156_25_clk                  (mac_clk),
        
        // Reset
        .csr_rst_n                      (~reset),
        .tx_rst_n                       (~tx_digitalreset),
        .rx_rst_n                       (~rx_digitalreset),
        
        // MAC CSR
        .csr_address                    (csr_mac_address),
        .csr_read                       (csr_mac_read),
        .csr_write                      (csr_mac_write),
        .csr_writedata                  (csr_mac_writedata),
        .csr_readdata                   (csr_mac_readdata),
        .csr_waitrequest                (csr_mac_waitrequest),
        
        // MAC TX User Frame
        .avalon_st_tx_valid             (avalon_st_tx_valid),
        .avalon_st_tx_ready             (avalon_st_tx_ready),
        .avalon_st_tx_startofpacket     (avalon_st_tx_startofpacket),
        .avalon_st_tx_endofpacket       (avalon_st_tx_endofpacket),
        .avalon_st_tx_data              (avalon_st_tx_data),
        .avalon_st_tx_empty             (avalon_st_tx_empty),
        .avalon_st_tx_error             (avalon_st_tx_error),
        
        // MAC RX User Frame
        .avalon_st_rx_valid             (avalon_st_rx_valid),
        .avalon_st_rx_ready             (avalon_st_rx_ready),
        .avalon_st_rx_startofpacket     (avalon_st_rx_startofpacket),
        .avalon_st_rx_endofpacket       (avalon_st_rx_endofpacket),
        .avalon_st_rx_data              (avalon_st_rx_data),
        .avalon_st_rx_empty             (avalon_st_rx_empty),
        .avalon_st_rx_error             (avalon_st_rx_error),
        
        // MAC TX Frame Status
        .avalon_st_txstatus_valid       (avalon_st_txstatus_valid),
        .avalon_st_txstatus_data        (avalon_st_txstatus_data),
        .avalon_st_txstatus_error       (avalon_st_txstatus_error),
        
        // MAC RX Frame Status
        .avalon_st_rxstatus_valid       (avalon_st_rxstatus_valid),
        .avalon_st_rxstatus_data        (avalon_st_rxstatus_data),
        .avalon_st_rxstatus_error       (avalon_st_rxstatus_error),
        
        // MAC TX Pause Frame Generation Command
        .avalon_st_pause_data           (avalon_st_pause_data),
        
        // GMII Clock from PHY to MAC
        .gmii16b_tx_clk                 (gmii16b_tx_clk),
        .gmii16b_rx_clk                 (gmii16b_rx_clk),
        
        // GMII TX from MAC to PHY
        .gmii16b_tx_en                  (gmii16b_tx_en),
        .gmii16b_tx_d                   (gmii16b_tx_d),
        .gmii16b_tx_err                 (gmii16b_tx_err),
        
        // GMII RX from PHY to MAC
        .gmii16b_rx_dv                  (gmii16b_rx_dv),
        .gmii16b_rx_d                   (gmii16b_rx_d),
        .gmii16b_rx_err                 (gmii16b_rx_err),
        
        // PHY Operating Speed to MAC
        .speed_sel                      (operating_speed)
    );
    
    phy_layer phy (
        // CSR Clock
        .csr_clk                        (csr_clk),
        
        // PHY Clock Out
        .tx_clkout                      (gmii16b_tx_clk),
        .rx_clkout                      (gmii16b_rx_clk),
        
        // Reset
        .reset                          (reset),
        .tx_digitalreset                (tx_digitalreset),
        .rx_digitalreset                (rx_digitalreset),
        .tx_analogreset                 (tx_analogreset),
        .rx_analogreset                 (rx_analogreset),
        .tx_analogreset_stat            (tx_analogreset_stat),
        .tx_digitalreset_stat           (tx_digitalreset_stat),
        .rx_analogreset_stat            (rx_analogreset_stat),
        .rx_digitalreset_stat           (rx_digitalreset_stat),

        // PHY CSR
        .csr_address                    (csr_phy_address),
        .csr_read                       (csr_phy_read),
        .csr_write                      (csr_phy_write),
        .csr_writedata                  (csr_phy_writedata),
        .csr_readdata                   (csr_phy_readdata),
        .csr_waitrequest                (csr_phy_waitrequest),
        
        // GMII TX from MAC to PHY
        .gmii16b_tx_en                  (gmii16b_tx_en),
        .gmii16b_tx_d                   (gmii16b_tx_d),
        .gmii16b_tx_err                 (gmii16b_tx_err),
        
        // GMII RX from PHY to MAC
        .gmii16b_rx_dv                  (gmii16b_rx_dv),
        .gmii16b_rx_d                   (gmii16b_rx_d),
        .gmii16b_rx_err                 (gmii16b_rx_err),
        
        // PHY Operating Mode from Reconfig Block
        .xcvr_mode                      (xcvr_mode),
        
        // PHY Operating Speed to MAC
        .operating_speed                (operating_speed),
        
        // PHY Status
        .led_link                       (led_link),
        .led_char_err                   (led_char_err),
        .led_disp_err                   (led_disp_err),
        .led_an                         (led_an),
        
        // Transceiver Serial Interface
        .tx_serial_clk                  (tx_serial_clk),
        .rx_cdr_refclk                  (rx_cdr_refclk),
        .rx_pma_clkout                  (rx_pma_clkout),
        .tx_serial_data                 (tx_serial_data),
        .rx_serial_data                 (rx_serial_data),
        
        // Transceiver Status
        .rx_is_lockedtodata             (rx_is_lockedtodata),
        .tx_cal_busy                    (tx_cal_busy),
        .rx_cal_busy                    (rx_cal_busy),
        
        // Transceiver Reconfiguration
        .reconfig_clk                   (reconfig_clk),
        .reconfig_reset                 (reconfig_reset),
        .reconfig_address               ({1'b0,reconfig_address}),
        .reconfig_read                  (reconfig_read),
        .reconfig_write                 (reconfig_write),
        .reconfig_writedata             (reconfig_writedata),
        .reconfig_readdata              (reconfig_readdata),
        .reconfig_waitrequest           (reconfig_waitrequest)
    );

endmodule
