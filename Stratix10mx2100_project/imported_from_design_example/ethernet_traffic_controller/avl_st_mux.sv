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


module avl_st_mux #(	
	parameter 	MUX_INPUT = 2					//Can only set to 2 - 2 to 1 MUX Only
)(
	input 	wire 			avl_st_clk,
	input 	wire 			avl_st_reset_n,
	
	input	wire			mux_sel,
	
	//Avalon ST From Traffic Controller
	input	wire	[MUX_INPUT-1:0][63:0]	mux_in_avl_st_tx_data,
	input	wire	[MUX_INPUT-1:0][2:0]	mux_in_avl_st_tx_empty,
	input	wire	[MUX_INPUT-1:0]			mux_in_avl_st_tx_eop,
	input	wire	[MUX_INPUT-1:0]			mux_in_avl_st_tx_error,
	output	reg		[MUX_INPUT-1:0]			mux_in_avl_st_tx_ready,
	input	wire	[MUX_INPUT-1:0]			mux_in_avl_st_tx_sop,
	input	wire	[MUX_INPUT-1:0]			mux_in_avl_st_tx_val,
	
	output	reg		[MUX_INPUT-1:0][63:0]	demux_out_avl_st_rx_data,
	output	reg		[MUX_INPUT-1:0][2:0]	demux_out_avl_st_rx_empty,
	output	reg		[MUX_INPUT-1:0]			demux_out_avl_st_rx_eop,
	output	reg		[MUX_INPUT-1:0][5:0]	demux_out_avl_st_rx_error,
	input	wire	[MUX_INPUT-1:0]			demux_out_avl_st_rx_ready,
	output	reg		[MUX_INPUT-1:0]			demux_out_avl_st_rx_sop,
	output	reg		[MUX_INPUT-1:0]			demux_out_avl_st_rx_val,
	
	//Avalon ST To MAC
	output 	reg		[63:0] 	mux_out_avl_st_tx_data,
	output 	reg		[2:0]  	mux_out_avl_st_tx_empty,
	output 	reg		 		mux_out_avl_st_tx_eop,
	output 	reg		 		mux_out_avl_st_tx_error,
	input 	wire	 		mux_out_avl_st_tx_ready,
	output 	reg		 		mux_out_avl_st_tx_sop,
	output 	reg		 		mux_out_avl_st_tx_val,             
                	
	input 	wire	[63:0] 	demux_in_avl_st_rx_data,
	input 	wire	[2:0]  	demux_in_avl_st_rx_empty,
	input 	wire	 		demux_in_avl_st_rx_eop,
	input 	wire	[5:0]	demux_in_avl_st_rx_error,
	output 	reg		 		demux_in_avl_st_rx_ready,
	input 	wire	 		demux_in_avl_st_rx_sop,
	input 	wire	 		demux_in_avl_st_rx_val	
);

localparam	IN0 = 1'd0;
localparam	IN1 = 1'd1;

reg		mux_sel_sync;

altera_std_synchronizer #(2) sync_u0 (
	.clk		(avl_st_clk),
	.reset_n	(avl_st_reset_n),
	.din		(mux_sel),
	.dout		(mux_sel_sync)
);
   
//Avalon ST Mux
always @(*)
begin
	case (mux_sel_sync)
		IN0: begin
			mux_out_avl_st_tx_data		= mux_in_avl_st_tx_data[0];
			mux_out_avl_st_tx_empty		= mux_in_avl_st_tx_empty[0]; 
			mux_out_avl_st_tx_eop		= mux_in_avl_st_tx_eop[0];
			mux_out_avl_st_tx_error		= mux_in_avl_st_tx_error[0];
			mux_out_avl_st_tx_sop		= mux_in_avl_st_tx_sop[0];
			mux_out_avl_st_tx_val		= mux_in_avl_st_tx_val[0]; 		
		end
		
		IN1: begin
			mux_out_avl_st_tx_data		= mux_in_avl_st_tx_data[1];
			mux_out_avl_st_tx_empty		= mux_in_avl_st_tx_empty[1]; 
			mux_out_avl_st_tx_eop		= mux_in_avl_st_tx_eop[1];
			mux_out_avl_st_tx_error		= mux_in_avl_st_tx_error[1];
			mux_out_avl_st_tx_sop		= mux_in_avl_st_tx_sop[1];
			mux_out_avl_st_tx_val		= mux_in_avl_st_tx_val[1]; 		
		end
		
		default: begin
			mux_out_avl_st_tx_data		= 64'd0;
			mux_out_avl_st_tx_empty		= 3'd0; 
			mux_out_avl_st_tx_eop		= 1'd0;
			mux_out_avl_st_tx_error		= 1'd0;
			mux_out_avl_st_tx_sop		= 1'd0;
			mux_out_avl_st_tx_val		= 1'd0; 	
		end
	endcase
