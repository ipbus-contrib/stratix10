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


module char10g1588_avg(
                       input             clk, 
                       input             rst_n,
                       input [95:0]      offset_adjustment_data,
                       input             offset_adjustment_valid,
                       output reg        offset_adjustment_ready,
                       output reg [47:0] average_offset_fnsec,
                       output reg        sec_error,
                       output reg        queue_valid
                       );

   parameter QUEUE_DEPTH = 64;
   localparam BILLION = 32'd1000000000;

   function integer log2;
      input [31:0] value;
      for (log2=0; value>0; log2=log2+1) begin
        value = value>>1;
      end
   endfunction

   reg [47:0]                            fnsec_adjustment_q[0:QUEUE_DEPTH-1];
   reg [47:0]                            fnsec_delta;
   reg [log2(QUEUE_DEPTH):0]             idx;
   reg                                   compute_avg;
   
   reg [48+log2(QUEUE_DEPTH):0]          runsum;
  

   wire [47:0]                           sec_data;
   assign sec_data   = offset_adjustment_data[95:48];
   wire [47:0]                           fnsec_data;
   assign fnsec_data = offset_adjustment_data[47:0];

   wire [48+log2(QUEUE_DEPTH):0]         fnsec_delta_extend;
   assign fnsec_delta_extend = {{(log2(QUEUE_DEPTH)+1){fnsec_delta[47]}},fnsec_delta};

   wire [47:0]                           fnsec_q_read;
   assign fnsec_q_read = fnsec_adjustment_q[idx];
   wire [48+log2(QUEUE_DEPTH):0]         fnsec_q_extend;
   assign fnsec_q_extend = {{(log2(QUEUE_DEPTH)+1){fnsec_q_read[47]}},fnsec_q_read};

   always @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         compute_avg<=0;
         fnsec_delta<=0;
         sec_error <= 0;
         offset_adjustment_ready <= 0;
         
      end else begin
         offset_adjustment_ready <= 1;
         if (offset_adjustment_valid && ~compute_avg) begin
            if (sec_data == 0) begin
               compute_avg<=1;
               fnsec_delta <= fnsec_data;
            end else if (sec_data == 1) begin
               compute_avg<=1;
               fnsec_delta <= {BILLION,16'b0} + fnsec_data;
            end else if (&sec_data == 1) begin
               compute_avg<=1;
               fnsec_delta <= fnsec_data - {BILLION,16'b0};
            end else begin
               compute_avg<=0;
               fnsec_delta <= 0;
               sec_error <= 1;
            end
         end // if (offset_adjustment_valid)
         else begin
            compute_avg <= 0;
         end // else: !if(offset_adjustment_valid)
      end
   end
   
   always @(posedge clk) begin
      if (compute_avg)
         fnsec_adjustment_q[idx] <= fnsec_delta;
   end

   always @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         idx <= 0;
         runsum <= 0;
         queue_valid <= 0;
         average_offset_fnsec <= 0;
      end else begin
         average_offset_fnsec <= runsum / QUEUE_DEPTH;

         if (compute_avg) begin
            if (idx == QUEUE_DEPTH-1) begin
               queue_valid <= 1;
               idx <= 0;
            end else begin
               queue_valid <= queue_valid;
               idx <= idx + {{(log2(QUEUE_DEPTH)){1'b0}}, 1'b1};
            end
            runsum <= runsum +
                      fnsec_delta_extend -
                      ((queue_valid) ? fnsec_q_extend : 0);
         end
      end
   end
                       
endmodule
                       
