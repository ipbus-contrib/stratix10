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


module char10g1588_slave(input clk, input rst_n,

                         input wire          slave_st_tx_ready, 
                         output wire         slave_st_tx_endofpacket, 
                         output wire         slave_st_tx_error, 
                         output wire         slave_st_tx_startofpacket, 
                         output wire         slave_st_tx_valid, 
                         output wire [2:0]   slave_st_tx_empty, 
                         output wire [63:0]  slave_st_tx_data, 

                         output wire         slave_st_rx_ready, 
                         input wire          slave_st_rx_endofpacket, 
                         input wire          slave_st_rx_startofpacket, 
                         input wire          slave_st_rx_valid, 
                         input wire [2:0]    slave_st_rx_empty, 
                         input wire [5:0]    slave_st_rx_error, 
                         input wire [63:0]   slave_st_rx_data, 

                         output wire         slave_tx_egress_timestamp_request_valid, 
                         output wire [3:0]   slave_tx_egress_timestamp_request_fingerprint, 

                         input wire          slave_tx_egress_timestamp_96b_valid, 
                         input wire [95:0]   slave_tx_egress_timestamp_96b_data, 
                         input wire [3:0]   slave_tx_egress_timestamp_96b_fingerprint, 

                         input wire          slave_rx_ingress_timestamp_96b_valid, 
                         input wire [95:0]   slave_rx_ingress_timestamp_96b_data, 

                         output wire         offset_adjustment_valid,
                         output wire [191:0] offset_adjustment_data,
                         input wire          offset_adjustment_ready,

                         output wire         error_o
                         );

   wire [95:0]                               t1, t2, t3, t4;

   localparam INIT = 0;
   localparam SYNC_RCV = 1;
   localparam DELAY_REQ = 2;
   localparam DELAY_RESP_RCV = 3;
   localparam COMPUTE = 4;
   
   reg [2:0]                                 slave_state;
   wire                                      eth_ready;
   wire                                      sync_rcvd;
   wire                                      delay_req_done;
   wire                                      delay_resp_rcvd;
   
   assign eth_ready = 1;
   
   always @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         slave_state <= INIT;
      end else begin
         case (slave_state)
           INIT: begin
              if (eth_ready)
                slave_state <= SYNC_RCV;
           end
           SYNC_RCV: begin
              if (sync_rcvd)
                slave_state <= DELAY_REQ;
           end
           DELAY_REQ: begin
              if (delay_req_done)
                slave_state <= DELAY_RESP_RCV;
           end
           DELAY_RESP_RCV: begin
              if (delay_resp_rcvd)
                slave_state <= COMPUTE;
           end
           COMPUTE: begin
              if (offset_adjustment_valid)
                slave_state <= SYNC_RCV;
           end
           default:
             slave_state <= INIT;
         endcase // case (slave_state)
      end
   end // always @ (posedge clk or negedge rst_n)
   
   char10g1588_slave_pkt_gen
     pkt_gen(.clk(clk),
             .rst_n(rst_n),
             
             .delay_req_gen(slave_state == DELAY_REQ),
             .delay_req_done(delay_req_done),

             .slave_st_tx_endofpacket(slave_st_tx_endofpacket), 
             .slave_st_tx_error(slave_st_tx_error), 
             .slave_st_tx_startofpacket(slave_st_tx_startofpacket), 
             .slave_st_tx_valid(slave_st_tx_valid), 
             .slave_st_tx_empty(slave_st_tx_empty), 
             .slave_st_tx_data(slave_st_tx_data), 
             .slave_st_tx_ready(slave_st_tx_ready),

             .slave_tx_egress_timestamp_request_valid(slave_tx_egress_timestamp_request_valid), 
             .slave_tx_egress_timestamp_request_fingerprint(slave_tx_egress_timestamp_request_fingerprint),

             .slave_tx_egress_timestamp_96b_valid(slave_tx_egress_timestamp_96b_valid), 
             .slave_tx_egress_timestamp_96b_data(slave_tx_egress_timestamp_96b_data),

             .t3(t3)

             );

   char10g1588_slave_pkt_rcv
     pkt_rcv(.clk(clk),
             .rst_n(rst_n),

             .error_o(error_o),
             .sync_en(slave_state == SYNC_RCV),
             .sync_rcvd(sync_rcvd),
             
             .delay_resp_en(slave_state == DELAY_RESP_RCV),
             .delay_resp_rcvd(delay_resp_rcvd),

             .slave_st_rx_endofpacket(slave_st_rx_endofpacket), 
             .slave_st_rx_error(slave_st_rx_error), 
             .slave_st_rx_startofpacket(slave_st_rx_startofpacket), 
             .slave_st_rx_valid(slave_st_rx_valid), 
             .slave_st_rx_empty(slave_st_rx_empty), 
             .slave_st_rx_data(slave_st_rx_data), 
             .slave_st_rx_ready(slave_st_rx_ready), 
   
             .slave_rx_ingress_timestamp_96b_valid(slave_rx_ingress_timestamp_96b_valid), 
             .slave_rx_ingress_timestamp_96b_data(slave_rx_ingress_timestamp_96b_data),

             .t1(t1),
             .t2(t2),
             .t4(t4)

             );

   char10g1588_slave_compute
     compute(.clk(clk),
             .rst_n(rst_n),

             .compute_en(slave_state == COMPUTE),
             
             .t1(t1),
             .t2(t2),
             .t3(t3),
             .t4(t4),

             .valid(offset_adjustment_valid),
             .offset(offset_adjustment_data[95:0]),
             .delay(offset_adjustment_data[191:96]),
             .ready(offset_adjustment_ready)
             
             );

   
endmodule // slave
