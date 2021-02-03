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


module char10g1588_master_pkt_gen(
                                  input         clk,
                                  input         rst_n,

                                  input         sync_gen,
                                  output        sync_done,

                                  input         delay_resp_gen,
                                  output        delay_resp_done,

                                  output        master_st_tx_endofpacket,
                                  output        master_st_tx_error,
                                  output        master_st_tx_startofpacket,
                                  output        master_st_tx_valid,
                                  output [2:0]  master_st_tx_empty,
                                  output [63:0] master_st_tx_data,
                                  input         master_st_tx_ready,


                                  // For Delay Resp
                                  input [95:0]  delay_resp_timestamp);

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [63:0]          delay_resp_data;        // From delay_resp_pgen of char10g1588_pkt_gen.v
   wire [2:0]           delay_resp_empty;       // From delay_resp_pgen of char10g1588_pkt_gen.v
   wire                 delay_resp_endofpacket; // From delay_resp_pgen of char10g1588_pkt_gen.v
   wire                 delay_resp_error;       // From delay_resp_pgen of char10g1588_pkt_gen.v
   wire                 delay_resp_startofpacket;// From delay_resp_pgen of char10g1588_pkt_gen.v
   wire                 delay_resp_valid;       // From delay_resp_pgen of char10g1588_pkt_gen.v
   wire [63:0]          sync_data;              // From sync_pgen of char10g1588_pkt_gen.v
   wire [2:0]           sync_empty;             // From sync_pgen of char10g1588_pkt_gen.v
   wire                 sync_endofpacket;       // From sync_pgen of char10g1588_pkt_gen.v
   wire                 sync_error;             // From sync_pgen of char10g1588_pkt_gen.v
   wire                 sync_startofpacket;     // From sync_pgen of char10g1588_pkt_gen.v
   wire                 sync_valid;             // From sync_pgen of char10g1588_pkt_gen.v
   // End of automatics

   /* char10g1588_pkt_gen AUTO_TEMPLATE (
    .done                       (sync_done),
    .endofpacket                (sync_endofpacket),
    .error                      (sync_error),
    .startofpacket              (sync_startofpacket),
    .valid                      (sync_valid),
    .empty                      (sync_empty[2:0]),
    .data                       (sync_data[63:0]),
    .gen                        (sync_gen),
    .ready                      (master_st_tx_ready),
    .timestamp                  (80'b0),
    .correction                 (64'd0),
    );
    */

   char10g1588_pkt_gen
     sync_pgen(/*AUTOINST*/
               // Outputs
               .done                    (sync_done),             // Templated
               .endofpacket             (sync_endofpacket),      // Templated
               .error                   (sync_error),            // Templated
               .startofpacket           (sync_startofpacket),    // Templated
               .valid                   (sync_valid),            // Templated
               .empty                   (sync_empty[2:0]),       // Templated
               .data                    (sync_data[63:0]),       // Templated
               // Inputs
               .clk                     (clk),
               .rst_n                   (rst_n),
               .gen                     (sync_gen),              // Templated
               .ready                   (master_st_tx_ready),    // Templated
               .timestamp               (80'b0),                 // Templated
               .correction              (64'd0));                // Templated



   /* char10g1588_pkt_gen AUTO_TEMPLATE (
    .done                       (delay_resp_done),
    .endofpacket                (delay_resp_endofpacket),
    .error                      (delay_resp_error),
    .startofpacket              (delay_resp_startofpacket),
    .valid                      (delay_resp_valid),
    .empty                      (delay_resp_empty[2:0]),
    .data                       (delay_resp_data[63:0]),
    .gen                        (delay_resp_gen),
    .ready                      (master_st_tx_ready),
    .timestamp                  (delay_resp_timestamp[95:16]),
    .correction                 ({48'd0,delay_resp_timestamp[15:0]}),
    );
    */


   char10g1588_pkt_gen
     #(.pkt_end(16'd9),
       .messageLength(16'd68),
       .messageType(8'h03),
       .empty_flag(3'd4))
     delay_resp_pgen(/*AUTOINST*/
                     // Outputs
                     .done              (delay_resp_done),       // Templated
                     .endofpacket       (delay_resp_endofpacket), // Templated
                     .error             (delay_resp_error),      // Templated
                     .startofpacket     (delay_resp_startofpacket), // Templated
                     .valid             (delay_resp_valid),      // Templated
                     .empty             (delay_resp_empty[2:0]), // Templated
                     .data              (delay_resp_data[63:0]), // Templated
                     // Inputs
                     .clk               (clk),
                     .rst_n             (rst_n),
                     .gen               (delay_resp_gen),        // Templated
                     .ready             (master_st_tx_ready),    // Templated
                     .timestamp         (delay_resp_timestamp[95:16]), // Templated
                     .correction        ({48'd0,delay_resp_timestamp[15:0]})); // Templated


   assign master_st_tx_endofpacket   = sync_endofpacket | delay_resp_endofpacket;
   assign master_st_tx_error         = sync_error | delay_resp_error;
   assign master_st_tx_startofpacket = sync_startofpacket | delay_resp_startofpacket;
   assign master_st_tx_valid         = sync_valid | delay_resp_valid;
   assign master_st_tx_empty         = sync_empty | delay_resp_empty;
   assign master_st_tx_data          = sync_data | delay_resp_data;
   
   

endmodule // char10g1588_master_pkt_gen

// Local Variables:
// verilog-library-flags:("-y ./")
// End:
