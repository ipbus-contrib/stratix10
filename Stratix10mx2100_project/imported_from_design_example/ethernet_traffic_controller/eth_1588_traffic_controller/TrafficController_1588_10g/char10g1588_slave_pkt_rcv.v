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


module char10g1588_slave_pkt_rcv(
                                 input             clk,
                                 input             rst_n,

                                 input             delay_resp_en,
                                 output            delay_resp_rcvd,

                                 input             sync_en,
                                 output            sync_rcvd,

                                 input             slave_st_rx_endofpacket,
                                 input             slave_st_rx_startofpacket,
                                 input             slave_st_rx_valid,
                                 input [2:0]       slave_st_rx_empty,
                                 input [5:0]       slave_st_rx_error,
                                 input [63:0]      slave_st_rx_data,
                                 output            slave_st_rx_ready,

                                 input             slave_rx_ingress_timestamp_96b_valid,
                                 input [95:0]      slave_rx_ingress_timestamp_96b_data,
                                  
                                 output reg [95:0] t1,
                                 output reg [95:0] t2,
                                 output reg [95:0] t4,

                                 output error_o
                                 
                                 
                                 );

   wire [63:0]                 delay_resp_correction;  // From delay_resp_rcvr of char10g1588_pkt_rcv.v
   wire [63:0]                 sync_correction;  // From delay_resp_rcvr of char10g1588_pkt_rcv.v
   wire [79:0]                 delay_resp_timestamp;  // From delay_resp_rcvr of char10g1588_pkt_rcv.v
   wire [79:0]                 sync_timestamp;  // From delay_resp_rcvr of char10g1588_pkt_rcv.v

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 delay_resp_ready;       // From delay_resp_rcvr of char10g1588_pkt_rcv.v
   wire                 error1;                 // From delay_resp_rcvr of char10g1588_pkt_rcv.v
   wire                 error2;                 // From sync_rcvr of char10g1588_pkt_rcv.v
   wire                 sync_ready;             // From sync_rcvr of char10g1588_pkt_rcv.v
   // End of automatics

   assign error_o = error1 | error2;

   /* char10g1588_pkt_rcv AUTO_TEMPLATE (
    .rcvd               (delay_resp_rcvd),
    .error_o            (error1),
    .en                 (delay_resp_en),
    .ready              (delay_resp_ready),
    .timestamp          (delay_resp_timestamp),
    .correction         (delay_resp_correction),
    .endofpacket        (slave_st_rx_endofpacket),
    .error              (slave_st_rx_error),
    .startofpacket      (slave_st_rx_startofpacket),
    .valid              (slave_st_rx_valid),
    .empty              (slave_st_rx_empty),
    .data               (slave_st_rx_data),
    );
    */


   char10g1588_pkt_rcv
    #(.messageType(16'd3)) // delayResp
     delay_resp_rcvr(/*AUTOINST*/
                     // Outputs
                     .rcvd              (delay_resp_rcvd),       // Templated
                     .error_o           (error1),                // Templated
                     .ready             (delay_resp_ready),      // Templated
                     .timestamp         (delay_resp_timestamp),  // Templated
                     .correction        (delay_resp_correction), // Templated
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .en                (delay_resp_en),         // Templated
                     .endofpacket       (slave_st_rx_endofpacket), // Templated
                     .error             (slave_st_rx_error),     // Templated
                     .startofpacket     (slave_st_rx_startofpacket), // Templated
                     .valid             (slave_st_rx_valid),     // Templated
                     .empty             (slave_st_rx_empty),     // Templated
                     .data              (slave_st_rx_data));     // Templated
   

   /* char10g1588_pkt_rcv AUTO_TEMPLATE (
    .rcvd                       (sync_rcvd),
    .error_o            (error2),
    .en                         (sync_en),
    .ready                      (sync_ready),
    .timestamp                  (sync_timestamp),
    .correction                 (sync_correction),
    .endofpacket        (slave_st_rx_endofpacket),
    .error              (slave_st_rx_error),
    .startofpacket      (slave_st_rx_startofpacket),
    .valid              (slave_st_rx_valid),
    .empty              (slave_st_rx_empty),
    .data               (slave_st_rx_data),
    );
    */


   char10g1588_pkt_rcv
     #(.messageType(16'd0)) // sync
     sync_rcvr(/*AUTOINST*/
               // Outputs
               .rcvd                    (sync_rcvd),             // Templated
               .error_o                 (error2),                // Templated
               .ready                   (sync_ready),            // Templated
               .timestamp               (sync_timestamp),        // Templated
               .correction              (sync_correction),       // Templated
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .en                      (sync_en),               // Templated
               .endofpacket             (slave_st_rx_endofpacket), // Templated
               .error                   (slave_st_rx_error),     // Templated
               .startofpacket           (slave_st_rx_startofpacket), // Templated
               .valid                   (slave_st_rx_valid),     // Templated
               .empty                   (slave_st_rx_empty),     // Templated
               .data                    (slave_st_rx_data));     // Templated
   
   assign slave_st_rx_ready = sync_ready | delay_resp_ready;
   
   
   always @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         t1 <= 0;
         t2 <= 0;
         t4 <= 0;
      end else begin
         if (sync_en &&
             slave_st_rx_startofpacket &&
             slave_rx_ingress_timestamp_96b_valid)
           t2 <= slave_rx_ingress_timestamp_96b_data;

         if (sync_rcvd)
           t1 <= {sync_timestamp,sync_correction[15:0]};

         if (delay_resp_rcvd)
           t4 <= {delay_resp_timestamp,delay_resp_correction[15:0]};
      end
   end

   
endmodule // char10g1588_slave_pkt_rcv

// Local Variables:
// verilog-library-flags:("-y ./")
// End:
