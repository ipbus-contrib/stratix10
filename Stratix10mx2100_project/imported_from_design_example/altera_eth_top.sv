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

module altera_eth_top # (
    parameter NUM_OF_CHANNEL = 1,
    parameter DEVICE_FAMILY  = "Stratix 10"
 )(
    
    // Clock
    input                               refclk,
    //input                               csr_clk,
    input                               clk_100,
    
    output                              mac_clk,
    output                              ipbus_clk,
    
    // Reset
    input                               reset_n,
    
    // Serial Interface
    input       [NUM_OF_CHANNEL-1:0]    rx_serial_data,
    output      [NUM_OF_CHANNEL-1:0]    tx_serial_data,

    // MAC TX User Frame
    input  [NUM_OF_CHANNEL-1:0]         avalon_st_tx_valid,
    output [NUM_OF_CHANNEL-1:0]         avalon_st_tx_ready,
    input  [NUM_OF_CHANNEL-1:0]         avalon_st_tx_startofpacket,
    input  [NUM_OF_CHANNEL-1:0]         avalon_st_tx_endofpacket,
    input  [NUM_OF_CHANNEL-1:0][31:0]   avalon_st_tx_data,
    input  [NUM_OF_CHANNEL-1:0][ 1:0]   avalon_st_tx_empty,
    input  [NUM_OF_CHANNEL-1:0]         avalon_st_tx_error,
    
    // MAC RX User Frame
    output [NUM_OF_CHANNEL-1:0]         avalon_st_rx_valid,
    input  [NUM_OF_CHANNEL-1:0]         avalon_st_rx_ready,
    output [NUM_OF_CHANNEL-1:0]         avalon_st_rx_startofpacket,
    output [NUM_OF_CHANNEL-1:0]         avalon_st_rx_endofpacket,
    output [NUM_OF_CHANNEL-1:0][31:0]   avalon_st_rx_data,
    output [NUM_OF_CHANNEL-1:0][ 1:0]   avalon_st_rx_empty,
    output [NUM_OF_CHANNEL-1:0][ 5:0]   avalon_st_rx_error,

    // LED
    output      [NUM_OF_CHANNEL-1:0]    channel_ready_n,
    
    // PLL
    output                              core_pll_locked
    
);

    // Loop Control Variable
    genvar i;
    
    
    // Reset
    wire [NUM_OF_CHANNEL-1:0]           tx_digitalreset;
    wire [NUM_OF_CHANNEL-1:0]           rx_digitalreset;
    wire                                reset_mac_clk;
    wire                                master_reset;
    
    // JTAG CSR
    wire                     [31:0]     jtag_if_address;
    wire                                jtag_if_read;
    wire                                jtag_if_write;
    wire                     [31:0]     jtag_if_writedata;
    wire                     [31:0]     jtag_if_readdata;
    wire                                jtag_if_readdatavalid;
    wire                                jtag_if_waitrequest;
    wire                     [ 3:0]     jtag_if_byteenable;
    
    // MAC CSR
    wire [NUM_OF_CHANNEL-1:0][ 9:0]     csr_mac_address;
    wire [NUM_OF_CHANNEL-1:0]           csr_mac_read;
    wire [NUM_OF_CHANNEL-1:0]           csr_mac_write;
    wire [NUM_OF_CHANNEL-1:0][31:0]     csr_mac_writedata;
    wire [NUM_OF_CHANNEL-1:0][31:0]     csr_mac_readdata;
    wire [NUM_OF_CHANNEL-1:0]           csr_mac_waitrequest;
    
    // PHY CSR
    wire [NUM_OF_CHANNEL-1:0][ 4:0]     csr_phy_address;
    wire [NUM_OF_CHANNEL-1:0]           csr_phy_read;
    wire [NUM_OF_CHANNEL-1:0]           csr_phy_write;
    wire [NUM_OF_CHANNEL-1:0][15:0]     csr_phy_writedata;
    wire [NUM_OF_CHANNEL-1:0][15:0]     csr_phy_readdata;
    wire [NUM_OF_CHANNEL-1:0]           csr_phy_waitrequest;
    
    wire [NUM_OF_CHANNEL-1:0][15:0]     csr_phy_writedata_unused;
    
    // Data Path Readiness
    wire [NUM_OF_CHANNEL-1:0]           channel_tx_ready;
    wire [NUM_OF_CHANNEL-1:0]           channel_rx_ready;
    
    // Reconfig CSR
    wire                     [ 1:0]     csr_rcfg_address;
    wire                                csr_rcfg_read;
    wire                                csr_rcfg_write;
    wire                     [31:0]     csr_rcfg_writedata;
    wire                     [31:0]     csr_rcfg_readdata;
    
    // Traffic Controller CSR
    wire [NUM_OF_CHANNEL/2-1:0][11:0]   csr_traffic_controller_address;
    wire [NUM_OF_CHANNEL/2-1:0]         csr_traffic_controller_read;
    wire [NUM_OF_CHANNEL/2-1:0]         csr_traffic_controller_write;
    wire [NUM_OF_CHANNEL/2-1:0][31:0]   csr_traffic_controller_writedata;
    wire [NUM_OF_CHANNEL/2-1:0][31:0]   csr_traffic_controller_readdata;
    wire [NUM_OF_CHANNEL/2-1:0]         csr_traffic_controller_waitrequest;
    
    // Native PHY Reconfig CSR
    wire [NUM_OF_CHANNEL-1:0][ 9:0]     csr_native_phy_rcfg_address;
    wire [NUM_OF_CHANNEL-1:0]           csr_native_phy_rcfg_read;
    wire [NUM_OF_CHANNEL-1:0]           csr_native_phy_rcfg_write;
    wire [NUM_OF_CHANNEL-1:0][31:0]     csr_native_phy_rcfg_writedata;
    wire [NUM_OF_CHANNEL-1:0][31:0]     csr_native_phy_rcfg_readdata;
    wire [NUM_OF_CHANNEL-1:0]           csr_native_phy_rcfg_waitrequest;
    
    // Channel Ready
    assign channel_ready_n = ~(channel_tx_ready & channel_rx_ready & {NUM_OF_CHANNEL{core_pll_locked}});
    
    // I am not entirely sure of what this signal represents..
    // In particular because this design was for another board....
    // For the moment it's commented out..
    // SFP
    // assign sfp_txdisable = 1'b0;

    // Core PLL
    clock_gen_pll core_pll (
        .rst                (~reset_n),
        .refclk             (clk_100),
        .locked             (core_pll_locked),
        .outclk_0           (mac_clk),
        .outclk_1           (ipbus_clk),
        .outclk_2           (csr_clk)
    );

    // Reset
    alt_mge_reset_synchronizer lb_fifo_reset_sync (
        .clk        (mac_clk),
        .reset_in   (~reset_n),
        .reset_out  (reset_mac_clk)
    );
    
    // DUT
    alt_mge_rd #(
        .NUM_OF_CHANNEL                 (NUM_OF_CHANNEL),
        .DEVICE_FAMILY                  (DEVICE_FAMILY)
    ) DUT (
        
        // CSR Clock
        .csr_clk                        (csr_clk),
        
        // MAC Clock
        .mac_clk                        (mac_clk),
        
        // Reference Clock
        .refclk                         (refclk),
        
        // Reset
        .reset                          (~reset_n),
        .tx_digitalreset                (tx_digitalreset),
        .rx_digitalreset                (rx_digitalreset),
        
        // MAC CSR
        .csr_mac_address                (csr_mac_address),
        .csr_mac_read                   (csr_mac_read),
        .csr_mac_write                  (csr_mac_write),
        .csr_mac_writedata              (csr_mac_writedata),
        .csr_mac_readdata               (csr_mac_readdata),
        .csr_mac_waitrequest            (csr_mac_waitrequest),
        
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
        .avalon_st_txstatus_valid       (),
        .avalon_st_txstatus_data        (),
        .avalon_st_txstatus_error       (),
        
        // MAC RX Frame Status
        .avalon_st_rxstatus_valid       (),
        .avalon_st_rxstatus_data        (),
        .avalon_st_rxstatus_error       (),
        
        // MAC TX Pause Frame Generation Command
        .avalon_st_pause_data           ({NUM_OF_CHANNEL{2'b00}}),
        
        // PHY CSR
        .csr_phy_address                (csr_phy_address),
        .csr_phy_read                   (csr_phy_read),
        .csr_phy_write                  (csr_phy_write),
        .csr_phy_writedata              (csr_phy_writedata),
        .csr_phy_readdata               (csr_phy_readdata),
        .csr_phy_waitrequest            (csr_phy_waitrequest),
        
        // PHY Status
        .led_link                       (),
        .led_char_err                   (),
        .led_disp_err                   (),
        .led_an                         (),
        
        // Transceiver Serial Interface
        .tx_serial_data                 (tx_serial_data),
        .rx_serial_data                 (rx_serial_data),
        .rx_pma_clkout                  (),
        
        // Data Path Readiness
        .channel_tx_ready               (channel_tx_ready),
        .channel_rx_ready               (channel_rx_ready),
        
        // Reconfig CSR
        .csr_rcfg_address               (csr_rcfg_address),
        .csr_rcfg_read                  (csr_rcfg_read),
        .csr_rcfg_write                 (csr_rcfg_write),
        .csr_rcfg_writedata             (csr_rcfg_writedata),
        .csr_rcfg_readdata              (csr_rcfg_readdata),
        
        // Native PHY Reconfig CSR
        .csr_native_phy_rcfg_address    (csr_native_phy_rcfg_address),
        .csr_native_phy_rcfg_read       (csr_native_phy_rcfg_read),
        .csr_native_phy_rcfg_write      (csr_native_phy_rcfg_write),
        .csr_native_phy_rcfg_writedata  (csr_native_phy_rcfg_writedata),
        .csr_native_phy_rcfg_readdata   (csr_native_phy_rcfg_readdata),
        .csr_native_phy_rcfg_waitrequest(csr_native_phy_rcfg_waitrequest)
        
    );

    //This block is not needed as only 1 channel is used
   
   // generate for (i =0; i <(NUM_OF_CHANNEL/2); i = i + 1)
   //     begin: ETH_TRAFFIC_CTRL_PAIR_CHANNEL
   //         eth_traffic_controller_32b_top eth_traffic_controller (
   //             .clk                            (mac_clk),
   //             .reset_n                        (~reset_mac_clk),
   //             
   //             .csr_address                    (csr_traffic_controller_address[i]),
   //             .csr_read                       (csr_traffic_controller_read[i]),
   //             .csr_write                      (csr_traffic_controller_write[i]),
   //             .csr_writedata                  (csr_traffic_controller_writedata[i]),
   //             .csr_readdata                   (csr_traffic_controller_readdata[i]),
   //             .csr_waitrequest                (csr_traffic_controller_waitrequest[i]),
   //             
   //             .avalon_st_tx_valid             (avalon_st_tx_valid         [2*(i+1)-1: 2*i]),
   //             .avalon_st_tx_ready             (avalon_st_tx_ready         [2*(i+1)-1: 2*i]),
   //             .avalon_st_tx_startofpacket     (avalon_st_tx_startofpacket [2*(i+1)-1: 2*i]),
   //             .avalon_st_tx_endofpacket       (avalon_st_tx_endofpacket   [2*(i+1)-1: 2*i]),
   //             .avalon_st_tx_data              (avalon_st_tx_data          [2*(i+1)-1: 2*i]),
   //             .avalon_st_tx_empty             (avalon_st_tx_empty         [2*(i+1)-1: 2*i]),
   //             .avalon_st_tx_error             (avalon_st_tx_error         [2*(i+1)-1: 2*i]),
   //             
   //             .avalon_st_rx_valid             (avalon_st_rx_valid         [2*(i+1)-1: 2*i]),
   //             .avalon_st_rx_ready             (avalon_st_rx_ready         [2*(i+1)-1: 2*i]),
   //             .avalon_st_rx_startofpacket     (avalon_st_rx_startofpacket [2*(i+1)-1: 2*i]),
   //             .avalon_st_rx_endofpacket       (avalon_st_rx_endofpacket   [2*(i+1)-1: 2*i]),
   //             .avalon_st_rx_data              (avalon_st_rx_data          [2*(i+1)-1: 2*i]),
   //             .avalon_st_rx_empty             (avalon_st_rx_empty         [2*(i+1)-1: 2*i]),
   //             .avalon_st_rx_error             (avalon_st_rx_error         [2*(i+1)-1: 2*i])
   //         );    
   //     end
   // endgenerate


    // JTAG Master
    alt_jtag_csr_master jtag_master (
        .clk_clk                           (csr_clk),
        .clk_reset_reset                   (~reset_n),
        .master_reset_reset                (master_reset),
        .master_address                    (jtag_if_address),
        .master_readdata                   (jtag_if_readdata),
        .master_read                       (jtag_if_read),
        .master_write                      (jtag_if_write),
        .master_writedata                  (jtag_if_writedata),
        .master_waitrequest                (jtag_if_waitrequest),
        .master_readdatavalid              (jtag_if_readdatavalid),
        .master_byteenable                 (jtag_if_byteenable)
    );
    
    // Avalon-MM Address Decoder
    // Commenting out the channel 1 and the connection to the controller (adjusted also in qsys)
    alt_mge_rd_addrdec_mch csr_address_decoder (
        .csr_clk_clk                                (csr_clk),
        .csr_clk_reset_reset_n                      (reset_n),
        
        .mac_clk_clk                                (mac_clk),
        .mac_clk_reset_reset_n                      (reset_n),
        
        .slave_address                              (24'h0),
        .slave_write                                (1'b0),
        .slave_read                                 (1'b0),
        .slave_writedata                            (32'h0),
        .slave_readdata                             (),
        .slave_waitrequest                          (),
        
        .jtag_slave_address                         (jtag_if_address),
        .jtag_slave_write                           (jtag_if_write),
        .jtag_slave_read                            (jtag_if_read),
        .jtag_slave_writedata                       (jtag_if_writedata),
        .jtag_slave_readdata                        (jtag_if_readdata),
        .jtag_slave_readdatavalid                   (jtag_if_readdatavalid),
        .jtag_slave_waitrequest                     (jtag_if_waitrequest),
        .jtag_slave_byteenable                      (jtag_if_byteenable),
        
        .mge_reconfig_address                       (csr_rcfg_address),
        .mge_reconfig_read                          (csr_rcfg_read),
        .mge_reconfig_write                         (csr_rcfg_write),
        .mge_reconfig_writedata                     (csr_rcfg_writedata),
        .mge_reconfig_readdata                      (csr_rcfg_readdata),
        
        .channel_0_mac_address                      (csr_mac_address[0]),
        .channel_0_mac_read                         (csr_mac_read[0]),
        .channel_0_mac_write                        (csr_mac_write[0]),
        .channel_0_mac_writedata                    (csr_mac_writedata[0]),
        .channel_0_mac_readdata                     (csr_mac_readdata[0]),
        .channel_0_mac_waitrequest                  (csr_mac_waitrequest[0]),
        
        .channel_0_phy_address                      (csr_phy_address[0]),
        .channel_0_phy_read                         (csr_phy_read[0]),
        .channel_0_phy_write                        (csr_phy_write[0]),
        .channel_0_phy_writedata                    ({csr_phy_writedata_unused[0], csr_phy_writedata[0]}),
        .channel_0_phy_readdata                     ({16'h0, csr_phy_readdata[0]}),
        .channel_0_phy_waitrequest                  (csr_phy_waitrequest[0]),
        
        .channel_0_native_phy_rcfg_address          (csr_native_phy_rcfg_address[0]),
        .channel_0_native_phy_rcfg_read             (csr_native_phy_rcfg_read[0]),
        .channel_0_native_phy_rcfg_write            (csr_native_phy_rcfg_write[0]),
        .channel_0_native_phy_rcfg_writedata        (csr_native_phy_rcfg_writedata[0]),
        .channel_0_native_phy_rcfg_readdata         (csr_native_phy_rcfg_readdata[0]),
        .channel_0_native_phy_rcfg_waitrequest      (csr_native_phy_rcfg_waitrequest[0])
        
//        .channel_1_mac_address                      (csr_mac_address[1]),
//        .channel_1_mac_read                         (csr_mac_read[1]),
//        .channel_1_mac_write                        (csr_mac_write[1]),
//        .channel_1_mac_writedata                    (csr_mac_writedata[1]),
//        .channel_1_mac_readdata                     (csr_mac_readdata[1]),
//        .channel_1_mac_waitrequest                  (csr_mac_waitrequest[1]),
//        
//        .channel_1_phy_address                      (csr_phy_address[1]),
//        .channel_1_phy_read                         (csr_phy_read[1]),
//        .channel_1_phy_write                        (csr_phy_write[1]),
//        .channel_1_phy_writedata                    ({csr_phy_writedata_unused[1], csr_phy_writedata[1]}),
//        .channel_1_phy_readdata                     ({16'h0, csr_phy_readdata[1]}),
//        .channel_1_phy_waitrequest                  (csr_phy_waitrequest[1]),
//        
//        .channel_1_native_phy_rcfg_address          (csr_native_phy_rcfg_address[1]),
//        .channel_1_native_phy_rcfg_read             (csr_native_phy_rcfg_read[1]),
//        .channel_1_native_phy_rcfg_write            (csr_native_phy_rcfg_write[1]),
//        .channel_1_native_phy_rcfg_writedata        (csr_native_phy_rcfg_writedata[1]),
//        .channel_1_native_phy_rcfg_readdata         (csr_native_phy_rcfg_readdata[1]),
//        .channel_1_native_phy_rcfg_waitrequest      (csr_native_phy_rcfg_waitrequest[1]),
//        
//        .channel_0_1_traffic_controller_address     (csr_traffic_controller_address[0]),
//        .channel_0_1_traffic_controller_read        (csr_traffic_controller_read[0]),
//        .channel_0_1_traffic_controller_write       (csr_traffic_controller_write[0]),
//        .channel_0_1_traffic_controller_writedata   (csr_traffic_controller_writedata[0]),
//        .channel_0_1_traffic_controller_readdata    (csr_traffic_controller_readdata[0]),
//        .channel_0_1_traffic_controller_waitrequest (csr_traffic_controller_waitrequest[0])
    );
    

endmodule

