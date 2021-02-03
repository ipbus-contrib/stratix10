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


module char10g1588_slave_compute(
                                 input             clk,
                                 input             rst_n,

                                 input             compute_en,
                                 input             ready,

                                 input [95:0]      t1, t2, t3, t4,

                                 output reg        valid,
                                 output reg [95:0] offset,
                                 output reg [95:0] delay
                                 );

   wire [47:0]                                     t1_sec, t2_sec, t3_sec, t4_sec;
   wire [47:0]                                     t1_fnsec, t2_fnsec, t3_fnsec, t4_fnsec;
   
   assign t1_sec   = t1[95:48];
   assign t1_fnsec = t1[47:0];
   assign t2_sec   = t2[95:48];
   assign t2_fnsec = t2[47:0];
   assign t3_sec   = t3[95:48];
   assign t3_fnsec = t3[47:0];
   assign t4_sec   = t4[95:48];
   assign t4_fnsec = t4[47:0];

   reg                                             inter;
   reg [47:0]                                      offset_sec, offset_fnsec;
   reg [47:0]                                      delay_sec, delay_fnsec;

   always @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         valid <= 0;
         offset <= 0;
         delay <= 0;
         inter <= 0;
         offset_sec <= 0;
         offset_fnsec <= 0;
         delay_sec <= 0;
         delay_fnsec <= 0;
      end else begin
         if (valid) begin
            if (compute_en == 0) valid <= 0;
         end else if (compute_en && inter==0) begin
            valid <= 0;
            inter <= 1;
            offset_sec <= (t2_sec - t1_sec - t4_sec + t3_sec);
            delay_sec  <= (t2_sec - t1_sec + t4_sec - t3_sec);
            offset_fnsec <= (t2_fnsec - t1_fnsec - t4_fnsec + t3_fnsec); // divide by 2 below
            delay_fnsec  <= (t2_fnsec - t1_fnsec + t4_fnsec - t3_fnsec); // divide by 2 below
         end else if (compute_en && inter==1) begin
            
            valid <= 1;
            inter <= 0;
            
            // Divide by 2, sign extend
            offset[95:48] <= {offset_sec[47],offset_sec[47:1]};
            offset[47:0] <= {offset_fnsec[47],offset_fnsec[47:1]};
               
            // Divide by 2, sign extend (probably unnecessary)
            delay[95:48] <= {delay_sec[47],delay_sec[47:1]};
            delay[47:0] <= {delay_fnsec[47],delay_fnsec[47:1]};
         end // else: !if(offset_sec != 0)
         
      end
   end // always @ (posedge clk or negedge rst_n)


endmodule // char10g1588_slave_compute

 
// comment:
// Offset = (T2-T1) - (T4-T3)    ,     Delay = (T2-T1) + (T4-T3)
//          -----------------    ,             -----------------
//                  2            ,                     2
// MSB must be a sign instead of part of large positive number. because both offset and delay 
// are not expected to have up to 48bits positive value