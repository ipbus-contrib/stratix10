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



module eth_traffic_controller_32b_top # (
    parameter     NUM_CHANNELS = 2,            // Only 2 is supported
    parameter     TSTAMP_FP_WIDTH = 4
 )(
    input                                   clk,
    input                                   reset_n,
    
    input                         [11:0]    csr_address,
    input                                   csr_read,
    input                                   csr_write,
    input                         [31:0]    csr_writedata,
    output                        [31:0]    csr_readdata,
    output                                  csr_waitrequest,
    
    output      [NUM_CHANNELS-1:0]          avalon_st_tx_valid,
    input       [NUM_CHANNELS-1:0]          avalon_st_tx_ready,
    output      [NUM_CHANNELS-1:0]          avalon_st_tx_startofpacket,
    output      [NUM_CHANNELS-1:0]          avalon_st_tx_endofpacket,
    output      [NUM_CHANNELS-1:0][31:0]    avalon_st_tx_data,
    output      [NUM_CHANNELS-1:0][1:0]     avalon_st_tx_empty,
    output      [NUM_CHANNELS-1:0]          avalon_st_tx_error,
    
    input       [NUM_CHANNELS-1:0]          avalon_st_rx_valid,
    output      [NUM_CHANNELS-1:0]          avalon_st_rx_ready,
    input       [NUM_CHANNELS-1:0]          avalon_st_rx_startofpacket,
    input       [NUM_CHANNELS-1:0]          avalon_st_rx_endofpacket,
    input       [NUM_CHANNELS-1:0][31:0]    avalon_st_rx_data,
    input       [NUM_CHANNELS-1:0][ 1:0]    avalon_st_rx_empty,
    input       [NUM_CHANNELS-1:0][ 5:0]    avalon_st_rx_error,
    
    input       [NUM_CHANNELS-1:0]                        tx_egress_timestamp_96b_valid, 
    input       [NUM_CHANNELS-1:0][95:0]                  tx_egress_timestamp_96b_data, 
    input       [NUM_CHANNELS-1:0][TSTAMP_FP_WIDTH-1:0]   tx_egress_timestamp_96b_fingerprint, 

    output reg  [NUM_CHANNELS-1:0][TSTAMP_FP_WIDTH-1:0]   tx_egress_timestamp_request_fingerprint, 
    output reg  [NUM_CHANNELS-1:0]                        tx_egress_timestamp_request_valid,
                                                                
    input       [NUM_CHANNELS-1:0]                        rx_ingress_timestamp_96b_valid, 
    input       [NUM_CHANNELS-1:0][95:0]                  rx_ingress_timestamp_96b_data,
    
    //eth_1588_traffic_controller control port                  
    input                                   eth_1588_wait_limit,
    output                         [1:0]    eth_1588_start_tod_sync,
    input                          [1:0]    eth_1588_channel_ready,
    output                                  eth_1588_traffic_controller_error_n
    
);
    
    wire        [NUM_CHANNELS-1:0]          avalon_st_tx_64b_valid;
    wire        [NUM_CHANNELS-1:0]          avalon_st_tx_64b_ready;
    wire        [NUM_CHANNELS-1:0]          avalon_st_tx_64b_startofpacket;
    wire        [NUM_CHANNELS-1:0]          avalon_st_tx_64b_endofpacket;
    wire        [NUM_CHANNELS-1:0][63:0]    avalon_st_tx_64b_data;
    wire        [NUM_CHANNELS-1:0][ 2:0]    avalon_st_tx_64b_empty;
    wire        [NUM_CHANNELS-1:0]          avalon_st_tx_64b_error;
    
    wire        [NUM_CHANNELS-1:0]          avalon_st_rx_64b_valid;
    wire        [NUM_CHANNELS-1:0]          avalon_st_rx_64b_ready;
    wire        [NUM_CHANNELS-1:0]          avalon_st_rx_64b_startofpacket;
    wire        [NUM_CHANNELS-1:0]          avalon_st_rx_64b_endofpacket;
    wire        [NUM_CHANNELS-1:0][63:0]    avalon_st_rx_64b_data;
    wire        [NUM_CHANNELS-1:0][ 2:0]    avalon_st_rx_64b_empty;
    wire        [NUM_CHANNELS-1:0][ 5:0]    avalon_st_rx_64b_error;
    
    wire        [NUM_CHANNELS-1:0][TSTAMP_FP_WIDTH-1:0] tx_egress_timestamp_request_fingerprint_wire;
    wire        [NUM_CHANNELS-1:0]                      tx_egress_timestamp_request_valid_wire;
    
    reg         [NUM_CHANNELS-1:0][95:0]                rx_ingress_timestamp_96b_data_reg;
    
    genvar i;
    
    generate for(i = 0; i < 2; i = i + 1)
        begin : ADAPTOR
            
            always @(posedge clk or negedge reset_n) begin
                if(!reset_n) begin
                    tx_egress_timestamp_request_fingerprint[i] <= {TSTAMP_FP_WIDTH{1'b0}};
                    tx_egress_timestamp_request_valid[i] <= 1'b0;
                end
                else begin
                    if(avalon_st_tx_64b_valid[i] & avalon_st_tx_64b_ready[i] & avalon_st_tx_64b_startofpacket[i]) begin
                        tx_egress_timestamp_request_fingerprint[i] <= tx_egress_timestamp_request_fingerprint_wire[i];
                        tx_egress_timestamp_request_valid[i] <= tx_egress_timestamp_request_valid_wire[i];
                    end
                end
            end
            
            always @(posedge clk or negedge reset_n) begin
                if(!reset_n) begin
                    rx_ingress_timestamp_96b_data_reg[i] <= 96'h0;
                end
                else begin
                    if(rx_ingress_timestamp_96b_valid[i]) begin
                        rx_ingress_timestamp_96b_data_reg[i] <= rx_ingress_timestamp_96b_data[i];
                    end
                end
            end
            
            avalon_st_tx_64b_to_32b tx_64b_to_32b (
                .clk                (clk),
                .reset_n            (reset_n),
                
                .in_valid           (avalon_st_tx_64b_valid[i]),
                .in_ready           (avalon_st_tx_64b_ready[i]),
                .in_startofpacket   (avalon_st_tx_64b_startofpacket[i]),
                .in_endofpacket     (avalon_st_tx_64b_endofpacket[i]),
                .in_data            (avalon_st_tx_64b_data[i]),
                .in_empty           (avalon_st_tx_64b_empty[i]),
                .in_error           (avalon_st_tx_64b_error[i]),
                
                .out_valid          (avalon_st_tx_valid[i]),
                .out_ready          (avalon_st_tx_ready[i]),
                .out_startofpacket  (avalon_st_tx_startofpacket[i]),
                .out_endofpacket    (avalon_st_tx_endofpacket[i]),
                .out_data           (avalon_st_tx_data[i]),
                .out_empty          (avalon_st_tx_empty[i]),
                .out_error          (avalon_st_tx_error[i])
            );
            
            avalon_st_rx_32b_to_64b rx_32b_to_64b (
                .clk                (clk),
                .reset_n            (reset_n),
                
                .in_valid           (avalon_st_rx_valid[i]),
                .in_ready           (avalon_st_rx_ready[i]),
                .in_startofpacket   (avalon_st_rx_startofpacket[i]),
                .in_endofpacket     (avalon_st_rx_endofpacket[i]),
                .in_data            (avalon_st_rx_data[i]),
                .in_empty           (avalon_st_rx_empty[i]),
                .in_error           (avalon_st_rx_error[i]),
                
                .out_valid          (avalon_st_rx_64b_valid[i]),
                .out_ready          (avalon_st_rx_64b_ready[i]),
                .out_startofpacket  (avalon_st_rx_64b_startofpacket[i]),
                .out_endofpacket    (avalon_st_rx_64b_endofpacket[i]),
                .out_data           (avalon_st_rx_64b_data[i]),
                .out_empty          (avalon_st_rx_64b_empty[i]),
                .out_error          (avalon_st_rx_64b_error[i])
            );
        
        end
    endgenerate

    eth_traffic_controller_top #(NUM_CHANNELS,TSTAMP_FP_WIDTH) eth_traffic_controller_top_u0 (
        .clk                                        (clk),
        .reset_n                                    (reset_n),
        
        .avl_mm_baddress                            ({csr_address, 2'b00}),
        .avl_mm_read                                (csr_read),
        .avl_mm_write                               (csr_write),
        .avl_mm_writedata                           (csr_writedata),
        .avl_mm_readdata                            (csr_readdata),
        .avl_mm_waitrequest                         (csr_waitrequest),
        
        .avl_st_tx_val                              (avalon_st_tx_64b_valid),
        .avl_st_tx_ready                            (avalon_st_tx_64b_ready),
        .avl_st_tx_sop                              (avalon_st_tx_64b_startofpacket),
        .avl_st_tx_eop                              (avalon_st_tx_64b_endofpacket),
        .avl_st_tx_data                             (avalon_st_tx_64b_data),
        .avl_st_tx_empty                            (avalon_st_tx_64b_empty),
        .avl_st_tx_error                            (avalon_st_tx_64b_error),
        
        .avl_st_rx_val                              (avalon_st_rx_64b_valid),
        .avl_st_rx_ready                            (avalon_st_rx_64b_ready),
        .avl_st_rx_sop                              (avalon_st_rx_64b_startofpacket),
        .avl_st_rx_eop                              (avalon_st_rx_64b_endofpacket),
        .avl_st_rx_data                             (avalon_st_rx_64b_data),
        .avl_st_rx_empty                            (avalon_st_rx_64b_empty),
        .avl_st_rx_error                            (avalon_st_rx_64b_error),
        
        .avl_st_tx_status_valid                     ({NUM_CHANNELS{1'b0}}),
        .avl_st_tx_status_data                      ({NUM_CHANNELS{40'h0}}),
        .avl_st_tx_status_error                     ({NUM_CHANNELS{7'h0}}),
        
        .avl_st_rx_status_valid                     ({NUM_CHANNELS{1'b0}}),
        .avl_st_rx_status_data                      ({NUM_CHANNELS{40'h0}}),
        .avl_st_rx_status_error                     ({NUM_CHANNELS{7'h0}}),
        
        .tx_egress_timestamp_96b_valid              (tx_egress_timestamp_96b_valid),
        .tx_egress_timestamp_96b_data               (tx_egress_timestamp_96b_data),
        .tx_egress_timestamp_96b_fingerprint        (tx_egress_timestamp_96b_fingerprint),
        
        .tx_egress_timestamp_request_fingerprint    (tx_egress_timestamp_request_fingerprint_wire),
        .tx_egress_timestamp_request_valid          (tx_egress_timestamp_request_valid_wire),
        
        .rx_ingress_timestamp_96b_valid             (avalon_st_rx_64b_valid & avalon_st_rx_64b_ready & avalon_st_rx_64b_startofpacket),
        .rx_ingress_timestamp_96b_data              (rx_ingress_timestamp_96b_data_reg),
        
        .eth_std_stop_mon                           (2'b00),
        .eth_std_mon_active                         (),
        .eth_std_mon_done                           (),
        .eth_std_mon_error                          (),
        
        .eth_1588_wait_limit                        (eth_1588_wait_limit),
        .eth_1588_start_tod_sync                    (eth_1588_start_tod_sync),
        .eth_1588_channel_ready                     (eth_1588_channel_ready),
        .eth_1588_traffic_controller_error_n        (eth_1588_traffic_controller_error_n)
    );

endmodule
