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


module char10g1588_master_pkt_rcv(
                                  input             clk,
                                  input             rst_n,

                                  input             delay_req_en,
                                  output            delay_req_rcvd,

                                  input             master_st_rx_endofpacket,
                                  input             master_st_rx_startofpacket,
                                  input             master_st_rx_valid,
                                  input [2:0]       master_st_rx_empty,
                                  input [5:0]       master_st_rx_error,
                                  input [63:0]      master_st_rx_data,
                                  output            master_st_rx_ready,

                                  input             master_rx_ingress_timestamp_96b_valid,
                                  input [95:0]      master_rx_ingress_timestamp_96b_data,
                                  
                                  output reg [95:0] delay_resp_timestamp,
                                  output            error_o
                                  );

   /* char10g1588_pkt_rcv AUTO_TEMPLATE (
    .rcvd                       (delay_req_rcvd),
    .en                         (delay_req_en),
    .timestamp                  (),
    .correction                 (),
    .endofpacket        (master_st_rx_endofpacket),
    .error              (master_st_rx_error),
    .startofpacket      (master_st_rx_startofpacket),
    .valid              (master_st_rx_valid),
    .ready              (master_st_rx_ready),
    .empty              (master_st_rx_empty),
    .data               (master_st_rx_data),
    );
    */

  char10g1588_pkt_rcv
    #(.messageType(16'd1)) // delayReq
    rcv(/*AUTOINST*/
        // Outputs
        .rcvd                           (delay_req_rcvd),        // Templated
        .error_o                        (error_o),
        .ready                          (master_st_rx_ready),    // Templated
        .timestamp                      (),                      // Templated
        .correction                     (),                      // Templated
        // Inputs
        .clk                            (clk),
        .rst_n                          (rst_n),
        .en                             (delay_req_en),          // Templated
        .endofpacket                    (master_st_rx_endofpacket), // Templated
        .error                          (master_st_rx_error),    // Templated
        .startofpacket                  (master_st_rx_startofpacket), // Templated
        .valid                          (master_st_rx_valid),    // Templated
        .empty                          (master_st_rx_empty),    // Templated
        .data                           (master_st_rx_data));    // Templated

   always @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         delay_resp_timestamp <= 0;
      end else begin
         if (delay_req_en &&
             master_st_rx_startofpacket &&
             master_rx_ingress_timestamp_96b_valid)
           delay_resp_timestamp <= master_rx_ingress_timestamp_96b_data;
      end
   end
   
endmodule // char10g1588_master_pkt_rcv