end

always @(*)
begin
	mux_in_avl_st_tx_ready[0]	= mux_out_avl_st_tx_ready;
	mux_in_avl_st_tx_ready[1]	= mux_out_avl_st_tx_ready;
	demux_in_avl_st_rx_ready		= mux_sel_sync? demux_out_avl_st_rx_ready[1] : demux_out_avl_st_rx_ready[0];  
end

always @(*)
begin
	case (mux_sel_sync)
		IN0: begin
			demux_out_avl_st_rx_data[0]		= demux_in_avl_st_rx_data;
			demux_out_avl_st_rx_empty[0]	= demux_in_avl_st_rx_empty; 
			demux_out_avl_st_rx_eop[0]		= demux_in_avl_st_rx_eop;
			demux_out_avl_st_rx_error[0]	= demux_in_avl_st_rx_error;
			demux_out_avl_st_rx_sop[0]		= demux_in_avl_st_rx_sop;
			demux_out_avl_st_rx_val[0]		= demux_in_avl_st_rx_val; 		
		end
		
		IN1: begin
			demux_out_avl_st_rx_data[0]		= 64'd0;
			demux_out_avl_st_rx_empty[0]	= 3'd0;  
			demux_out_avl_st_rx_eop[0]		= 1'd0; 
			demux_out_avl_st_rx_error[0]	= 6'd0; 
			demux_out_avl_st_rx_sop[0]		= 1'd0; 
			demux_out_avl_st_rx_val[0]		= 1'd0; 
		end
		
		default: begin
			demux_out_avl_st_rx_data[0]		= 64'd0;
			demux_out_avl_st_rx_empty[0]	= 3'd0; 
			demux_out_avl_st_rx_eop[0]		= 1'd0;
			demux_out_avl_st_rx_error[0]	= 6'd0;
			demux_out_avl_st_rx_sop[0]		= 1'd0;
			demux_out_avl_st_rx_val[0]		= 1'd0; 	
		end
	endcase
end

always @(*)
begin
	case (mux_sel_sync)
		IN0: begin
			demux_out_avl_st_rx_data[1]		= 64'd0;
			demux_out_avl_st_rx_empty[1]	= 3'd0; 
			demux_out_avl_st_rx_eop[1]		= 1'd0; 
			demux_out_avl_st_rx_error[1]	= 6'd0; 
			demux_out_avl_st_rx_sop[1]		= 1'd0; 
			demux_out_avl_st_rx_val[1]		= 1'd0; 	
		end
		
		IN1: begin
			demux_out_avl_st_rx_data[1]		= demux_in_avl_st_rx_data;  
			demux_out_avl_st_rx_empty[1]	= demux_in_avl_st_rx_empty; 
			demux_out_avl_st_rx_eop[1]		= demux_in_avl_st_rx_eop;   
			demux_out_avl_st_rx_error[1]	= demux_in_avl_st_rx_error; 
			demux_out_avl_st_rx_sop[1]		= demux_in_avl_st_rx_sop;   
			demux_out_avl_st_rx_val[1]		= demux_in_avl_st_rx_val; 	 
		end
		
		default: begin
			demux_out_avl_st_rx_data[1]		= 64'd0;
			demux_out_avl_st_rx_empty[1]	= 3'd0; 
			demux_out_avl_st_rx_eop[1]		= 1'd0;
			demux_out_avl_st_rx_error[1]	= 6'd0;
			demux_out_avl_st_rx_sop[1]		= 1'd0;
			demux_out_avl_st_rx_val[1]		= 1'd0; 	
		end
	endcase
end

endmodule