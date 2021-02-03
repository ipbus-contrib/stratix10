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


module avl_st_sel_csr (
	input 	wire 			avl_mm_clk,
	input 	wire 			avl_mm_reset_n,
	
	//Avalon MM
	input 	wire			avl_mm_read,
	input 	wire			avl_mm_write,
	output 	wire			avl_mm_waitrequest,
	input 	wire	[0:0]	avl_mm_baddress,
	output 	reg		[31:0]	avl_mm_readdata,
	input 	wire	[31:0]	avl_mm_writedata,

	output	reg		[0:0]	eth_traffic_ctrl_sel
);

// ___________________________________________________________
//	    address parameters
// ___________________________________________________________
parameter ADDR_TAFFIC_CONTROLLER_SEL 		= 1'b0;

// ____________________________________________________________________________
// Ethernet Traffic Controller Selector register
//	0 - IEEE1588 Traffic Controller
//	1 - Standard Ethhernet Traffic Controller
// ____________________________________________________________________________
always @ (negedge avl_mm_reset_n or posedge avl_mm_clk)
   begin
      if (!avl_mm_reset_n) 
      	eth_traffic_ctrl_sel <= 1'd1;
      else if (avl_mm_write && (avl_mm_baddress == ADDR_TAFFIC_CONTROLLER_SEL)) 
      	eth_traffic_ctrl_sel <= avl_mm_writedata[0];
   end

always @ (negedge avl_mm_reset_n or posedge avl_mm_clk)
   begin
      if (!avl_mm_reset_n)
      		avl_mm_readdata <=32'h0;		
      else if (avl_mm_read) begin
         case (avl_mm_baddress)
            ADDR_TAFFIC_CONTROLLER_SEL: avl_mm_readdata <= {31'd0, eth_traffic_ctrl_sel[0]};
            default: avl_mm_readdata <=32'h0;
         endcase
      end
   end   
   
reg rddly, wrdly;

always@(posedge avl_mm_clk or negedge avl_mm_reset_n)
begin
   if(!avl_mm_reset_n) 
	 begin 
	      wrdly <= 1'b0; 
	      rddly <= 1'b0; 
	 end 
   else 
	 begin 
	      wrdly <= avl_mm_write; 
	      rddly <= avl_mm_read; 
	 end 
end

wire wredge = avl_mm_write& ~wrdly;
wire rdedge = avl_mm_read & ~rddly;

assign avl_mm_waitrequest = (wredge|rdedge); // your design is done with transaction when this goes down
   	
endmodule