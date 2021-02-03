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


module char10g1588_initial 
  #(
    parameter CLKCOUNT = 200,
    parameter XGMIICOUNT = 200
    )
   (input  clk, 
    input      rst_n, 
    input      xgmii_clk,
    output reg ready);

   reg [15:0]                 clk_count;
   reg [15:0]                 xgmii_count;
   reg                        clk_ready;
   reg                        clk_ready_xgmii;
   
   always @(posedge clk or negedge rst_n)
     if (rst_n == 0) begin
        clk_count <= 0;
        clk_ready <= 0;
     end else begin
        clk_count <= clk_count+1;
        clk_ready <= clk_ready | (clk_count >= CLKCOUNT);
     end

   
   always @(posedge xgmii_clk or negedge rst_n)
     if (rst_n == 0) begin
        ready <= 0;
        clk_ready_xgmii <= 0;
        xgmii_count <= 0;
     end else begin
        ready <= ready | (xgmii_count >= XGMIICOUNT);
        clk_ready_xgmii <= clk_ready;
        xgmii_count <= (clk_ready_xgmii) ? xgmii_count+1 : 0;
     end
   
endmodule // char10g1588_initial

        
   
   
   
                           