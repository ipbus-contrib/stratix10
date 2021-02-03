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


module char10g1588_pkt_rcv
  #(
    parameter lengthType = 16'h88f7,  // 802.3 1588 ethertype
    parameter messageType = 8'b0,
    parameter ptpVersion = 8'b0,
    parameter messageLength = 16'd58,

    parameter correctionField = 64'd0,
    
    parameter pkt_start = 1,
    parameter pkt_end = 8,
    
    parameter empty_flag = 3'd6
    )
   (input clk,
    input        rst_n,
                           
    input        en,
    output reg   rcvd,
    output reg   error_o,

    input        endofpacket,
    input [5:0]  error,
    input        startofpacket,
    input        valid,
    input [2:0]  empty,
    input [63:0] data,
    output reg   ready,

    output reg [79:0] timestamp,
    output reg [63:0] correction

    );

   // Big endian.

   // PACKET MAP
   // S S D D D D D D    : D - dest, S - source
   // V M T T S S S S    : T - type 0x88f7, M - message type (0 sync), V - version (0)
   // C C F F R D L L    : L - length, R - reserved, F - flag, C - CorrectionField
   // R R C C C C C C    : R - reserved
   // S S S S S S R R    : S - Source Port Identity
   // M C Q Q S S S S    : Q - Sequence ID, C - control field, M - logMessageInterval
   // T T T T T T T T    : T - Timestamp

   // sync:
   // X X X X X X T T    : X - Unspecified
   // Message Length = 'd58

   // delay_resp: (filled in with 0)
   // I I I I I I T T    : I - RequestingPortId
   // X X X X I I I I
   // Message Length = 'd68

   
   reg [15:0]                                 count;
   reg [15:0]                                 lType;
   reg [7:0]                                  mType;
   reg [7:0]                                  pVersion;
   reg [63:0]                                 junk;

   always @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         count <= 0;
         rcvd <= 0;
         ready <= 0;
      end else begin
         ready <= en;

         if (rcvd == 1) begin
            count <= 0;
            if (en == 0) rcvd <= 0;
         end else if (count == 0 && 
                      en == 1) begin
            count <= 1;
            rcvd <= 0;
         end else if (count > 0 &&
                      valid == 1) begin
            count <= count + 16'd1;
            if (endofpacket == 1) begin
               if (lType == lengthType &&
                   mType == messageType) begin
                  rcvd <= 1;
               end else begin
                  count <= 0;
               end
            end
            
         end
      end // else: !if(rst_n == 0)
   end // always @ (posedge clk or negedge rst_n)

   always @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         timestamp <= 0;
         correction <= 0;
         lType <= 0;
         mType <= 0;
         pVersion <= 0;
         junk <= 0;
         error_o <= 0;
      end
      else begin
         if (valid) begin
            case (count)
              //           0: data <= 64'h00_00_00_00_00_00_00_00;
              //           1: data <= {sourceAddr[15:0],destAddr};
              //           2: data <= {ptpVersion,messageType,lengthType,sourceAddr[47:16]};
              2: {junk[47:16],lType,mType,pVersion} <= data;
              3: {junk[47:0],correction[63:48]} <= data;
              4: {correction[47:0],junk[15:0]} <= data;
              //           5: data <= {sourcePortId[47:0],16'b0};
              5: error_o <= (data == 64'haaaaaaaaaaaaaaaa) ? error_o : 1'b1;
              //           6: data <= {logMessageInterval,controlField,sequenceId,sourcePortId[79:48]};
              6: error_o <= (data == 64'h5555555555555555) ? error_o : 1'b1;
              7: timestamp[79:16] <= data;
              8: {timestamp[15:0],junk[47:0]} <= data;
              default : begin
                 timestamp <= timestamp;
                 correction <= correction;
              end
            endcase // case (count)
         end // if (valid)
         else begin
            timestamp <= timestamp;
            correction <= correction;
         end // else: !if(valid)
      end
   end // always @ (posedge clk or negedge rst_n)


endmodule // char10g1588_pkt_rcv

