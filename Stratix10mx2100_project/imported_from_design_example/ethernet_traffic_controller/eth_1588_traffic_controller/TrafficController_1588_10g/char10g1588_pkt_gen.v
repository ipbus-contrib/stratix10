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


module char10g1588_pkt_gen
  #(
    parameter destAddr = 48'd0,
    parameter sourceAddr = 48'd0,
    parameter lengthType = 16'h88f7,  // 802.3 1588 ethertype
    parameter messageType = 8'b0,
    parameter ptpVersion = 8'b0,
    parameter messageLength = 16'd58,
    parameter domainNumber = 8'b0,
    parameter flagField = 16'b0000_0000_0000_0100,  // Unicast
    parameter sourcePortId = 80'd0,
    parameter sequenceId = 16'd0,
    parameter controlField = 8'd0,
    parameter logMessageInterval = 8'b0,
    
    parameter pkt_start = 16'd1,
    parameter pkt_end = 16'd8,
    
    parameter empty_flag = 3'd6
    )
   (input clk,
    input             rst_n,
                           
    input             gen,
    output reg        done,

    output reg        endofpacket,
    //output reg        error,				//jier avoid inferring latch
    output wire 		error,
    output reg        startofpacket,
    output reg        valid,
    output reg [2:0]  empty,
    output reg [63:0] data,
    input             ready,
    input [79:0]      timestamp,
    input [63:0]      correction
    

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

   assign	error	= 1'b0;		//jier avoid inferring latch
   
   reg [15:0]                                 count;

   always @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         count <= 0;
         //error <= 0;					//jier avoid inferring latch
         done <= 0;
      end
      else begin
         // valid, SOP, EOP
         if (count == 0) begin
            if (done==1) begin
               count <= 0;
               if (gen == 0) done <= 0;
            end else begin
               if (gen == 1) count <= pkt_start;
               done <= 0;
            end
         end else begin
            if (ready) begin
               if (count == pkt_end) count <= 0;
               else count <= count + 16'd1;
            end
            
            if (count == pkt_end) done <= 1;
            else done <= 0;
            
         end
      end
   end // always @ (posedge clk or negedge rst_n)

   always @* begin
         startofpacket <= (count == pkt_start) ? 1'b1 : 1'b0;
         valid <= (count >= pkt_start && count <= pkt_end) ? 1'b1:1'b0;
         endofpacket <= (count == pkt_end) ? 1'b1:1'b0;
         empty <= (count==pkt_end) ? empty_flag : 3'b0;

         // data
         case (count)
           0: data <= 64'h00_00_00_00_00_00_00_00;
           1: data <= {destAddr,sourceAddr[15:0]};
           //2: data <= {ptpVersion,messageType,lengthType,sourceAddr[47:16]};
           2: data <= {sourceAddr[47:16],lengthType,messageType,ptpVersion};
           // 3: data <= {correctionField[15:0],flagField,8'b0,domainNumber,messageLength};
           3: data <= {messageLength,domainNumber,8'b0,flagField,correction[63:48]};
           4: data <= {correction[47:0],16'b0};
           5: // data <= {16'b0,sourcePortId[47:0]};
             data <= 64'haaaaaaaaaaaaaaaa;
           6: // data <= {sourcePortId[79:48],sequenceId,controlField,logMessageInterval};
             data <= 64'h5555555555555555;
           7: data <= {timestamp[79:16]};
           8: data <= {timestamp[15:0],48'b0};
           default : data <= 64'h00_00_00_00_00_00_00_00;
         endcase // case (count)
   end
   

endmodule // char10g1588_pkt_gen
