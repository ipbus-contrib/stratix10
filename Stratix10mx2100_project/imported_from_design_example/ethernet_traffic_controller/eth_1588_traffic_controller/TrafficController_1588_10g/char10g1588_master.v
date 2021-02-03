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


module char10g1588_master
  #(parameter WAIT_LIMIT0 = 32'd156250000,
    parameter WAIT_LIMIT1 = 32'd512
    )
   
   (input clk, input rst_n,

    input wire         wait_limit,

    input wire         master_tx_egress_timestamp_96b_valid, 
    input wire [95:0]  master_tx_egress_timestamp_96b_data, 
    input wire [3:0]   master_tx_egress_timestamp_96b_fingerprint, 

    output wire [3:0]  master_tx_egress_timestamp_request_fingerprint, 
    output wire        master_tx_egress_timestamp_request_valid,

    output wire        master_st_rx_ready, 
    input wire         master_st_rx_endofpacket, 
    input wire         master_st_rx_startofpacket, 
    input wire         master_st_rx_valid, 
    input wire [2:0]   master_st_rx_empty, 
    input wire [5:0]   master_st_rx_error, 
    input wire [63:0]  master_st_rx_data, 

    output wire        master_st_tx_endofpacket, 
    output wire        master_st_tx_error, 
    output wire        master_st_tx_startofpacket, 
    output wire        master_st_tx_valid, 
    output wire [2:0]  master_st_tx_empty, 
    output wire [63:0] master_st_tx_data, 
    input wire         master_st_tx_ready, 

    input wire         master_rx_ingress_timestamp_96b_valid, 
    input wire [95:0]  master_rx_ingress_timestamp_96b_data, 

    input wire         master_rx_ready_export, 
    input wire         master_tx_ready_export, 

    input wire         master_st_rxstatus_valid, 
    input wire [39:0]  master_st_rxstatus_data, 
    input wire [6:0]   master_st_rxstatus_error, 

    input wire         master_txstatus_valid, 
    input wire [39:0]  master_txstatus_data, 
    input wire [6:0]   master_txstatus_error,
    input wire [1:0]   master_link_fault_status_xgmii_rx_data,

    input wire         loopback_en,
    output wire        error_o
    );

   localparam INIT = 0;
   localparam WAIT = 1;
   localparam SYNC = 2;
   localparam DELAY_REQ_RCV = 3;
   localparam DELAY_RESP = 4;


   reg [2:0]                                 master_state;

   wire                                      eth_ready;

   reg [31:0]                                wait_count;

   wire                                      delay_req_rcvd;
   wire                                      delay_resp_done;

   wire                                      sync_done;

   wire [95:0]                               delay_resp_timestamp;

   assign eth_ready = master_rx_ready_export & master_tx_ready_export & (master_link_fault_status_xgmii_rx_data==0);

   assign master_tx_egress_timestamp_request_fingerprint = 4'b0000;
   assign master_tx_egress_timestamp_request_valid = 1'b0;

   // TODO: add watchdog?
   
   always @(posedge clk or negedge rst_n) begin
     if (rst_n == 0) begin
        master_state <= INIT;
        wait_count <= 0;
     end else begin
        case (master_state)
          INIT: begin
				 wait_count <= 0;
             if (eth_ready == 1)
               master_state <= WAIT;
             else 
                master_state <= INIT;
			 end
          WAIT: begin
             if (wait_count >= ((wait_limit == 1'b1)? WAIT_LIMIT1:WAIT_LIMIT0)) begin
                master_state <= SYNC;
                wait_count <= 0;
             end else begin
                master_state <= WAIT;
                wait_count <= wait_count+1;
             end
          end
          SYNC: begin
             //wait_count <= wait_count+1;//nga remove
             if (sync_done) begin
                master_state <= DELAY_REQ_RCV;
             end
				 else 
				  master_state <= SYNC;
				 
          end
          DELAY_REQ_RCV: begin
             //wait_count <= wait_count+1;//nga remove
             if (delay_req_rcvd)
               master_state <= DELAY_RESP;
				 else 
				  master_state <= DELAY_REQ_RCV;
          end
          DELAY_RESP: begin
             //wait_count <= wait_count+1; //nga remove
             if (delay_resp_done)
               master_state <= INIT;  // nga modify , orignal: master_state <= WAIT
				 else 
				  master_state <= DELAY_RESP;
          end
          default: begin
             //wait_count <= wait_count+1;//nga remove
             master_state <= INIT;
          end
        endcase // case (master_state)
     end
   end // always @ (posedge clk or negedge rst_n)

   char10g1588_master_pkt_gen
     pkt_gen(.clk(clk),
             .rst_n(rst_n),
             .sync_gen(master_state == SYNC),
             .sync_done(sync_done),
             .delay_resp_gen(master_state == DELAY_RESP),
             .delay_resp_done(delay_resp_done),

             .master_st_tx_endofpacket(master_st_tx_endofpacket), 
             .master_st_tx_error(master_st_tx_error), 
             .master_st_tx_startofpacket(master_st_tx_startofpacket), 
             .master_st_tx_valid(master_st_tx_valid), 
             .master_st_tx_empty(master_st_tx_empty), 
             .master_st_tx_data(master_st_tx_data), 
             .master_st_tx_ready(master_st_tx_ready),

             // For Delay Resp
             .delay_resp_timestamp(delay_resp_timestamp)

             );

   char10g1588_master_pkt_rcv
     pkt_rcv(.clk(clk),
             .rst_n(rst_n),
             .error_o(error_o),

             .delay_req_en(master_state == DELAY_REQ_RCV),
             .delay_req_rcvd(delay_req_rcvd),

             .master_st_rx_endofpacket(master_st_rx_endofpacket), 
             .master_st_rx_error(master_st_rx_error), 
             .master_st_rx_startofpacket(master_st_rx_startofpacket), 
             .master_st_rx_valid(master_st_rx_valid), 
             .master_st_rx_empty(master_st_rx_empty), 
             .master_st_rx_data(master_st_rx_data), 
             .master_st_rx_ready(master_st_rx_ready), 
   
             .master_rx_ingress_timestamp_96b_valid(master_rx_ingress_timestamp_96b_valid), 
             .master_rx_ingress_timestamp_96b_data(master_rx_ingress_timestamp_96b_data),
             
             .delay_resp_timestamp(delay_resp_timestamp)
             );

   
endmodule // char10g1588_master
