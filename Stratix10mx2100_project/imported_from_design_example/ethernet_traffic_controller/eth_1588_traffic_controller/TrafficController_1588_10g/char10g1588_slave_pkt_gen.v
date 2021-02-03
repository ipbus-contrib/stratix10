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


module char10g1588_slave_pkt_gen(
                                 input             clk,
                                 input             rst_n,

                                 input             delay_req_gen,
                                 output            delay_req_done,

                                 output            slave_st_tx_endofpacket,
                                 output            slave_st_tx_error,
                                 output            slave_st_tx_startofpacket,
                                 output            slave_st_tx_valid,
                                 output [2:0]      slave_st_tx_empty,
                                 output [63:0]     slave_st_tx_data,
                                 input             slave_st_tx_ready,

                                 output            slave_tx_egress_timestamp_request_valid,
                                 output [3:0]      slave_tx_egress_timestamp_request_fingerprint,

                                 input             slave_tx_egress_timestamp_96b_valid,
                                 input [95:0]      slave_tx_egress_timestamp_96b_data,

                                 // For Delay Resp
                                 output reg [95:0] t3
                                 );


   /* char10g1588_pkt_gen AUTO_TEMPLATE (
    .done                       (delay_req_done),
    .gen                        (delay_req_gen),
    .endofpacket                (slave_st_tx_endofpacket),
    .error                      (slave_st_tx_error),
    .startofpacket              (slave_st_tx_startofpacket),
    .valid                      (slave_st_tx_valid),
    .empty                      (slave_st_tx_empty[2:0]),
    .data                       (slave_st_tx_data[63:0]),
    .ready                      (slave_st_tx_ready),
    .timestamp                  (80'b0),
    .correction                 (64'd0),
    );
    */

   char10g1588_pkt_gen
     #(.messageType(8'h01))
   delay_req_pgen(/*AUTOINST*/
                  // Outputs
                  .done                 (delay_req_done),        // Templated
                  .endofpacket          (slave_st_tx_endofpacket), // Templated
                  .error                (slave_st_tx_error),     // Templated
                  .startofpacket        (slave_st_tx_startofpacket), // Templated
                  .valid                (slave_st_tx_valid),     // Templated
                  .empty                (slave_st_tx_empty[2:0]), // Templated
                  .data                 (slave_st_tx_data[63:0]), // Templated
                  // Inputs
                  .clk                  (clk),
                  .rst_n                (rst_n),
                  .gen                  (delay_req_gen),         // Templated
                  .ready                (slave_st_tx_ready),     // Templated
                  .timestamp            (80'b0),                 // Templated
                  .correction           (64'd0));                // Templated

   assign slave_tx_egress_timestamp_request_valid = slave_st_tx_startofpacket;
   assign slave_tx_egress_timestamp_request_fingerprint = 4'b0101;

   // TODO: improve
   always @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         t3 <= 0;
      end else begin
         if (slave_tx_egress_timestamp_96b_valid)
           t3 <= slave_tx_egress_timestamp_96b_data[95:0];
      end
   end

endmodule
                                  
                                  